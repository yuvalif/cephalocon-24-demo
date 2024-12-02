
# Slow Ops Demo

* install prometheus in the cluster:

```bash
kubectl create -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/refs/heads/main/bundle.yaml
```

* setup promeheus to monitor Ceph:

```bash
kubectl create -f https://raw.githubusercontent.com/coreos/prometheus-operator/v0.71.1/bundle.yaml
kubectl create -f https://raw.githubusercontent.com/rook/rook/refs/heads/master/deploy/examples/monitoring/service-monitor.yaml
kubectl create -f https://raw.githubusercontent.com/rook/rook/refs/heads/master/deploy/examples/monitoring/prometheus.yaml
kubectl create -f https://raw.githubusercontent.com/rook/rook/refs/heads/master/deploy/examples/monitoring/prometheus-service.yaml
```

* Setup prometheus alerts with slow-ops alert in prometheus

from rook repo, edit `deploy/examples/monitoring/localrules.yaml` to lower
`CephSlowOps` to 3s

```bash
kubectl create -f deploy/examples/monitoring/rbac.yaml
kubectl create -f https://raw.githubusercontent.com/rook/rook/refs/heads/master/deploy/examples/monitoring/prometheus-service.yaml
kubectl create -f https://raw.githubusercontent.com/yuvalif/cephalocon-24-demo/refs/heads/main/localrules.yaml
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
kubectl rook-ceph ceph config set mgr mgr/prometheus/scrape_interval 3
```

* add the [lua-requests](https://github.com/JakobGreen/lua-requests) luarocks
  package to the allowlist and reload:

```bash
TOOLBOX_POD=$(kubectl -n rook-ceph get pods -l=app=rook-ceph-tools -o jsonpath='{.items[0].metadata.name}')
kubectl rook-ceph ceph config set client.rgw rgw_lua_max_memory_per_state 512K
kubectl rook-ceph radosgw-admin script-package add --package=lua-cjson --allow-compilation
kubectl rook-ceph radosgw-admin script-package add --package=luasocket --allow-compilation
kubectl rook-ceph radosgw-admin script-package list
kubectl rollout restart deployment rook-ceph-rgw-my-store-a -n rook-ceph
```

* add the background lua script to poll the slow-ops alert, and the prerequest
  lua script to set tracing if slow-ops alert is triggered:

```bash
TOOLBOX_POD=$(kubectl -n rook-ceph get pods -l=app=rook-ceph-tools -o jsonpath='{.items[0].metadata.name}')
kubectl -n rook-ceph cp slow-ops-poll.lua $TOOLBOX_POD:/tmp/slow-ops-poll.lua
kubectl -n rook-ceph cp slow-ops-trace.lua $TOOLBOX_POD:/tmp/slow-ops-trace.lua
kubectl rook-ceph radosgw-admin script put --context=background --infile /tmp/slow-ops-poll.lua
kubectl rook-ceph radosgw-admin script put --context=prerequest --infile /tmp/slow-ops-trace.lua
```

* Generate worlkload:
run rados bench or any other heavy workload

```bash
 kubectl rook-ceph ceph osd pool create test 32 
 kubectl rook-ceph rados bench -p test 1 write -t 4
 or run
 hsbench -u http://127.0.0.1:32741 -z 4K -d 1 -a BSGUB92SRUAR9NIW5PQH -s CzWBqC0jrBYhvsqUJlCMMdbb9x0fXhHmjxsG9Nsb
```

* verify that no traces are being generated:

```bash
curl "$JAEGER_URL/api/traces?service=rgw&limit=20&lookback=1h" | jq
```

* change the environment to cause slow-ops:

1. set the paramater to reproduce slow Ops

```bash
 kubectl rook-ceph ceph config set osd osd_op_complaint_time 0.001
```

* run rados bench or any other heavy workload again for longer duration

```bash
  kubectl rook-ceph rados bench -p test 50 write -t 4 
  or run
  hsbench -u http://127.0.0.1:32741 -z 4K -d 50 \
  -t 10 -a BSGUB92SRUAR9NIW5PQH -s CzWBqC0jrBYhvsqUJlCMMdbb9x0fXhHmjxsG9Nsb
```

* verify that traces are being generated:

```bash
curl "$JAEGER_URL/api/traces?service=rgw&limit=20&lookback=1h" | jq
```

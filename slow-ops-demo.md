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
  
from rook repo, edit `deploy/examples/monitoring/localrules.yaml` to lower `CephSlowOps` to 3s

```bash
kubectl create -f deploy/examples/monitoring/rbac.yaml
kubectl create -f deploy/examples/monitoring/localrules.yaml
```

* add the [lua-requests](https://github.com/JakobGreen/lua-requests) luarocks package to the allowlist and reload:
```bash
TOOLBOX_POD=$(kubectl -n rook-ceph get pods -l=app=rook-ceph-tools -o jsonpath='{.items[0].metadata.name}')
kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- bash -c "radosgw-admin script-package add --package=dkjson --allow-compilation"
kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- bash -c "radosgw-admin script-package add --package=socket.http --allow-compilation"
kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- bash -c "radosgw-admin script-package list"
```

* add the background lua script to poll the slow-ops alert, and the prerequest lua script to set tracing if slow-ops alert is triggered:
```bash
TOOLBOX_POD=$(kubectl -n rook-ceph get pods -l=app=rook-ceph-tools -o jsonpath='{.items[0].metadata.name}')
kubectl -n rook-ceph cp slow-ops-poll.lua $TOOLBOX_POD:/tmp/slow-ops-poll.lua
kubectl -n rook-ceph cp slow-ops-trace.lua $TOOLBOX_POD:/tmp/slow-ops-trace.lua
kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- bash -c "radosgw-admin script put --context=background --infile /tmp/slow-ops-poll.lua"
kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- bash -c "radosgw-admin script put --context=prerequest --infile /tmp/slow-ops-trace.lua"
```

* Generate worlkload:
run rados bench or any other heavy workload
```
 kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- ceph osd pool create testbench 32 
 kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- rados bench -p testbench 1 write -t 4
```

* verify that no traces are being generated:
```bash
curl "$JAEGER_URL/api/traces?service=rgw&limit=20&lookback=1h" | jq
```

* change the environment to cause slow-ops:

1. set the paramater to reproduce slow Ops

```
ceph config set osd osd_op_complaint_time 0.01
```
* run rados bench or any other heavy workload again for longer duration

```
 rados bench -p testbench 200 write -t 4
```

* verify that traces are being generated:
```bash
curl "$JAEGER_URL/api/traces?service=rgw&limit=20&lookback=1h" | jq
```

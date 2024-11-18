* install prometheus in the cluster:
```bash
kubectl create -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/refs/heads/main/bundle.yaml
```

* setup promeheus to monitor Ceph:
```bash
kubectl create -f https://raw.githubusercontent.com/rook/rook/refs/heads/master/deploy/examples/monitoring/service-monitor.yaml
kubectl create -f https://raw.githubusercontent.com/rook/rook/refs/heads/master/deploy/examples/monitoring/prometheus.yaml
kubectl create -f https://raw.githubusercontent.com/rook/rook/refs/heads/master/deploy/examples/monitoring/prometheus-service.yaml
```

* setup slow-ops alert in prometheus:
```bash
TODO
```

* add the [lua-requests](https://github.com/JakobGreen/lua-requests) luarocks package to the allowlist and reload:
```bash
TOOLBOX_POD=$(kubectl -n rook-ceph get pods -l=app=rook-ceph-tools -o jsonpath='{.items[0].metadata.name}')
kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- bash -c "radosgw-admin script-package add --package=lua-requests --allow-compilation"
kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- bash -c "radosgw-admin script-package reload"
```

* add the background lua script to poll the slow-ops alert, and the prerequest lua script to set tracing if slow-ops alert is triggered:
```bash
TOOLBOX_POD=$(kubectl -n rook-ceph get pods -l=app=rook-ceph-tools -o jsonpath='{.items[0].metadata.name}')
kubectl -n rook-ceph cp slow-ops-poll.lua $TOOLBOX_POD:/tmp/slow-ops-poll.lua
kubectl -n rook-ceph cp slow-ops-trace.lua $TOOLBOX_POD:/tmp/slow-ops-trace.lua
kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- bash -c "radosgw-admin script put --context=background --infile /tmp/slow-ops-poll.lua"
kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- bash -c "radosgw-admin script put --context=prerequest --infile /tmp/slow-ops-trace.lua"
```

* verify that no traces are being generated:
```bash
TODO
```

* change the environment to cause slow-ops:
```bash
TODO
```

* verify that traces are being generated:
```bash
TODO
```

## Demo Slow Ops Tracing

Deploy prometheus and with it prometheus alerts would also be shipped.

1. set the paramater to reproduce slow Ops

```
ceph config set osd osd_op_complaint_time 0.01
```

2. apply the custom alert for slow Ops

```
ceph config-key set mgr/cephadm/services/prometheus/alerting/custom_alerts.yml  -i $PWD/custom_alerts.yml
```

3. run rados bench or any other heavy workload

```
 rados bench -p testbench 105 write -t 4

```

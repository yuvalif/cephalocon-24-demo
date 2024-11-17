* install the toolbox pod (currently lua script can only be loaded by an admin command):
```bash
kubectl create -f https://raw.githubusercontent.com/rook/rook/refs/heads/master/deploy/examples/toolbox.yaml
```
* upload a lua script to trace only multipart upload requests:
```bash
TOOLBOX_POD=$(kubectl -n rook-ceph get pods -l=app=rook-ceph-tools -o jsonpath='{.items[0].metadata.name}')
kubectl -n rook-ceph cp multipart-trace.lua $TOOLBOX_POD:/tmp/multipart-trace.lua
kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- bash -c "radosgw-admin script put --context=prerequest --infile /tmp/multipart-trace.lua"
```
* perform multipart upload "manually" using the s3api, by calling: `create-multipart-upload`, `upload-part`, `complete-multipart-upload`:
```bash
TODO
```
* fetch the traces:
```bash
TODO
```
* perform multipart upload "manually" using the s3api, without calling `complete-multipart-upload` to simulate a failed upload:
```bash
TODO
```
* fetch the traces:
```bash
TODO
```
## Setup
* start k8s with kinikube:
```bash
minikube start --extra-disks=1
```
* install rook:
```bash
kubectl apply -f https://raw.githubusercontent.com/rook/rook/refs/heads/master/deploy/examples/crds.yaml
kubectl apply -f https://raw.githubusercontent.com/rook/rook/refs/heads/master/deploy/examples/common.yaml
kubectl apply -f https://raw.githubusercontent.com/rook/rook/refs/heads/master/deploy/examples/operator.yaml
```
* start a ceph cluster with jaeger tracing enabled:
```bash
kubectl apply -f cluster-test.yaml
```
* start object store with jaeger tracing enabled:
```bash
kubectl apply -f object-test.yaml
```
* install cert manager via helm:
```bash
helm repo add jetstack https://charts.jetstack.io --force-update
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.16.1 \
  --set crds.enabled=true
```
* install jaeger operator:
```bash
kubectl create namespace observability
kubectl create -f https://github.com/jaegertracing/jaeger-operator/releases/download/v1.62.0/jaeger-operator.yaml -n observability
```
* start jaeger and expose it:
```bash
kubectl apply -f jaeger-test.yaml
```
## Test
* create a storage class and object bucket claim:
```bash
kubectl apply -f https://raw.githubusercontent.com/rook/rook/refs/heads/master/deploy/examples/storageclass-bucket-delete.yaml
kubectl apply -f https://raw.githubusercontent.com/rook/rook/refs/heads/master/deploy/examples/object-bucket-claim-delete.yaml
```
* upload an object to the bucket:
```bash
export AWS_URL=$(minikube service --url rook-ceph-rgw-my-store-external -n rook-ceph)
export AWS_ACCESS_KEY_ID=$(kubectl -n default get secret ceph-delete-bucket -o jsonpath='{.data.AWS_ACCESS_KEY_ID}' | base64 --decode)
export AWS_SECRET_ACCESS_KEY=$(kubectl -n default get secret ceph-delete-bucket -o jsonpath='{.data.AWS_SECRET_ACCESS_KEY}' | base64 --decode)
export BUCKET_NAME=$(kubectl get objectbucketclaim ceph-delete-bucket -o jsonpath='{.spec.bucketName}')
echo "hello world" > hello.txt
aws --endpoint-url $AWS_URL s3 cp hello.txt s3://$BUCKET_NAME
```
* get the traces associated with this upload:
```bash
export JAEGER_URL=$(minikube service --url simplest-query-external -n observability)
curl "$JAEGER_URL/api/traces?service=rgw&limit=20&lookback=1h" | jq
```




#!/bin/bash


AWS_PORT="$(k describe svc rook-ceph-rgw-my-store-external -nrook-ceph | grep NodePort | awk '{print $3}' |  cut -d'/' -f1 | tr -d '[:space:]')"
export AWS_URL=http://127.0.0.1:$AWS_PORT

#export AWS_ACCESS_KEY_ID=$(kubectl -n default get secret ceph-delete-bucket -o jsonpath='{.data.AWS_ACCESS_KEY_ID}' | base64 --decode)
#export AWS_ACCESS_KEY_ID=cfe02a89d2154b0b8332efb16a7b1d5a
#export AWS_SECRET_ACCESS_KEY=ee6634b46e8b45dda3384ebc16c5b4fa
export BUCKET_NAME=$(kubectl get objectbucketclaim ceph-delete-bucket -o jsonpath='{.spec.bucketName}')

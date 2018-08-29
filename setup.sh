#!/bin/bash
set -m

wait_for_start() {
    "$@"
    while [ $? -ne 0 ]
    do
        echo 'waiting for couchbase to start'
        sleep 1
        "$@"
    done
}

echo 'start couchbase...'
/entrypoint.sh couchbase-server & 

#sleep 10
wait_for_start curl 127.0.0.1:8091 -f

export IP=`hostname -I|tr -d ' '`

echo 'node init'
couchbase-cli node-init -c ${IP}:8091 \
  -u "$CB_ADMIN_USER" \
  -p "$CB_ADMIN_PASSWORD" \
  --node-init-hostname=$IP

echo 'cluster init'
couchbase-cli cluster-init -c '127.0.0.1:8091' --cluster-username="$CB_ADMIN_USER" --cluster-password="$CB_ADMIN_PASSWORD" --cluster-ramsize="$CB_RAM_QUOTA" --cluster-index-ramsize="$CB_RAM_QUOTA" --services='data'

echo 'bucket init'
couchbase-cli bucket-create -c '127.0.0.1:8091' -u "$CB_ADMIN_USER" -p "$CB_ADMIN_PASSWORD" --bucket="$CB_BUCKET" --bucket-type=couchbase --bucket-ramsize="$CB_BUCKET_RAM" --enable-flush=1 --wait

echo "creating user: '$CB_BUCKET'"
couchbase-cli user-manage -c '127.0.0.1:8091' -u "$CB_ADMIN_USER" \
 -p "$CB_ADMIN_PASSWORD" --set --rbac-username "$CB_BUCKET" --rbac-password "$CB_BUCKET_PASSWORD" \
 --rbac-name "$CB_BUCKET" --roles 'bucket_full_access[*]' \
 --auth-domain local

echo 'couchbase setup done'
fg 1

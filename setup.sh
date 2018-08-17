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

echo 'node init'
couchbase-cli node-init -u "$CB_ADMIN_USER" -p "$CB_ADMIN_PASSWORD" -c '127.0.0.1:8091'

echo 'cluster init'
couchbase-cli cluster-init -u "$CB_ADMIN_USER" -p "$CB_ADMIN_PASSWORD" -c '127.0.0.1:8091' --cluster-username="$CB_ADMIN_USER" --cluster-password="$CB_ADMIN_PASSWORD" --cluster-ramsize="$CB_RAM_QUOTA" --cluster-index-ramsize="$CB_RAM_QUOTA" --services='data,index,query'

echo 'bucket init'
couchbase-cli bucket-create -u "$CB_ADMIN_USER" -p "$CB_ADMIN_PASSWORD" -c '127.0.0.1:8091' --bucket="$CB_BUCKET" --bucket-port=11211 --bucket-password="$CB_BUCKET_PASSWORD" --bucket-type=couchbase --bucket-ramsize="$CB_BUCKET_RAM" --enable-flush=1 --wait

echo 'couchbase setup done'
fg 1

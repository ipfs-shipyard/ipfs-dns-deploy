#!/usr/bin/env bash

# TODO: check env exists

CLUSTER_HOST="/dnsaddr/cluster.ipfs.io"
DOMAIN="example.org"
INPUT_DIR=/tmp/workspace/$BUILD_DIR

./updste-github-status.sh "pending" "Pinnning to IPFS cluster"

# pin to cluster
root_cid=$(ipfs-cluster-ctl \
    --host $CLUSTER_HOST \
    --basic-auth $CLUSTER_USER:$CLUSTER_PASSWORD \
    add --rmin 3 --rmax 3 --name $DOMAIN \
    --recursive $INPUT_DIR | tail -n1 | cut -d " " -f 2 )

preview_url=https://ipfs.io/ipfs/$root_cid

# Preload ipfs hash on the gateway
curl --silent --output /dev/null --show-error $preview_url

./updste-github-status.sh "success" "Website added to IPFS" "$preview_url"

echo "$root_cid"

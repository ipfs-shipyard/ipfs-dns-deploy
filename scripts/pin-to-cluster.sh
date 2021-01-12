#!/usr/bin/env bash

# This script is used as part of CI workflows.
# It must echo only the new root CID value, or exit with a messge and error status.
# The root CID can be used to update a DNSLink to publish a site.
# See: https://github.com/ipfs/blog/blob/36ddd981492790c9e36ab23619c00d5f85776c10/.circleci/config.yml#L26-L36

set -e

if [[ $# -eq 0 ]] ; then
  echo 'Usage:'
  echo 'CLUSTER_USER="who" \'
  echo 'CLUSTER_PASSWORD="_secret_" \'
  echo 'GITHUB_TOKEN="_secret" \'
  echo 'CIRCLE_SHA1="bf3aae3bc98666fbf459b03ab2d87a97505bfab0" \'
  echo 'CIRCLE_PROJECT_USERNAME="ipfs-shipyard" \'
  echo 'CIRCLE_PROJECT_REPONAME="ipld-explorer" \'
  echo './pin-to-cluster.sh <pin name> <input root dir to pin recursivly>'
  exit 1
fi

HOST=${CLUSTER_HOST:-"/dnsaddr/cluster.ipfs.io"}
PIN_NAME=$1
INPUT_DIR=$2
STATUS_API_URL="https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/statuses/$CIRCLE_SHA1"

update_github_status () {
  local params
  params=$(jq --monochrome-output --null-input --compact-output \
    --arg state "$1" \
    --arg description "$2" \
    --arg target_url "$3" \
    --arg context "IPFS" \
    '{ state: $state, target_url: $target_url, description: $description, context: $context }' )

  # The --fail flag means curl will set a failure exit code for us for non-success http error codes
  # and it will print a useful error message with the status code. Combined with set -x this means
  # we stop the script and log an error.
  # We capture the output in $result here so that in the happy path it will not print anything; thhe only
  # output we want on success is the CID from ipfs-cluster-ctl
  result=$(curl --fail --silent --show-error -X POST -H "Authorization: token $GITHUB_TOKEN" -H 'Content-Type: application/json' --data "$params" "$STATUS_API_URL") || {
    # If it fails show the url and params
    echo "$STATUS_API_URL $params" 1>&2
    echo "Failed to update github status" 1>&2
    false
  }
}

update_github_status "pending" "Pinnning to IPFS cluster" "https://ipfs.io/"

# pin to cluster
root_cid=$(ipfs-cluster-ctl \
    --host "$HOST" \
    --basic-auth "$CLUSTER_USER:$CLUSTER_PASSWORD" \
    add --quieter \
    --cid-version 1 \
    --name "$PIN_NAME" \
    --recursive "$INPUT_DIR" ) || {
  # If it fails, show the ipfs-cluster-ctl command and the error message
  echo "ipfs-cluster-ctl --host $HOST --basic-auth *** add --quieter --local --cid-version 1 --name '$PIN_NAME' --recursive $INPUT_DIR" 1>&2
  echo "$root_cid" 1>&2
  echo "Failed to pin to cluster" 1>&2
  false
}

preview_url="https://$root_cid.ipfs.dweb.link"

update_github_status "success" "Website added to IPFS" "$preview_url"

echo "$root_cid"

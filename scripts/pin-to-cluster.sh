#!/usr/bin/env bash
set -e
set -x

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

update_github_status () {
  local STATE=$1
  local DESCRIPTION=$2
  local TARGET_URL=$3
  local CONTEXT='IPFS'
  local STATUS_API_URL="https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/statuses/$CIRCLE_SHA1"
  local params
  params=$(jq --monochrome-output --null-input \
    --arg state "$STATE" \
    --arg target_url "$TARGET_URL" \
    --arg description "$DESCRIPTION" \
    --arg context "$CONTEXT" \
    '{ state: $state, target_url: $target_url, description: $description, context: $context }' )

  curl --silent --output /dev/null -X POST -H "Authorization: token $GITHUB_TOKEN" -H 'Content-Type: application/json' --data "$params" $STATUS_API_URL
}

update_github_status "pending" "Pinnning to IPFS cluster" "https://ipfs.io/"

# pin to cluster
root_cid=$(ipfs-cluster-ctl \
    --host $HOST \
    --basic-auth $CLUSTER_USER:$CLUSTER_PASSWORD \
    add --quieter \
    --local \
    --cid-version 1 \
    --name "$PIN_NAME" \
    --recursive $INPUT_DIR )

preview_url="https://$root_cid.ipfs.dweb.link"

update_github_status "success" "Website added to IPFS" "$preview_url"

echo "$root_cid"

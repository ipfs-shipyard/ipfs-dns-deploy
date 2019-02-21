#!/usr/bin/env bash
set -e

# Add website preview as PR Status
#
# see: https://developer.github.com/v3/repos/statuses/#create-a-status
#
# Example payload
#
# ```json
# {
#   "state": "success",
#   "target_url": "https://example.com/build/status",
#   "description": "The build succeeded!",
#   "context": "continuous-integration/jenkins"
# }
# ```

# state can be one of error, failure, pending, or success.
# STATE="success"
# TARGET_URL="https://ipfs.io/ipfs/QmRobAq7DT6T8fQSi4aeQWbEYZc4kX4HjdvE7Lbyx9BeU8"
# DESCRIPTION="Website added to IPFS"
# CONTEXT="IPFS"
#
# GITHUB_TOKEN=""
# CIRCLE_PROJECT_USERNAME=""
# CIRCLE_PROJECT_REPONAME=""
# CIRCLE_SHA1=""
STATUS_API_URL="https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/statuses/$CIRCLE_SHA1"

params=$(jq --monochrome-output --null-input \
  --arg state "$STATE" \
  --arg target_url "$TARGET_URL" \
  --arg description "$DESCRIPTION" \
  --arg context "$CONTEXT" \
  '{ state: $state, target_url: $target_url, description: $description, context: $context }' )

echo "Github status update: $params"

curl -X POST -H "Authorization: token $GITHUB_TOKEN" -H 'Content-Type: application/json' --data "$params" $STATUS_API_URL

#!/usr/bin/env bash

set -euo pipefail

trap cleanup EXIT

cleanup() {
    curl -X DELETE \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: token $GITHUB_TOKEN" \
        "$DELETE_URL"

    echo "[INFO] Deleted webhook $DELETE_URL"
}

# I believe the left side of the pipe returns exit code 141 because
# it's continuously reading from `/dev/urandom`, but I really don't
# have a good explanation, I'm afraid.
set +o pipefail
SECRET=$(< /dev/urandom tr -cd "[:alnum:]" | head -c 64)
set -o pipefail

echo "[INFO] Creating webhook..."

DELETE_URL=$(
    curl -X POST \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/orgs/$GITHUB_ORG/hooks" \
        -d '{ "name": "web", "events": [ "issue_comment", "push", "pull_request", "pull_request_review" ], "config": { "url": "'"$URL"/events'", "content_type": "json", "secret": "'"$SECRET"'" } }' \
	2> /dev/null \
	| jq --raw-output .url
)


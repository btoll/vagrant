#!/usr/bin/env bash

set -euo pipefail

trap cleanup EXIT

cleanup() {
    echo "[INFO] Deleting webhook $DELETE_URL..."

    curl -X DELETE \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/repos/btoll/vagrantfiles/hooks/$DELETE_URL"
}

echo "[INFO] Create webhook..."

DELETE_URL=$(
    curl -X POST \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: token $GITHUB_TOKEN" \
        https://api.github.com/repos/btoll/vagrantfiles/hooks \
        -d '{ "name": "web", "events": [ "issue_comment", "push", "pull_request", "pull_request_review" ], "config": { "url": "'"$URL"/events'", "content_type": "json", "secret": "'"$SECRET"'", "token": "'"$GITHUB_TOKEN"'" } }'
)

echo "[INFO] Starting atlantis server..."

atlantis server \
    --atlantis-url="$URL" \
    --gh-user="$GITHUB_USERNAME" \
    --gh-token="$GITHUB_TOKEN" \
    --gh-webhook-secret="$SECRET" \
    --repo-allowlist="$REPO_ALLOWLIST"


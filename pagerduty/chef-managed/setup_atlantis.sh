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
# Either way, briefly turn off pipefail because we don't want to exit
# if it's a cryptic, non-essential error.
set +o pipefail
SECRET=$(< /dev/urandom tr -cd "[:alnum:]" | head -c 64)
set -o pipefail

echo "[INFO] Creating webhook..."

DELETE_URL=$(
    curl -X POST \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/repos/$TARGET_USER/$TARGET_REPO/hooks" \
        -d '{ "name": "web", "events": [ "issue_comment", "push", "pull_request", "pull_request_review" ], "config": { "url": "'"$URL"/events'", "content_type": "json", "secret": "'"$SECRET"'", "token": "'"$GITHUB_TOKEN"'" } }' \
	2> /dev/null \
	| jq --raw-output .url
)

#echo "[INFO] Starting Python simple server (in background)..."
#python3 -m http.server 80 &

echo "[INFO] Starting atlantis server..."

atlantis server \
    --atlantis-url="$URL" \
    --gh-user="$TARGET_USER" \
    --gh-token="$GITHUB_TOKEN" \
    --gh-webhook-secret="$SECRET" \
    --repo-allowlist="$REPO_ALLOWLIST"


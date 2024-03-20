#!/bin/bash

set -eo pipefail

LANG=C
umask 0022

if [ -z "$1" ]
then
    echo "[ERROR] You must provide an organization name."
    exit 1
fi

ORG_NAME="$1"

# https://docs.github.com/en/rest/authentication/authenticating-to-the-rest-api?apiVersion=2022-11-28
if [[ $(curl -s --request GET \
    --url "https://api.github.com/octocat" \
    --header "Authorization: Bearer $GITHUB_TOKEN" \
    --header "X-GitHub-Api-Version: 2022-11-28" \
    | jq -r ".message" 2> /dev/null) == "Bad credentials" ]]
then
    echo "[ERROR] Bad credentials."
    exit 1
fi

# https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28#list-organization-repositories
if ! curl -sL \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/orgs/$ORG_NAME/repos" \
    | jq -r ".[].name" 2> /dev/null
then
    echo "[ERROR] Bad organization name."
    exit 1
fi


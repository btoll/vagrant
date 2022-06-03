#!/bin/bash

set -eo pipefail


info() {
    echo "--------------------"
    echo "[$0] [INFO] Using Chef repository: $CHEF_REPO"
    echo "[$0] [INFO]     Using Chef branch: $CHEF_BRANCH"
    echo "--------------------"
}

while getopts "c:i:hv" opt
do
    case "$opt" in
        h)
            usage 0
            ;;
        i)
            IDENTITY="$OPTARG"
            ;;
        v)
            info
            exit 0
            ;;
        ?)
            echo "Invalid option: -$OPTARG."
            exit 2
            ;;
        *)
            echo "Invalid flag: -$OPTARG."
            exit 2
            ;;
    esac
done

if [ -z "$IDENTITY" ]
then
    echo "[$0][ERROR] No identity was given.  Exiting..."
    exit 1
fi

info

mkdir .chef
# The `--recursive` flag will grab the entire contents of the "directory".
aws s3 cp "s3://pd-chef/identity/$IDENTITY" .chef --recursive --exclude "*" --include "${IDENTITY}.pem" --include config.rb

berks upload
knife cookbook upload --all -o internal-cookbooks:cookbooks:site-cookbooks
#knife upload environments
knife upload roles
knife upload data_bags


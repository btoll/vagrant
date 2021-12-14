#!/bin/bash

set -eo pipefail

while getopts "c:i:h" opt
do
    case "$opt" in
        h)
            usage 0
            ;;
        i)
            IDENTITY="$OPTARG"
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

mkdir /root/.chef
# The `--recursive` flag will grab the entire contents of the "directory".
aws s3 cp "s3://pd-chef/identity/$IDENTITY" /root/.chef --recursive --exclude "*" --include "${IDENTITY}.pem" --include config.rb

knife cookbook bulk delete "^.*$" --purge --yes


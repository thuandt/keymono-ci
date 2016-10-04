#!/bin/bash
# Description: Install protoc latest version from Github

PROJECT="google/protobuf"

LATEST_RELEASE_URL="https://api.github.com/repos/$PROJECT/releases/latest"
LATEST_PREBUILT="$(curl -sSL $LATEST_RELEASE_URL | jq -r '.assets[] | select(.name | endswith("linux-x86_64.zip")) | .browser_download_url')"

curl -sSL "$LATEST_PREBUILT" -o /tmp/protoc.zip

unzip -j "/tmp/protoc.zip" "bin/protoc" -d /usr/bin

# Ensure protoc has execute permission
chmod +x /usr/bin/protoc

# cleanup
rm /tmp/protoc.zip

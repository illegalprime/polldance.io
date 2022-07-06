#!/usr/bin/env bash
set -euo pipefail

CODE=$(curl -s -o /dev/null -w "%{http_code}" https://pollparty.io)

echo "$CODE"

test "$CODE" -eq 200

KEY=$(< "$HEALTHCHECKS_KEY")

curl -s https://hc-ping.com/"$KEY"

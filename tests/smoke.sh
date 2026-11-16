#!/usr/bin/env bash
set -euo pipefail

image=${1:?usage: smoke.sh <image>}

test "$(docker run --rm --entrypoint id "$image" -u)" != "0"
docker run --rm "$image" -h
docker run --rm "$image" list -B -a

# Scan a local HTTP server: it sends Server and lacks Strict-Transport-Security.
result=$(docker run --rm --entrypoint sh "$image" -c '
  python -m http.server 8080 --bind 127.0.0.1 > /dev/null 2>&1 &
  sleep 2
  python h2t.py scan -B -E -o csv http://127.0.0.1:8080
')
echo "$result"
grep -q ';recommended to remove;Server$' <<< "$result"
grep -q ';recommended to use;HTTP Strict Transport Security \[HSTS\]$' <<< "$result"

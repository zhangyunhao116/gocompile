#!/usr/bin/env bash
set -e

SCOPE=$1

rm -rf go
if [ "$SCOPE"x = "all"x ]; then
  rm -rf golang-go
  rm -rf *.tar.gz
fi

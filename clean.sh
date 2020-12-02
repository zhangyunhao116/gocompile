#!/usr/bin/env bash
set -e

rm -rf go
if [ "$1"x = "all"x ]; then
  rm -rf golang-go
  rm -rf *.tar.gz
fi

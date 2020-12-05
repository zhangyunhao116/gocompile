#!/usr/bin/env bash
set -e

rm -rf workspace
if [ "$1"x = "all"x ]; then
  rm -rf go
  rm -rf golang-go
  rm -rf workspace
  rm -rf results
fi

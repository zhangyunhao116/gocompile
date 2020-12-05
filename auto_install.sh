#!/usr/bin/env bash
set -e

sh compile.sh
sh install.sh results/go.tar.gz

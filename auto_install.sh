#!/usr/bin/env bash
set -e

INSTALL_DIR=$1
if [ -z "${INSTALL_DIR}" ]; then INSTALL_DIR=golang-go; fi
sh compile.sh "${INSTALL_DIR}"
sh install.sh results/go.tar.gz

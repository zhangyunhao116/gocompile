#!/usr/bin/env bash
set -e

INSTALL_PACKAGE=$1
if [ -z "${INSTALL_PACKAGE}" ]; then INSTALL_PACKAGE=results/go.tar.gz; fi
tar -C /usr/local -xzf "${INSTALL_PACKAGE}"
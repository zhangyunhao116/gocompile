#!/usr/bin/env bash
set -e

INSTALL_PACKAGE=$1
if [ -z "${INSTALL_PACKAGE}" ]; then INSTALL_PACKAGE=results/go.tar.gz; fi
DIR_NAME=`tar -tzf "${INSTALL_PACKAGE}" | head -1 | cut -f1 -d"/"`
sudo rm -rf /usr/local/"${DIR_NAME}"
sudo tar -C /usr/local -xzf "${INSTALL_PACKAGE}"

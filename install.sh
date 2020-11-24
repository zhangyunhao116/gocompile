#!/usr/bin/env bash
set -e

INSTALL_PACKAGE=$1

rm -rf go
tar -xzf "${INSTALL_PACKAGE}"
sudo rm -rf /usr/local/go
sudo mv go /usr/local/
rm -rf go

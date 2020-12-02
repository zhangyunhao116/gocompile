#!/usr/bin/env bash

if [ "$1"x = "local"x ]; then
    git clone http://192.168.3.30:3000/zhangyunhao/go.git
    mv go golang-go
    exit 0
fi


git clone https://github.com/golang/go.git
mv go golang-go

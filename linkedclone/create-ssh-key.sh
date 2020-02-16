#!/bin/bash
set -ex
curdir=${PWD##*/}
echo "curdir=$curdir"
ssh-keygen -t rsa -b 4096 -f id_rsa -C $curdir -N "" -q

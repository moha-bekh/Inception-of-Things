#!/bin/bash

set -e

HOME=/home/vagrant
CONFS=$HOME/confs

sudo mkdir -p $CONFS

while [ ! -f $CONFS/node-token ]; do
  sleep 5
done

K3S_URL="https://192.168.56.110:6443"
K3S_TOKEN=$(cat $CONFS/node-token)

curl -sfL https://get.k3s.io | K3S_URL=$K3S_URL K3S_TOKEN=$K3S_TOKEN sh -s - --node-ip 192.168.56.111

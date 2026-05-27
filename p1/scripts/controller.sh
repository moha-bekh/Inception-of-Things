#!/bin/bash

set -e

HOME=/home/vagrant
CONFS=$HOME/confs

sudo mkdir -p $CONFS
rm -rf $CONFS/node-token

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode=644" sh -s - --node-ip 192.168.56.110

sleep 10

sudo cp /var/lib/rancher/k3s/server/node-token $CONFS/node-token
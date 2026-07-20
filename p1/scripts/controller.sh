#!/bin/bash
# Configuration for the K3s Controller node

set -e

HOME=/home/vagrant
CONFS=$HOME/confs

sudo mkdir -p $CONFS
rm -rf $CONFS/node-token

# Force K3s to listen and advertise its API strictly through the host-only IP
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --node-ip=192.168.56.110 --bind-address=192.168.56.110 --advertise-address=192.168.56.110" sh -s -

sleep 10
sudo cp /var/lib/rancher/k3s/server/node-token $CONFS/node-token
sync
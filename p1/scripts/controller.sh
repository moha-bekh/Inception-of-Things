#!/bin/bash

set -e

sudo mkdir -p /vagrant/confs
rm -rf /vagrant/confs/node-token

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode=644" sh -s - --node-ip 192.168.56.10

sleep 10

sudo cp /var/lib/rancher/k3s/server/node-token /vagrant/confs/node-token
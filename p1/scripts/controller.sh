#!/bin/bash

set -e

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode=644" sh -

sleep 10
sudo cp /var/lib/rancher/k3s/server/node-token /vagrant/confs/node-token
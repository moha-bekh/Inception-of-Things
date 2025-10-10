#!/bin/bash

set -e

sudo mkdir -p /home/vagrant/confs
sudo mkdir -p /home/vagrant/.local/bin
sudo ln -sf /home/vagrant/confs/deploy.sh /home/vagrant/.local/bin/deploy

sudo apt install -y make

echo "export PATH=$PATH:/home/vagrant/.local/bin" >> /home/vagrant/.bashrc
source /home/vagrant/.bashrc

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode=644" sh -s - --node-ip 192.168.56.110
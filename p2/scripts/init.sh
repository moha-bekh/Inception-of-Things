#!/bin/bash

set -e

HOME=/home/vagrant
CONFS=$HOME/confs

sudo mkdir -p $CONFS
sudo mkdir -p $HOME/.local/bin
sudo ln -sf $CONFS/deploy.sh $HOME/.local/bin/deploy

echo "export PATH=$PATH:$HOME/.local/bin" >> $HOME/.bashrc
source $HOME/.bashrc

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode=644" sh -s - --node-ip 192.168.56.110
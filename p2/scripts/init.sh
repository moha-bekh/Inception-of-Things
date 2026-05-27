#!/bin/bash

set -e

USER_HOME=/home/vagrant
CONFS=$USER_HOME/confs

sudo mkdir -p $CONFS
sudo mkdir -p $USER_HOME/.local/bin
sudo ln -sf $CONFS/deploy.sh $USER_HOME/.local/bin/deploy
sudo chown -R vagrant:vagrant $USER_HOME/.local

grep -qxF 'export PATH=$PATH:$HOME/.local/bin' $USER_HOME/.bashrc || echo 'export PATH=$PATH:$HOME/.local/bin' >> $USER_HOME/.bashrc

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode=644" sh -s - --node-ip 192.168.56.110

until kubectl get nodes >/dev/null 2>&1; do
	sleep 2
done

kubectl wait --for=condition=Ready nodes --all --timeout=120s
bash "$CONFS/deploy.sh"

if [ -d "$USER_HOME/.kube" ]; then
	sudo chown -R vagrant:vagrant "$USER_HOME/.kube"
fi

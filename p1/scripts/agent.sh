#!/bin/bash

set -e

sudo mkdir -p /vagrant/confs

while [ ! -f /vagrant/confs/node-token ]; do
  sleep 5
done

K3S_TOKEN=$(cat /vagrant/confs/node-token)
K3S_URL="https://192.168.56.10:6443"

curl -sfL https://get.k3s.io | K3S_URL=$K3S_URL K3S_TOKEN=$K3S_TOKEN sh -s - --node-ip 192.168.56.11
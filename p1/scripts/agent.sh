#!/bin/bash
# Configuration for the K3s Agent node

set -e

HOME=/home/vagrant
CONFS=$HOME/confs

sudo mkdir -p $CONFS

while [ ! -s $CONFS/node-token ]; do
  sleep 5
done

K3S_URL="https://192.168.56.110:6443"
K3S_TOKEN=$(cat $CONFS/node-token)
export K3S_NODE_NAME="mbekheirSW"

# --flannel-iface=eth1 forces the agent's internal proxy and networking to route over the 192.168.56.X interface
curl -sfL https://get.k3s.io | K3S_URL=$K3S_URL K3S_TOKEN=$K3S_TOKEN sh -s - --node-ip 192.168.56.111 --flannel-iface=eth1
#!/bin/bash

set -e

CONFS=/home/vagrant/confs
TARGETS=(
    "app1"
    "app2"
    "app3"
    "ingress.yml"
)

for TARGET in "${TARGETS[@]}"; do
	kubectl apply -f "$CONFS/$TARGET"
done

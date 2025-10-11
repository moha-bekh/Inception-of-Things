#!/bin/bash

set -e

CONFS=/home/vagrant/confs
TARGETS=(
    "ingress.yml"
    "app1"
    "app2"
    "app3"
)

for TARGET in "${TARGETS[@]}"; do
	kubectl apply -f "$CONFS/$TARGET"
done
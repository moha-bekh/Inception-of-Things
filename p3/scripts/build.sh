#!/bin/bash

set -e

LOCAL_PORT=8080
SERVICE_PORT=8080

if k3d cluster list | grep -q argo-cluster; then
	echo "Cluster 'argo-cluster' already exists."
else
	k3d cluster create argo-cluster -p "$LOCAL_PORT:$SERVICE_PORT@loadbalancer"
fi

if kubectl get namespace argocd &> /dev/null; then
	echo "Namespace 'argocd' already exists."
else
	kubectl create namespace argocd
fi

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

DIR=$(dirname "$0")
kubectl apply -f $DIR/../confs/application.yml
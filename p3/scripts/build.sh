#!/bin/bash

set -euo pipefail

CLUSTER_NAME=argo-cluster
ARGOCD_NAMESPACE=argocd
DEV_NAMESPACE=dev
ARGOCD_MANIFEST_URL=https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if ! docker info >/dev/null 2>&1; then
	echo "Docker is not reachable. If you were just added to the docker group, reopen your shell."
	exit 1
fi

if k3d cluster list | grep -q "$CLUSTER_NAME"; then
	echo "Cluster '$CLUSTER_NAME' already exists."
	kubectl config use-context "k3d-$CLUSTER_NAME" >/dev/null
else
	k3d cluster create "$CLUSTER_NAME"
fi

kubectl create namespace "$ARGOCD_NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace "$DEV_NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -n "$ARGOCD_NAMESPACE" -f "$ARGOCD_MANIFEST_URL"
kubectl wait --for=condition=Established crd/applications.argoproj.io --timeout=180s
kubectl wait --for=condition=Available deployment/argocd-server -n "$ARGOCD_NAMESPACE" --timeout=300s
kubectl wait --for=condition=Available deployment/argocd-repo-server -n "$ARGOCD_NAMESPACE" --timeout=300s
kubectl rollout status statefulset/argocd-application-controller -n "$ARGOCD_NAMESPACE" --timeout=300s

kubectl apply -f "$SCRIPT_DIR/../confs/application.yml"
kubectl wait --for=jsonpath='{.status.health.status}'=Healthy application/argo-app -n "$ARGOCD_NAMESPACE" --timeout=300s

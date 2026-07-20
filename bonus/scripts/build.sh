#!/bin/bash

set -euo pipefail

CLUSTER_NAME="argo-cluster"
ARGOCD_NAMESPACE="argocd"
DEV_NAMESPACE="dev"
GITLAB_NAMESPACE="gitlab"
GITLAB_CHART_VERSION="9.11.8"
ARGOCD_MANIFEST_URL="https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Checking Docker..."

if ! docker info >/dev/null 2>&1; then
    echo "Docker is not reachable."
    echo "If you were just added to the docker group, reopen your shell and try again."
    exit 1
fi

echo "Creating k3d cluster..."

if k3d cluster list | grep -qw "$CLUSTER_NAME"; then
    echo "Cluster '$CLUSTER_NAME' already exists."
    kubectl config use-context "k3d-$CLUSTER_NAME" >/dev/null
else
    k3d cluster create "$CLUSTER_NAME"
fi

echo "Creating namespaces..."

for ns in "$ARGOCD_NAMESPACE" "$DEV_NAMESPACE" "$GITLAB_NAMESPACE"; do
    kubectl create namespace "$ns" \
        --dry-run=client -o yaml | kubectl apply -f -
done

echo "Installing Argo CD..."

# ArgoCD CRDs are too large for client-side apply.
kubectl apply \
    --server-side \
    --force-conflicts \
    -n "$ARGOCD_NAMESPACE" \
    -f "$ARGOCD_MANIFEST_URL"

echo "Waiting for Argo CD..."

kubectl wait \
    --for=condition=Established \
    crd/applications.argoproj.io \
    --timeout=180s

kubectl wait \
    --for=condition=Available \
    deployment/argocd-server \
    -n "$ARGOCD_NAMESPACE" \
    --timeout=300s

kubectl wait \
    --for=condition=Available \
    deployment/argocd-repo-server \
    -n "$ARGOCD_NAMESPACE" \
    --timeout=300s

kubectl rollout status \
    statefulset/argocd-application-controller \
    -n "$ARGOCD_NAMESPACE" \
    --timeout=300s

echo "Installing GitLab..."

helm repo add gitlab https://charts.gitlab.io/ >/dev/null 2>&1 || true
helm repo update >/dev/null

helm upgrade --install gitlab gitlab/gitlab \
    --namespace "$GITLAB_NAMESPACE" \
    --create-namespace \
    --values "$SCRIPT_DIR/../confs/gitlab-values.yml" \
    --version "$GITLAB_CHART_VERSION" \
    --skip-crds

echo "Waiting for GitLab..."

kubectl rollout status \
    deployment/gitlab-webservice-default \
    -n "$GITLAB_NAMESPACE" \
    --timeout=900s

echo "GitLab is ready. Create the project 'root/mbekheir' in GitLab and push the"
echo "contents of '$SCRIPT_DIR/../confs/base/' to its 'base/' directory."
echo "GitLab can be reached with: make gitlab-port"
echo "Then rerun this script (or run the command below) to create the Argo CD application:"
echo "kubectl apply -f $SCRIPT_DIR/../confs/application.yml"

if kubectl get application argo-app -n "$ARGOCD_NAMESPACE" >/dev/null 2>&1; then
    echo "Updating Argo CD Application..."
    kubectl apply -f "$SCRIPT_DIR/../confs/application.yml"
else
    echo "Argo CD Application was not created yet: its GitLab repository does not exist."
fi

echo "Done."

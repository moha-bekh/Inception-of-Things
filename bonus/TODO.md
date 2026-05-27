# Bonus TODO - Local GitLab with K3d and Argo CD

The bonus goal is to reuse the P3 logic, but with a local GitLab instance instead of the public GitHub repository.

GitLab must run locally, inside the lab, and Argo CD must deploy the application from a repository hosted by this local GitLab.

## Expected Runtime Architecture

```text
k3d cluster
|-- namespace gitlab
|   `-- local GitLab instance
|-- namespace argocd
|   `-- Argo CD
`-- namespace dev
    `-- wil42/playground application
```

## Repository Layout to Create

```text
bonus/
  Makefile
  README.md
  TODO.md
  scripts/
    install.sh
    build.sh
  confs/
    application.yml
    gitlab-values.yml
```

## Main Requirements

- [ ] Install all required tools during the defense.
- [ ] Install Docker.
- [ ] Install kubectl.
- [ ] Install k3d.
- [ ] Install Helm.
- [ ] Create a k3d cluster for the bonus.
- [ ] Create a namespace named `gitlab`.
- [ ] Create a namespace named `argocd`.
- [ ] Create a namespace named `dev`.
- [ ] Install the latest official GitLab version available from GitLab.
- [ ] Run GitLab locally.
- [ ] Install Argo CD in the `argocd` namespace.
- [ ] Create a GitLab project containing the app manifests.
- [ ] Configure Argo CD to sync from the local GitLab repository.
- [ ] Deploy the application into the `dev` namespace.
- [ ] Prove that changing the image tag from `v1` to `v2` in GitLab updates the running app.

## Recommended Implementation Steps

### 1. Prepare Tool Installation

Create `bonus/scripts/install.sh`.

It should install:

```text
docker
kubectl
k3d
helm
curl
git
```

For an Arch-based VM, this can be done with `pacman`.

Important:

- Docker must be enabled and started.
- The user may need to be added to the `docker` group.
- If the user was just added to the Docker group, the shell may need to be reopened.

### 2. Create the Cluster

Create a k3d cluster, for example:

```bash
k3d cluster create bonus-cluster
```

GitLab is heavy. Use enough resources on the VM:

- at least 6 GB RAM if possible;
- 2 or more CPUs;
- several GB of free disk space.

### 3. Create Namespaces

```bash
kubectl create namespace gitlab --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f -
```

### 4. Install GitLab with Helm

Use the official GitLab Helm chart.

Example direction:

```bash
helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm upgrade --install gitlab gitlab/gitlab -n gitlab -f confs/gitlab-values.yml
```

Before the defense, check the latest official GitLab version:

```text
https://about.gitlab.com/releases/
```

Keep the GitLab setup as small as possible. The bonus is about proving the GitLab + Argo CD workflow, not building a production GitLab.

### 5. Wait for GitLab

Add waits/checks in `build.sh`.

Useful commands:

```bash
kubectl get pods -n gitlab
kubectl get svc -n gitlab
```

GitLab can take a long time to become ready.

### 6. Get GitLab Root Password

The official Helm chart stores the initial root password in a secret.

Add a Makefile target to print it, for example:

```bash
make gitlab-passwd
```

### 7. Create the Local GitLab Repository

Create a project in the local GitLab instance, for example:

```text
root/mbekheir
```

The project must contain the Kubernetes manifests:

```text
base/deployment.yml
base/service.yml
```

Use the same app as P3:

```yaml
image: wil42/playground:v1
```

The service should expose the app port correctly:

```yaml
targetPort: 8888
```

### 8. Configure Argo CD

Install Argo CD in the `argocd` namespace.

Then create an Argo CD `Application` that points to the local GitLab repository instead of GitHub.

Example idea:

```yaml
source:
  repoURL: http://gitlab-webservice-default.gitlab.svc.cluster.local/root/mbekheir.git
  targetRevision: HEAD
  path: base
destination:
  server: https://kubernetes.default.svc
  namespace: dev
```

The exact GitLab service URL may differ depending on the Helm chart services.
Check with:

```bash
kubectl get svc -n gitlab
```

### 9. Verify the Deployment

Expected checks:

```bash
kubectl get ns
kubectl get pods -n gitlab
kubectl get pods -n argocd
kubectl get pods -n dev
kubectl get svc -n dev
```

Forward the app locally:

```bash
kubectl port-forward svc/argo-app-service -n dev 8888:8080
```

Then test:

```bash
curl http://localhost:8888/
```

Expected result with `v1`:

```json
{"status":"ok", "message": "v1"}
```

### 10. Prove GitOps Sync from GitLab

In the local GitLab repository, change:

```yaml
image: wil42/playground:v1
```

to:

```yaml
image: wil42/playground:v2
```

Commit and push the change to local GitLab.

Argo CD must detect the change and update the app in `dev`.

Then test again:

```bash
curl http://localhost:8888/
```

Expected result:

```json
{"status":"ok", "message": "v2"}
```

## Useful Makefile Targets

Recommended targets:

```make
all
install
build
show
show-gitlab
show-argocd
show-dev
gitlab-passwd
argo-passwd
gitlab-port
argo-port
app-port
fclean
```

## Defense Checklist

- [ ] `make all` installs tools and builds the lab.
- [ ] `kubectl get ns` shows `gitlab`, `argocd` and `dev`.
- [ ] GitLab pods are running in `gitlab`.
- [ ] Argo CD pods are running in `argocd`.
- [ ] The app pod is running in `dev`.
- [ ] The local GitLab repository contains the app manifests.
- [ ] Argo CD Application is synced and healthy.
- [ ] `curl http://localhost:8888/` returns `v1`.
- [ ] Changing the GitLab repo to `v2` updates the running app.
- [ ] `curl http://localhost:8888/` returns `v2`.

## Main Risks

- GitLab needs a lot of RAM and takes time to start.
- The official GitLab Helm chart creates many services and pods.
- Argo CD may need credentials if the local GitLab repository is private.
- The internal GitLab service URL must match the actual service created by Helm.
- The bonus is evaluated only if P1, P2 and P3 are flawless.

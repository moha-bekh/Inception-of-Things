# Bonus — local GitLab, K3d and Argo CD

This bonus extends P3 with a local GitLab instance. GitLab, Argo CD and the
application run in the same K3d cluster, respectively in `gitlab`, `argocd` and
`dev` namespaces.

## Requirements

GitLab is resource intensive: allocate at least 6 GiB of RAM and 2 CPUs to the
VM/Docker runtime. The install script targets Arch Linux.

```bash
cd bonus
make all
```

The deployment intentionally uses GitLab chart `9.11.8` (GitLab `18.11`). It is
the last official self-contained chart: newer chart releases require external
PostgreSQL, Redis and object storage, so they cannot work with only a values
file in this lab.

## Initialise the GitOps repository

Once `make all` reports that GitLab is ready, expose GitLab locally:

```bash
make gitlab-port
```

Open `http://localhost:8081`, sign in as `root`, and get the initial password
in another terminal:

```bash
make gitlab-passwd
```

Create the project **`mbekheir`** under the `root` namespace. Clone it and copy
the provided GitOps manifests so that the repository contains `base/`:

```bash
git clone http://root@localhost:8081/root/mbekheir.git
cd mbekheir
cp -r /tmp/mbekheir/base .
git add .
git commit -m 'Add v1 application manifests'
git push
```

Stop the port-forward, then create the Argo CD Application:

```bash
kubectl apply -f bonus/confs/application.yml
kubectl wait --for=jsonpath='{.status.health.status}'=Healthy application/argo-app -n argocd --timeout=300s
```

## Check and update

```bash
make show-gitlab
make show-argocd
make show-dev
make app-port
curl http://localhost:8888/
```

Change `wil42/playground:v1` to `wil42/playground:v2` in the GitLab project's
`base/deployment.yml`, commit and push. Argo CD automatically synchronizes the
new version.

## Useful commands

```bash
make argo-port       # Argo CD UI: https://localhost:8080
make argocd-passwd
make gitlab-passwd
make fclean
```

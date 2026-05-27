# P3 - K3d and Argo CD

Part 3 of the Inception of Things project.

This part uses K3d, Docker and Argo CD. It creates:

- a K3d cluster named `argo-cluster`;
- an `argocd` namespace for Argo CD;
- a `dev` namespace for the application;
- an Argo CD Application syncing the public repository `https://github.com/moha-bekh/mbekheir.git`.

The application uses the `wil42/playground` image and can be switched between the `v1` and `v2` tags from the GitHub repository.

## Install and Start

```bash
cd p3
make all
```

`make all` runs:

- `sudo ./scripts/install.sh` to install Docker, kubectl and k3d;
- `./scripts/build.sh` to create the cluster, install Argo CD and apply the Application.

If the user has just been added to the Docker group, the terminal may need to be reopened before running `make build` again.

## Checks

```bash
make show
make show-argocd
make show-dev
```

Show the initial Argo CD admin password:

```bash
make show-passwd
```

Start the Argo CD UI port-forward:

```bash
make argo-port
```

Then open:

```text
https://localhost:8080
```

Start the application port-forward:

```bash
make app-port
```

Test the application:

```bash
curl http://localhost:8888/
```

Expected result with `v1`:

```json
{"status":"ok", "message": "v1"}
```

After changing the GitHub repository from `wil42/playground:v1` to `wil42/playground:v2`, Argo CD must resync the application. The test should then return:

```json
{"status":"ok", "message": "v2"}
```

## Cleanup

```bash
make fclean
```

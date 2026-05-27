# P2 - K3s and Three Applications

Part 2 of the Inception of Things project.

This part starts one Vagrant machine with K3s in server mode:

- `mbekheirS`: K3s server, IP `192.168.56.110`

Three web applications are deployed in K3s. The Traefik ingress selects the application from the HTTP `Host` header:

- `app1.com` -> `app1`
- `app2.com` -> `app2`
- any other host, or no host, -> `app3`

`app2` is configured with 3 replicas.

## Start

```bash
cd p2
vagrant up
```

The provisioning script installs K3s, waits for the node to be ready, then automatically applies the Kubernetes manifests from `confs`.

If needed, the deployment can be applied again inside the VM:

```bash
vagrant ssh -c "deploy"
```

## Checks

```bash
vagrant ssh -c "kubectl get pods -o wide"
vagrant ssh -c "kubectl get svc"
vagrant ssh -c "kubectl get ingress"
```

HTTP tests from the host machine:

```bash
curl -H "Host: app1.com" http://192.168.56.110/
curl -H "Host: app2.com" http://192.168.56.110/
curl http://192.168.56.110/
```

Expected result:

```text
app1
app2
app3
```

## Cleanup

```bash
vagrant destroy -f
```

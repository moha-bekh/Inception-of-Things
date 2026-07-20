# P1 - K3s and Vagrant

Part 1 of the Inception of Things project.

This part starts two Vagrant machines with K3s:

- `mbekheirS`: K3s server, IP `192.168.56.110`
- `mbekheirSW`: K3s agent, IP `192.168.56.111`

## Start

```bash
cd p1
vagrant up
```

The server installs K3s in controller mode and copies the `node-token` into the shared `confs` folder.
The agent waits for this token, then joins the cluster through `https://192.168.56.110:6443`.

## Checks

```bash
vagrant status
vagrant ssh mbekheirS -c "kubectl get nodes -o wide"
vagrant ssh mbekheirS -c "ip a"
vagrant ssh mbekheirSW -c "ip a"
```

Expected result:

- both VMs are `running`;
- both Kubernetes nodes are `Ready`;
- `mbekheirS` uses `192.168.56.110`;
- `mbekheirSW` uses `192.168.56.111`.

## Cleanup

```bash
vagrant destroy -f
```
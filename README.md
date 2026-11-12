# Demo runbook: Four Resources, One Object

Runs on macOS with **k3d** (k3s in Docker). Pinned: k3s **v1.36.5**, Envoy Gateway **v1.9.3** (bundles Gateway API v1.6.1 CRDs), kro **0.9.4**. All images used have arm64 builds, so Apple Silicon works.

## Prerequisites (Mac)

```bash
brew install k3d helm yq
# Rancher Desktop provides docker and kubectl (~/.rd/bin).
# Settings: Container Engine = dockerd (moby), Kubernetes = off, VM memory >= 4 GB, 4 CPUs.
```

Two k3s specifics the script handles:
- k3s ships Traefik, and Traefik's chart installs its own Gateway API CRDs. The script disables Traefik so Envoy Gateway's CRDs are the only ones installed.
- k3s's built-in load balancer (servicelb) gives the Envoy Service an address, and k3d maps two ports to it. No port-forward needed:
  - `localhost:8080` → Envoy port 80, the shared Gateway's own listener. Used in Acts 1–2.
  - `localhost:8081` → Envoy port 8081, the app's ListenerSet created by the RGD. Used in Act 3.

Why two ports: plain-HTTP listeners on the same port merge into one Envoy listener, and Envoy Gateway rejects a ClientTrafficPolicy that would apply to more than one of them (`Accepted=False, Invalid`). So the app's ListenerSet gets its own port. In production you'd use HTTPS on 443, where Envoy splits listeners by hostname.

## Scripts

| Script | Needs internet | What it does |
|---|---|---|
| `install.sh` | **Yes** (~3–5 min) | Creates the cluster, installs Envoy Gateway and kro, and starts the platform once to cache its images, then removes it. Run it before you travel. |
| `reset.sh` | No (seconds) | Deletes every demo object, keeps the cluster and cached images. Use between rehearsals and before going on stage. |
| `cleanup.sh` | No, but you'll need internet to reinstall | Deletes the cluster and its cached images. Don't run it at the venue. |


## Teardown
```bash
./cleanup.sh          # deletes the gateway-api-kro cluster; ./install.sh recreates it
```

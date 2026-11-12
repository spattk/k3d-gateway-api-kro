#!/usr/bin/env bash
# Local cluster for "Four Resources, One Object": k3d (k3s in Docker) on macOS.
# Pinned: k3s v1.36.5, Envoy Gateway v1.9.3 (+ Gateway API v1.6.1 CRDs), kro 0.9.4.
# This is the only step that needs internet. Everything after it runs offline.
set -euo pipefail
cd "$(dirname "$0")"

# Traefik is disabled because k3s's bundled Traefik installs its own Gateway API CRDs.
# localhost:8080 -> Envoy port 80:   the shared Gateway listener (Acts 1-2).
# localhost:8081 -> Envoy port 8081: the app's ListenerSet created by the RGD (Act 3).
k3d cluster create gateway-api-kro \
  --image rancher/k3s:v1.36.5-k3s1 \
  -p "8080:80@loadbalancer" \
  -p "8081:8081@loadbalancer" \
  --k3s-arg "--disable=traefik@server:0"

helm install eg oci://docker.io/envoyproxy/gateway-helm --version v1.9.3 \
  -n envoy-gateway-system --create-namespace --wait

# Demo only: kro's chart defaults to full cluster access (rbac.mode=unrestricted).
helm install kro oci://registry.k8s.io/kro/charts/kro --version 0.9.4 \
  -n kro-system --create-namespace --wait

# Warm the image cache: start the platform once so the Envoy proxy and model images
# are pulled now, then remove it. On stage, `kubectl apply -f platform/` uses the cache.
kubectl apply -f platform/
kubectl -n platform  wait gateway/shared-gw --for=condition=Programmed --timeout=3m
kubectl -n team-chat wait deployment --all --for=condition=Available --timeout=3m
kubectl delete -f platform/ --wait

echo "Ready. On stage, start with: kubectl apply -f platform/"

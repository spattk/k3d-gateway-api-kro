#!/usr/bin/env bash
# Offline reset between rehearsals: removes every demo object, keeps the cluster and
# its cached images. Leaves the cluster as install.sh left it.
set -euo pipefail
cd "$(dirname "$0")"

# Instances first, so kro deletes their routes and policies in reverse order.
kubectl delete chatendpoint --all -n team-chat --ignore-not-found 2>/dev/null || true
kubectl delete rgd chatendpoint --ignore-not-found
# Removes the Gateway, models, JWKS, and both namespaces (and any before/ objects in them).
kubectl delete -f platform/ --ignore-not-found --wait

echo "Reset. Start again with: kubectl apply -f platform/"

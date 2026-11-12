#!/usr/bin/env bash
# Deletes the demo cluster and everything in it. Recreate with ./install.sh.
set -euo pipefail
k3d cluster delete gateway-api-kro

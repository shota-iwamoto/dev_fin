#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="dev-finace"

if [ "${1:-}" = "--delete-cluster" ]; then
  echo "==> deleting kind cluster: $CLUSTER_NAME"
  kind delete cluster --name "$CLUSTER_NAME"
else
  echo "==> deleting dev-finace namespace (cluster kept)"
  kubectl delete namespace dev-finace --ignore-not-found
  echo "(cluster ごと消すには: scripts/k8s-down.sh --delete-cluster)"
fi

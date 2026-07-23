#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLUSTER_NAME="dev-finace"
IMAGE_TAG="dev-finace-api:dev"

cd "$ROOT_DIR"

if ! kind get clusters 2>/dev/null | grep -qx "$CLUSTER_NAME"; then
  echo "==> creating kind cluster: $CLUSTER_NAME"
  kind create cluster --config k8s/kind-config.yaml
else
  echo "==> kind cluster already exists: $CLUSTER_NAME"
fi

echo "==> building api image"
docker build -t "$IMAGE_TAG" ./app

echo "==> loading image into kind"
kind load docker-image "$IMAGE_TAG" --name "$CLUSTER_NAME"

echo "==> applying namespace"
kubectl apply -f k8s/namespace.yaml

echo "==> syncing app-env secret from .env"
kubectl create secret generic app-env \
  --from-env-file=.env \
  --namespace dev-finace \
  --dry-run=client -o yaml | kubectl apply -f -

echo "==> applying manifests"
kubectl apply -f k8s/mariadb.yaml
kubectl apply -f k8s/valkey.yaml
kubectl apply -f k8s/api.yaml

echo "==> waiting for rollout"
kubectl -n dev-finace rollout status deployment/mariadb --timeout=120s
kubectl -n dev-finace rollout status deployment/valkey --timeout=60s
kubectl -n dev-finace rollout status deployment/api --timeout=60s

echo "==> done. API available at http://localhost:8080"

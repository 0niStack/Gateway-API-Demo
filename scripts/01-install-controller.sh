#!/usr/bin/env bash
# Installs Gateway API CRDs + Envoy Gateway (controller). Run once per cluster.
# Envoy Gateway's install.yaml bundles the Gateway API CRDs, so no separate CRD step is needed.
set -euo pipefail

EG_VERSION="${EG_VERSION:-v1.4.0}"   # override: EG_VERSION=v1.x.y ./01-install-controller.sh

command -v kubectl >/dev/null || { echo "kubectl not found"; exit 1; }
kubectl cluster-info >/dev/null || { echo "Cannot reach a cluster"; exit 1; }

echo ">> Installing Envoy Gateway ${EG_VERSION} (includes Gateway API CRDs)..."
kubectl apply --server-side -f "https://github.com/envoyproxy/gateway/releases/download/${EG_VERSION}/install.yaml"

echo ">> Waiting for the controller to be ready..."
kubectl wait --timeout=5m -n envoy-gateway-system deployment/envoy-gateway --for=condition=Available

echo ">> Done. CRDs installed:"
kubectl get crd | grep gateway.networking.k8s.io || true

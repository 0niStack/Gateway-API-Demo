#!/usr/bin/env bash
# Removes the demo. Pass --all to also remove Envoy Gateway and the Gateway API CRDs.
set -euo pipefail
cd "$(dirname "$0")/.."

kubectl delete -f manifests/ --ignore-not-found

if [[ "${1:-}" == "--all" ]]; then
  EG_VERSION="${EG_VERSION:-v1.4.0}"
  kubectl delete -f "https://github.com/envoyproxy/gateway/releases/download/${EG_VERSION}/install.yaml" --ignore-not-found
fi

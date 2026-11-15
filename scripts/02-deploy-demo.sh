#!/usr/bin/env bash
# Deploys namespace, app, GatewayClass, Gateway and HTTPRoutes.
set -euo pipefail
cd "$(dirname "$0")/.."

kubectl get crd gateways.gateway.networking.k8s.io >/dev/null 2>&1 || {
  echo "Gateway API CRDs missing. Run scripts/01-install-controller.sh first."; exit 1; }

kubectl apply -f manifests/

echo ">> Waiting for app and Gateway..."
kubectl -n gateway-demo rollout status deploy/demo-app --timeout=120s
kubectl -n gateway-demo wait --for=condition=Programmed gateway/demo-gw --timeout=180s || \
  echo "!! Gateway not Programmed yet. On local clusters you may need a LoadBalancer (see README)."

kubectl -n gateway-demo get deploy,svc,gateway,httproute

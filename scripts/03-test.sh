#!/usr/bin/env bash
# Tests the demo. Uses the Gateway address if it has one, else falls back to port-forward.
set -euo pipefail

GW=$(kubectl -n gateway-demo get gateway demo-gw -o jsonpath='{.status.addresses[0].value}' 2>/dev/null || true)
PF_PID=""

if [[ -z "$GW" || "${USE_PORT_FORWARD:-}" == "1" ]]; then
  echo ">> No external address (or USE_PORT_FORWARD=1). Using port-forward on localhost:8888"
  SVC=$(kubectl -n envoy-gateway-system get svc \
    -l gateway.envoyproxy.io/owning-gateway-name=demo-gw,gateway.envoyproxy.io/owning-gateway-namespace=gateway-demo \
    -o jsonpath='{.items[0].metadata.name}')
  kubectl -n envoy-gateway-system port-forward "svc/${SVC}" 8888:80 >/dev/null &
  PF_PID=$!
  trap '[[ -n "$PF_PID" ]] && kill $PF_PID 2>/dev/null' EXIT
  sleep 3
  GW="localhost:8888"
fi

echo ">> Gateway: $GW"
echo; echo "--- curl http://$GW/ (IP route)"
curl -s -i "http://$GW/"
echo; echo "--- curl -H 'Host: demo.example.com' http://$GW/ (host route)"
curl -s -i -H "Host: demo.example.com" "http://$GW/"
echo

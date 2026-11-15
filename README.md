# Gateway API Demo

A minimal, self-contained Kubernetes Gateway API demo. It starts from a cluster
with **no Gateway API CRDs and no controller**, installs both, then exposes a
sample app through a Gateway and two HTTPRoutes (host-based and IP-based).

## Prerequisites
- A Kubernetes cluster (kind, minikube, k3s, or cloud) and `kubectl` pointed at it
- `curl`
- Internet access (pulls the Envoy Gateway release manifest and the `hashicorp/http-echo` image)

## Quick start
```bash
./scripts/01-install-controller.sh   # Gateway API CRDs + Envoy Gateway (once per cluster)
./scripts/02-deploy-demo.sh          # namespace, app, GatewayClass, Gateway, routes
./scripts/03-test.sh                 # curl both routes
```
Or with make: `make install deploy test`

## Layout
```
gateway-api-demo/
├── manifests/
│   ├── 00-namespace.yaml        # gateway-demo namespace
│   ├── 05-gatewayclass.yaml     # GatewayClass "eg" -> Envoy Gateway
│   ├── 10-deployment.yaml       # demo-app (2 replicas, http-echo)
│   ├── 20-service.yaml          # Service demo-app :80 -> :5678
│   ├── 30-gateway.yaml          # Gateway demo-gw (HTTP :80)
│   ├── 40-httproute-name.yaml   # host route: demo.example.com
│   └── 50-httproute-ip.yaml     # catch-all route (direct IP)
├── scripts/
│   ├── 01-install-controller.sh
│   ├── 02-deploy-demo.sh
│   ├── 03-test.sh
│   └── 99-cleanup.sh
├── Makefile
└── README.md
```

## How it fits together
```
curl -> Gateway demo-gw (:80, class eg) -> HTTPRoute -> Service demo-app -> Pods
```
- `GatewayClass eg` binds the Gateway to Envoy Gateway.
- `demo-route-name` matches `Host: demo.example.com`; `demo-route-ip` has no hostname, so it catches everything else.
- The Gateway only accepts routes from its own namespace (`allowedRoutes.from: Same`).

## Manual test
```bash
GW=$(kubectl -n gateway-demo get gateway demo-gw -o jsonpath='{.status.addresses[0].value}')
curl http://$GW/
curl -H "Host: demo.example.com" http://$GW/
```
Expected: `Hello from the Gateway API demo!`

## Local clusters (no LoadBalancer)
On kind/minikube the Gateway may have no ADDRESS. Options:
- **Port-forward (easiest):** `USE_PORT_FORWARD=1 ./scripts/03-test.sh`
- **kind:** run [cloud-provider-kind](https://github.com/kubernetes-sigs/cloud-provider-kind) in another terminal
- **minikube:** run `minikube tunnel` in another terminal

## Troubleshooting
```bash
kubectl get crd | grep gateway.networking.k8s.io
kubectl get gatewayclass                                  # eg should be Accepted=True
kubectl -n gateway-demo describe gateway demo-gw          # look at Programmed / Accepted
kubectl -n gateway-demo describe httproute                # look at Accepted / ResolvedRefs
kubectl -n envoy-gateway-system get pods,svc
```

## Versions
Envoy Gateway version defaults to `v1.4.0`. Override with:
`EG_VERSION=v1.x.y ./scripts/01-install-controller.sh`

## Cleanup
```bash
./scripts/99-cleanup.sh          # remove the demo only
./scripts/99-cleanup.sh --all    # also remove Envoy Gateway + CRDs
```

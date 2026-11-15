# gateway-demo

kubectl get gatewayclass
kubectl apply -f .
kubectl -n gateway-demo get deploy,svc,gateway,httproute

GW=$(kubectl -n gateway-demo get gateway demo-gw -o jsonpath='{.status.addresses[0].value}')
curl http://$GW/
curl -H "Host: demo.example.com" http://$GW/

kubectl delete -f .

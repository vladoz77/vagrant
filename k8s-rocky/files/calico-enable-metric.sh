#!/bin/bash
echo "wait while namespace calico-system create"
sleep 20
# Enable metrics 
kubectl patch felixconfiguration default --type merge --patch '{"spec":{"prometheusMetricsEnabled": true}}'
kubectl patch installation default --type=merge -p '{"spec": {"typhaMetricsPort":9093}}'

# Create service for calico node
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: calico-felix-metrics
  namespace: calico-system
spec:
  selector:
    k8s-app: calico-node
  ports:
  - port: 9091
    targetPort: 9091
EOF

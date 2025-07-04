# Install k3s
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="--flannel-backend=none --disable servicelb --cluster-cidr=10.10.0.0/16 --disable-network-policy --disable=traefik --disable servicelb  --advertise-address=192.168.59.100  --node-ip=192.168.59.100" sh

# Install calico
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml


# Install resources
curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/custom-resources.yaml

# config installation
kubectl apply -f - << EOF
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  calicoNetwork:
    ipPools:
    - name: default-ipv4-ippool
      blockSize: 26
      cidr: 10.10.0.0/16
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()

---

apiVersion: operator.tigera.io/v1
kind: APIServer
metadata:
  name: default
spec: {}
EOF

# Config calico metrics
# Enable metrics
kubectl patch felixconfiguration default --type merge --patch '{"spec":{"prometheusMetricsEnabled": true}}'
kubectl patch installation default --type=merge -p '{"spec": {"typhaMetricsPort":9093}}'

# Create service for metrucs
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



# install metallb
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml

# Config ippols
kubectl apply -f - <<EOF
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.59.250-192.168.59.253

---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: first-pool
  namespace: metallb-system
EOF

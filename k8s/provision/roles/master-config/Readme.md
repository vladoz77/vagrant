# Kubernetes Master Configuration Role

This role initializes a Kubernetes master node and configures essential cluster components including network plugin (Calico) and optional NodeLocal DNS cache.

## Directory Structure

```
master-config/
├── defaults/            - Default variables
│   └── main.yaml
├── files/              - Script files
│   └── calico-enable-metric.sh
├── tasks/              - Task files
│   ├── cluster-init.yaml - Cluster initialization
│   ├── ha-master-init.yaml - HA master setup
│   ├── main.yaml       - Main task file
│   ├── network-config.yaml - Network plugin setup
│   └── nodelocaldns.yaml - NodeLocal DNS setup
├── templates/          - Configuration templates
│   ├── kubeadm-config.j2 - kubeadm config template
│   ├── kube-calico-cdr.j2 - Calico config template
│   └── localdns.j2     - NodeLocal DNS template
└── vars/               - Role variables
    └── main.yaml
```

## Features

### Cluster Initialization
- kubeadm-based cluster initialization
- Configurable via Jinja2 templates
- Supports both standalone and HA master setups
- Proper kubeconfig setup for admin user

### Network Configuration
- Calico CNI plugin installation
- Customizable pod and service subnets
- VXLAN encapsulation support
- Metrics endpoint configuration

### Optional Components
- NodeLocal DNS cache setup
- kube-proxy mode selection (iptables/ipvs)
- System resource reservations
- Log rotation configuration

## Variables

### Default Variables (defaults/main.yaml)

**Cluster Configuration:**
- `kube_domain_name`: Cluster domain (default: cluster.local)
- `ha_enabled`: Enable HA mode (default: false)
- `vip_address`: Virtual IP for HA (default: 192.168.1.222)
- `vip_port`: VIP port (default: 8443)
- `podSubnet`: Pod network CIDR (default: 10.244.0.0/16)
- `serviceSubnet`: Service network CIDR (default: 10.243.0.0/16)

**kube-proxy:**
- `kubeproxy_mode_ipvs`: Use IPVS mode (default: false)

**kubelet:**
- `system_reserved`: Enable system resource reservations
- `system_memory`: Reserved memory (default: 512Mi)
- `system_cpu`: Reserved CPU (default: 500m)
- `system_ephemeral_storage`: Reserved storage (default: 5Gi)
- `container_log_max_size`: Max log file size (default: 1Mi)
- `container_log_max_file`: Max log files to keep (default: 3)

**Calico:**
- `calico_version`: Calico version (default: v3.29.2)
- `network_plugin`: Network plugin (default: calico)

**NodeLocal DNS:**
- `nodelocaldns`: Enable NodeLocal DNS (default: false)
- `nodelocaldns_address`: DNS cache IP (default: 169.254.20.10)
- `nodelocaldns_image`: DNS cache image (default: registry.k8s.io/dns/k8s-dns-node-cache:1.23.1)

### Role Variables (vars/main.yaml)
- Calico installation manifests and metrics script paths
- NodeLocal DNS template path

## Usage

1. Include this role in your playbook:

```yaml
- hosts: master
  roles:
    - master-config
```

2. Customize cluster parameters:

```yaml
vars:
  podSubnet: 10.100.0.0/16
  serviceSubnet: 10.101.0.0/16
  nodelocaldns: true
```

## Tasks Overview

### Cluster Initialization
- Generates kubeadm config from template
- Initializes cluster using kubeadm
- Sets up kubeconfig for admin user
- Configures kubelet and kube-proxy

### Network Setup
- Installs Calico CNI plugin
- Configures pod network with VXLAN
- Enables Calico metrics endpoints

### NodeLocal DNS
- Deploys DNS cache as DaemonSet
- Configures CoreDNS forwarding rules
- Sets up metrics and health checks

## Requirements

- Ansible 2.9+
- Preconfigured container runtime (ContainerD)
- Proper network connectivity between nodes
- Sufficient system resources

## Notes

- For HA clusters, ensure `ha_enabled: true` and configure VIP
- NodeLocal DNS reduces DNS lookup latency but requires additional resources
- Calico metrics are exposed on port 9091 (node) and 9093 (typha)
- Role is idempotent - won't reinitialize running clusters

## Customization

Override templates for specific requirements:
- `kubeadm-config.j2` for advanced kubeadm options
- `kube-calico-cdr.j2` for custom Calico configuration
- `localdns.j2` for DNS cache tuning
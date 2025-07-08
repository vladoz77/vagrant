# Kubernetes Cluster Provisioning Project

## Overview

This project provides complete automation for deploying a Kubernetes cluster using Vagrant and Ansible, supporting both standalone and HA (High Availability) configurations. It includes everything from VM provisioning to full cluster initialization.

## Project Structure

```
.
├── provision/                     # Ansible provisioning files
│   ├── group_vars/                # Group variables
│   │   └── all.yaml               # Common variables for all nodes
│   ├── master-playbook.yaml       # Playbook for master nodes
│   ├── node-playbook.yaml         # Playbook for worker nodes
│   └── roles/
│       ├── common-config/         # Base system configuration
│       ├── ha-master-config/      # HA setup for control plane
│       ├── join-cluster/          # Node joining automation
│       └── master-config/         # Master node initialization
└── Vagrantfile                    # VM configuration
```

## Key Features

- **Flexible Deployment**:
  - Supports both standalone and HA clusters
  - Configurable number of master and worker nodes
  - Automatic IP assignment

- **Complete Cluster Setup**:
  - Container runtime (containerd) configuration
  - Network plugin (Calico) installation
  - Optional NodeLocal DNS cache
  - HAProxy and Keepalived for HA control plane

- **Infrastructure as Code**:
  - Vagrant for VM management
  - Ansible for configuration management
  - Version-controlled provisioning

## Prerequisites

1. **Software Requirements**:
   - Vagrant (with VirtualBox provider)
   - Ansible
   - Git

2. **System Resources** (minimum):
   - 8GB RAM
   - 4 CPU cores
   - 20GB free disk space

## Quick Start

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd <project-directory>
   ```

2. Configure cluster parameters in:
   - `provision/group_vars/all.yaml` - Main cluster configuration
   - `Vagrantfile` - VM resources and node count

3. Start the cluster:
   ```bash
   vagrant up
   ```

## Configuration Guide

### Key Configuration Files

1. **Vagrantfile**:
   - `Master` - Number of master nodes (default: 3)
   - `Node` - Number of worker nodes (default: 1)
   - VM resources (CPU, memory)

2. **group_vars/all.yaml**:
   ```yaml
   # Kubernetes version
   kubernetesVersion: '1.33'
   kubernetesSubversion: '2'
   
   # Cluster configuration
   ha_enabled: true             # HA mode
   vip_address: 192.168.1.250   # Virtual IP for HA
   
   # Network settings
   podSubnet: 10.100.0.0/16
   serviceSubnet: 10.200.0.0/16
   
   # Features
   nodelocaldns: true          # NodeLocal DNS cache
   dockerhubMirror: true       # Docker registry mirror
   ```

### Playbooks

1. **master-playbook.yaml**:
   - Configures all master nodes
   - Initializes cluster on first master
   - Sets up HA when enabled

2. **node-playbook.yaml**:
   - Configures worker nodes
   - Joins them to the cluster

## Roles Overview

### 1. common-config
**Purpose**: Base configuration for all nodes  
**Features**:
- System packages installation
- Kernel parameters tuning
- Container runtime setup
- Common utilities and tools

### 2. ha-master-config
**Purpose**: HA setup for control plane nodes  
**Features**:
- HAProxy load balancer
- Keepalived for VIP management
- Automatic failover

### 3. master-config
**Purpose**: Cluster initialization  
**Features**:
- kubeadm cluster initialization
- Network plugin installation
- DNS configuration
- Metrics setup

### 4. join-cluster
**Purpose**: Node joining automation  
**Features**:
- Automatic token generation
- Control plane nodes joining (HA)
- Worker nodes joining
- Idempotent operations

## Usage Examples

### 1. Start a basic cluster (3 masters, 1 worker):
```bash
vagrant up
```

### 2. Provision specific nodes:
```bash
vagrant up master1 node1
```

### 3. Re-run provisioning:
```bash
vagrant provision
```

### 4. Destroy the cluster:
```bash
vagrant destroy -f
```

## Customization Options

1. **Cluster Size**:
   - Edit `Master` and `Node` values in Vagrantfile

2. **Kubernetes Version**:
   - Modify `kubernetesVersion` and `kubernetesSubversion` in group_vars

3. **Network Configuration**:
   - Adjust `podSubnet` and `serviceSubnet` as needed

4. **Features**:
   - Enable/disable NodeLocal DNS, HA mode, registry mirror


# HA Master Config Ansible Role

This role configures High Availability (HA) for Kubernetes master nodes using HAProxy for load balancing and Keepalived for VIP management.

## Directory Structure

```
ha-master-config/
├── defaults/            - Default variables
│   └── main.yaml
├── handlers/           - Handlers for service management
│   └── main.yaml
├── tasks/              - Task files
│   ├── ha-config.yaml  - HA configuration tasks
│   └── main.yaml       - Main task file
├── templates/          - Configuration templates
│   ├── haproxy.cfg.j2  - HAProxy configuration template
│   └── keepalived.conf.j2 - Keepalived configuration template
└── vars/               - Role variables
    └── main.yaml
```

## Features

### High Availability Setup
- Configures HAProxy as TCP load balancer for Kubernetes API server
- Implements Keepalived for Virtual IP (VIP) failover
- Automatic configuration based on master node inventory
- Supports multiple master nodes in round-robin load balancing

### Configuration Management
- Conditional installation (only if not already configured)
- Idempotent configuration deployment
- Automatic service restart on configuration changes
- Proper file permissions enforcement

## Variables

### Default Variables (defaults/main.yaml)

**HA Configuration:**
- `ha_enabled`: Enable HA setup (default: false)
- `vip_address`: Virtual IP address (default: 192.168.1.222)
- `vip_port`: Virtual IP port (default: 8443)

**Packages:**
- `ha_packages`: List of required packages (haproxy, keepalived)

### Role Variables (vars/main.yaml)
- `haproxy_config_template`: HAProxy template file
- `haproxy_config_dir`: HAProxy config destination path
- `keepalived_config_template`: Keepalived template file
- `keepalived_config_dir`: Keepalived config destination path
- `keepalived_check_script_template`: Health check script template
- `keepalived_check_script_dir`: Health check script destination path

## Usage

1. Include this role in your playbook:

```yaml
- hosts: master
  roles:
    - ha-master-config
```

2. Set `ha_enabled: true` to activate HA configuration

3. Customize VIP settings in your inventory:

```yaml
vars:
  vip_address: 10.10.10.100
  vip_port: 6443
```

## Configuration Details

### HAProxy
- Listens on VIP port (default: 8443)
- Balances traffic across all master nodes on port 6443
- Uses TCP mode for Kubernetes API traffic
- Round-robin load balancing algorithm

### Keepalived
- Implements VRRP protocol for VIP failover
- First master node in inventory becomes MASTER (priority 101)
- Other master nodes become BACKUP (priority 100)
- Includes HAProxy process health checking
- Automatic failover if MASTER node fails

## Requirements

- Ansible 2.9+
- RHEL/CentOS 7/8/9
- Existing Kubernetes master nodes
- Network interface configured for VRRP (default: eth1)

## Handlers

- `restart_haproxy`: Restarts and enables HAProxy service
- `restart_keepalived`: Restarts and enables Keepalived service

## Notes

- Ensure proper network configuration for VRRP traffic
- VIP must be in the same subnet as master nodes
- Firewall must allow VRRP protocol (IP protocol 112)
- For production use, customize health checks and timeouts
- Role is idempotent - won't reconfigure existing installations unless forced
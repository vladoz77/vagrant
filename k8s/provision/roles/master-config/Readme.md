# Роль `master-config`: Настройка Kubernetes Master с Ansible

Эта роль предназначена для автоматизации настройки узла управления (master) в кластере Kubernetes с использованием Ansible. Она использует `kubeadm` для инициализации кластера, разворачивает сетевой плагин Calico и может настраивать NodeLocalDNS.

## Основные возможности роли:
- Инициализация кластера Kubernetes.
- Поддержка eBPF режима через Calico.
- Настройка HA-кластера или одиночного master узла.
- Настраиваемая конфигурация kube-proxy (iptables или IPVS).
- Установка и настройка Calico как сетевого плагина.
- Включение NodeLocalDNS для повышения производительности DNS в кластере.

---

## Требования

### Системные требования:
- Один или несколько хостов с поддержкой запуска Kubernetes.
- Установленный `containerd` и `kubeadm`.
- Ansible 2.10+.

---

## Переменные по умолчанию

Переменные определены в файле `defaults/main.yaml`. Ниже приведен список основных параметров:

| Переменная | Описание | Значение по умолчанию |
|------------|----------|------------------------|
| `kube_domain_name` | Доменное имя кластера Kubernetes | `cluster.local` |
| `ha_enabled` | Включить ли HA-режим | `false` |
| `vip_address` | IP-адрес виртуального балансировщика нагрузки (VIP) | `192.168.1.222` |
| `vip_port` | Порт VIP для API сервера | `8443` |
| `podSubnet` | CIDR для подсети Pod | `10.244.0.0/16` |
| `serviceSubnet` | CIDR для сервисной сети | `10.243.0.0/16` |
| `kubeproxy_mode_ipvs` | Режим работы kube-proxy (`ipvs` или `iptables`) | `false` |
| `ebpf_enabled` | Включить eBPF-режим в Calico | `false` |
| `nodelocaldns` | Включить NodeLocalDNS | `false` |
| `nodelocaldns_address` | IP-адрес для локального DNS | `169.254.20.10` |
| `nodelocaldns_image` | Образ NodeLocalDNS | `registry.k8s.io/dns/k8s-dns-node-cache:1.23.1` |

---

## Конфигурационные параметры ядра Kubernetes

Роль позволяет гибко настраивать параметры kubelet:

- `system_reserved` — использовать ли резервирование системных ресурсов.
- `system_memory` — объем памяти для системных процессов.
- `system_cpu` — количество CPU для системных процессов.
- `system_ephemeral_storage` — дисковое пространство для временных данных.
- `container_log_max_size` — максимальный размер лог-файлов контейнеров.
- `container_log_max_file` — максимальное число лог-файлов на контейнер.

---

## Структура роли

```
master-config/
├── defaults
│   └── main.yaml       # Переменные по умолчанию
├── Readme.md           # Описание роли
├── tasks
│   ├── cluster-init.yaml      # Инициализация кластера
│   ├── cluster-init-ebpf.yaml # Инициализация кластера в eBPF-режиме
│   ├── main.yaml              # Основная задача, проверяет статус кластера и вызывает нужную инициализацию
│   └── nodelocaldns.yaml      # Установка NodeLocalDNS
├── templates
│   ├── kubeadm-config.j2          # Шаблон конфигурации kubeadm
│   ├── kube-calico-cdr.j2         # Шаблон установки Calico
│   ├── kube-calico-crd-bpf.yaml.j2 # Шаблон Calico в eBPF-режиме
│   ├── kubernetes-service-endpoint.yaml.j2 # Конфигурация сервиса Kubernetes
│   └── localdns.j2                # Шаблон NodeLocalDNS
└── vars
    └── main.yaml                  # Вспомогательные переменные
```

---

## Пример использования

Пример playbook для применения роли:

```yaml
---
- name: Configure Kubernetes Master
  hosts: master
  become: yes
  roles:
    - role: master-config
      vars:
        ha_enabled: false
        ebpf_enabled: true
        nodelocaldns: true
```

---

## Особенности

### eBPF режим
Если `ebpf_enabled == true`, то используется отдельная задача `cluster-init-ebpf.yaml`, которая:
- Пропускает фазу установки kube-proxy.
- Активирует BPF-драйплейн в Calico.

### NodeLocalDNS
При активации `nodelocaldns == true` роль:
- Получает IP-адрес сервиса `kube-dns`.
- Развертывает локальный кэширующий DNS на каждом узле.

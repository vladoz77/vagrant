# Ansible Role: `ha-master-config`

## Описание

Эта роль обеспечивает настройку High Availability (HA) мастер-нод в Kubernetes кластере. Она устанавливает и конфигурирует `haproxy` как TCP-прокси для балансировки нагрузки между мастерами и `keepalived` для управления виртуальным IP-адресом (`VIP`) и отказоустойчивостью.

Роль подходит для использования в тестовых или учебных окружениях, где необходимо быстро развернуть HA-архитектуру Kubernetes без внешних Load Balancer'ов.

---

## Функционал

- Установка `haproxy` и `keepalived`
- Создание конфигурационных файлов для:
  - `haproxy.cfg` — балансировка между всеми master-узлами
  - `keepalived.conf` — управление виртуальным IP-адресом (VIP)
- Настройка автоматического переключения между мастер-узлами при падении одного из них
- Привязка VIP к интерфейсу `eth1` (настраивается)
- Настройка разных состояний VRRP (MASTER/BACKUP) на первичной и резервной нодах

---

## Структура роли

```
ha-master-config/
├── defaults
│   └── main.yaml         # Дефолтные переменные
├── handlers
│   └── main.yaml         # Обработчики (рестарт служб)
├── tasks
│   ├── ha-config.yaml    # Логика установки и конфигурации
│   └── main.yaml         # Точка входа
├── templates
│   ├── haproxy.cfg.j2    # Шаблон конфига haproxy
│   └── keepalived.conf.j2# Шаблон конфига keepalived
└── vars
    └── main.yaml         # Внутренние параметры шаблонов
```

---

## Переменные

### Дефолтные переменные (`defaults/main.yaml`)

| Переменная        | Значение по умолчанию / Описание |
|------------------|-------------------------------|
| `ha_enabled`     | `false` — включить HA-режим |
| `vip_address`    | `192.168.1.222` — виртуальный IP |
| `vip_port`       | `8443` — порт для доступа через VIP |
| `ha_packages`    | Пакеты: `haproxy`, `keepalived` |

### Константы путей (задаются внутри роли):

| Переменная                     | По умолчанию |
|-------------------------------|--------------|
| `haproxy_config_dir`         | `/etc/haproxy/haproxy.cfg` |
| `keepalived_config_dir`      | `/etc/keepalived/keepalived.conf` |
| `haproxy_config_template`    | `templates/haproxy.cfg.j2` |
| `keepalived_config_template` | `templates/keepalived.conf.j2` |

---

## Требования

- CentOS 7/8/9
- Ansible >= 2.10
- Несколько хостов в группе `master` в инвентаре
- Доступ к интернету для установки пакетов
- Интерфейс `eth1` должен быть настроен на всех мастерах

---

## Пример использования

```yaml
- hosts: master
  roles:
    - role: ha-master-config
      vars:
        ha_enabled: true
        vip_address: 192.168.1.222
        vip_port: 8443
```

**Примечание:** Роль должна применяться ко всем мастер-нодам (`hosts: master`). Первый хост будет назначен MASTER, остальные — BACKUP.

---

## Инвентарь (пример)

```yaml
all:
  hosts:
    master1:
      ansible_host: 192.168.56.101
    master2:
      ansible_host: 192.168.56.102
    master3:
      ansible_host: 192.168.56.103
  groups:
    master:
      - master1
      - master2
      - master3
```

---

## Что происходит после применения:

- Устанавливаются `haproxy` и `keepalived`
- Генерируются конфиги на основе шаблонов
- Сервисы запускаются и добавляются в автозапуск
- VIP (`vip_address`) назначается на интерфейсе `eth1`
- Все запросы на `{{ vip_address }}:{{ vip_port }}` проксируются на `6443` порт каждого из мастеров

---

## Важно

- Эта роль не настраивает сам Kubernetes, только инфраструктуру вокруг него.
- Убедитесь, что все мастера имеют статические IP и корректно настроенный сетевой интерфейс (`eth1`).


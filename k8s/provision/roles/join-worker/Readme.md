# Роль `join-worker`: Подключение worker-узлов к кластеру Kubernetes

Эта роль предназначена для автоматизации подключения worker-узлов к существующему кластеру Kubernetes с использованием Ansible. Роль выполняет получение токенов и хэшей сертификатов с master-узла, генерирует конфигурационный файл `kubeadm join`, и регистрирует worker-ноды в кластере.

---

## Основные возможности роли:
- Получение токена и хэша сертификата с master-узла.
- Динамическое формирование конфига для `kubeadm join`.
- Автоматическое определение уже зарегистрированных нод.
- Поддержка настройки IP-адреса через интерфейс `eth1`.

---

## Требования

### Системные требования:
- Установленный `containerd` и `kubeadm` на worker-узле.
- Доступ к master-узлу (для получения токенов и информации о кластере).
- Ansible 2.10+.

---

## Переменные по умолчанию

Переменные определены в файле `defaults/main.yaml`.

| Переменная | Описание | Значение по умолчанию |
|------------|----------|------------------------|
| `base_kube_conf_dir` | Путь к файлу конфигурации администратора на master-узле | `/etc/kubernetes/admin.conf` |

---

## Структура роли

```
join-worker/
├── defaults
│   └── main.yaml           # Переменные по умолчанию
├── tasks
│   ├── get-credentials.yaml # Получает токен и хэш CA-сертификата с мастера
│   ├── join-worker.yaml     # Выполняет присоединение worker-ноды к кластеру
│   └── main.yaml            # Основной playbook
└── templates
    └── kubeadm-join-worker.yaml.j2 # Шаблон конфигурации для kubeadm join
```

---

## Пример использования

Пример playbook для применения роли:

```yaml
---
- name: Join Worker Nodes to Kubernetes Cluster
  hosts: node
  become: yes
  roles:
    - role: join-worker
```

> **Примечание:** Убедитесь, что группа `master` содержит как минимум один активный узел управления, а группа `node` — список worker-узлов, которые вы хотите добавить.

---

## Как это работает

1. **Получение данных с master-узла**  
   Роль подключается к первому узлу из группы `master` и:
   - Генерирует временный токен для регистрации ноды.
   - Получает хэш CA-сертификата (`discovery-token-ca-cert-hash`).
   - Извлекает адрес API сервера.

2. **Регистрация worker-узла**
   На каждом worker-узле:
   - Проверяется наличие файла `/etc/kubernetes/kubelet.conf` (факт наличия ранее выполненного `kubeadm join`).
   - Если узел ещё не зарегистрирован, генерируется шаблон `kubeadm join` и выполняется команда `kubeadm join`.

3. **Шаблон `kubeadm join`**
   Формируется динамически с учётом:
   - имени хоста (`ansible_hostname`)
   - IP-адреса (`ansible_facts.eth1.ipv4.address`)
   - токена
   - хэша CA-сертификата
   - адреса API сервера


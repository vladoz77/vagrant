## Ansible Role: PostgreSQL

Эта роль устанавливает, настраивает и управляет PostgreSQL на хостах с ОС Ubuntu (Debian). Она позволяет:

- Настроить параметры сервера 
- Создать базу данных, пользователя и назначить ему привилегии
- Разрешить удалённый доступ через pg_hba.conf

## Структура роли

```plain-text
postgresql/
├── defaults/                # Значения по умолчанию
│   └── main.yaml
├── handlers/                # Обработчики (например, перезапуск PostgreSQL)
│   └── main.yaml
├── tasks/                   # Основные задачи
│   ├── config-postgresql.yaml
│   ├── create-user-db-priv.yaml
│   ├── install-postgresql.yaml
│   └── main.yaml
├── vars/                    # Переменные под конкретную ОС
│   ├── main.yaml
│   └── ubuntu.yaml
└── README.md                # Этот файл
```

## Переменные

**В `defaults/main.yaml`:**

| Переменная | Описание |
| --- | --- |
| `default_postresql_user` | Пользователь PostgreSQL, от имени которого выполняются операции |
| `pg_hba_conf_path` | Путь к файлу `pg_hba.conf` |


**В `vars/main.yaml`:**

| Переменная | Описание |
| --- | --- |
| `python_library` | Библиотеки Python, необходимые для работы модулей PostgreSQL  (например,psycopg2-binary) |
| `postgresql_settings` | Параметры PostgreSQL, которые будут изменены |
| `db_name` | Имя создаваемой базы данных |
| `db_user` | Имя пользователя PostgreSQL |
| `db_user_password` | Пароль пользователя PostgreSQL |
| db_user_privileges | Список привелегий для пользователя |
| `allowed_ips` | Разрешенные сети для подключения к базе |


**В `vars/debian.yaml`:**

| Переменная | Описание |
| --- | --- |
| postgresql | Версия PostgreSQL (например,postgresql-14) |
| version | Номер версии PostgreSQL |
| packages | Дополнительные необходимые системные пакеты |


## Пример использования

```yaml
- hosts: all
  become: yes
  roles:
    - postgresql
```

Или переопределение переменных

```yaml
- hosts: all
  become: yes
  roles:
    - role: postgresql
      vars:
        db_name: myapp_db
        db_user: myapp_user
        db_user_password: securepassword123
        postgresql_settings:
          listen_addresses: "*"
          max_connections: 2000
```
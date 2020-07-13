# 專案指引

實作書本《Django for Professionals》。

# 疑難排解

## 清除 PostgresSQL Volume 內的資料庫

### （1）確認 Volume Name （postgres_data）。

【指令】：

```
docker volume ls
```

【操作】：

```
$ docker volume ls --filter "name=ex2020-001"
DRIVER              VOLUME NAME
local               ex2020-001_postgres_data
local               ex2020-001_pycharm_helpers_PY-201.8538.36
local               ex2020-001_pycharm_skeletons_1294759262
```

### （2）清空 PostgresSQl Volume 。

【指令】：

```
docker volume rm <VOLUME>
```

【操作】：

```
$ docker volume rm ex2020-001_postgres_data
Error response from daemon: remove ex2020-001_postgres_data: volume is in use - [b2499e018fa5fdcc6093c5665302d50a47f7d752ef015c2c4f0c119a3c422a7d]

$ docker volume rm ex2020-001_postgres_data -f
Error response from daemon: remove ex2020-001_postgres_data: volume is in use - [b2499e018fa5fdcc6093c5665302d50a47f7d752ef015c2c4f0c119a3c422a7d]

$ docker-compose ps
      Name                    Command               State           Ports
----------------------------------------------------------------------------------
ex2020-001_db_1    docker-entrypoint.sh postgres    Up      5432/tcp
ex2020-001_web_1   python /code/manage.py run ...   Up      0.0.0.0:8000->8000/tcp

$ docker-compose down
Stopping ex2020-001_web_1 ... done
Stopping ex2020-001_db_1  ... done
Removing ex2020-001_web_1 ... done
Removing ex2020-001_db_1  ... done
Removing network ex2020-001_default

$ docker volume rm ex2020-001_postgres_data
ex2020-001_postgres_data
```

## 建立新 Model ，卻無法執行 migrate

使用 startapp 建立新 app ，並於此 app 新建 Model ，可以順利完成 makemigration ，卻無法完成 migrate 。

```
$ docker-compose exec web python manage.py makemigrations users
Migrations for 'users':
  users/migrations/0001_initial.py
    - Create model CustomUser

$ docker-compose exec web python manage.py migrate
Traceback (most recent call last):
  File "manage.py", line 21, in <module>
    main()
  File "manage.py", line 17, in main
    execute_from_command_line(sys.argv)
  File "/usr/local/lib/python3.8/site-packages/django/core/management/__init__.py", line 401, in execute_from_command_line
    utility.execute()
  File "/usr/local/lib/python3.8/site-packages/django/core/management/__init__.py", line 395, in execute
    self.fetch_command(subcommand).run_from_argv(self.argv)
  File "/usr/local/lib/python3.8/site-packages/django/core/management/base.py", line 328, in run_from_argv
    self.execute(*args, **cmd_options)
  File "/usr/local/lib/python3.8/site-packages/django/core/management/base.py", line 369, in execute
    output = self.handle(*args, **options)
  File "/usr/local/lib/python3.8/site-packages/django/core/management/base.py", line 83, in wrapped
    res = handle_func(*args, **kwargs)
  File "/usr/local/lib/python3.8/site-packages/django/core/management/commands/migrate.py", line 89, in handle
    executor.loader.check_consistent_history(connection)
  File "/usr/local/lib/python3.8/site-packages/django/db/migrations/loader.py", line 295, in check_consistent_history
    raise InconsistentMigrationHistory(
django.db.migrations.exceptions.InconsistentMigrationHistory: Migration admin.0001_initial is applied before its dependency users.0001_initial on data
base 'default'.
```

上述問題可先清空 PostgreSQL Volume 後，再重建。

```
# 確認 docker-compose 已重新啟動
$ docker-compose up -d --build
⋯⋯
$ docker-compose ps
      Name                    Command               State           Ports
----------------------------------------------------------------------------------
ex2020-001_db_1    docker-entrypoint.sh postgres    Up      5432/tcp
ex2020-001_web_1   python /code/manage.py run ...   Up      0.0.0.0:8000->8000/tcp

# 要求 PostgreSQL 重建「資料庫」
$ docker-compose exec web python manage.py migrate
Operations to perform:
  Apply all migrations: admin, auth, contenttypes, sessions, users
Running migrations:
  Applying contenttypes.0001_initial... OK
  Applying contenttypes.0002_remove_content_type_name... OK
  Applying auth.0001_initial... OK
  Applying auth.0002_alter_permission_name_max_length... OK
  Applying auth.0003_alter_user_email_max_length... OK
  Applying auth.0004_alter_user_username_opts... OK
  Applying auth.0005_alter_user_last_login_null... OK
  Applying auth.0006_require_contenttypes_0002... OK
  Applying auth.0007_alter_validators_add_error_messages... OK
  Applying auth.0008_alter_user_username_max_length... OK
  Applying auth.0009_alter_user_last_name_max_length... OK
  Applying auth.0010_alter_group_name_max_length... OK
  Applying auth.0011_update_proxy_permissions... OK
  Applying users.0001_initial... OK
  Applying admin.0001_initial... OK
  Applying admin.0002_logentry_remove_auto_add... OK
  Applying admin.0003_logentry_add_action_flag_choices... OK
  Applying sessions.0001_initial... OK

$ docker-compose exec web python manage.py createsuperuser
Username: admin
Email address: alanjui.1960@gmail.com
Password:
Password (again):
Superuser created successfully.
```

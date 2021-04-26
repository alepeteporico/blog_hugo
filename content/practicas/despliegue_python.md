+++
title = "Despliegue de una aplicación python"
description = ""
tags = [
    "IWEB"
]
date = "2021-04-26"
menu = "main"
+++

## Vamos a desarrollar la aplicación del tutorial de django 3.1. Vamos a configurar tu equipo como entorno de desarrollo para trabajar con la aplicación.

------------------------------------------------------------------------------------------------

* Realizamos un fork de la aplicación añadiendola a nuestros repositorios y seguidamente lo clonaremos en nuestra maquina:

        alejandrogv@AlejandroGV:~/Escritorio/ASIR/IWEB/despliegue_python$ git clone git@github.com:alepeteporico/django_tutorial.git

* Crearemos el entorno virtual donde instalaremos las dependencias necesarias para hacer funcionar nuestra aplicación.

        alejandrogv@AlejandroGV:~/Escritorio/ASIR/IWEB$ python3 -m venv django

        (django) alejandrogv@AlejandroGV:~/Escritorio/ASIR/IWEB$ pip install -r despliegue_python/django_tutorial/requirements.txt

* En el fichero settings.py podremos comprobar con que base de datos vamos a trabajar. Efectivamente, es una base de datos sqlite con el nombre db.sqlite3

        (django) alejandrogv@AlejandroGV:~/Escritorio/ASIR/IWEB/despliegue_python/django_tutorial$ cat django_tutorial/settings.py

        DATABASES = {
            'default': {
                'ENGINE': 'django.db.backends.sqlite3',
                'NAME': BASE_DIR / 'db.sqlite3',
            }
        }

* Crearemos la base de datos.

        (django) alejandrogv@AlejandroGV:~/Escritorio/ASIR/IWEB/despliegue_python/django_tutorial$ python3 manage.py migrate
        Operations to perform:
          Apply all migrations: admin, auth, contenttypes, polls, sessions
        Running migrations:
          Applying contenttypes.0001_initial... OK
          Applying auth.0001_initial... OK
          Applying admin.0001_initial... OK
          Applying admin.0002_logentry_remove_auto_add... OK
          Applying admin.0003_logentry_add_action_flag_choices... OK
          Applying contenttypes.0002_remove_content_type_name... OK
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
          Applying auth.0012_alter_user_first_name_max_length... OK
          Applying polls.0001_initial... OK
          Applying sessions.0001_initial... OK

* Y seguidamente tendremos que crear un usuario para administrar dicha base de datos.

        (django) alejandrogv@AlejandroGV:~/Escritorio/ASIR/IWEB/despliegue_python/django_tutorial$ python3 manage.py createsuperuser
        Username (leave blank to use 'alejandrogv'): admin
        Email address: tojandro@gmail.com
        Password: 
        Password (again): 
        The password is too similar to the username.
        This password is too short. It must contain at least 8 characters.
        This password is too common.
        Bypass password validation and create user anyway? [y/N]: y
        Superuser created successfully.

* Ahora ejecutaremos el servidor y entraremos en la zona de admin para comprobar su funcionamiento.

        (django) alejandrogv@AlejandroGV:~/Escritorio/ASIR/IWEB/despliegue_python/django_tutorial$ python manage.py runserver

![admin](/despliegue_python/1.png)

![admin](/despliegue_python/2.png)

* Crearemos dos preguntas con posibles respuestas.

![pregunta1](/despliegue_python/3.png)

![pregunta2](/despliegue_python/4.png)

![preguntas](/despliegue_python/5.png)

* Comprobaremos que funciona la url `/polls`

![polls](/despliegue_python/6.png)
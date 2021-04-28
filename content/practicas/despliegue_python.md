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

### ENTORNO DE DESARROLLO.

* Pasemos al entorno de desarrollo, el cual será una maquina que tendremos en nuestro cloud. El primer paso en la misma será instalar los siguiente paquetes.

        debian@python:~$ sudo apt-get install apache2

        debian@python:~$ sudo apt-get install libapache2-mod-wsgi-py3

* Copiaremos nuestro repositorio con la aplicación y la guardaremos en el que se convertirá en nuestro DocumentRoot.

        debian@python:~$ git clone https://github.com/alepeteporico/django_tutorial.git

        debian@python:~$ sudo mv django_tutorial/ /var/www/django/

* Seguidamente crearemos un entorno virtual con python para instalar las dependencias de nuestra aplicación, tal como hicimos anteriormente en el entorno de prueba.

        debian@python:~$ python3 -m venv django

        (django) debian@python:~$ pip install -r /var/www/django/django_tutorial/requirements.txt 
        Collecting asgiref==3.3.0 (from -r /var/www/django/django_tutorial/requirements.txt (line 1))
          Downloading https://files.pythonhosted.org/packages/c0/e8/578887011652048c2d273bf98839a11020891917f3aa638a0bc9ac04d653/asgiref-3.3.0-py3-none-any.whl
        Collecting Django==3.1.3 (from -r /var/www/django/django_tutorial/requirements.txt (line 2))
          Downloading https://files.pythonhosted.org/packages/7f/17/16267e782a30ea2ce08a9a452c1db285afb0ff226cfe3753f484d3d65662/Django-3.1.3-py3-none-any.whl (7.8MB)
            100% |████████████████████████████████| 7.8MB 115kB/s 
        Collecting pytz==2020.4 (from -r /var/www/django/django_tutorial/requirements.txt (line 3))
          Downloading https://files.pythonhosted.org/packages/12/f8/ff09af6ff61a3efaad5f61ba5facdf17e7722c4393f7d8a66674d2dbd29f/pytz-2020.4-py2.py3-none-any.whl (509kB)
            100% |████████████████████████████████| 512kB 694kB/s 
        Collecting sqlparse==0.4.1 (from -r /var/www/django/django_tutorial/requirements.txt (line 4))
          Downloading https://files.pythonhosted.org/packages/14/05/6e8eb62ca685b10e34051a80d7ea94b7137369d8c0be5c3b9d9b6e3f5dae/sqlparse-0.4.1-py3-none-any.whl (42kB)
            100% |████████████████████████████████| 51kB 1.1MB/s 
        Installing collected packages: asgiref, pytz, sqlparse, Django
        Successfully installed Django-3.1.3 asgiref-3.3.0 pytz-2020.4 sqlparse-0.4.1

* A parte, instalaremos unos módulos que le permitirán a python trabajar con mysql.

        (django) debian@python:~$ pip install mysql-connector-python
        debian@python:~$ sudo apt-get install python3-mysqldb

* Accederemos a la mysql y crearemos una base de datos y un usuario que tendrá permisos sobre esta base de datos.

        (django) debian@python:~$ sudo mysql -u root -p

        MariaDB [(none)]> CREATE DATABASE django_bbdd;
        Query OK, 1 row affected (0.007 sec)

        MariaDB [(none)]> CREATE USER 'usuario'@'localhost' IDENTIFIED BY 'usuario';
        Query OK, 0 rows affected (0.010 sec)

        MariaDB [(none)]> GRANT ALL PRIVILEGES ON django_bbdd.* TO 'usuario'@'localhost';
        Query OK, 0 rows affected (0.001 sec)

* El siguiente paso será modificar el archivo de configuración de django donde teníamos la configuración de la base de datos, veamos como quedaría nuestra configuración:

        DATABASES = {
            'default': {
                'ENGINE': 'mysql.connector.django',
                'NAME': 'django_bbdd',
                'USER': 'usuario',
                'PASSWORD': 'usuario',
                'HOST': 'localhost',
                'PORT': '3306',
            }
        }

* A parte, en este fichero tendremos que especificar el nombre de dominio por el que vamos a acceder a la aplicación, esto lo configuraremos mas tarde.

        ALLOWED_HOSTS = ['www.alegvdjango.es']

* Migramos la base de datos.

        (django) root@python:/var/www/django_tutorial# python3 manage.py migrate
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

* Como hicimos anteriormente crearemos un usuario.

        (django) root@python:/var/www/django_tutorial# python3 manage.py createsuperuser
        Username (leave blank to use 'root'): admin
        Email address: tojandro@gmail.com	
        Password: 
        Password (again): 
        The password is too similar to the username.
        This password is too short. It must contain at least 8 characters.
        This password is too common.
        Bypass password validation and create user anyway? [y/N]: y
        Superuser created successfully.

* Ahora crearemos un VirtualHost que tendrá la siguiente configuración:

        <VirtualHost *:80>

                ServerName www.alegvdjango.es 

                ServerAdmin webmaster@localhost
                WSGIDaemonProcess flask_temp user=www-data group=www-data processes=1 threads=5 python-path$
                WSGIScriptAlias / /var/www/django_tutorial/django_tutorial/wsgi.py
                DocumentRoot /var/www/html

                Alias /static/ /var/www/django_tutorial/static/

                <Directory /srv/django_tutorial>
                        WSGIProcessGroup flask_temp
                        WSGIApplicationGroup %{GLOBAL}
                        Require all granted
                </Directory>

                ErrorLog ${APACHE_LOG_DIR}/error.log
                CustomLog ${APACHE_LOG_DIR}/access.log combined

        </VirtualHost>

* Creamos las carpetas para el contenido estático que tendremos que copiar de los directorios que veremos a continuación:

        (django) root@python:/var/www/django_tutorial# mkdir -p static/{admin,polls}

        (django) root@python:/var/www/django_tutorial# cp -r /home/debian/django/lib/python3.7/site-packages/django/contrib/admin/static/admin/* static/admin/
        (django) root@python:/var/www/django_tutorial# cp -r polls/static/polls/* static/polls/

* añadiremos al `/etc/hosts` de nuestra anfitriona la dirección de nuestra aplicación y comprobaremos su funcionamiento.


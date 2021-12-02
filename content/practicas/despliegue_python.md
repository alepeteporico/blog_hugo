+++
title = "Despliegue de una aplicación python"
description = ""
tags = [
    "IWEB"
]
date = "2021-11-16"
menu = "main"
+++

## Vamos a desarrollar la aplicación del tutorial de django 3.1. Vamos a configurar tu equipo como entorno de desarrollo para trabajar con la aplicación.

------------------------------------------------------------------------------------------------

* Realizamos un fork de la aplicación añadiendola a nuestros repositorios y seguidamente lo clonaremos en nuestra maquina:

~~~
alejandrogv@AlejandroGV:~/Escritorio/ASIR/IWEB/despliegue_python$ git clone git@github.com:alepeteporico/django_tutorial.git
~~~

* Crearemos el entorno virtual donde instalaremos las dependencias necesarias para hacer funcionar nuestra aplicación.

~~~
alejandrogv@AlejandroGV:~/Escritorio/ASIR/IWEB$ python3 -m venv django

(django) alejandrogv@AlejandroGV:~/Escritorio/ASIR/IWEB$ pip install -r despliegue_python/django_tutorial/requirements.txt
~~~

* En el fichero settings.py podremos comprobar con que base de datos vamos a trabajar. Efectivamente, es una base de datos sqlite con el nombre db.sqlite3

~~~
(django) alejandrogv@AlejandroGV:~/Escritorio/ASIR/IWEB/despliegue_python/django_tutorial$ cat django_tutorial/settings.py

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}
~~~

* Crearemos la base de datos.

~~~
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
~~~

* Y seguidamente tendremos que crear un usuario para administrar dicha base de datos.

~~~
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
~~~

* Ahora ejecutaremos el servidor y entraremos en la zona de admin para comprobar su funcionamiento.

(django) alejandrogv@AlejandroGV:~/Escritorio/ASIR/IWEB/despliegue_python/django_tutorial$ python3 manage.py runserver

![admin](/despliegue_python/1.png)

![admin](/despliegue_python/2.png)

* Crearemos dos preguntas con posibles respuestas.

![pregunta1](/despliegue_python/3.png)

![pregunta2](/despliegue_python/4.png)

![preguntas](/despliegue_python/5.png)

* Comprobaremos que funciona la url `/polls`

![polls](/despliegue_python/6.png)

### ENTORNO DE PRODUCCIÓN.

* Copiaremos nuestro repositorio con la aplicación y la guardaremos en el que se convertirá en nuestro DocumentRoot.

~~~
debian@mrrobot:~$ git clone https://github.com/alepeteporico/django_tutorial.git

debian@mrrobot:~$ sudo mv django_tutorial/ /var/www/
~~~

* Seguidamente crearemos un entorno virtual con python para instalar las dependencias de nuestra aplicación, tal como hicimos anteriormente en el entorno de prueba.

~~~
debian@mrrobot:~$ python3 -m venv entornos/django

(django) debian@mrrobot:~$ pip install -r /var/www/django/requirements.txt 
Collecting Django
  Downloading Django-3.2.9-py3-none-any.whl (7.9 MB)
     |████████████████████████████████| 7.9 MB 7.7 MB/s 
Collecting pytz
  Downloading pytz-2021.3-py2.py3-none-any.whl (503 kB)
     |████████████████████████████████| 503 kB 14.8 MB/s 
Collecting sqlparse>=0.2.2
  Downloading sqlparse-0.4.2-py3-none-any.whl (42 kB)
     |████████████████████████████████| 42 kB 2.2 MB/s 
Collecting asgiref<4,>=3.3.2
  Downloading asgiref-3.4.1-py3-none-any.whl (25 kB)
Installing collected packages: sqlparse, pytz, asgiref, Django
Successfully installed Django-3.2.9 asgiref-3.4.1 pytz-2021.3 sqlparse-0.4.2
~~~

* A parte, instalaremos unos módulos y dependencias que le permitirán a python trabajar con mysql.

~~~
(django) debian@mrrobot:~$ sudo apt-get install python3-dev default-libmysqlclient-dev build-essential
(django) debian@mrrobot:~$ pip install mysqlclient
~~~

* Accederemos a la mysql y crearemos una base de datos y un usuario que tendrá permisos sobre esta base de datos.

~~~
(django) debian@mrrobot:~$ sudo mysql -u root -p

MariaDB [(none)]> CREATE DATABASE django_bbdd;
Query OK, 1 row affected (0.007 sec)

MariaDB [(none)]> CREATE USER 'usuario'@'localhost' IDENTIFIED BY 'usuario';
Query OK, 0 rows affected (0.010 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON django_bbdd.* TO 'usuario'@'localhost';
Query OK, 0 rows affected (0.001 sec)
~~~

* El siguiente paso será modificar el fichero de configuración de django donde teníamos la configuración de la base de datos llamado `settings.py`, veamos como quedaría nuestra configuración:

~~~
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
~~~

* A parte, en este fichero tendremos que especificar el nombre de dominio por el que vamos a acceder a la aplicación, esto lo configuraremos mas tarde.

~~~
ALLOWED_HOSTS = ['www.alegvdjango.site']
~~~

* Migramos la base de datos.

~~~
(django) root@mrrobot:/var/www/django_tutorial# python3 manage.py migrate
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
~~~

* Como hicimos anteriormente crearemos un usuario.

~~~
(django) root@mrrobot:/var/www/django_tutorial# python3 manage.py createsuperuser
Username (leave blank to use 'root'): admin
Email address: tojandro@gmail.com
Password: 
Password (again): 
The password is too similar to the username.
This password is too short. It must contain at least 8 characters.
This password is too common.
Bypass password validation and create user anyway? [y/N]: y
Superuser created successfully.
~~~

* Crearemos una unidad de systemd con el siguiente contenido:

~~~
[Unit]
Description=django_aplicacion
After=network.target

[Install]
WantedBy=multi-user.target

[Service]
User=www-data
Group=www-data
Restart=always

ExecStart=/home/debian/entornos/django/bin/gunicorn -w 2 -b :8080 wsgi:application
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s TERM $MAINPID

WorkingDirectory=/var/www/django_tutorial/django_tutorial
Environment=PYTHONPATH='/var/www/django_tutorial/django_tutorial:/home/debian/entornos/django/lib/python3.9/site-packages'

PrivateTmp=true
~~~

* Ahora crearemos un VirtualHost que tendrá la siguiente configuración:

~~~
server

{

    listen 80;

    server_name django.alejandrogv.site;

    index index.php index.html index.htm default.php default.htm default.html;

    root /var/www/django_tutorial;

    #path_to_your_directory

    # Forbidden files or directories

    location ~ ^/(\.user.ini|\.htaccess|\.git|\.svn|\.project|LICENSE|README.md)

    {

        return 404;

    }

     location /static {

        autoindex on;

        alias /var/www/django_tutorial/static/ ;

    }

    location /

{

    proxy_pass http://127.0.0.1:8000;

}

}
~~~

* Creamos las carpetas para el contenido estático que tendremos que copiar de los directorios que veremos a continuación:

~~~
root@mrrobot:/var/www/django_tutorial# mkdir -p static/{admin,polls}

root@mrrobot:/var/www/django_tutorial# cp -r /home/debian/entornos/django/lib/python3.9/site-packages/django/contrib/admin/static/admin/* static/admin/
root@mrrobot:/var/www/django_tutorial# cp -r polls/static/polls/* static/polls/
~~~

* añadiremos al `/etc/hosts` de nuestra anfitriona la dirección de nuestra aplicación y comprobaremos su funcionamiento.

![exito](/despliegue_python/7.png)

* Podemos comprobar que nuestro sitio hace uso de las hojas de estilo

![hojas estilo](/despliegue_python/8.png)

* Para evitar que se pueda mostrar información sensible configuramos el fichero settings.py y quitamos el debug.

        DEBUG = False

### Modificación de la aplicación.

* Primero realizaremos estos cambios en el entorno de desarrollo, el primero de ellos será que nuestro nombre aparezca en la pagina de admin. Para ello modificaremos el fichero `django_tutorial/polls/templates/polls/index.html`.

        {% load static %}

        <link rel="stylesheet" type="text/css" href="{% static 'polls/style.css' %}">

        <h1>Alejandro Gutiérrez Valencia<h1>

        {% if latest_question_list %}
            <ul>
            {% for question in latest_question_list %}
            <li><a href="{% url 'polls:detail' question.id %}">{{ question.question_text }}</a></li>
            {% endfor %}
            </ul>
        {% else %}
            <p>No polls are available.</p>
        {% endif %}

![nombre](/despliegue_python/8.png)

* Vamos a modificar la imagen que se ve de fondo en la aplicación, para ello modificamos el archivo `django/lib/python3.7/site-packages/django/contrib/admin/static/admin/css/base.css` y podemos por ejemplo cambiar el color de fondo

        body {
            margin: 0;
            padding: 0;
            font-size: 14px;
            font-family: "Roboto","Lucida Grande","DejaVu Sans","Bitstream Vera Sans",Verdana,Arial,sans-serif;
            color: #333;
            background: #ebe10d;
        }

![fondo](/despliegue_python/10.png)

* Añadiremos una nueva tabla en la base de datos, para ello añadimos el siguiente modelo a `polls/models.py`

          class Categoria(models.Model):
          	Abr = models.CharField(max_length=4)
          	Nombre = models.CharField(max_length=50)

          	def __str__(self):
          		return self.Abr+" - "+self.Nombre 

* El siguiente paso es crear una nueva migración:

        (django) alejandrogv@AlejandroGV:~/django_tutorial$ python3 manage.py makemigrations
        Migrations for 'polls':
          polls/migrations/0002_categoria.py
            - Create model Categoria

* Ahora en `polls/admin.py` debemos añadir el nuevo modelo.

        from .models import Choice, Question, Categoria

        admin.site.register(Categoria)

* Y migramos por supuesto.

        (django) alejandrogv@AlejandroGV:~/django_tutorial$ python3 manage.py migrate
        Operations to perform:
          Apply all migrations: admin, auth, contenttypes, polls, sessions
        Running migrations:
          Applying polls.0002_categoria... OK

![fondo](/despliegue_python/11.png)
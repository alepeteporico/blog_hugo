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


### Entorno de producción

* Clonamos nuevamente el repositorio, esta vez en nuestra VPS.

~~~
debian@mrrobot:~/aplicaciones$ git clone https://github.com/alepeteporico/django_tutorial.git
~~~

* Como hicimos anteriormente, crearemos un entorno virtual donde instalaremos las dependencias necesarias y como novedad debemos instalar el paquete que permitirá a python trabajar con mysql.

~~~
pip install mysqlclient
~~~

* Nos dirigimos a mariadb donde crearemos una base de datos y un usuario con privilegios sobre ella.

~~~
MariaDB [(none)]> create database django_tutorial;

MariaDB [(none)]> grant all on django_tutorial.* to 'admin'@'%' identified by 'admin' with grant option;
~~~

* Ahora configuramos el fichero `settings,py` de la aplicación para añadir esta base de datos.

~~~
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'django_tutorial',
        'USER': 'admin',
        'PASSWORD': 'admin',
        'HOST': 'db.alejandrogv.site',
        'PORT': '3306',
    }
}
~~~

* Realizamos la migración.

~~~
(django) debian@mrrobot:~/aplicaciones/django_tutorial$ python3 manage.py migrate
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

* Y creamos un super usuario.

~~~
(django) debian@mrrobot:~/aplicaciones/django_tutorial$ python3 manage.py createsuperuser
Username (leave blank to use 'debian'): admin
Email address: tojandro@gmail.com
Password: 
Password (again):
Bypass password validation and create user anyway? [y/N]: y
Superuser created successfully.
~~~

* Usaremos gunicorn como servidor de aplicaciones python, para ello debemos instalarlo.

~~~
pip install gunicorn
~~~

* Vamos a crear una unidad de systemd para poder tener encendida nuestra aplicación continuamente.

~~~
[Unit]
Description=django_tutorial
After=network.target

[Install]
WantedBy=multi-user.target

[Service]
User=www-data
Group=www-data
Restart=always

ExecStart=/home/debian/entornos/django/bin/gunicorn django_tutorial.wsgi
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s TERM $MAINPID

WorkingDirectory=/home/debian/aplicaciones/django_tutorial
Environment=PYTHONPATH='/home/debian/aplicaciones/django_tutorial:/home/debian/entornos/django/lib/python3.9/site-packages'

PrivateTmp=true
~~~

* Creamos el virtual host en nginx.

~~~
server {
        listen 80;
        listen [::]:80;

        root /home/debian/aplicaciones/django_tutorial;

        index index.html index.php index.htm index.nginx-debian.html;

        server_name django.alejandrogv.site;

        location / {
                proxy_pass http://localhost:8000;
                include proxy_params;
        }

        location /static {
                alias /home/debian/entornos/django/lib/python3.9/site-packages/django/contrib/admin/static;
        }
}
~~~

* Creamos el enlace a sites-enabled.

~~~
sudo ln -s /etc/nginx/sites-available/django_tutorial.conf /etc/nginx/sites-enabled/
~~~

* Debemos añadir el host de acceso a la línea de allowed host en el fichero `settings.py` de la aplicación.

~~~
ALLOWED_HOSTS = ['django.alejandrogv.site']
~~~

* Comprobamos que podemos acceder.

![acceso](/despliegue_python/12.png)

* Ahora para que no aparezcan errores de ejecución mientras se está sirviendo la aplicación cambiamos la línea de debug a false en el fichero `settings.py` y reiniciamos nginx y la unidad de systemdb que creamos.

~~~
DEBUG = False
~~~

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
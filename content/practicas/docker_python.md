+++
title = "Implantación de aplicaciones web Python en docker"
description = ""
tags = [
    "IWEB"
]
date = "2022-06-10"
menu = "main"
+++

## Puntos a tener el cuenta.

* La aplicación debe guardar los datos en una base de datos mariadb.

* La aplicación se podrá configurar para indicar los parámetros de conexión a la base de datos: usuario, contraseña, host y base de datos.

* La aplicación deberá tener creado un usuario administrador para el acceso.

## Aplicación

### Crea una imagen docker para poder desplegar un contenedor con la aplicación. La imagen la puedes hacer desde una imagen base o desde la imagen oficial de python.

* Debemos crear una red que usaremos en nuestro entorno de desarrollo.

~~~
alejandrogv@AlejandroGV:~$ docker network create django
~~~

* Creamos el contenedor de base de datos con las variables correspondiente.

~~~
alejandrogv@AlejandroGV:~$ docker run -d --name mariadb -v vol_polls:/var/lib/mysql --network django -e MARIADB_ROOT_PASSWORD=root -e MARIADB_USER=django -e MARIADB_PASSWORD=django -e MARIADB_DATABASE=django mariadb
~~~

* La aplicación que usaremos será de la django que usamos en una práctica anterior, vamos a acceder a está aplicación y modificar el fichero `settings.py` añadiendo y modificando las siguientes líneas para que nuestra aplicación pueda leer las variables de entorno.

~~~
import os
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
~~~

~~~
ALLOWED_HOSTS = [os.environ.get("ALLOWED_HOSTS")]
~~~

~~~
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': os.environ.get("DB"),
        'USER': os.environ.get('USER'),
        'PASSWORD': os.environ.get("PASSW"),
        'HOST': os.environ.get('HOST'),
        'PORT': '3306',
    }
}
~~~

~~~
STATIC_ROOT = os.path.join(BASE_DIR, 'static')

CSRF_TRUSTED_ORIGINS = ['http://*.alejandrogv.site','http://*.127.0.0.1','https://*.alejandrogv.site','https://*.127.0.0.1']
~~~

* Creamos un DockerFile.

~~~
FROM python:3
WORKDIR /usr/src/app
MAINTAINER Alejandro Gutierrez Valencia "tojandro@gmail.com"
RUN pip install django mysqlclient && mkdir static
ENV ALLOWED_HOSTS=*
ENV HOST=mariadb
ENV USER=django
ENV PASSW=django
ENV DB=django
ENV DJANGO_SUPERUSER_PASSWORD=admin
ENV DJANGO_SUPERUSER_USERNAME=admin
ENV DJANGO_SUPERUSER_EMAIL=admin@example.org
ADD django_tutorial/ /usr/src/app
ADD django.sh /usr/src/app/
RUN chmod +x /usr/src/app/django.sh
CMD ["/usr/src/app/django.sh"]
~~~

* Debemos crear el script al que hacemos referencia, que se encargará de compilar e iniciar la aplicación.

~~~
! /bin/sh

sleep 30
python3 manage.py makemigrations
python3 manage.py migrate
python3 manage.py createsuperuser --noinput --username DJANGO_SUPERUSER_USERNAME
python3 manage.py collectstatic --no-input
python3 manage.py runserver 0.0.0.0:8006
~~~

* Creamos el contenedor.

~~~
alejandrogv@AlejandroGV:~/Escritorio/ASIR/IWEB/docker_python$ docker build -t alejandrogv/django .
Sending build context to Docker daemon  60.42kB
Step 1/15 : FROM python:3
 ---> 6bb8bdb609b6
Step 2/15 : WORKDIR /usr/src/app
 ---> Using cache
 ---> fe5838197e59
Step 3/15 : MAINTAINER Alejandro Gutierrez Valencia "tojandro@gmail.com"
 ---> Using cache
 ---> b3e3fdd7e70b
Step 4/15 : RUN pip install django mysqlclient && git clone https://github.com/alepeteporico/django_tutorial.git /usr/src/app && mkdir static
 ---> Using cache
 ---> 30b52eaadf3c
Step 5/15 : ENV ALLOWED_HOSTS=*
 ---> Using cache
 ---> e98020fb34a3
Step 6/15 : ENV HOST=mariadb
 ---> Using cache
 ---> 6528caa7033a
Step 7/15 : ENV USER=django
 ---> Running in c20c36842a65
Removing intermediate container c20c36842a65
 ---> 3aebfe5ce092
Step 8/15 : ENV PASSW=django
 ---> Running in 18021b977e29
Removing intermediate container 18021b977e29
 ---> 4003af8faf47
Step 9/15 : ENV BD=django
 ---> Running in 9535e60ccd63
Removing intermediate container 9535e60ccd63
 ---> 8c5f8b458309
Step 10/15 : ENV DJANGO_SUPERUSER_PASSWORD=admin
 ---> Running in a89d38dd87f0
Removing intermediate container a89d38dd87f0
 ---> c9ad0e527207
Step 11/15 : ENV DJANGO_SUPERUSER_USERNAME=admin
 ---> Running in 3f9db467ec52
Removing intermediate container 3f9db467ec52
 ---> 09c4715adac6
Step 12/15 : ENV DJANGO_SUPERUSER_EMAIL=admin@example.org
 ---> Running in b6e67175dddf
Removing intermediate container b6e67175dddf
 ---> 3e0e16d8a939
Step 13/15 : ADD django.sh /usr/src/app/
 ---> 5c3e39ef9c80
Step 14/15 : RUN chmod +x /usr/src/app/django.sh
 ---> Running in eadd9db7fd7d
Removing intermediate container eadd9db7fd7d
 ---> 4b375f582220
Step 15/15 : CMD ["/usr/src/app/django.sh"]
 ---> Running in 577dee5aa02c
Removing intermediate container 577dee5aa02c
 ---> c471330cec62
Successfully built c471330cec62
Successfully tagged alejandrogv/django:latest
~~~

* Creamos el docker-compose.

~~~
version: '3.1'
services:
  django-tutorial:
    container_name: django_tutorial
    image: alejandrogv/django
    restart: always
    environment:
      ALLOWED_HOSTS: "*"
      HOST: bd_mariadb_django
      USER: django
      PASSW: django
      BD: django
      DJANGO_SUPERUSER_PASSWORD: admin
      DJANGO_SUPERUSER_USERNAME: admin
      DJANGO_SUPERUSER_EMAIL: admin@example.org
    ports:
      - 8096:8006
    depends_on:
      - db_django
  db_django:
    container_name: bd_mariadb_django
    image: mariadb
    restart: always
    environment:
      MARIADB_ROOT_PASSWORD: root
      MARIADB_DATABASE: django
      MARIADB_USER: django
      MARIADB_PASSWORD: django
    volumes:
      - mariadb_data_django:/var/lib/mysql
volumes:
    mariadb_data_django:
~~~

* Iniciamos los contenedores.

~~~
alejandrogv@AlejandroGV:~/Escritorio/ASIR/IWEB/docker_python$ docker-compose up -d
~~~

* Comprobamos que podemos acceder a la aplicación y a la zona de administración.

![admin](/docker_python/1.png)

![admin](/docker_python/2.png)

* Una vez funcionando en nuestro entorno de desarrollo nos dirigimos a producción donde clonaremos este repositorio, crearemos un nuevo registro cname y crearemos un certificado para nuestro nuevo sitio.

~~~
debian@mrrobot:~/docker_python$ sudo certbot certonly --standalone -d djangotutorial.alejandrogv.site
~~~

* Creamos la imagen y los contenedores.

~~~
debian@mrrobot:~/docker_python$ docker build -t alejandrogv/django .

debian@mrrobot:~/docker_python$ docker-compose up -d
~~~

* Ahora crearemos nuestro virtualhost en nginx que actuara de proxy inverso

~~~
server {
        listen 80;
        listen [::]:80;

        server_name djangotutorial.alejandrogv.site;

        return 301 https://$host$request_uri;
}

server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;

        ssl    on;
        ssl_certificate /etc/letsencrypt/live/djangotutorial.alejandrogv.site/fullchain.pem;
        ssl_certificate_key     /etc/letsencrypt/live/djangotutorial.alejandrogv.site/privkey.pem;

        index index.html index.php index.htm index.nginx-debian.html;

        server_name djangotutorial.alejandrogv.site;

        location / {
                proxy_pass http://localhost:8096;
                include proxy_params;
        }
}
~~~

* Comprobamos que podemos acceder.

![admin](/docker_python/3.png)
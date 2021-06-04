+++
title = "Instalación de aplicación web python"
description = ""
tags = [
    "IWEB"
]
date = "2021-06-02"
menu = "main"
+++

* Vamos a crear el entorno virtual en el cual instalaremos Mezzanine.

        alejandrogv@AlejandroGV:~/entornos/mezzanine$ source despliegue/bin/activate
        (despliegue) alejandrogv@AlejandroGV:~/entornos/mezzanine$

* Ahora instalamos con pip mezzanine y creamos un proyecto.

        (despliegue) alejandrogv@AlejandroGV:~/proyecto$ pip install mezzanine
        (despliegue) alejandrogv@AlejandroGV:~/proyecto$ mezzanine-project cms

* Vamos a modificar uno de los ficheros que se ha generado `cms/settings.py` para usar la base de datos sqlite ya que estamos en el entorno de pruebas.

        DATABASES = {
            "default": {
                "ENGINE": "django.db.backends.sqlite3",
                "NAME": "",
                "USER": "",
                "PASSWORD": "",
                "HOST": "",
                "PORT": "",
            }
        }

* Hacemos una migración para generar las tablas de sqlite.

        (despliegue) alejandrogv@AlejandroGV:~/proyecto/cms$ python3 manage.py migrate

* También necesitaremos crear un usuario para poder gestionarla.

        (despliegue) alejandrogv@AlejandroGV:~/proyecto/cms$ python3 manage.py createsuperuser
        Username (leave blank to use 'alejandrogv'): admin
        Email address: tojandro@gmail.com
        Password: 
        Password (again): 
        Superuser created successfully.

* Ahora vamos a ejecutar el servidor.

        (despliegue) alejandrogv@AlejandroGV:~/proyecto/cms$ python3 manage.py runserver
                      .....
                  _d^^^^^^^^^b_
               .d''           ``b.
             .p'                `q.
            .d'                   `b.
           .d'                     `b.   * Mezzanine 4.3.1
           ::                       ::   * Django 1.11.29
          ::    M E Z Z A N I N E    ::  * Python 3.7.3
           ::                       ::   * SQLite 3.27.2
           `p.                     .q'   * Linux 4.19.0-16-amd64
            `p.                   .q'
             `b.                 .d'
               `q..          ..p'
                  ^q........p^
                      ''''

        Performing system checks...

        System check identified no issues (0 silenced).
        June 02, 2021 - 19:08:04
        Django version 1.11.29, using settings 'cms.settings'
        Starting development server at http://127.0.0.1:8000/
        Quit the server with CONTROL-C.

* Entramos desde localhost por el puerto 8000 y comprobamos que funciona.

![pagina](/python_openstack/1.png)

* Ahora nos loggeamos y vemos que podemos cambiar cosas como añadir paginas, cambiar titulos, etc...

![pagina](/python_openstack/2.png)

* Ya funciona en nuestro entorno de desarrolo, para migrar al entorno de producción haremos un backup.

        (despliegue) alejandrogv@AlejandroGV:~/proyecto/cms$ python3 manage.py dumpdata > backup.json

* Nos dirigimos a freston, donde añadiremos un registro nuevo en el DNS para nuestro nuevo sitio.

#### interna

        dulcinea        IN      A       10.0.1.8
        sancho  IN      A       10.0.1.6
        quijote IN      A       10.0.2.5
        freston IN      A       10.0.1.9
        www     IN      CNAME   quijote
        bd      IN      CNAME   sancho
        python  IN      CNAME   quijote

#### externa

        dulcinea        IN      A       172.22.200.87
        www     IN      CNAME   dulcinea
        python  IN      CNAME   dulcinea

#### dmz

        dulcinea        IN      A       10.0.2.10
        sancho  IN      A       10.0.1.6
        quijote IN      A       10.0.2.5
        freston IN      A       10.0.1.9
        www     IN      CNAME   quijote
        bd      IN      CNAME   sancho
        python  IN      CNAME   quijote

* Ahora en sancho vamos a crear una base de datos y un usuario remoto que la administrará.

        MariaDB [(none)]> CREATE DATABASE mezzanine;
        Query OK, 1 row affected (0.023 sec)

        MariaDB [(none)]> GRANT USAGE ON *.* TO 'quijote'@'10.0.2.5' IDENTIFIED BY 'alegv';
        Query OK, 0 rows affected (0.041 sec)

        MariaDB [(none)]> GRANT ALL PRIVILEGES ON mezzanine.* to 'ale'@'10.0.2.5';
        Query OK, 0 rows affected (0.009 sec)

* Vamos a instalar las dependencias necesarias en quijote.

        [centos@quijote ~]$ sudo dnf install virtualenv git python3-mod_wsgi gcc python3-devel mysql-devel

* Como hicimos anteriormente crearemos el entorno donde instalaremos las dependencias de la aplicación.

        [centos@quijote virtualenv]$ python3 -m venv despliegue
        [centos@quijote virtualenv]$ source despliegue/bin/activate

* Una vez tengamos nuestra carpeta `cms` con todo el contenido incluido el backup en quijote instalamos las dependencias usando el fichero requirements.txt y algunos paquetes mas necesarios

        (despliegue) [centos@quijote cms]$ pip install -r requirements.txt
        (despliegue) [centos@quijote cms]$ pip install mysql-connector-python uwsgi mysqlclient

* Cambiaremos el fichero settings.py para que use la base de datos de mysql.

        DATABASES = {
            "default": {
                # Add "postgresql_psycopg2", "mysql", "sqlite3" or "oracle".
                "ENGINE": "django.db.backends.mysql",
                # DB name or path to database file if using sqlite3.
                "NAME": "mezzanine",
                # Not used with sqlite3.
                "USER": "quijote",
                # Not used with sqlite3.
                "PASSWORD": "alegv",
                # Set to empty string for localhost. Not used with sqlite3.
                "HOST": "bd.alegv.gonzalonazareno.org",
                # Set to empty string for default. Not used with sqlite3.
                "PORT": "",
            }
        }

* Migramos para que use la nueva base de datos.

        (despliegue) [centos@quijote cms]$ python3 manage.py migrate

* 
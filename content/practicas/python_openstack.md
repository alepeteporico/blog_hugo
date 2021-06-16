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

![pagina](/python_openstack/3.png)

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

        MariaDB [(none)]> GRANT USAGE ON *.* TO 'ale'@'10.0.2.5' IDENTIFIED BY 'ale';
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
        Operations to perform:
          Apply all migrations: admin, auth, blog, conf, contenttypes, core, django_comments, forms, galleries, generic, pages, redirects, sessions, sites, twitter
        Running migrations:
          Applying contenttypes.0001_initial... OK
          Applying auth.0001_initial... OK
          Applying admin.0001_initial... OK
          Applying admin.0002_logentry_remove_auto_add... OK
          Applying contenttypes.0002_remove_content_type_name... OK
          Applying auth.0002_alter_permission_name_max_length... OK
          Applying auth.0003_alter_user_email_max_length... OK
          Applying auth.0004_alter_user_username_opts... OK
          Applying auth.0005_alter_user_last_login_null... OK
          Applying auth.0006_require_contenttypes_0002... OK
          Applying auth.0007_alter_validators_add_error_messages... OK
          Applying auth.0008_alter_user_username_max_length... OK
          Applying sites.0001_initial... OK
          Applying blog.0001_initial... OK
          Applying blog.0002_auto_20150527_1555... OK
          Applying blog.0003_auto_20170411_0504... OK
          Applying conf.0001_initial... OK
          Applying core.0001_initial... OK
          Applying core.0002_auto_20150414_2140... OK
          Applying django_comments.0001_initial... OK
          Applying django_comments.0002_update_user_email_field_length... OK
          Applying django_comments.0003_add_submit_date_index... OK
          Applying pages.0001_initial... OK
          Applying forms.0001_initial... OK
          Applying forms.0002_auto_20141227_0224... OK
          Applying forms.0003_emailfield... OK
          Applying forms.0004_auto_20150517_0510... OK
          Applying forms.0005_auto_20151026_1600... OK
          Applying forms.0006_auto_20170425_2225... OK
          Applying galleries.0001_initial... OK
          Applying galleries.0002_auto_20141227_0224... OK
          Applying generic.0001_initial... OK
          Applying generic.0002_auto_20141227_0224... OK
          Applying generic.0003_auto_20170411_0504... OK
          Applying pages.0002_auto_20141227_0224... OK
          Applying pages.0003_auto_20150527_1555... OK
          Applying pages.0004_auto_20170411_0504... OK
          Applying redirects.0001_initial... OK
          Applying sessions.0001_initial... OK
          Applying sites.0002_alter_domain_unique... OK
          Applying twitter.0001_initial... OK

* Ahora vamos a importar los datos de la base de datos que teniamos en el entorno de desarrollo.

        (despliegue) [centos@quijote cms]$ python3 manage.py loaddata backup.json
        Installed 128 object(s) from 1 fixture(s)

* Ahora vamos a generar el contenido estático

        (despliegue) [centos@quijote cms]$ python manage.py collectstatic

* Ahora moveremos la carpeta con todo el contenido a /var/www/ allí crearemos una carpeta de log dentro de la misma y un archivo llamado `uwsgi.ini` que hará que nuestra aplicación escuche por el puerto 8080.

        [uwsgi]
        http = :8080
        chdir = /var/www/mezzanine 
        wsgi-file = /var/www/mezzanine/cms/wsgi.py
        processes = 4
        threads = 2

* seguidamente crearemos nuestro virtualhost.

        <VirtualHost *:80>
            ServerName python.alegv.gonzalonazareno.org
            DocumentRoot /var/www/mezzanine/

            WSGIDaemonProcess mysite user=apache group=apache processes=1 threads=5 python-path=/var/www/mezzanine
            WSGIScriptAlias / /var/www//mezzanine/cms/wsgi.py

            <Directory /var/www/mezzanine>
                  WSGIProcessGroup mysite
                  WSGIApplicationGroup %{GLOBAL}
                  Require all granted
            </Directory>

            ProxyPass /static !
            ProxyPass / http://127.0.0.1:8080/
            ProxyPassReverse / http://127.0.0.1:8080/
        
        </VirtualHost>

* creamos el enlace simbólico y reiniciamos el servicio.

        (despliegue) [root@quijote ~]# ln -s /etc/httpd/sites-available/mezzanine.conf /etc/httpd/sites-enabled/
        (despliegue) [root@quijote ~]# systemctl restart httpd

* Vamos a ejecutarlo.

        (despliegue) [root@quijote mezzanine]# uwsgi --ini uwsgi.ini
        [uWSGI] getting INI configuration from uwsgi.ini
        *** Starting uWSGI 2.0.19.1 (64bit) on [Wed Jun 16 09:33:45 2021] ***
        compiled with version: 8.3.1 20191121 (Red Hat 8.3.1-5) on 15 June 2021 14:37:47
        os: Linux-4.18.0-240.22.1.el8_3.x86_64 #1 SMP Thu Apr 8 19:01:30 UTC 2021
        nodename: quijote.alegv.gonzalonazareno.org
        machine: x86_64
        clock source: unix
        detected number of CPU cores: 1
        current working directory: /var/www/mezzanine
        detected binary path: /root/virtualenv/despliegue/bin/uwsgi
        !!! no internal routing support, rebuild with pcre support !!!
        uWSGI running as root, you can use --uid/--gid/--chroot options
        *** WARNING: you are running uWSGI as root !!! (use the --uid flag) *** 
        chdir() to /var/www/mezzanine
        *** WARNING: you are running uWSGI without its master process manager ***
        your processes number limit is 1627
        your memory page size is 4096 bytes
        detected max file descriptor number: 1024
        lock engine: pthread robust mutexes
        thunder lock: disabled (you can enable it with --thunder-lock)
        uWSGI http bound on :8080 fd 7
        spawned uWSGI http 1 (pid: 23493)
        uwsgi socket 0 bound to TCP address 127.0.0.1:36921 (port auto-assigned) fd 6
        uWSGI running as root, you can use --uid/--gid/--chroot options
        *** WARNING: you are running uWSGI as root !!! (use the --uid flag) *** 
        Python version: 3.6.8 (default, Aug 24 2020, 17:57:11)  [GCC 8.3.1 20191121 (Red Hat 8.3.1-5)]
        Python main interpreter initialized at 0x1690cd0
        uWSGI running as root, you can use --uid/--gid/--chroot options
        *** WARNING: you are running uWSGI as root !!! (use the --uid flag) *** 
        python threads support enabled
        your server socket listen backlog is limited to 100 connections
        your mercy for graceful operations on workers is 60 seconds
        mapped 333504 bytes (325 KB) for 8 cores
        *** Operational MODE: preforking+threaded ***
        WSGI app 0 (mountpoint='') ready in 0 seconds on interpreter 0x1690cd0 pid: 23492 (default app)
        uWSGI running as root, you can use --uid/--gid/--chroot options
        *** WARNING: you are running uWSGI as root !!! (use the --uid flag) *** 
        *** uWSGI is running in multiple interpreter mode ***
        spawned uWSGI worker 1 (pid: 23492, cores: 2)
        spawned uWSGI worker 2 (pid: 23495, cores: 2)
        spawned uWSGI worker 3 (pid: 23496, cores: 2)
        spawned uWSGI worker 4 (pid: 23497, cores: 2)

* Aunque funciona, por alguna razon cuando intento entrar se abre el gestiona del instituto.

![fallo](/python_openstack/5.png)
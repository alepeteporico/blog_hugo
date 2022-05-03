+++
title = "Desplegando aplicaciones flask con apache2 + mod_wsgi"
description = ""
tags = [
    "IWEB"
]
date = "2021-11-09"
menu = "main"
+++

* Creamos un entorno virtual y lo activamos:

~~~
alejandrogv@AlejandroGV:~/entornos$ python3 -m venv wsgi
alejandrogv@AlejandroGV:~/entornos$ source wsgi/bin/activate
~~~

* Vamos a instalar los paquetes necesarios

~~~
pip install flask redis
~~~

* Tenemos que instalar el módulo de apache para que wsgi funcione

~~~
sudo apt install libapache2-mod-wsgi-py3
~~~

* Clonamos el respositorio con la aplicación.

~~~
(wsgi) alejandrogv@AlejandroGV:~/Escritorio/ASIR/IWEB/wsgi$ git clone https://github.com/josedom24/guestbook.git
~~~

* Ahora creamos un fichero en el respositorio llamado `wsgi.py` dentro de la carpeta `app` donde añadiremos la siguiente línea:

~~~
from app import prog as application
~~~

* Creamos un virtual host con la siguiente configuración:

~~~
<VirtualHost *:80>

        ServerName www.guestbook.com
        ServerAdmin webmaster@localhost
        DocumentRoot /home/alejandrogv/Escritorio/ASIR/IWEB/wsgi/guestbook/app/

        WSGIDaemonProcess guestbook python-path=/home/vagrant/guestbook/app:/home/alejandrogv/entornos/wsgi/lib/python3.9/site-packages
        WSGIProcessGroup guestbook
        WSGIScriptAlias / /home/alejandrogv/Escritorio/ASIR/IWEB/wsgi/guestbook/app/wsgi.py process-group=guestbook
        <Directory /home/alejandrogv/Escritorio/ASIR/IWEB/wsgi/guestbook/app/>
                Require all granted
        </Directory>

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>
~~~

* Comprobamos su funcionamiento.

![tablas](/wsgi/1.png)
+++
title = "Desplegando aplicaciones flask con apache2 + uwsgi"
description = ""
tags = [
    "IWEB"
]
date = "2022-04-11"
menu = "main"
+++

* Tendremos nuestro entorno virtual donde debemos instalar los siguientes paquetes.

~~~
(ejercicio3) alejandrogv@AlejandroGV:~$ pip install flask uwsgi
~~~

* Clonamos la aplicación que instalaremos.

~~~
alejandrogv@AlejandroGV:~/Escritorio/ASIR/IWEB$ git clone https://github.com/josedom24/guestbook.git
~~~

* En este repositorio encontraremos una carpeta llamada app donde se alojará un fichero llamado `app.py` ahí debemos crear un fichero llamado `wsgi.py` con el siguiente contenido.

~~~
from app import prog as application
~~~

* Instalamos los paquetes del requirementes.txt que se aloja también la carpeta app.

~~~
pip install -r requirements.txt
~~~

* Una vez hecho esto podemos usar el siguiente comando para ejecutar la aplicación.

~~~
uwsgi --http :8082 --chdir /home/alejandrogv/Escritorio/ASIR/IWEB/guestbook/app/ --wsgi-file    wsgi.py --process 4 --threads 2 --master
~~~

![prueba](/apache_uwsgi/1.png)

* Pero en vez de tener que ejecutar este comando vamos a crear un fichero `.ini`.

~~~
[uwsgi]
http = :8082
chdir = /home/alejandrogv/Escritorio/ASIR/IWEB/guestbook/app/             
wsgi-file = wsgi.py
processes = 4
threads = 2
~~~

* Lo ejecutariamos con el siguiente comando.

~~~
uwsgi guestbook.ini
~~~

* Ahora crearemos una unidad de systemd, para poder ejecutar la aplicación. tendremos que crearla en la carpeta `/etc/systemd/system/`, lo llamaremos `uwsgi-guestbook.service`.

~~~
[Unit]
Description=uwsgi-guestbook
After=network.target

[Install]
WantedBy=multi-user.target

[Service]
User=www-data
Group=www-data
Restart=always

ExecStart=/home/alejandrogv/entornos/ejercicio3/bin/uwsgi /home/alejandrogv/Escritorio/ASIR/IWEB/guestbook/app/guestbook.ini
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s TERM $MAINPID

WorkingDirectory=/home/alejandrogv/Escritorio/ASIR/IWEB/guestbook/app/
Environment=PYTHONPATH='/home/alejandrogv/Escritorio/ASIR/IWEB/guestbook/app/:/home/alejandrogv/entornos/ejercicio3/lib/python3.9/site-packages'

PrivateTmp=true
~~~

* La habilitamos e inicializamos.

~~~
sudo systemctl enable uwsgi-guestbook.service
Created symlink /etc/systemd/system/multi-user.target.wants/uwsgi-guestbook.service → /etc/systemd/system/uwsgi-guestbook.service.

sudo systemctl start uwsgi-guestbook.service
~~~

* Creamos un virtualhost en apache tal que así:

~~~
<VirtualHost *:80>

        ServerName www.guestbook.com
        ServerAdmin webmaster@localhost
        DocumentRoot /home/alejandrogv/Escritorio/ASIR/IWEB/guestbook/app/
        ProxyPass / http://127.0.0.1:8082/
        ProxyPassReverse / http://127.0.0.1:8082/
        <Directory /home/alejandrogv/Escritorio/ASIR/IWEB/guestbook/app/>
                Require all granted
        </Directory>

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>
~~~

* Lo habilitamos y activamos 2 módulos de proxy necesarios.

~~~
a2ensite guestbook.conf

sudo a2enmod proxy proxy_http
~~~

* Después de reiniciar apache podemos comprobar que tenemos nuestra aplicación funcionando.

![prueba con apache](/apache_uwsgi/2.png)
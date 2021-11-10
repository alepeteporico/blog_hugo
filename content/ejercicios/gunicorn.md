+++
title = "Desplegando aplicaciones flask con apache2 + gunicorn"
description = ""
tags = [
    "IWEB"
]
date = "2021-11-09"
menu = "main"
+++

* Vamos a instalar este cms llamado gunicorn, para ello creamos un entorno virutal y lo instalamos:

~~~
(gunicorn) vagrant@cmsagv:~$ pip install gunicorn
~~~

* Vamos a instalar las dependencias del fichero requirements

~~~
(gunicorn) vagrant@cmsagv:~/guestbook/app$ pip install -r requirements.txt
~~~

* Ahora vamos a crear un virtualhost donde añadiremos el modulo de proxy inverso ya. Y moveremos el guestbook a /var/www/

~~~
<VirtualHost *:80>
        ServerName www.alegv-guestbook.com

        DocumentRoot /var/www/guestbook/app/

        ProxyPass / http://127.0.0.1:8080/

        ProxyPassReverse / http://127.0.0.1:8080/

        <Directory /var/www/guestbook/app/>
                Require all granted
        </Directory>

        ErrorLog /var/log/apache2/wsgi_error.log
        CustomLog /var/log/apache2/wsgi_access.log combined

</VirtualHost>
~~~

* Tenemos que activar en modulo de proxy inverso en apache2.

~~~
(gunicorn) vagrant@cmsagv:~$ sudo a2enmod proxy_http
~~~

* Pero no vamos a ejecutar a mano la aplicación, por ello vamos a crear una unidad systemd. Para esto primero crearemos el fichero `/etc/systemd/system/gunicorn-temperaturas.service` y le añadiremos el siguiente contenido:

~~~
[Unit]
Description=gunicorn-guestbook
After=network.target

[Install]
WantedBy=multi-user.target

[Service]
User=www-data
Group=www-data
Restart=always

ExecStart=/home/vagrant/gunicorn/bin/gunicorn -w 2 -b :8080 wsgi:application
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s TERM $MAINPID

WorkingDirectory=/var/www/guestbook/app
Environment=PYTHONPATH='/var/www/guestbook/app:/home/vagrant/gunicorn/lib/python3.9/site-packages'

PrivateTmp=true
~~~

* Habilitamos e iniciamos esta unidad:

~~~
vagrant@cmsagv:~/flask_temperaturas$ sudo systemctl enable gunicorn-guestbook.service

vagrant@cmsagv:~/flask_temperaturas$ sudo systemctl start gunicorn-guestbook.service
~~~

* Y ya tendriamos nuestra aplicacion python funcionando.

![prueba1](/gunicorn/1.png)
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

* Ahora desplegamos nuestra aplicación manualmente:

~~~
(gunicorn) vagrant@cmsagv:~/flask_temperaturas$ gunicorn -w 2 -b :8080 wsgi:application
~~~

![prueba1](/gunicorn/1.png)

* Pero no vamos a ejecutar a mano la aplicación, por ello vamos a crear una unidad systemd. Para esto primero crearemos el fichero `/etc/systemd/system/gunicorn-temperaturas.service` y le añadiremos el siguiente contenido:

~~~
[Unit]
Description=gunicorn-temperaturas
After=network.target

[Install]
WantedBy=multi-user.target

[Service]
User=www-data
Group=www-data
Restart=always

ExecStart=/home/vagrant/venv/flask/bin/gunicorn -w 2 -b :8080 wsgi:application
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s TERM $MAINPID

WorkingDirectory=/home/vagrant/flask_temperaturas
Environment=PYTHONPATH='/home/vagrant/flask_temperaturas:/home/vagrant/venv/flask/lib/python3.9/site-packages'

PrivateTmp=true
~~~

* Habilitamos e iniciamos esta unidad:

~~~
vagrant@cmsagv:~/flask_temperaturas$ sudo systemctl enable gunicorn-temperaturas.service

vagrant@cmsagv:~/flask_temperaturas$ sudo systemctl start gunicorn-temperaturas.service
~~~

* 
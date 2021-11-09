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
vagrant@cmsagv:~/wsgi$ python3 -m venv wsgi
(wsgi) vagrant@cmsagv:~$ source wsgi/bin/activate
~~~

* Después de clonar la aplicación vamos a instalar los paquetes del fichero requeriments.txt.

~~~
(wsgi) vagrant@cmsagv:~/flask_temperaturas$ pip install -r requirements.txt
~~~

* Tenemos que instalar el módulo de apache para que wsgi funcione

~~~
vagrant@cmsagv:~/flask_temperaturas$ sudo apt install libapache2-mod-wsgi-py3
~~~

* Ahora creamos un fichero en el respositorio llamado `wsgi.py` donde añadiremos la siguiente línea:

~~~
from app import app as application
~~~

* Creamos un virtual host con la siguiente configuración:

~~~
<VirtualHost *:80>
        WSGIDaemonProcess flask_temp python-path=/home/vagrant/flask_temperaturas:/home/vagrant/venv/fla>
        WSGIProcessGroup flask_temp
        WSGIScriptAlias / /home/vagrant/flask_temperaturas/wsgi.py process-group=flask_temp
        <Directory /home/vagrant/flask_temperaturas>
                Require all granted
        </Directory>

        ErrorLog /var/log/apache2/wsgi_error.log
        CustomLog /var/log/apache2/wsgi_access.log combined

</VirtualHost>
~~~


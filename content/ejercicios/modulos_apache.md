+++
title = "Módulos en apache"
description = ""
tags = [
    "SRI"
]
date = "2021-11-08"
menu = "main"
+++

### UserDIR

* Este módulo nos permitirá que cada usuario tenga una carpeta en su home llamada `public_html` donde podrá añadir contenido web.

* Vamos a instalar este módulo:
~~~
vagrant@cmsagv:~$ sudo a2enmod userdir
~~~

* Ahora creamos la carpeta public_html y le damos los permisos necesarios.
~~~
vagrant@cmsagv:~$ mkdir public_html
vagrant@cmsagv:~$ sudo chmod 0755 public_html/
~~~

* Y ya tenemos nuestro directorio donde podemos subir contenido. Aunque podemos cambiar el nombre de esta carpeta, vamos a llamarla `personal` y para que el módulo pueda ver el cambio vamos al fichero `/etc/apache2/mods-enabled/php7.4.conf` y modificamos la siguiente línea tal y como vemos:

~~~
    <Directory /home/*/personal
~~~

* Vamos a añadir contenido y probar nuestra web.

![userdir](/modulos_apache/1.png)
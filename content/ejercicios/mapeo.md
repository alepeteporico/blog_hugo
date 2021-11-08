+++
title = "Mapear URL a ubicaciones de un sistema de ficheros"
description = ""
tags = [
    "SRI"
]
date = "2021-04-21"
menu = "main"
+++

### Crea un nuevo host virtual que es accedido con el nombre www.mapeo.com, cuyo DocumentRoot sea /srv/mapeo.

* En primer lugar para que nuestro apache pueda acceder a /srv/ y reconocer esta ruta como DocumentRoot debemos modificar el fichero `etc/apache2/apache2.conf` y descomentar las siguientes líneas.

        <Directory /srv/>
                Options Indexes FollowSymLinks
                AllowOverride None
                Require all granted
        </Directory>

* Una vez hecho esto creamos la carpeta mapeo en /srv/ y añadimos el nuevo host virtual en sites-avaiable, veamos como quedaría el fichero de sites-avaiable.

        vagrant@cmsagv:~$ cat /etc/apache2/sites-available/mapeo.conf
        <VirtualHost *:80>

                ServerName www.mapeo.com

                ServerAdmin webmaster@localhost
                DocumentRoot /srv/mapeo 

                ErrorLog ${APACHE_LOG_DIR}/error.log
                CustomLog ${APACHE_LOG_DIR}/access.log combined

        </VirtualHost>

* Habilitamos el sitio.

        vagrant@cmsagv:/etc/apache2/sites-available$ sudo a2ensite mapeo.conf 

* Y por último en la máquina anfitriona añadimos nuestro servidor al `/etc/hosts`

        192.168.100.200 www.mapeo.com

* comprobamos que funciona

![principal](/mapeo/1.png)

### Cuando se entre a la dirección www.mapeo.com se redireccionará automáticamente a www.mapeo.com/principal, donde se mostrará el mensaje de bienvenida.

* Para realizar esta tarea primero debemos crear el directorio `principal` con su correspondiente `index.html` y seguidamente en el fichero mapeo.conf que hemos configurado anteriormente añadiremos la siguiente línea.

        Redirect 301 /index.html        /principal

### En el directorio principal no se permite ver la lista de los ficheros, no se permite que se siga los enlaces simbólicos y no se permite negociación de contenido. Muestra al profesor el funcionamiento. ¿Qué configuración tienes que poner?

* Volvemos a `etc/apache2/apache2.conf` y añadimos lo siguiente.

        <Directory "/srv/mapeo">
                Options -Indexes -FollowSymLinks -Multiviews
        </Directory>

### Si accedes a la página www.mapeo.com/principal/documentos se visualizarán los documentos que hay en /home/usuario/doc. Por lo tanto se permitirá el listado de fichero y el seguimiento de enlaces simbólicos siempre que el propietario del enlace y del fichero al que apunta sean el mismo usuario. Explica bien y pon una prueba de funcionamiento donde se vea bien el seguimiento de los enlaces simbólicos.

* El primer paso para realizar esta tarea será crear un alias dentro del archivo de configuración de mapeo.

        Alias "/documentos" "/home/vagrant/Documentos"

* Y seguidamente daremos permisos a este virtual host para acceder a la carpeta documentos de nuestro usuario vagrant.

        <Directory "/home/vagrant/Documentos">
                Options Indexes FollowSymLinks
                AllowOverride None
                Require all granted
        </Directory>

* Nuevamente comprobamos su funcionamiento:

![documentos](/mapeo/2.png)

### En todo el host virtual se debe redefinir los mensajes de error de objeto no encontrado y no permitido. Para el ello se crearan dos ficheros html dentro del directorio error. Entrega las modificaciones necesarias en la configuración y una comprobación del buen funcionamiento.

* Crearemos una carpeta error en mapeo y añadiremos 2 html uno para un error 404 y otro para 403.

        vagrant@cmsagv:/srv/mapeo/error$ ls
        403.html  404.html

* Ahora añadiremos unas línas de configuración a nuestro archivo de configuración de mapeo las cuales especificarán que al producirse uno de estos dos errores debe mostrar su correspondiente html que hemos creado.

        ErrorDocument 403 /error/403.html
        ErrorDocument 404 /error/404.html

* Comprobamos su funcionamiento.

![403](/mapeo/3.png)

------------------------------------------------------------------------------------------------------------

![404](/mapeo/4.png)
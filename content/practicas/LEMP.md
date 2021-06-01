+++
title = "Servidor LEMP"
description = ""
tags = [
    "SRI"
]
date = "2021-06-01"
menu = "main"
+++

* Vamos a instalar todos los paquetes necesarios.

        debian@sputnik:~$ sudo apt install nginx mariadb-client mariadb-server php php-mysql php-fpm

* Crearemos el directorio sobre el que trabajaremos en nuestro virtual host.

        root@sputnik:~# mkdir /var/www/iesgn06

* Crearemos un virtual host en `sites-available`

        server {
                listen 80;
                listen [::]:80;

                root /var/www/iesgn06;

                index index.html index.htm index.nginx-debian.html;

                server_name www.iesgn06.es;

                location / {
                        try_files $uri $uri/ =404;
                }
        }

* Y creamos el enlace simbólico en sites-enabled.

        root@sputnik:/etc/nginx/sites-available# ln -s /etc/nginx/sites-available/iesgn06 /etc/nginx/sites-enabled/

* Después de añadir la ruta a nuestro `etc/hosts` comprobaremos que podemos acceder desde el navegador.

![nginx](/lemp/1.png)

* Ahora crearemos una redirección, cuando se acceda a www.iesgn06.es se redireccionará a `/principal`, para ello añadiremos lo siguiente a nuestro fichero de configuración del virtual host.

        location / {
                try_files $uri $uri/ =404;
                return 301 /principal/index.html;
                location /principal {
                        autoindex off;
                }
        }

* Comprobamos su funcionamiento.

![principal](/lemp/2.png)

* Ahora vamos a instalar una plantilla, primero debemos descargarla.

        root@sputnik:~# wget https://plantillashtmlgratis.com/wp-content/themes/helium-child/descargas/page267/brunch.zip

* Lo descomprimimos y movemos todo el contenido a principal.

        root@sputnik:~# mv 2112_brunch/* /var/www/iesgn06/principal/

* Reiniciamos el servicio y entramos a nuestra web para comprobar que la plantilla se ha instalado exitosamente.

![principal](/lemp/3.png)

* Ahora configuraremos nuestrovirtual host para que pueda ejectuar php añadiendo de nuevo en nuestro fichero de configuración lo siguiente.

        location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                fastcgi_pass unix:/run/php/php7.3-fpm.sock;
        }

* Creamos un fichero info.php en principal.

        root@sputnik:~# cat /var/www/iesgn06/principal/info.php
        <?php
        phpinfo();
        ?>

* Comprobamos que funciona.

![principal](/lemp/4.png)
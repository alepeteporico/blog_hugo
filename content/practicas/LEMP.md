+++
title = "Servidor LEMP"
description = ""
tags = [
    "SRI"
]
date = "2022-30-03"
menu = "main"
+++

* Vamos a instalar todos los paquetes necesarios.

~~~
debian@mrrobot:~$ sudo apt install nginx mariadb-client mariadb-server php php-mysql php-fpm
~~~

* También debemos instalar el servidor de aplicaciones php-fpm.

~~~
debian@mrrobot:~$ sudo apt install php7.4-fpm php7.4
~~~

### Virtualhosting

* Crearemos un virtual host en `sites-available`

~~~
server {
        listen 80;
        listen [::]:80;

        root /var/www/web;

        index index.html index.htm index.nginx-debian.html;

        server_name www.alejandrogv.site;

        location / {
                try_files $uri $uri/ =404;
        }
}
~~~

* Para que nuestro virtualhost por defecto sea este, debemos añadir la siguiente línea el el fichero default de el directorio sites-available, dentro del bloque server.

~~~
rewrite ^/$ http://www.alejandrogv.site permanent;
~~~

* Y creamos el enlace simbólico en sites-enabled.

~~~
debian@mrrobot:~$ sudo ln -s /etc/nginx/sites-available/web.conf /etc/nginx/sites-enabled/
~~~

* Comprobaremos que podemos acceder desde el navegador.

![nginx](/lemp/1.png)

### Mapeo URL

* Ahora crearemos una redirección, cuando se acceda a www.iesgn06.es se redireccionará a `/principal`, para ello añadiremos lo siguiente a nuestro fichero de configuración del virtual host.

~~~
location / {
        try_files $uri $uri/ =404;
        return 301 /principal/index.html;
        location /principal {
                autoindex off;
        }
}
~~~

* Ahora vamos a instalar una plantilla, primero debemos descargarla.

~~~
debian@mrrobot:~$ wget https://plantillashtmlgratis.com/wp-content/themes/helium-child/descargas/page267/brunch.zip
~~~

* Lo descomprimimos y movemos todo el contenido a principal.

~~~
debian@mrrobot:~$ sudo mv 2112_brunch/* /var/www/web
~~~

* Reiniciamos el servicio y entramos a nuestra web para comprobar que la plantilla se ha instalado exitosamente.

![principal](/lemp/3.png)

* Si entramos en /principal/documentos se deberán ver los documentos de /srv/doc para ello añadimos las siguiente líneas en en virtualhost.

~~~
location /principal/documentos {
        alias /srv/doc;
        autoindex on;
        disable_symlinks off;
}
~~~

* Vemos que funciona.

![principal](/lemp/4.png)

### Autentificación

* Vamos a limitar el acceso en `www.alejandrogv.site/secreto`, para ello primero debemos crear un htaccess en nginx, lo haremos de la siguiente forma.

~~~
debian@mrrobot:~$ sudo sh -c "echo -n 'usuario:' >> /etc/nginx/.htpasswd"
debian@mrrobot:~$ sudo sh -c "openssl passwd -apr1 >> /etc/nginx/.htpasswd"
Password: 
Verifying - Password:
~~~

* Añadimos la localicación correspondiente haciendo referencia a que es restringido y donde encontrar el usario y contraseña en el virtualhost.

~~~
location /secreto {
        auth_basic           “Restringido”;
        auth_basic_user_file /etc/nginx/.htpasswd;
}
~~~

* Reiniciamos el servicio y comprobamos que nos pide usuario y contraseña al entrar en secreto.

![principal](/lemp/5.png)

![principal](/lemp/6.png)

### PHP

* Ahora configuraremos nuestrovirtual host para que pueda ejectuar php añadiendo de nuevo en nuestro fichero de configuración lo siguiente.

~~~
location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php7.3-fpm.sock;
}
~~~

* Comprobamos que funciona.

![principal](/lemp/7.png)

### Ansible

* Aquí tenemos nuestro [repositorio](https://github.com/alepeteporico/ansible_LEMP.git) ansible 
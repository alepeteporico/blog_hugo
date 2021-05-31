+++
title = "Servidor nginx"
description = ""
tags = [
    "SRI"
]
date = "2021-05-31"
menu = "main"
+++

#### Crea una máquina del cloud con una red pública. Añade la clave pública del profesor a la máquina. Instala el servidor web nginx en la máquina. Modifica la página index.html que viene por defecto y accede a ella desde un navegador.

* La IP del servidor es la 172.22.201.5

* Una vez añadida la clave pública del profesor instalamos el servidor web nginx.

        debian@nginx:~$ sudo apt install nginx

* Comprobamos que podemos acceder perfectamente desde fuera.

![index](/nginx/1.png)

* Vamos a modificar el index que se aloja en `/var/www/html/index.nginx-debian.html` y a comprobar que se realiza esta modificación.

        <!DOCTYPE html>
        <html>
        <head>
        <title>Bievenido</title>
        <style>
            body {
                width: 35em;
                margin: 0 auto;
                font-family: Tahoma, Verdana, Arial, sans-serif;
            }
        </style>
        </head>
        <body>
        <h1>Estás en el index de nginx</h1>
        </body>
        </html>

![mod](/nginx/2.png)

#### Queremos que nuestro servidor web ofrezca dos sitios web, teniendo en cuenta lo siguiente:

1. Cada sitio web tendrá nombres distintos.
2. Cada sitio web compartirán la misma dirección IP y el mismo puerto (80).

**Los dos sitios web tendrán las siguientes características:**

* **El nombre de dominio del primero será www.iesgn.org, su directorio base será /srv/www/iesgn y contendrá una página llamada index.html, donde sólo se verá una bienvenida a la página del Instituto Gonzalo Nazareno.**

* **En el segundo sitio vamos a crear una página donde se pondrán noticias por parte de los departamento, el nombre de este sitio será departamentos.iesgn.org, y su directorio base será /srv/www/departamentos. En este sitio sólo tendremos una página inicial index.html, dando la bienvenida a la página de los departamentos del instituto.**

* Tal como haríamos en apache en la carpeta `/etc/nginx/sites-available` crearemos dos ficheros que configuraremos para ser nuestro virtual host. 

        debian@nginx:/etc/nginx/sites-available$ ls
        default  departamentos  iesgn


* Vamos a ver como serían estos ficheros de configuración

### iesgn

        server {
                listen 80;
                listen [::]:80;

                server_name www.iesgn.org;

                root /srv/www/iesgn;
                index index.html;

                location / {
                        try_files $uri $uri/ =404;
                }
        }

### departamentos

        server {
                listen 80;
                listen [::]:80;

                server_name departamentos.iesgn.org;

                root /srv/www/departamentos;
                index index.html;

                location / {
                        try_files $uri $uri/ =404;
                }
        }

* Vamos a crear los enlaces simbólicos en `sites-enabled`.

        debian@nginx:/etc/nginx/sites-available$ sudo ln -s /etc/nginx/sites-available/iesgn /etc/nginx/sites-enabled/
        debian@nginx:/etc/nginx/sites-available$ sudo ln -s /etc/nginx/sites-available/departamentos /etc/nginx/sites-enabled/

* Añadimos al `/etc/hosts` de nuestra anfitriona las líneas correspondientes.

        172.22.201.5    www.iesgn.org
        172.22.201.5    departamentos.iesgn.org

* Y comprobamos que están en funcionamiento estás páginas.

![iesgn](/nginx/3.png)

![departamentos](/nginx/4.png)

#### Cambia la configuración del sitio web www.iesgn.org para que se comporte de la siguiente forma:

1. Cuando se entre a la dirección www.iesgn.org se redireccionará automáticamente a www.iesgn.org/principal, donde se mostrará el mensaje de bienvenida. En el directorio principal no se permite ver la lista de los ficheros, no se permite que se siga los enlaces simbólicos y no se permite negociación de contenido. Muestra al profesor el funcionamiento.

2. Si accedes a la página www.iesgn.org/principal/documentos se visualizarán los documentos que hay en /srv/doc. Por lo tanto se permitirá el listado de fichero y el seguimiento de enlaces simbólicos siempre que sean a ficheros o directorios cuyo dueño sea el usuario. Muestra al profesor el funcionamiento.

3. En todo el host virtual se debe redefinir los mensajes de error de objeto no encontrado y no permitido. Para el ello se crearan dos ficheros html dentro del directorio error. Entrega las modificaciones necesarias en la configuración y una comprobación del buen funcionamiento.

* Vamos a crear la carpeta principal dentro de iesgn.

debian@nginx:/srv/www/iesgn$ ls
index.html  principal

* Modificamos la parte de `location` de nuestro fichero de configuración de iesgn.

        location / {
                        return 301 http://www.iesgn.org/principal;
                        }

                        location /principal {
                        try_files $uri $uri/ =404;
                        disable_symlinks on;
                }

* Y comprobamos que al acceder a iesgn nos redirecciona a principal.

![principal](/nginx/5.png)

----------------------------------------

* Crearemos el directorio doc en srv y crearemos contenido para visualizar posteriormente.

        debian@nginx:/srv/doc$ ls
        maspruebas  prueba1  prueba2

* Y añadiremos una nueva redirección en el fichero de iesgn.

                location /principal/documentos {
                try_files $uri $uri/ =404;
                alias /srv/doc;
                disable_symlinks if_not_owner;
                autoindex on;
        }

* Comprobamos que funciona la redirección.

![documentos](/nginx/6.png)

* Vamos a crear un enlace a `/srv/doc`.

        debian@nginx:~$ sudo ln -s /home/debian/link_prueba /srv/doc/

* Y volvemos a comprobar su funcionamiento.

![link](/nginx/7.png)

--------------------------------------------

* Crearemos una carpeta `error` dentro de iesgn donde definiremos dos ficheros html con el mensaje de error de su respectivo código.

        debian@nginx:/srv/www/iesgn$ tree error/
        error/
        ├── 403.html
        └── 404.html

* Definimos los errores en el fichero de iesgn

               error_page 403 /error/403.html;
                        location /error/403.html {
                                internal;
                        }

                error_page 404 /error/404.html;
                        location /error/404.html {
                                internal;
                        }

* Comprobamos que funciona.

![404](/nginx/8.png)

#### Autentificación, Autorización, y Control de AccesoPermalink

1. Añade al escenario otra máquina conectada por una red interna al servidor. A la URL departamentos.iesgn.org/intranet sólo se debe tener acceso desde el cliente de la red local, y no se pueda acceder desde la anfitriona por la red pública. A la URL departamentos.iesgn.org/internet, sin embargo, sólo se debe tener acceso desde la anfitriona por la red pública, y no desde la red local.

* Vamos a crear los directorios correspondientes en departamentos.

        debian@nginx:/srv/www/departamentos$ tree
        .
        ├── index.html
        ├── internet
        │   └── fichero1.txt
        └── intranet
            └── fichero2.txt

* Añadimos algunas localizaciones a nuestro fichero de configuración de departamentos.

                location / {
                        try_files $uri $uri/ =404;

                location /intranet {
                        allow 172.22.200.0/24;
                        deny all;
                }
                location /internet {
                        deny 172.22.200.0/24;
                        allow all;
                        }
                }

![403](/nginx/9.png)

2. Autentificación básica. Limita el acceso a la URL departamentos.iesgn.org/secreto. Comprueba las cabeceras de los mensajes HTTP que se intercambian entre el servidor y el cliente.

* Debemos descargar esta herramienta.

        debian@nginx:/srv/www/departamentos$ sudo apt install apache2-utils

* Añadimos una nueva localización en nuestro fichero de departamentos.

                        location /secreto {
                                auth_basic "Acceso restringido";
                                auth_basic_user_file /etc/nginx/.htpasswd;
                        }

* Añadimos el fichero de la contraseña.

        debian@nginx:/srv/www/departamentos$ sudo htpasswd -c /etc/nginx/.htpasswd user
        New password: 
        Re-type new password: 
        Adding password for user user

* Comprobamos su funcionamiento

![secreto](/nginx/10.png)

![secreto](/nginx/11.png)

--------------------------------------

3. Vamos a combinar el control de acceso (tarea 6) y la autentificación (tarea 7), y vamos a configurar el virtual host para que se comporte de la siguiente manera: el acceso a la URL departamentos.iesgn.org/secreto se hace forma directa desde la intranet, desde la red pública te pide la autentificación. Muestra el resultado al profesor.

* solo debemos añadir algunas cosas a la location de secreto:

                 location /secreto {
                auth_basic "Acceso restringido";
                auth_basic_user_file /etc/nginx/.htpasswd;
                allow 172.22.200.0/24;
                deny all;
                }
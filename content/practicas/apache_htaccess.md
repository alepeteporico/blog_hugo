+++
title = "Configuración de apache mediante archivo .htaccess "
description = ""
tags = [
    "SRI"
]
date = "2021-04-24"
menu = "main"
+++

## Date de alta en un proveedor de hosting. ¿Si necesitamos configurar el servidor web que han configurado los administradores del proveedor?, ¿qué podemos hacer? Explica la directiva AllowOverride de apache2. Utilizando archivos .htaccess realiza las siguientes configuraciones:

* El hosting que usaré será `000webhost`

### Habilita el listado de ficheros en la URL http://host.dominio/nas.

* En nuestro hosting tendremos una carpeta llamada `public_html` en la cual podremos encontrar un fichero llamado `.htaccess`, si lo abrimos vemos que tiene la siguiente estructura.

        # HTID:17436579: DO NOT REMOVE OR MODIFY THIS LINE AND THE LINES BELOW
        php_value display_errors 1
        # DO NOT REMOVE OR MODIFY THIS LINE AND THE LINES ABOVE HTID:17436579:

* El primer paso será deshabilitar el listado de ficheros, para ello añadiremos la siguiente línea.

        Options -Indexes

* Crearemos el directoria `nas`.

![carpeta](/htaccess/1.png)

* Seguidamente crearemos un fichero `.htaccess` dentro de la carpeta `nas` recien creada y añadiremos la siguiente opción.

        Options +Indexes

* Comprobemos que funciona.

![nas](/htaccess/2.png)

### Crea una redirección permanente: cuando entremos en ttp://host.dominio/google salte a www.google.es

* Crearemos un redirect en el `htaccess` de la carpeta `public_html`.

        Redirect 301 /google https://www.google.es

### Pedir autentificación para entrar en la URL http://host.dominio/prohibido

* Después de crear el directorio dentro de `public_html` y un index dentro de la misma para que se muestre contenido, en nuestra maquina anfitriona crearemos un fichero donde guardaremos una contraseña de la siguiente forma:

        alejandrogv@AlejandroGV:~$ htpasswd -c contraseña.txt alejandrogv
        New password: 
        Re-type new password: 
        Adding password for user alejandrogv

* Ahora copiaremos el contenido de este fichero a un fichero que podemos crear el raiz por ejemplo de nuestro hosting.

![contraseña](/htaccess/3.png)

* Necesitaremos saber la ruta que tiene el directorio raiz de nuestro hosting, para ello nos iremos a lista de nuestros sitios y veremos los detalles del nuestro clicando sobre `quick actions`

![ruta](/htaccess/4.png)

* Y por último creamos un `htaccess` dentro de nuestro directorio `prohibido` que tendrá la siguiente forma.

        AuthType Basic
        AuthName "Acceso restringido"
        AuthUserFile  /storage/ssd1/005/16762005/passwd.txt
        Require valid-user

* Si tratamos de entrar veremos que nos pide credenciales.

![prohibido](/htaccess/5.png)

![prohibido](/htaccess/6.png)
+++
title = "Ejercicios de docker"
description = ""
tags = [
    "IWEB"
]
date = "2022-01-19"
menu = "main"
+++

### Introducción

* Crearemos un contenedor demonio a partir de la imagen nginx, el contenedor se debe llamar servidor_web y se debe acceder a él utilizando el puerto 8181 del ordenador donde tengas instalado docker.

* Creación y comprobación de que funciona el contenedor

~~~
alejandrogv@AlejandroGV:~$ docker run --name servidor_web -p 8181:80 -d nginx
964b2c315b83655e5d662a88e620a23f1eaac38666cc64170cd5cd62db72e5fd

alejandrogv@AlejandroGV:~$ docker ps -a
CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS         PORTS                  NAMES
964b2c315b83   nginx     "/docker-entrypoint.…"   5 minutes ago   Up 5 minutes   0.0.0.0:8181->80/tcp   servidor_web
~~~

* Pantallazo donde se vea el acceso al servidor web utilizando un navegador web 

![nginx](/ejercicios_docker/1.png)

* Vistazo de las imagenes que tenemos en el registro local

~~~
alejandrogv@AlejandroGV:~$ docker images
REPOSITORY        TAG       IMAGE ID       CREATED        SIZE
nginx             latest    605c77e624dd   2 weeks ago    141MB
alegv/bookmedik   v1        6514fb85dd9d   7 months ago   245MB
<none>            <none>    9723443d1ffa   7 months ago   245MB
<none>            <none>    60d63ecb8fb0   7 months ago   251MB
nextcloud         latest    44f9792fd39d   7 months ago   868MB
joomla            latest    8b6137e2ef00   7 months ago   458MB
mariadb           latest    eff629089685   7 months ago   408MB
debian            latest    4a7a1f401734   8 months ago   114MB
~~~

* Eliminación del conetenedor

~~~
alejandrogv@AlejandroGV:~$ docker stop servidor_web
servidor_web
alejandrogv@AlejandroGV:~$ docker rm servidor_web 
servidor_web
alejandrogv@AlejandroGV:~$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
~~~

### Imagenes

#### Servidor web

* Pantallazo que desde el navegador muestre el fichero index.html

![html](/ejercicios_docker/2.png)

* Pantallazo que desde el navegador muestre el fichero index.php

![html](/ejercicios_docker/3.png)

* ver el tamaño del contenedor web después de crear los dos ficheros.

~~~
alejandrogv@AlejandroGV:~$ docker ps --size
CONTAINER ID   IMAGE            COMMAND                  CREATED          STATUS          PORTS                  NAMES     SIZE
742fced008c7   php:7.4-apache   "docker-php-entrypoi…"   12 minutes ago   Up 12 minutes   0.0.0.0:8000->80/tcp   web       67B (virtual 469MB)
~~~

* Observar que hemos podido conectarnos al servidor de base de datos con el usuario creado y que se ha creado la base de datos prueba (show databases). El acceso se debe realizar desde el ordenador que tenéis instalado docker, no hay que acceder desde dentro del contenedor, es decir, no usar docker exec.

~~~
alejandrogv@AlejandroGV:~$ sudo mysql -u invitado -p -h 127.0.0.1 -P 3336
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 4
Server version: 10.5.10-MariaDB-1:10.5.10+maria~focal mariadb.org binary distribution

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| prueba             |
+--------------------+
2 rows in set (0.090 sec)
~~~

* Comprobación que no se puede borrar la imagen mariadb mientras el contenedor bbdd está creado.

~~~
alejandrogv@AlejandroGV:~$ docker rmi mariadb
Error response from daemon: conflict: unable to remove repository reference "mariadb" (must force) - container 802bb2b97b91 is using its referenced image eff629089685
~~~

### Almacenamiento
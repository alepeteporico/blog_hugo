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

* ver los dos volúmenes creados.

~~~
alejandrogv@AlejandroGV:~$ docker volume ls
DRIVER    VOLUME NAME
local     volumen_datos
local     volumen_web
~~~

* Orden correspondiente para arrancar el contenedor c1 usando el volumen_web.

~~~
alejandrogv@AlejandroGV:~$ docker run -d --name c1 -v volumen_web:/var/www/html -p 8080:80 php:7.4-apache48f5e1618e8e1e413ca391a2fb00b4aa3e517470179875fd6807d5c01b127bc0
~~~

* Orden correspondiente para arrancar el contenedor c2 usando el volumen_datos.

~~~
alejandrogv@AlejandroGV:~$ docker run -d --name c2 --env MARIADB_ROOT_PASSWORD=admin -v volumen_datos:/var/lib/mysql -p 3336:3306 mariadb:latest
29a9e08e78a80ca6b2a379ed579498ebb061bcd5cfdeb1c8d68955c85c2c3238
~~~

* Borrar el volumen_datos.

~~~
alejandrogv@AlejandroGV:~$ docker stop c2
c2

alejandrogv@AlejandroGV:~$ docker rm c2
c2

alejandrogv@AlejandroGV:~$ docker volume rm volumen_datos 
volumen_datos
~~~

* Ver el borrado de c1 y la creación de c3.

alejandrogv@AlejandroGV:~$ docker stop c1
c1
alejandrogv@AlejandroGV:~$ docker rm c1
c1
alejandrogv@AlejandroGV:~$ docker run -d --name c3 -v volumen_web:/var/www/html -p 8081:80 php:7.4-apacheca59e4cf8a198fbc2fe98a680c20091c360461e3c4c5e6574c925635d5c8b234

* Pantallazo donde se vea el acceso al contenedor c3.

![almacenamiento](/ejercicios_docker/4.png)

-------------------------------------------------------

* Orden correspondiente para arrancar el contenedor c1 (puerto 8181) realizando el bind mount solicitado.

~~~
alejandrogv@AlejandroGV:~$ docker run -d --name c1 -v /home/alejandrogv/saludo/:/var/www/html -p 8181:80 php:7.4-apache
636720dfba87e2fbac97f5e9132d19413068ecca64c53e11b761edb0bd06a5b6
~~~

* Orden correspondiente para arrancar el contenedor c2 (puerto 8282) realizando el bind mount solicitado.

~~~
alejandrogv@AlejandroGV:~$ docker run -d --name c2 -v /home/alejandrogv/saludo/:/var/www/html -p 8282:80 php:7.4-apache
7f382af0afa28bafd9c80c598944abc29994c2b485b0e7d9791722e60296a123
~~~

* Pantallazo donde se pueda apreciar que accediendo a c1 se puede ver el contenido de index.html.

![almacenamiento](/ejercicios_docker/5.png)

* Pantallazo donde se pueda apreciar que accediendo a c2 se puede ver el contenido de index.html.

![almacenamiento](/ejercicios_docker/6.png)

* Pantallazo donde se vea accediendo a los contenedores después de modificar el fichero index.html.

![almacenamiento](/ejercicios_docker/7.png)

### Redes

* Ver la configuración de red del contenedor u1.

~~~
alejandrogv@AlejandroGV:~$ docker network inspect red1
[
    {
        "Name": "red1",
        "Id": "82a48b53729278cfb46b8363bba2fa97d3d91bf7b083845e1add90a070686041",
        "Created": "2022-01-20T10:32:32.594291092+01:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.28.0.0/16",
                    "Gateway": "172.28.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {},
        "Options": {},
        "Labels": {}
    }
]
~~~

* la configuración de red del contenedor u2.

~~~
alejandrogv@AlejandroGV:~$ docker network inspect red2
[
    {
        "Name": "red2",
        "Id": "2e1656146b6f213c6ba33781661fb49cfb5338f73a5e9a17575c2112c60fc08a",
        "Created": "2022-01-20T10:33:08.016492543+01:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.20.0.0/16",
                    "Gateway": "172.20.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {},
        "Options": {},
        "Labels": {}
    }
]
~~~

* desde cualquiera de los dos contenedores se pueda ver que no podemos hacer ping al otro ni por ip ni por nombre.

~~~
root@host2:/# ping 172.28.0.10
PING 172.28.0.10 (172.28.0.10): 56 data bytes
^C--- 172.28.0.10 ping statistics ---
3 packets transmitted, 0 packets received, 100% packet loss

root@host2:/# ping host1      
ping: unknown host
~~~

* Comprobar que si conectamos el contenedor u1 a la red2 (con docker network connect), desde el contenedor u1, tenemos acceso al contenedor u2 mediante ping, tanto por nombre como por ip.

~~~
root@host1:/# ping 172.20.0.2
PING 172.20.0.2 (172.20.0.2): 56 data bytes
64 bytes from 172.20.0.2: icmp_seq=0 ttl=64 time=0.204 ms
64 bytes from 172.20.0.2: icmp_seq=1 ttl=64 time=0.145 ms
^C--- 172.20.0.2 ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max/stddev = 0.145/0.174/0.204/0.030 ms

root@host1:/# ping host2     
PING host2 (172.20.0.2): 56 data bytes
64 bytes from 172.20.0.2: icmp_seq=0 ttl=64 time=0.316 ms
^C--- host2 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max/stddev = 0.316/0.316/0.316/0.000 ms
~~~
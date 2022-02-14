+++
title = "Aplicación php en docker"
description = ""
tags = [
    "IWEB"
]
date = "2022-02-02"
menu = "main"
+++

### Creación de una imagen docker con una aplicación web desde una imagen base

* [url](https://github.com/alepeteporico/docker_php.git) del repositorio GitHub donde tengas los ficheros necesarios para hacer la construcción de la imagen.

* Imagen docker con la aplicación desde una imagen base de debian o ubuntu. En el registro de tu entorno de desarrollo.

~~~
alejandrogv@AlejandroGV:~/docker/docker_php$ docker image ls
REPOSITORY            TAG          IMAGE ID       CREATED        SIZE
alejandro/bookmedik   v1           04c149347bc6   2 days ago     257MB
~~~

### Despliegue en el entorno de desarrollo

* Instrucción para ver los dos contenedores del escenario funcionando.

~~~
alejandrogv@AlejandroGV:~/docker/docker_php/deploy$ docker-compose up -d
Creating servidor_mariadb ... done
Creating bookmedik        ... done

alejandrogv@AlejandroGV:~/docker/docker_php/deploy$ docker ps -a
CONTAINER ID   IMAGE                    COMMAND                  CREATED          STATUS          PORTS                  NAMES
c0a74ef3523e   mariadb                  "docker-entrypoint.s…"   35 seconds ago   Up 21 seconds   3306/tcp               servidor_mariadb
c6e1d60dcec4   alejandro/bookmedik:v1   "script.sh"              35 seconds ago   Up 20 seconds   0.0.0.0:8081->80/tcp   bookmedik
~~~

* 
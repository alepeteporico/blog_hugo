+++
title = "Aplicación php en docker"
description = ""
tags = [
    "IWEB"
]
date = "2022-02-02"
menu = "main"
+++

### Tarea 1: Creación de una imagen docker con una aplicación web desde una imagen base

* [url](https://github.com/alepeteporico/docker_bookmedik/tree/main/imagen_base) del repositorio GitHub donde tengas los ficheros necesarios para hacer la construcción de la imagen.

* Imagen docker con la aplicación desde una imagen base de debian o ubuntu. En el registro de tu entorno de desarrollo.

~~~
alejandrogv@AlejandroGV:~/Escritorio/ASIR/IWEB/docker_bookmedik$ docker images
REPOSITORY                    TAG          IMAGE ID       CREATED         SIZE
alejandro/bookmedik           v1           ee540637fb01   8 seconds ago   309MB
~~~

### Tarea 2: Despliegue en el entorno de desarrollo

* [url](https://github.com/alepeteporico/docker_bookmedik/tree/main/despliegue_desarrollo) del repositorio GitHub donde hayas añadido el fichero docker-compose.yml.

* Instrucción para ver los dos contenedores del escenario funcionando.

~~~
alejandrogv@AlejandroGV:~/docker/docker_php/deploy$ docker-compose up -d
Creating servidor_mariadb ... done
Creating bookmedik        ... done

alejandrogv@AlejandroGV:~/Escritorio/ASIR/IWEB/docker_bookmedik$ docker ps -a 
CONTAINER ID   IMAGE                    COMMAND                  CREATED              STATUS                     PORTS                  NAMES
8c6374ef9987   alejandro/bookmedik:v1   "/opt/script.sh"         About a minute ago   Up About a minute          0.0.0.0:8085->80/tcp   app_bookmedik
b76d7a188431   mariadb                  "docker-entrypoint.s…"   2 minutes ago        Up About a minute
~~~

* Captura de pantalla donde se vea funcionando la aplicación, una vez que te has logueado.

![admin](/docker_bookmedik/1.png)

### Tarea 3: Creación de una imagen docker con una aplicación web desde una imagen PHP

* [url](https://github.com/alepeteporico/docker_bookmedik/tree/main/imagen_php) del repositorio GitHub donde tengas los ficheros necesarios para hacer la construcción de la imagen.

* Captura de pantalla donde se vea la imagen en el registro de tu entorno de desarrollo.

~~~
alejandrogv@AlejandroGV:~/Escritorio/ASIR/IWEB/docker_bookmedik$ docker images
REPOSITORY                    TAG                   IMAGE ID       CREATED         SIZE
alejandro/bookmedik           v2                    ad1e9651d765   7 seconds ago   496MB
~~~

* Instrucción para ver los dos contenedores del escenario funcionando.

~~~
alejandrogv@AlejandroGV:~/Escritorio/ASIR/IWEB/docker_bookmedik$ docker-compose ps
      Name                    Command             State          Ports        
------------------------------------------------------------------------------
app_bookmedik       /opt/script.sh                Up      0.0.0.0:8090->80/tcp
mariadb_bookmedik   docker-entrypoint.sh mysqld   Up      3306/tcp
~~~

* Captura de pantalla donde se vea funcionando la aplicación, una vez que te has logueado.

![admin](/docker_bookmedik/2.png)

### Tarea 4: Ejecución de una aplicación PHP en docker con nginx

* [url]() del repositorio GitHub donde tengas los ficheros necesarios para hacer la construcción de la imagen.

* Captura de pantalla donde se vea la imagen en el registro de tu entorno de desarrollo.

~~~

~~~

### Tarea 5: Puesta en producción de nuestra aplicación

* Captura de pantalla de Docker Hub donde se vea tu imagen subida.

![admin](/docker_bookmedik/3.png)

* Configuración de nginx.

~~~
server {
        listen 80;
        listen [::]:80;

        server_name bookmedik.alejandrogv.site;

        return 301 https://$host$request_uri;
}

server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;

        ssl    on;
        ssl_certificate /etc/letsencrypt/live/bookmedik.alejandrogv.site/fullchain.pem;
        ssl_certificate_key     /etc/letsencrypt/live/bookmedik.alejandrogv.site/privkey.pem;

        index index.html index.php index.htm index.nginx-debian.html;

        server_name bookmedik.alejandrogv.site;

        location / {
                proxy_pass http://localhost:8090;
                include proxy_params;
        }

}
~~~

* Captura de pantalla donde se vea funcionando la aplicación, una vez que te has logueado.

![admin](/docker_bookmedik/4.png)
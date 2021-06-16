+++
title = "Implantación de aplicaciones web PHP en docker"
description = ""
tags = [
    "IWEB"
]
date = "2021-06-07"
menu = "main"
+++

* Vamos a clonar el repositorio necesario para la aplicación.

        alejandrogv@AlejandroGV:~/docker/php$ git clone https://github.com/evilnapsis/bookmedik.git

* Crearemos un repositorio con la siguiente estructura.

        alejandrogv@AlejandroGV:~/docker/php/php_docker$ tree
        .
        ├── build
        │   ├── bookmedik
        │   ├── Dockerfile
        │   └── script.sh
        ├── deploy
        │   └── docker-compose.yml
        └── README.md

* En el fichero docker-compose añadimos lo siguiente.

        version: "3.1"

        services:
          db:
            container_name: mysql
            image: mariadb
            restart: always
            environment:
              MYSQL_DATABASE: bookmedik
              MYSQL_USER: bookmedik
              MYSQL_PASSWORD: admin    
              MYSQL_ROOT_PASSWORD: admin
            volumes:
              - /opt/mysql_wp:/var/lib/mysql

* Y en la carpeta build crearemos un fichero Dockerfile que rellenaremos de la siguiente forma.

        FROM debian

        RUN apt-get update && apt-get install -y apache2 libapache2-mod-php7.3 php7.3 php7.3-mysql && apt-get cl$
        RUN rm /var/www/html/index.html

        ENV APACHE_SERVER_NAME=www.bookmedik-alegv.org
        ENV DATABASE_USER=admin    
        ENV DATABASE_PASSWORD=admin    
        ENV DATABASE_HOST=bd

        EXPOSE 80

        COPY ./bookmedik /var/www/html
        ADD script.sh /usr/local/bin/script.sh

        RUN chmod +x /usr/local/bin/script.sh

        CMD ["/usr/local/bin/script.sh"]

* Y en el mismo directorio crearemos un fichero script.sh en cual tendrá el siguiente contenido.

        #!/bin/bash

        sed -i 's/$this->usuario="admin";/$this->usuario="'${DATABASE_USER}'";/g' /var/www/html/core/controller/Database.php
        sed -i 's/$this->pass="";/$this->pass="'${DATABASE_PASSWORD}'";/g' /var/www/html/core/controller/Database.php
        sed -i 's/$this->host="localhost";/$this->host="'${DATABASE_HOST}'";/g' /var/www/html/core/controller/Database.php
        apache2ctl -D FOREGROUND

* Vamos a levantarlo.

        root@AlejandroGV:/home/alejandrogv/docker/php/php_docker/build# docker build -t alegv/bookmedik:v1 .

* Ahora tenemos que modifcar nuestro fichero docker-compose.yml añadiendo un nuevo contenedor donde alojaremos nuestra aplicación.

        bookmedik:
           container_name: bookmedik
           image: alegv/bookmedik:v1
           restart: always
           ports:
             - 8082:80
           volumes:
             - /opt/bookmedik:/var/log/apache2

* vamos a usar el script de generación de tablas sobre nuestro contenedor de mariadb.

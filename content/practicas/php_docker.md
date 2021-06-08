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

* Vamos a levantarlo.

        alejandrogv@AlejandroGV:~/docker/php/php_docker/deploy$ sudo docker-compose up -d
        Creating network "deploy_default" with the default driver
        Creating mysql ... done

* Dentro del primer repositorio que clonamos tenemos un fichero llamado `schema.sql` debemos acceder y comentar la siguiente línea.

        #create database bookmedik;

* Cargaremos el contenido de este fichero en nuestra base de datos.

        root@AlejandroGV:/home/alejandrogv/docker/php/bookmedik# cat schema.sql | docker exec -i mysql /usr/bin/mysql -u root --password=admin bookmedik

* Vamos a configurar un fichero `script.sh` que estará localizado en `/usr/local/bin`

        #!/bin/bash

        sed -i "s/$this->user=\"root\";/$this->user=\"$DATABASE_USER\";/g" /var/www/html/core/controller/Database.php
        sed -i "s/$this->pass=\"\";/$this->pass=\"$DATABASE_PASSWORD\";/g" /var/www/html/core/controller/Database.php
        sed -i "s/$this->host=\"localhost\";/$this->host=\"$DATABASE_HOST\";/g" /var/www/html/core/controller/Database.php
        apache2ctl -D FOREGROUND

* Vamos a configurar el Dockerfile.

        FROM debian
        MAINTAINER Ale Gutierrez "tojandro@gmail.com"

        RUN apt-get update && apt-get install -y apache2 \
        libapache2-mod-php7.3 \
        php7.3 \
        php7.3-mysql \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

        EXPOSE 80

        RUN rm /var/www/html/index.html
        COPY bookmedik /var/www/html/
        ADD script.sh /usr/local/bin/

        RUN chmod +x /usr/local/bin/script.sh

        ENV DATABASE_USER bookmedik
        ENV DATABASE_PASSWORD admin    
        ENV DATABASE_HOST db

        CMD ["script.sh"]

* Y a ejecutarlo.

        root@AlejandroGV:/home/alejandrogv/docker/php# docker build -t alegv/book_debian .
+++
title = "Instalación de wordpress"
description = ""
tags = [
    "Apuntes"
]
date = "2021-09-20"
menu = "main"
+++

**El cms elegido es wordpress, los descargamos y descomprimimos en primer lugar como hicimos con drupal**

    vagrant@cmsagv:~$ wget https://es.wordpress.org/latest-es_ES.tar.gz

    vagrant@cmsagv:~$ sudo tar xf latest-es_ES.tar.gz -C /var/www/
    vagrant@cmsagv:~$ sudo chown www-data:www-data /var/www/wordpress/ -R

**Nuevamente creamos una nueva base de datos y otorgamos privilegios a nuestro usario dentro de la misma.**

    MariaDB [(none)]> CREATE DATABASE wordpress;
    Query OK, 1 row affected (0.000 sec)

    MariaDB [(none)]> GRANT ALL PRIVILEGES ON wordpress.* to 'usuario2'@'172.22.100.5';
    Query OK, 0 rows affected (0.000 sec)

**Tendremos que instalar algunos nuevos módulos nuevos de apache:**

    vagrant@cmsagv:~$ sudo apt install php-bcmath php-curl php-imagick php-zip

**El siguiente paso será crear nuestro nuevo virtualhost, este tendrá el siguiente aspecto:**
~~~
<VirtualHost *:80>
        ServerName www.alegv-wordpress.org
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/wordpress
        <Directory /var/www/html/wordpress/>
                Options Indexes FollowSymLinks
                AllowOverride All
                Require all granted
        </Directory>

        ErrorLog /var/log/apache2/drupal_error.log
        CustomLog /var/log/apache2/drupal_access.log combined

</VirtualHost>
~~~

**Una vez hecho esto simplemente reinciamos apache, añadimos en el `/etc/hosts` de nuestra anfitriona y ya podremos acceder a nuestro wordpress**

![wordpress](/cms_php/16.png)

---------------------------------

![wordpress](/cms_php/17.png)
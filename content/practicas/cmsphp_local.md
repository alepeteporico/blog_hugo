+++
title = "Instalación local de un CMS PHP"
description = ""
tags = [
    "IWEB"
]
date = "2021-03-22"
menu = "main"
+++ 

**Instalamos un servidor LAMP**

#### Apache

**Hacemos una instalación sencilla:**

    vagrant@cmsalegv:~$ sudo apt install apache2 apache2-utils

**Y creamos una regla en iptables para permitir la conexión http**

    vagrant@cmsalegv:~$ sudo iptables -I INPUT -p tcp --dport 80 -j ACCEPT

#### Mariadb

**Instalamos Mariadb**

    vagrant@cmsalegv:~$ sudo apt install mariadb-server mariadb-client

#### PHP

**Y por últimos realizaremos la instalación de php**

    vagrant@cmsalegv:~$ sudo apt install php7.3 libapache2-mod-php7.3 php7.3-mysql php-common php7.3-cli php7.3-common php7.3-json php7.3-opcache php7.3-readline

**Tendremos que habilitar el mod de apache de PHP**

    vagrant@cmsalegv:~$ sudo a2enmod php7.3
    vagrant@cmsalegv:~$ sudo systemctl restart apache2

#### Base de datos

**Creamos un usuario nuevo en mariadb y le damos una contraseña**

    CREATE USER 'usuario1'@'localhost';

    SET PASSWORD FOR 'usuario1'@'localhost' = PASSWORD('usuario1');

**Y crearemos una nueva base de datos la cual el usuario que hemos creado tendrá acceso completo:**

    CREATE DATABASE drupal;

    GRANT ALL PRIVILEGES ON `drupal`.* TO 'usuario1'@'localhost';

#### Drupal

**Nuestro próximo paso será instalar Drupal, primero descargamos el paquete de instalación y lo extraemos**

    vagrant@cmsalegv:~$ wget https://ftp.drupal.org/files/projects/drupal-8.8.1.tar.gz

    vagrant@cmsalegv:~$ tar xvf drupal-8.8.1.tar.gz

**Movemos la carpeta a nuestra carpeta del virtual host**

    vagrant@cmsalegv:~$ sudo mv drupal-8.8.1 /var/www/html/

**Y para amenizar el trabajo podríamos crear un enlace simbólico para no tener que escribir la versión cada vez que queramos hacer una configuración:**

    vagrant@cmsalegv:~$ sudo ln -s /var/www/drupal-8.8.1/ /var/www/drupal

**Debemos activar el modulo rewrite en apache**

    vagrant@cmsalegv:~$ sudo a2enmod rewrite

**Configuramos un virtual host**

    <VirtualHost *:80>

            ServerName www.alegv-drupal.org
            ServerAdmin webmaster@localhost
            DocumentRoot /var/www/drupal
            <Directory /var/www/html/drupal/>
                    Options Indexes FollowSymLinks
                    AllowOverride All
                    Require all granted
            </Directory>

            ErrorLog /var/log/apache2/drupal_error.log
            CustomLog /var/log/apache2/drupal_access.log combined

    <VirtualHost>

**Añadimos la IP estática que hemos añadido a nuestro servidor en el `/etc/hosts` de nuestra máquina anfitriona**

        192.168.100.200    www.alegv-drupal.com

**Y ya podremos acceder a nuetro drupal**

![redes](/cms_php/1.png)
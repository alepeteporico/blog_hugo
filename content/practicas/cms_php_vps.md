+++
title = "Instalación/migración de aplicaciones web PHP eb tu VPS"
description = ""
tags = [
    "IWEB"
]
date = "2022-03-20"
menu = "main"
+++

### Drupal

* Primero migraremos la aplicación de drupal que tenemos instalada localmente. para ello vamos a migrar la base de datos.

~~~
root@cmsagv:~# mysqldump drupal > ./backup.sql
~~~

* Seguidamente nos iremos a nuestra VPS donde instalaremos mariadb y crearemos una base de datos y un usuario con privilegios sobre ella.

~~~
MariaDB [(none)]> CREATE DATABASE drupal;
Query OK, 1 row affected (0.000 sec)

MariaDB [(none)]> CREATE USER 'usuario1'@'localhost';
Query OK, 0 rows affected (0.004 sec)

MariaDB [(none)]> SET PASSWORD FOR 'usuario1'@'localhost' = PASSWORD('usuario1');
Query OK, 0 rows affected (0.001 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON `drupal`.* TO 'usuario1'@'localhost';
Query OK, 0 rows affected (0.002 sec)
~~~

* Ahora, importaremos el backup a esta base de datos.

~~~
root@mrrobot:~# mysql drupal < /home/debian/backup.sql
~~~

* Descargamos la aplicación de drupal y creamos el virtual host.

~~~
server {
        listen 80;
        listen [::]:80;

        root /var/www/drupal;

        index index.php index.html;

        server_name portal.alejandrogv.site;

        location / {
                try_files $uri $uri/ =404;
        }


        location ~ \.php$ {
               include snippets/fastcgi-php.conf;
               fastcgi_pass unix:/run/php/php7.4-fpm.sock;
        }

        error_log /var/log/nginx/drupal_error.log;

}
~~~

* Creamos el enlace a sites-enabled.

~~~
root@mrrobot:/etc/nginx/sites-available# ln -s drupal.conf ../sites-enabled/
~~~

* Vamos a nombrar la base de datos en producción localmente en el fichero /etc/hosts.

~~~
127.0.1.1       bd.alejandrogv.site
~~~

* Configuramos el fichero `/var/www/drupal/sites/default/default.settings.php` para que use la base de datos que hemos instalado.

~~~
$databases['default']['default'] = array (
  'database' => 'drupal',
  'username' => 'usuario1',
  'password' => 'usuario1',
  'prefix' => '',
  'host' => '127.0.1.1',
  'port' => '3306',
  'namespace' => 'Drupal\\Core\\Database\\Driver\\mysql',
  'driver' => 'mysql',
);
~~~

* Añadimos una nueva zona en la VPS.

![zona](/php_vps/2.png)

* Y ya tenemos funcionando [nuestra página](http://portal.alejandrogv.site/)

![pagina](/php_vps/1.png)

### Nextcloud

* Vamos a descargar el cms.

~~~
debian@mrrobot:~$ curl -LO https://download.nextcloud.com/server/releases/nextcloud-23.0.0.zip
~~~

* Después de descomprimirlo y alojarlo en nuestra carpeta de `/var/www/web` con el nombre de cloud vamos a realizar la migración de la base de datos que hemos creado previamente.

~~~
root@mrrobot:~# mysql nextcloud < /home/debian/nextcloud.sql
~~~

* Seguidamente editaremos el fichero de configuración alojandro en `config/config.php` para que use esta base de datos y el usuario correspondiente.

~~~
<?php
$CONFIG = array (
  'instanceid' => 'oc63uzaegkwf',
  'passwordsalt' => '1uzMp83xWHH46hMPcF+hxeFbHp+bE4',
  'secret' => 'cTynvVtIdkPmKRHCJHLinjVbuSic0hYo9sSzv3n387dFy6hp',
  'trusted_domains' => 
  array (
    0 => 'www.alejandrogv.site',
  ),
  'datadirectory' => '/var/www/web/cloud/data',
  'dbtype' => 'mysql',
  'version' => '23.0.0.10',
  'overwrite.cli.url' => 'http://www.alejandrogv.site/cloud',
  'dbname' => 'nextcloud',
  'dbhost' => 'bd.alejandrogv.site',
  'dbport' => '',
  'dbtableprefix' => 'oc_',
  'mysql.utf8mb4' => true,
  'dbuser' => 'usuario1',
  'dbpassword' => 'usuario1',
  'installed' => true,
);
~~~

* Comprobamos que tenemos acceso.

![pagina](/php_vps/3.png)

* Nuestro siguiente paso será instalar un cliente de nextcloud, debemos instalar el paquete `nextcloud-desktop` en la máquina que hará de cliente, seguidamente ejecutaremos el comando `nextcloud` y se nos abrirá la siguiente ventana.

![cliente](/php_vps/4.png)

* Clicamos en entrar y nos pedirá la url de nuestro servidor.

![pagina](/php_vps/5.png)

* Después de loggearnos ya estaríamos conectados.

![pagina](/php_vps/6.png)

* Ahora tendremos una carpeta de nextcloud donde podremos manegar nuestros ficheros.

~~~
alejandrogv@AlejandroGV:~/Nextcloud$ touch ficheronuevo.txt

alejandrogv@AlejandroGV:~/Nextcloud$ ls
 Documents         'Nextcloud intro.mp4'    Nextcloud.png   Plantillas
 ficheronuevo.txt  'Nextcloud Manual.pdf'   Photos         'Reasons to use Nextcloud.pdf'
~~~

![pagina](/php_vps/7.png)
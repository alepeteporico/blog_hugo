+++
title = "Instalación/migración de aplicaciones web PHP eb tu VPS"
description = ""
tags = [
    "IWEB"
]
date = "2021-03-20"
menu = "main"
+++

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
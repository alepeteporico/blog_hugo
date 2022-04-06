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

* Migramos la aplicación

~~~
alejandrogv@AlejandroGV:~$ scp drupal/ debian@mrrobot.alejandrogv.site/home/debian/
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

* Migramos la aplicación

~~~
alejandrogv@AlejandroGV:~$ scp nextcloud/ debian@mrrobot.alejandrogv.site/home/debian/
~~~

* Lo alojamos en nuestra carpeta de `/var/www/web` con el nombre de cloud vamos a realizar la migración de la base de datos que hemos creado previamente.

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

* Ahora tenemos que añadir las siguientes líneas a nuestro virtual host de web, para que podamos acceder mediante `www.alejandrogv.site/cloud`.

~~~
        location = /robots.txt {
            allow all;
            log_not_found off;
            access_log off;
        }

        location /.well-known {

            location = /.well-known/carddav   { return 301 /cloud/remote.php/dav/; }
            location = /.well-known/caldav    { return 301 /cloud/remote.php/dav/; }

            location /.well-known/acme-challenge    { try_files $uri $uri/ =404; }
            location /.well-known/pki-validation    { try_files $uri $uri/ =404; }

            try_files $uri $uri/ =404;
        }

        location ^~ /cloud {
            client_max_body_size 512M;
            fastcgi_buffers 64 4K;

            gzip on;
            gzip_vary on;
            gzip_comp_level 4;
            gzip_min_length 256;
            gzip_proxied expired no-cache no-store private no_last_modified no_etag auth;
            gzip_types application/atom+xml application/javascript application/json application/ld+json application/manifest+json application/rss+xml application/vnd.geo+json application/vnd.ms-fontobject application/x-font-ttf application/x-web-app-manifest+json application/xhtml+xml application/xml font/opentype image/bmp image/svg+xml image/x-icon text/cache-manifest text/css text/plain text/vcard text/vnd.rim.location.xloc text/vtt text/x-component text/x-cross-domain-policy;

            add_header Referrer-Policy                      "no-referrer"   always;
            add_header X-Content-Type-Options               "nosniff"       always;
            add_header X-Download-Options                   "noopen"        always;
            add_header X-Frame-Options                      "SAMEORIGIN"    always;
            add_header X-Permitted-Cross-Domain-Policies    "none"          always;
            add_header X-Robots-Tag                         "none"          always;
            add_header X-XSS-Protection                     "1; mode=block" always;

            fastcgi_hide_header X-Powered-By;

            index index.php index.html /cloud/index.php$request_uri;

            expires 1m;

            location = /cloud {
                if ( $http_user_agent ~ ^DavClnt ) {
                    return 302 /cloud/remote.php/webdav/$is_args$args;
                }
            }

            location ~ ^/cloud/(?:build|tests|config|lib|3rdparty|templates|data)(?:$|/)    { return 404; }
            location ~ ^/cloud/(?:\.|autotest|occ|issue|indie|db_|console)                { return 404; }

            location ~ \.php(?:$|/) {
                fastcgi_split_path_info ^(.+?\.php)(/.*)$;
                set $path_info $fastcgi_path_info;

                try_files $fastcgi_script_name =404;

                include fastcgi_params;
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                fastcgi_param PATH_INFO $path_info;

                fastcgi_param modHeadersAvailable true;
                fastcgi_param front_controller_active true;
                fastcgi_pass unix:/run/php/php7.4-fpm.sock;

                fastcgi_intercept_errors on;
                fastcgi_request_buffering off;
            }

            location ~ \.(?:css|js|svg|gif)$ {
                try_files $uri /cloud/index.php$request_uri;
                expires 6M;
                access_log off;
            }

            location ~ \.woff2?$ {
                try_files $uri /cloud/index.php$request_uri;
                expires 7d;
                access_log off;
            }

            location /cloud {
                try_files $uri $uri/ /cloud/index.php$request_uri;
            }
        }
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
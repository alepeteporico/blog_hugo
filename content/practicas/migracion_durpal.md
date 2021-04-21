+++
title = "Migración de aplicación web PHP"
description = ""
tags = [
    "IWEB"
]
date = "2021-04-12"
menu = "main"
+++

* Nos daremos de alta en un hosting gratuito, en mi caso cdmon. Y crearemos un nuevo hosting.

![hosting](/migracion_drupal/1.png)

## Migración de la base de datos.

* Lo primero que haremos será restaurar nuestra base de datos en nuestro hosting, para ello entraremos en la pestaña de mysql.

![mysql](/migracion_drupal/2.png)

* Creamos una nueva base de datos, en mi caso la llamaré drupalagv.

![nueva bbdd](/migracion_drupal/5.png)

* y accederemos a phpMyAdmin con las credenciales que se nos otorgan.

![phpMyAdmin](/migracion_drupal/3.png)

* Importaremos el archivo de backup de nuestra base de datos.

![Importar archivos, pues claro que me importan](/migracion_drupal/4.png)

* Y ya tendremos nuestra base de datos importada.

![importacion exitosa](/migracion_drupal/6.png)

## Migración de la aplicación

* Una vez nuestra base de datos importa lo que debemos hacer ahora es migrar nuestra aplicación. Para ello nos conectaremos al servidor ftp del hosting con las credenciales que se nos proporcionan.

        vagrant@cmsagv:~$ ftp 185.66.41.58
        Connected to 185.66.41.58.
        220---------------------------------------------------------
        220 This is a private system - No anonymous login
        Name (185.66.41.58:vagrant): portal
        331 User portal OK. Password required
        Password:
        230-OK. Current restricted directory is /
        230 16115 Kbytes used (0%) - authorized: 5242880 Kb
        Remote system type is UNIX.
        Using binary mode to transfer files.
        ftp> passive
        Passive mode on.

* Podemos comprobar todos los directorios que tenemos.

        ftp> ls
        227 Entering Passive Mode (185,66,41,58,125,34)
        150 Accepted data connection
        drwxr-xr-x    8 277255055  portal           4096 Apr 13 19:05 .
        drwxr-xr-x    8 277255055  portal           4096 Apr 13 19:05 ..
        -rw-------    1 277255055  portal             11 Apr 14 12:03 .ftpquota
        drwxrwxr-x    2 277255055  portal           4096 Apr 13 18:25 backup_db
        drwxr-xr-x    2 0          portal           4096 Apr 13 23:00 errors
        -rw-r--r--    1 0          0                   0 Apr 13 23:00 errors.log
        drwxrwxr-x    2 277255055  portal           4096 Apr 12 08:11 logs
        -rw-r--r--    1 277255055  portal        1047385 Apr 13 19:05 portal.iesgnag.es-13-04-2021-2005.zip
        drwxr-xr-x    2 277255055  portal           4096 Apr 13 18:34 restores
        drwxrwxr-x    2 277255055  portal           4096 Apr 12 08:11 tmp
        drwxrwxr-x    2 277255055  portal           4096 Apr 13 19:05 web
        226-Options: -a -l 
        226 11 matches total

* Una vez sabemos donde tenemos que subir nuestro directorio podemos usar scp:

        alejandrogv@AlejandroGV:~$ scp -r drupal/ portal@185.66.41.58:/web/

* Ya que tenemos nuestro directorio drupal copiado en nuestro hosting debemos cambiar la ruta de la base de datos y el usuario de drupal, para ello entraremos en el servidor mediante ssh y editaremos el fichero `/var/www/drupal/sites/default/settings.php` tal y como podemos ver ahora.

        $databases['default']['default'] = array (
          'database' => 'drupalagv',
          'username' => 'myportal',
          'password' => 'DzhILZeS',
          'prefix' => '',
          'host' => 'localhost',
          'port' => '3306',
          'namespace' => 'Drupal\\Core\\Database\\Driver\\mysql',
          'driver' => 'mysql',

* Seguidamente en CDMON entraremos en multidominios web y añadiremos un nuevo dominio que será nuestro drupal.

![drupal](/migracion_drupal/7.png)

* Y ya tenemos nuestro cms subido, aunque sin css debido a un problema quizás referente a la subida de archivos ocultos o probablemente referente al hosting lo cual estaría fuera de nuestro control.

![drupal mal](/migracion_drupal/8.png)
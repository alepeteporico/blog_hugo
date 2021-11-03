+++
title = "Migración de aplicación web PHP"
description = ""
tags = [
    "IWEB"
]
date = "2021-11-03"
menu = "main"
+++

* Nos daremos de alta en un hosting gratuito, en mi caso cdmon. Y crearemos un nuevo hosting.

![hosting](/migracion_drupal/1.png)

## Migración de la base de datos.

* Lo primero que haremos será restaurar nuestra base de datos en nuestro hosting, para ello entraremos en la pestaña de mysql.

![mysql](/migracion_drupal/2.png)

* Creamos una nueva base de datos, en mi caso la llamaré joomlaagv.

![nueva bbdd](/migracion_drupal/3.png)

* y accederemos a phpMyAdmin con las credenciales que se nos otorgan.

![phpMyAdmin](/migracion_drupal/5.png)

* Importaremos el archivo de backup de nuestra base de datos.

![Importar archivos, pues claro que me importan](/migracion_drupal/4.png)

* Y ya tendremos nuestra base de datos importada.

![importacion exitosa](/migracion_drupal/6.png)

## Migración de la aplicación

* Una vez nuestra base de datos importa lo que debemos hacer ahora es migrar nuestra aplicación. Para ello nos conectaremos al servidor ftp del hosting con las credenciales que se nos proporcionan.

~~~
root@cmsagv:~# ftp 185.66.41.166
Connected to 185.66.41.166.
220---------------------------------------------------------
220 This is a private system - No anonymous login
Name (185.66.41.166:vagrant): alegvjo
331 User alegvjo OK. Password required
Password:
230-OK. Current restricted directory is /
230 0 Kbytes used (0%) - authorized: 5242880 Kb
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> passive
Passive mode on.
~~~

* Podemos comprobar todos los directorios que tenemos.

~~~
ftp> ls
227 Entering Passive Mode (185,66,41,166,125,22)
150 Accepted data connection
drwxrwxr-x    7 277342134  alegvjo          4096 Nov  3 14:34 .
drwxrwxr-x    7 277342134  alegvjo          4096 Nov  3 14:34 ..
-rw-------    1 277342134  alegvjo             0 Nov  3 14:34 .ftpquota
drwxrwxr-x    2 277342134  alegvjo          4096 Nov  3 14:17 backup_db
drwxrwxr-x    2 277342134  alegvjo          4096 Nov  3 14:17 errors
-rw-r--r--    1 0          0                   0 Nov  3 14:17 errors.log
drwxrwxr-x    2 277342134  alegvjo          4096 Nov  3 14:17 logs
drwxrwxr-x    2 277342134  alegvjo          4096 Nov  3 14:17 tmp
drwxrwxr-x    2 277342134  alegvjo          4096 Nov  3 14:17 web
226-Options: -a -l 
226 9 matches total
~~~

* Una vez sabemos donde tenemos que subir nuestro directorio podemos usar scp:

~~~
root@cmsagv:~# scp -r /var/www/html/joomla/ alegvjo@185.66.41.166:/web/
~~~

* Ya que tenemos nuestro directorio joomla copiado en nuestro hosting debemos cambiar la ruta de la base de datos y el usuario de joomla, para ello entraremos en el servidor mediante ssh y editaremos el fichero `configuration.php` tal y como podemos ver ahora.

~~~
public $dbtype = 'mysqli';
public $host = 'localhost';
public $user = 'myalegvjo';
public $password = 'gUzj9FqL';
public $db = 'joomlaagv';
~~~

* Seguidamente en CDMON entraremos en multidominios web y añadiremos un nuevo dominio que será nuestro drupal.

![drupal](/migracion_drupal/7.png)
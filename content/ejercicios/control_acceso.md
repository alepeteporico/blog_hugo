+++
title = "Control de acceso, autentificación y autorización"
description = ""
tags = [
    "SRI"
]
date = "2021-04-24"
menu = "main"
+++

## Crea un escenario en Vagrant o reutiliza uno de los que tienes en ejercicios anteriores, que tenga un servidor con una red publica, y una privada y un cliente conectada a la red privada. Crea un host virtual departamentos.iesgn.org

* Para está práctica podremos usar la misma máquina de vagrant que usamos para las prácticas del cms y de mapeo.

### A la URL departamentos.iesgn.org/intranet sólo se debe tener acceso desde el cliente de la red local, y no se pueda acceder desde la anfitriona por la red pública. A la URL departamentos.iesgn.org/internet, sin embargo, sólo se debe tener acceso desde la anfitriona por la red pública, y no desde la red local.

* Vamos a crear la estructura de directorios que necesitaremos en `/var/www/`

        vagrant@cmsagv:~$ sudo mkdir -p /var/www/departamentos/{intranet,internet,secreto}

* Crearemos un nuevo virtual host en sites-avaiable y especificaremos que a intranet solo se pueda acceder desde la red interna y a internet solo desde la externa.

        <VirtualHost *:80>
                ServerName departamentos.iesgn.org

                ServerAdmin webmaster@localhost
                DocumentRoot /var/www/departamentos

                <Directory /var/www/departamentos/intranet/>
                            Options Indexes FollowSymLinks MultiViews
                            <RequireAll>
                                    Require ip 172.22.100
                                    Require all granted
                            </RequireAll>
                </Directory>

                <Directory /var/www/departamentos/internet/>
                            Options Indexes FollowSymLinks MultiViews
                            <RequireAll>
                                    Require ip 192.168.100
                                    Require all granted
                            </RequireAll>
                </Directory>

                #LogLevel info ssl:warn


                ErrorLog ${APACHE_LOG_DIR}/error.log
                CustomLog ${APACHE_LOG_DIR}/access.log combined

                #Include conf-available/serve-cgi-bin.conf

        </VirtualHost>

* Ahora añadiremos nuestro servidor al /etc/hosts de la anfitriona:

        192.168.100.200 departamentos.iesgn.org

* Y en nuestro cliente de la red local.

        172.22.100.5    departamentos.iesgn.org

* Comprobemos que funciona desde la anfitriona.

![departamentos](/control_acceso/1.png)

![intranet](/control_acceso/2.png)

* Y desde nuestro cliente.

![intranet](/control_acceso/3.png)

![internet](/control_acceso/4.png)

### Limita el acceso a la URL departamentos.iesgn.org/secreto.

* Nuestro primer paso para realizar esta tarea será crear un archivo con una contraseña, deberíamos crearlo en un directorio seguro.

        vagrant@cmsagv:/claves$ sudo htpasswd -c clave.txt root
        New password: 
        Re-type new password: 
        Adding password for user root

* En nuestro archivo de configuración debemos añadir lo siguiente.

        <Directory /var/www/departamentos/secreto/>
                AuthUserFile "/claves/clave.txt"
                AuthName "Solo acceso autorizado"
                AuthType Basic
                Require valid-user
        </Directory>

* Comprobemos que funciona.

![secreto](/control_acceso/5.png)

![secreto](/control_acceso/6.png)

### Cómo hemos visto la autentificación básica no es segura, modifica la autentificación para que sea del tipo digest, y sólo sea accesible a los usuarios pertenecientes al grupo directivos. Comprueba las cabeceras de los mensajes HTTP que se intercambian entre el servidor y el cliente. ¿Cómo funciona esta autentificación?

* Tendremos que cargar el módulo de digest para comenzar esta tarea.

        vagrant@cmsagv:/claves$ sudo a2enmod auth_digest
        Considering dependency authn_core for auth_digest:
        Module authn_core already enabled
        Enabling module auth_digest.
        To activate the new configuration, you need to run:
          systemctl restart apache2

* Ahora crearemos una nueva clave que será más segura que la anterior donde podremos especificar un usuario que formará parte de una especie de grupo.

        vagrant@cmsagv:/claves$ sudo htdigest -c clave2.txt directivos prueba
        Adding password for contraseña in realm directivos.
        New password: 
        Re-type new password:

* Y modificaremos el fichero de configuracion de departamentos, en concreto modificaremos las líneas que añadimos antes sobre el directorio `secreto` para que quede de la siguiete forma:

        <Directory /var/www/departamentos/secreto/>
                AuthUserFile "/claves/clave2.txt"
                AuthName "Solo acceso autorizado"
                AuthType Digest
                Require valid-user
        </Directory>

* Comprobamos que al introducir las credenciales que acabamos de crear podemos acceder.

![secreto](/control_acceso/7.png)
![secreto](/control_acceso/6.png)

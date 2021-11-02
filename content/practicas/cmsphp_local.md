+++
title = "Instalación local de un CMS PHP"
description = ""
tags = [
    "IWEB"
]
date = "2021-11-02"
menu = "main"
+++ 

## VagrantFile

    Vagrant.configure("2") do |config|
        config.vm.define :cmsagv do |cmsagv|
            cmsagv.vm.box = "debian/buster64"
            cmsagv.vm.hostname = "cmsagv"
            cmsagv.vm.network :private_network, ip: "172.22.100.5",
              virtualbox__intnet: "interna"
            cmsagv.vm.network :private_network, ip: "192.168.100.200"
        end
        config.vm.define :backup do |backup|
            backup.vm.box = "debian/buster64"
            backup.vm.hostname = "backup"
            backup.vm.network :private_network, ip: "172.22.100.10",
                    virtualbox__intnet: "interna"
        end
    end

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

    vagrant@cmsalegv:~$ sudo apt install php7.4 libapache2-mod-php7.4 php7.4-mysql php-common php7.4-cli php7.4-common php7.4-json php7.4-opcache php7.4-readline

**Tendremos que habilitar el mod de apache de PHP**

    vagrant@cmsalegv:~$ sudo a2enmod php7.4
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

        192.168.100.200 www.alegv-drupal.com

**Y ya podremos acceder a nuetro drupal**

![drupal](/cms_php/1.png)

**Y comenzamos con la instalación, en primer lugar realizaremos una instalación estandar.**

![estandar](/cms_php/2.png)

**Nos ha aparecido un error, como bien se ve al parecer faltan algunas librerias de php.**

![error](/cms_php/4.png)

**La solución es tan sencilla como instalarlas, en nuestro caso debemos instalar las siguientes:**

    vagrant@cmsagv:~$ sudo apt install php-xml php-gd php-mbstring

**Una vez hecho esto si no tenemos ningún otro error o warning pasaremos a la configuración de la base de datos, rellenaremos los datos oportunos que configuramos anteriormente en nuestra base de datos de mariadb.**

![base_datos](/cms_php/4.png)

**Una vez heche esto se pasará automáticamente a la instalación.**

![error](/cms_php/5.png)

**A continuación pasaremos a rellenar algunos datos necesarios para la configuración, como un nombre para nuestro sitio, un correo valido, un usuario y contraseña, etc...**

![config](/cms_php/6.png)

**Y finalmente tendremos nuestro drupal operativo**

![gg](/cms_php/7.png)

### Configuracion de Drupal

**Haremos algunas pequeñas configuraciones, como por ejemplo cambiar el tema, en el menu de arriba podemos entrar en aparencia y aparece la opción de instalar un nuevo tema.**

![newtheme](/cms_php/8.png)

**Lo que haremos será buscar un tema que nos guste en la [Pagina ofícial de oracle](https://www.drupal.org/project/project_theme) y añadir la url de descarga del archivo para la instalación como puede verse en la siguiente imágen.**

![instalacion](/cms_php/9.png)

------------------------------------------------------------

![hecho](/cms_php/10.png)

**Una vez elijamos el tema que recién hemos instalado cambiará la apariencia**

![apariencia](/cms_php/11.png)

**Vamos a ver como se crea contenido, también es bastante sencillo e intuitivo, simplemente iremos a la sección que podremos ver arriba de contenido y creamos un nuevo artículo, podremos añadir un título, cuerpo, imagenes, etc...**

![new_post](/cms_php/12.png)

![new_post](/cms_php/13.png)

**Para instalar un nuevo módulo nos dirijimos a la pestaña `ampliar`y tal y como hicimos para instalar el tema buscaremos un nuevo modulo que pueda interesarnos y los instalamos de la misma forma.**

![new_mod](/cms_php/14.png)

**Y lo activamos**

![new_mod](/cms_php/15.png)

## Copia de seguridad de la base de datos.

**realizar una copia de seguridad es muy sencillo, mariadb tiene una herramienta que nos permite hacerlo y volvar esta copia en un fichero:**

    root@cmsagv:~# mysqldump drupal > /backup.sql

    root@cmsagv:~# ls / | egrep backup
    backup.sql

**Ahora queremos configurar otro servidor de bbdd en otra máquina conectada a la nuestra por la red interna, ya tenemos esta máquina y esta red interna creada como pudimos ver en el VagrantFile. Así que entramos en ella e instalamos el servidor de mariadb tal como hicimos anteriormente. Crearemos una nueva base de datos.**

    MariaDB [(none)]> create database backup;
    Query OK, 1 row affected (0.001 sec)

**Ahora crearemos un usuario dentro de la misma, pero especificaremos que se conectará desde la ip del servidor apache donde nos conectaremos remotamente. Y por supuesto le daremos privilegios sobre la base de datos.**

    MariaDB [(none)]> CREATE USER 'usuario2'@'172.22.100.5' IDENTIFIED BY 'usuario2';
    Query OK, 0 rows affected (0.001 sec)

    MariaDB [(none)]> GRANT ALL PRIVILEGES ON backup.* to 'usuario2'@'172.22.100.5';
    Query OK, 0 rows affected (0.001 sec)

**Para permitir el acceso remoto debemos editar el fichero `/etc/mysql/mariadb.conf.d/50-server.cnf` y buscar la línea `bind-address`.**

    bind-address              = 127.0.0.1

**Lo único que deberemos hacer para permitir el acceso remoto es cambiar la dirección del localhost por 0.0.0.0**

    bind-address              = 0.0.0.0

**Nuestro siguiente paso será restaurar la copia de seguridad en nuestra nueva base de datos, para esto debemos recordar ponerle una contraseña a nuestras máquinas vagrant, sino no nos permitirá realizar una conexión ssh entre las mismas y también deberemos cambiar una línea del fichero de configuración de las dos máquinas `/etc/ssh/sshd_config` para que nos pida autentificación al conectarnos por ssh**

    PasswordAuthentication yes

**Enviamos el fichero y comprobamos que lo hemos recibido:**

    vagrant@cmsagv:~$ sudo scp /backup.sql vagrant@172.22.100.10:/home/vagrant/

    vagrant@backup:~$ ls
    backup.sql

**El proceso de importación a nuestra base de datos es igual de sencillo que fue exportarlo al backup:**

    root@backup:~# mysql backup < /home/vagrant/backup.sql

**Si entramos en la base de datos y hacemos un `show tables` podremos comprobar que la copia e importación se ha hecho correctamente**

    MariaDB [(none)]> use backup;
    Reading table information for completion of table and column names
    You can turn off this feature to get a quicker startup with -A

    Database changed
    MariaDB [backup]> show tables;
    +----------------------------------+
    | Tables_in_backup                 |
    +----------------------------------+
    | batch                            |
    | block_content                    |
    | block_content__body              |
    | block_content_field_data         |
    | block_content_field_revision     |
    | block_content_revision           |
    | block_content_revision__body     |
    | cache_bootstrap                  |
    | cache_config                     |
    | cache_container                  |
    | cache_data                       |
    | cache_default                    |
    | cache_discovery                  |
    | cache_dynamic_page_cache         |
    | cache_entity                     |
    | cache_menu                       |
    | cache_render                     |
    | cachetags                        |
    | comment                          |
    | comment__comment_body            |
    | comment_entity_statistics        |
    | comment_field_data               |
    | config                           |
    | file_managed                     |
    | file_usage                       |
    | history                          |
    | key_value                        |
    | key_value_expire                 |
    | locale_file                      |
    | locales_location                 |
    | locales_source                   |
    | locales_target                   |
    | menu_link_content                |
    | menu_link_content_data           |
    | menu_link_content_field_revision |
    | menu_link_content_revision       |
    | menu_tree                        |
    | node                             |
    | node__body                       |
    | node__comment                    |
    | node__field_image                |
    | node__field_tags                 |
    | node_access                      |
    | node_field_data                  |
    | node_field_revision              |
    | node_revision                    |
    | node_revision__body              |
    | node_revision__comment           |
    | node_revision__field_image       |
    | node_revision__field_tags        |
    | path_alias                       |
    | path_alias_revision              |
    | queue                            |
    | router                           |
    | search_dataset                   |
    | search_index                     |
    | search_total                     |
    | semaphore                        |
    | sequences                        |
    | sessions                         |
    | shortcut                         |
    | shortcut_field_data              |
    | shortcut_set_users               |
    | taxonomy_index                   |
    | taxonomy_term__parent            |
    | taxonomy_term_data               |
    | taxonomy_term_field_data         |
    | taxonomy_term_field_revision     |
    | taxonomy_term_revision           |
    | taxonomy_term_revision__parent   |
    | user__roles                      |
    | user__user_picture               |
    | users                            |
    | users_data                       |
    | users_field_data                 |
    | watchdog                         |
    +----------------------------------+
    76 rows in set (0.001 sec)

**Como nuestro objetivo es usar esta base de datos nueva eliminaremos la que teniamos al principio en nuestro servidor principal.**

    vagrant@cmsagv:~$ sudo apt purge mariadb-client-10.4 mariadb-server-10.4

**Por supuesto esto hará que nuestro drupal deje de funcionar, por ello tendremos que configurarlo para que use esta nueva base de datos. y para ello en primer lugar tendremos que configurar el fichero `/var/www/drupal/sites/default/settings.php` donde encontraremos un bloque de código como el siguiente con la información de nuestro antiguo servidor de bbdd.**

    $databases['default']['default'] = array (
      'database' => 'drupal',
      'username' => 'usuario1',
      'password' => 'usuario1',
      'prefix' => '',
      'host' => 'localhost',
      'port' => '3306',
      'namespace' => 'Drupal\\Core\\Database\\Driver\\mysql',
      'driver' => 'mysql',
    );

**Sustituiremos la información adecuadamente**

    $databases['default']['default'] = array (
      'database' => 'backup',
      'username' => 'usuario2',
      'password' => 'usuario2',
      'prefix' => '',
      'host' => '172.22.100.10',
      'port' => '3306',
      'namespace' => 'Drupal\\Core\\Database\\Driver\\mysql',
      'driver' => 'mysql',
    );

## Instalación de un nuevo CMS PHP

* Vamos a instalar un joomla, para ello descargaremos de [la página oficial](https://downloads.joomla.org/) la aplicación.

~~~
vagrant@cmsagv:~$ wget https://downloads.joomla.org/cms/joomla4/4-0-4/Joomla_4-0-4-Stable-Full_Package.zip?format=zip
~~~
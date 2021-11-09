+++
title = "Instalación de servidores y clientes"
description = ""
tags = [
    "ABD"
]
date = "2021-04-05"
menu = "main"
+++

Tras la instalación de cada servidor,  debe crearse una base de datos con al menos tres tablas o colecciones y poblarse de datos adecuadamente. Debe crearse un usuario y dotarlo de los privilegios necesarios para acceder remotamente a los datos. Se proporcionará esta información al resto de los miembros del grupo.

* Los clientes deben estar siempre en máquinas diferentes de los respectivos servidores a los que acceden.
* Se documentará todo el proceso de configuración de los servidores.
* Se aportarán pruebas del funcionamiento remoto de cada uno de los clientes.
* Se aportará el código de las aplicaciones realizadas y prueba de funcionamiento de las mismas.

## Instalación servidor Oracle 19c

* Hemos creado una maquina vagrant con centos 8 para instalar nuestro servidor de Oracle 19c, lo descargaremos de la [página oficial de Oracle](https://www.oracle.com/es/database/technologies/oracle19c-linux-downloads.html#license-lightbox) y llevamos el fichero de instalación a nuestra máquina usando scp.

~~~
[vagrant@oracle ~]$ [vagrant@oracle ~]$ scp alejandrogv@172.22.1.226:/home/alejandrogv/Descargas/oracle.rpm .
~~~

* Debemos instalar las dependencias necesarias:

~~~
[vagrant@oracle ~]$ sudo dnf install -y bc binutils elfutils-libelf elfutils-libelf-devel fontconfig-devel glibc glibc-devel ksh libaio libaio-devel libXrender libXrender-devel libX11 libXau libXi libXtst libgcc librdmacm-devel libstdc++ libstdc++-devel libxcb make net-tools smartmontools sysstat unzip libnsl libnsl2
~~~

* Descargamos el preinstall de oracle.

~~~
curl -o oracle-database-preinstall-19c-1.0-2.el8.x86_64.rpm https://yum.oracle.com/repo/OracleLinux/OL8/appstream/x86_64/getPackage/oracle-database-preinstall-19c-1.0-2.el8.x86_64.rpm
~~~

* Ahora instalamos el preinstall y la base de datos en si:

~~~
[vagrant@oracle ~]$ sudo dnf install oracle-database-preinstall-19c-1.0-2.el8.x86_64.rpm
[vagrant@oracle ~]$ sudo dnf install oracle.rpm
~~~

* Y procedemos a configurarlo:

~~~
[vagrant@oracle ~]$ sudo /etc/init.d/oracledb_ORCLCDB-19c configure
~~~

* Creamos los grupos y usuarios que necesitará oracle.

~~~
[vagrant@oracle ~]$ sudo groupadd -g 1501 oinstall
[vagrant@oracle ~]$ sudo groupadd -g 1502 dba
[vagrant@oracle ~]$ sudo groupadd -g 1503 oper
[vagrant@oracle ~]$ sudo groupadd -g 1504 backupdba
[vagrant@oracle ~]$ sudo groupadd -g 1505 dgdba
[vagrant@oracle ~]$ sudo groupadd -g 1507 racdba
[vagrant@oracle ~]$ sudo groupadd -g 1506 kmdba
~~~

* Y cambiamos la contraseña del usuario "oracle".

~~~
[root@oracle ~]# echo "oracle" | passwd oracle --stdin
Changing password for user oracle.
passwd: all authentication tokens updated successfully.
~~~

* Cambiamos el modo de selinux a permisivo para que no nos de problemas.

~~~
[root@oracle ~]# sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/sysconfig/selinux
[root@oracle ~]# setenforce permissive
~~~

* Creamos los diferentes directorios que necesitará oracle y le damos permisos a los usuarios necesarios sobre ellos.

~~~
[root@oracle ~]# mkdir -p /u01/app/oracle/product/19.3.0/dbhome_1
[root@oracle ~]# mkdir -p /u02/oradata
[root@oracle ~]# chown -R oracle:oinstall /u01 /u02
[root@oracle ~]# chmod -R 775 /u01 /u02
~~~

* Ahora entramos en el usuario oracle y en su fichero `.bash_profile` añadimos las siguientes variables de entorno.

~~~
# Oracle Settings
export TMP=/tmp
export TMPDIR=$TMP

export ORACLE_HOSTNAME=oracle-db-19c.centlinux.com
export ORACLE_UNQNAME=cdb1
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/19.3.0/dbhome_1
export ORA_INVENTORY=/u01/app/oraInventory
export ORACLE_SID=cdb1
export PDB_NAME=pdb1
export DATA_DIR=/u02/oradata

export PATH=$ORACLE_HOME/bin:$PATH

export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
export CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib
~~~

* ejecutamos este fichero.

~~~
[oracle@oracle ~]$ source ~/.bash_profile
~~~

* Una vez seguidos todos estos pasos descomprimimos el instalador de oracle que descargamos antes en los directorios de oracle que creamos antes y para ello usamos una de las variables que definimos anteriormente.

~~~
[oracle@oracle ~]$ unzip LINUX.X64_193000_db_home.zip -d $ORACLE_HOME
~~~

* En el fichero `$ORACLE_HOME/cv/admin/cvu_config` descomentamos la siguiente línea.

~~~
CV_ASSUME_DISTID=OEL5
~~~

* ahora usemos el instalador de oracle.

~~~
[oracle@oracle dbhome_1]$ ./runInstaller -ignorePrereq -waitforcompletion -silent \
oracle.install.option=INSTALL_DB_SWONLY \
ORACLE_HOSTNAME=${ORACLE_HOSTNAME} \
UNIX_GROUP_NAME=oinstall \
INVENTORY_LOCATION=${ORA_INVENTORY} \
ORACLE_HOME=${ORACLE_HOME} \
ORACLE_BASE=${ORACLE_BASE} \
oracle.install.db.InstallEdition=EE \
oracle.install.db.OSDBA_GROUP=dba \
oracle.install.db.OSBACKUPDBA_GROUP=backupdba \
oracle.install.db.OSDGDBA_GROUP=dgdba \
oracle.install.db.OSKMDBA_GROUP=kmdba \
oracle.install.db.OSRACDBA_GROUP=racdba \
SECURITY_UPDATES_VIA_MYORACLESUPPORT=false \    
DECLINE_SECURITY_UPDATES=true
~~~

* Una vez instalada podemos comprobar que accedemos a la misma.

~~~
[oracle@oracle ~]$ sqlplus / as sysdba 

SQL*Plus: Release 19.0.0.0.0 - Production on Tue Oct 5 09:01:50 2021
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.

Connected to an idle instance.

SQL>
~~~

* Podemos comprobar una pequeña información para ver que nuestra base de datos está operativa

        SQL> SELECT instance_name, host_name, version, startup_time FROM v$instance;

        INSTANCE_NAME
        ----------------
        HOST_NAME
        ----------------------------------------------------------------
        VERSION 	  STARTUP_T
        ----------------- ---------
        ORCLCDB
        oracle
        19.0.0.0.0	  05-APR-21

* Pudiera ser que nos diera un error, esto se puede deber a que la base de datos de prueba no esté montada, para solucionarlo usariamos `STARTUP` y debería solucionarse el problema.

* El siguiente paso será la creación de un usuario y otorgarle permisos al mismo

        SQL> CREATE USER c##ale IDENTIFIED BY ale;      

        User created.

        SQL> GRANT ALL PRIVILEGES TO c##ale;

        Grant succeeded.

* Nos desconectamos de este usuario y entramos en el recien creado para comprobar que funciona

        SQL> DISCONNECT
        Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
        Version 19.3.0.0.0
        SQL> CONNECT c##ale/ale
        Connected.

* Hemos creado unas tablas y añadido contenido a las mismas.

        SQL> SELECT * FROM propietarios;
        
        NIF	  NOMBRE	  APELLIDOS			 CUOTA
        --------- --------------- ------------------------- ----------
        61219065B Mario 	  Guti??rrez Valencia		   300
        20015195C Alexandra	  Angulo Lamas			   320
        19643077L Miriam	  Zafra Valencia		    45
        33599573T Josue 	  Reche de los Santos		    50
        X4164637G Christian	  Lopez Reyes			    50
        
        SQL> SELECT * FROM caballos;
        
        CODIGOCABA NIFPROPIE NOMBRE	     FECHNAC   RAZA
        ---------- --------- --------------- --------- --------------------
        1234567890 61219065B Sardinilla      22-APR-10 Arabe
        0987654321 61219065B Caramelo	     27-MAR-13 Mustang
        1098743564 20015195C Marques	     07-OCT-11 Mustang
        2348743564 20015195C Juan Valdez     15-NOV-08 Purasangre
        4348486564 19643077L Tarantino	     13-DEC-09 Lusitano
        3348486935 19643077L Paco	     07-JUN-14 Purasangre
        3348454346 33599573T Connell	     25-JUL-07 Akhal-Teke
        5438454346 33599573T Faraon	     23-MAY-12 Akhal-Teke
        5438345346 33599573T Isabel	     23-APR-12 Holsteiner
        3958345174 X4164637G Rafael	     05-FEB-10 Arabe
        
        10 rows selected.
        
        SQL> SELECT * FROM caballos_carreras;
        
        CODIGOCABA EDADMINPART EDADMAXPART
        ---------- ----------- -----------
        1234567890
        0987654321
        1098743564
        2348743564
        4348486564
        3348486935
        3348454346
        5438454346
        5438345346
        3958345174
        
        10 rows selected.

## Instalación de servidor MYSQL.

* la instalación es muy sencilla, simplemente instalamos el servidor de mariadb con un simple apt.

        vagrant@mysql:~$ sudo apt install mariadb-server

* Podemos entrar al servidor.

* Creamos un usuario.

        MariaDB [(none)]> CREATE USER 'ale'@'%' IDENTIFIED BY 'ale';
        Query OK, 0 rows affected (0.001 sec)

* Y al crear una base de datos debemos darle a nuestro usuario permisos sobre la misma.

        MariaDB [(none)]> CREATE DATABASE prueba;
        Query OK, 1 row affected (0.001 sec)

        MariaDB [(none)]> GRANT ALL PRIVILEGES ON prueba.* TO 'ale'@'%';
        Query OK, 0 rows affected (0.001 sec)

* Hemos creado algunas tablas y le hemos añadido datos.

        MariaDB [prueba]> SELECT * FROM Propietarios;
        +-----------+-----------+---------------------+--------+
        | NIF       | Nombre    | Apellidos           | Cuota  |
        +-----------+-----------+---------------------+--------+
        | 19643077L | Miriam    | Zafra Valencia      |  45.00 |
        | 20015195C | Alexandra | Angulo Lamas        | 320.00 |
        | 33599573T | Josue     | Reche de los Santos |  50.00 |
        | 61219065B | Mario     | Gutiérrez Valencia  | 300.00 |
        | X4164637G | Christian | Lopez Reyes         |  50.00 |
        +-----------+-----------+---------------------+--------+
        5 rows in set (0.001 sec)

        MariaDB [prueba]> SELECT * FROM Caballos;
        +---------------+----------------+-------------+------------+------------+
        | CodigoCaballo | NIFPropietario | Nombre      | FechNac    | Raza       |
        +---------------+----------------+-------------+------------+------------+
        | 1098743564    | 20015195C      | Marques     | 2011-11-07 | Mustang    |
        | 1234567890    | 61219065B      | Sardinilla  | 2010-03-22 | Arabe      |
        | 2348743564    | 20015195C      | Juan Valdez | 2008-02-15 | Purasangre |
        | 3958345174    | X4164637G      | Rafael      | 2010-05-06 | Arabe      |
        | 4348486564    | 19643077L      | Tarantino   | 2009-10-13 | Lusitano   |
        +---------------+----------------+-------------+------------+------------+
        5 rows in set (0.000 sec)

        MariaDB [prueba]> SELECT * FROM Caballos_Carreras;
        +---------------+-------------+-------------+
        | CodigoCaballo | EdadMinPart | EdadMaxPart |
        +---------------+-------------+-------------+
        | 1234567890    |        NULL |        NULL |
        | 2348743564    |        NULL |        NULL |
        | 4348486564    |        NULL |        NULL |
        +---------------+-------------+-------------+
        3 rows in set (0.001 sec)

### Configuración para acceso remoto de MYSQL.

* Debemos editar el fichero `/etc/mysql/mariadb.conf.d/50-server.cnf` y buscar la línea `bind-address`.

        bind-address              = 127.0.0.1

* Lo único que deberemos hacer para permitir el acceso remoto es cambiar la dirección del localhost por 0.0.0.0

        bind-address              = 0.0.0.0

* Ahora en la base de datos crearemos un usuario que especificaremos donde se encuentra, podríamos poner una sola IP específica, sin embargo permitiremos que se pueda acceder desde cualquier sitio usando `%`. Le daremos permisos sobre la base de datos y tendremos que ponerle contraseña a nuestro usuario.

        MariaDB [(none)]> CREATE USER 'remoto1'@'%' IDENTIFIED BY 'remoto';
        Query OK, 0 rows affected (0.161 sec)

        MariaDB [(none)]> GRANT ALL PRIVILEGES ON prueba.* TO 'remoto'@'%';
        Query OK, 0 rows affected (0.164 sec)

        MariaDB [(none)]> SET PASSWORD FOR 'remoto'@'%' = PASSWORD('remoto');

* Comprobamos que podemos acceder a nuestra base de datos desde el ciente.

        root@clientemysql:~# mysql -h 172.22.100.5 -u remoto -p
        Enter password: 
        Welcome to the MariaDB monitor.  Commands end with ; or \g.
        Your MariaDB connection id is 41
        Server version: 10.3.27-MariaDB-0+deb10u1 Debian 10

        Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

        Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

        MariaDB [(none)]> use prueba;
        Reading table information for completion of table and column names
        You can turn off this feature to get a quicker startup with -A

        Database changed
        MariaDB [prueba]>

* Vemos que podemos trabajar con la base de datos de prueba que creamos anteriormente.

        MariaDB [prueba]> SHOW TABLES;
        +-------------------+
        | Tables_in_prueba  |
        +-------------------+
        | Caballos          |
        | Caballos_Carreras |
        | Propietarios      |
        +-------------------+
        3 rows in set (0.002 sec)

### Cliente remoto de SQL*PLUS

* A continuación, configuraremos nuestro servidor para que escuche las peticiones que se hacen de fuera, si vemos el fichero `/opt/oracle/product/19c/dbhome_1/network/admin/listener.ora` podremos ver que se especifica justo antes de donde aparece el puerto donde escucha que solo escucha las peticiones de myhost, es decir, el localhost.

        LISTENER =
          (DESCRIPTION_LIST =
            (DESCRIPTION =
              (ADDRESS = (PROTOCOL = TCP)(HOST = myhost)(PORT = 1521))
              (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
            )
          )

* Lo modificaremos y podremos la dirección `0.0.0.0` para que escuche todas las peticiones de fuera.

        LISTENER =
          (DESCRIPTION_LIST =
            (DESCRIPTION =
              (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521))
              (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
            )
          )

* E iniciamos la escucha.

[oracle@oracle ~]$ lsnrctl start

        LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 13-APR-2021 07:17:12

        Copyright (c) 1991, 2019, Oracle.  All rights reserved.

        Starting /opt/oracle/product/19c/dbhome_1/bin/tnslsnr: please wait...

        TNSLSNR for Linux: Version 19.0.0.0.0 - Production
        System parameter file is /opt/oracle/product/19c/dbhome_1/network/admin/listener.ora
        Log messages written to /opt/oracle/diag/tnslsnr/oracle/listener/alert/log.xml
        Listening on: (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=0.0.0.0)(PORT=1521)))
        Listening on: (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1521)))

        Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=0.0.0.0)(PORT=1521)))
        STATUS of the LISTENER
        ------------------------
        Alias                     LISTENER
        Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
        Start Date                13-APR-2021 07:17:14
        Uptime                    0 days 0 hr. 0 min. 0 sec
        Trace Level               off
        Security                  ON: Local OS Authentication
        SNMP                      OFF
        Listener Parameter File   /opt/oracle/product/19c/dbhome_1/network/admin/listener.ora
        Listener Log File         /opt/oracle/diag/tnslsnr/oracle/listener/alert/log.xml
        Listening Endpoints Summary...
          (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=0.0.0.0)(PORT=1521)))
          (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1521)))
        The listener supports no services
        The command completed successfully

* En el cliente debemos instalar el paquete alien y descargar de la [página oficial de oracle](https://www.oracle.com/es/database/technologies/instant-client/linux-x86-64-downloads.html) los siguientes paquetes:

        oracle-instantclient19.6-basic-19.6.0.0.0-1.x86_64.rpm
        oracle-instantclient19.6-devel-19.6.0.0.0-1.x86_64.rpm
        oracle-instantclient19.6-sqlplus-19.6.0.0.0-1.x86_64.rpm

* Como se han descargado archivos RPM y tenemos un debian, podriamos convertirlos facilmente a una extensión DEB con el paquete recién instalado alien e instalariamos todos los paquetes.

        vagrant@clientoracle:~$ sudo alien oracle-instantclient19.6-basic-19.6.0.0.0-1.x86_64.rpm 
        Warning: Skipping conversion of scripts in package oracle-instantclient19.6-basic: postinst postrm
        Warning: Use the --scripts parameter to include the scripts.
        oracle-instantclient19.6-basic_19.6.0.0.0-2_amd64.deb generated

        vagrant@clientoracle:~$ sudo dpkg -i oracle-instantclient19.6-basic_19.6.0.0.0-2_amd64.deb 
        (Reading database ... 34588 files and directories currently installed.)
        Preparing to unpack oracle-instantclient19.6-basic_19.6.0.0.0-2_amd64.deb ...
        Unpacking oracle-instantclient19.6-basic (19.6.0.0.0-2) ...
        Setting up oracle-instantclient19.6-basic (19.6.0.0.0-2) ...
        Processing triggers for libc-bin (2.28-10) ...

* Creamos el fichero de configuración `/etc/ld.so.conf.d/oracle.conf` y añadimos la siguiente línea:

        /usr/lib/oracle/19.6/client64/lib/

* Y actualizamos la configuración:

        vagrant@clientoracle:~$ sudo ldconfig

### Aplicación web para postgres


* Por supuesto, primero instalamos postgres

        vagrant@postgres:~$ sudo apt install postgresql

* Instalaremos phppgadmin para poder administrar nuestra base de datos mediante una aplicación web.

        vagrant@postgres:~$ sudo apt install phppgadmin

* Ahora configuraremos esta aplicación, para ello lo primero que debemos hacer es permitir que se pueda acceder de forma remota en el archivo de configuración `/etc/apache2/conf-available/phppgadmin.conf` comentaremos la siguiente línea.

        #Require local

* Crearemos una base de datos y usuario al que daremos permisos sobre esta base de datos.

        postgres=# CREATE DATABASE prueba;
        CREATE DATABASE
        postgres=# CREATE USER usuario1 WITH PASSWORD 'usuario1';
        CREATE ROLE
        postgres=# GRANT ALL PRIVILEGES ON DATABASE prueba to usuario1;
        GRANT

* Una vez añadimos contenido a esta base de datos podremos conectarnos desde nuestro navegador.

![phppgadmin](/servidores_bbdd/1.png)

* Nos identificaremos con el usuario que creamos anteriormente y podremos acceder a las bases de datos sobre las que tiene privilegio y podríamos por ejemplo ver las tablas e información que tenemos en la misma. 

![phppgadmin](/servidores_bbdd/2.png)

![phppgadmin](/servidores_bbdd/3.png)

### Instalación de mongodb y una herramienta de administración web.

* Instalaremos mongodb, los pasos serían descargar el repositorio añadiendo la clave pública y añadir este repositorio a nuestro `sources.list`

        vagrant@mongo:~$ sudo wget https://www.mongodb.org/static/pgp/server-4.4.asc -qO- | sudo apt-key add -

        root@mongo:~# echo "deb http://repo.mongodb.org/apt/debian buster/mongodb-org/4.4 main" > /etc/apt/sources.list.d/mongodb-org-4.4.list

* Una vez hecho esto podremos instalar mongodb

        vagrant@mongo:~$ sudo apt install mongodb-org

* Entramos en la base de datos y nos autentificaremos con el usuario administrador.

        vagrant@mongo:~$ mongo
        MongoDB shell version v4.4.5
        connecting to: mongodb://127.0.0.1:27017/?compressors=disabled&gssapiServiceName=mongodb
        Implicit session: session { "id" : UUID("ff7e45d7-a6fb-4505-abb4-036f43dd5c26") }
        MongoDB server version: 4.4.5
        Welcome to the MongoDB shell.
        For interactive help, type "help".
        For more comprehensive documentation, see
        	https://docs.mongodb.com/
        Questions? Try the MongoDB Developer Community Forums
        	https://community.mongodb.com
        ---
        The server generated these startup warnings when booting: 
                2021-04-28T08:05:23.509+00:00: Using the XFS filesystem is strongly recommended with the WiredTiger storage engine. See http://dochub.mongodb.org/core/ prodnotes-filesystem
                2021-04-28T08:05:23.943+00:00: Access control is not enabled for the database. Read and write access to data and configuration is unrestricted
        ---
        ---
                Enable MongoDB's free cloud-based monitoring service, which will then receive and display
                metrics about your deployment (disk utilization, CPU, operation statistics, etc).

                The monitoring data will be available on a MongoDB website with a unique URL accessible to you
                and anyone you share the URL with. MongoDB may use this information to make product
                improvements and to suggest MongoDB products and deployment options to you.

                To enable free monitoring, run the following command: db.enableFreeMonitoring()
                To permanently disable this reminder, run the following command: db.disableFreeMonitoring()
        ---
        > use admin
        switched to db admin

* Creamos un usuario.

        > db.createUser(
        ... {
        ... user: "usuario",
        ... pwd: "usuario",
        ... roles: [ { role: "userAdminAnyDatabase", db: "admin" }, "readWriteAnyDatabase" ]
        ... }
        ... )
        Successfully added user: {
        	"user" : "usuario",
        	"roles" : [
        		{
        			"role" : "userAdminAnyDatabase",
        			"db" : "admin"
        		},
        		"readWriteAnyDatabase"
        	]
        }

* Modificaremos el fichero `/etc/mongod.conf` para activar la autentificación y reiniciaremos el servicio para que haga efecto. 

        security:
          authorization: enabled

        
        vagrant@mongo:~$ sudo systemctl restart mongod

* Veamos las bases de datos que tenemos, he creado una para tener un poco de contenido.

        > show dbs
        admin   0.000GB
        config  0.000GB
        local   0.000GB
        local   0.000GB

* Una vez tenemos nuestra base de datos a punto instalaremos nuestro administrador web. He elegido Rockmongo para ello instalaremos las dependencias necesarias.

        vagrant@mongo:~$ sudo apt install apache2 gcc php php-gd php-pear unzip wget php7.3-dev

        vagrant@mongo:~$ sudo pecl install mongodb

* Necesitamos modificar el fichero `/etc/php/7.3/apache2/php.ini` y añadir la siguiente línea:

        extension=mongo.so

* Debemos clonar el repositorio del modulo de php para mongo.

        vagrant@mongo:~ git clone https://github.com/mongodb/mongo-php-driver-legacy.git
        vagrant@mongo:~/mongo-php-driver$ git submodule sync && git submodule update --init

* Seguidamente entraremos en el repositorio y ejecutaremos el siguiente comando.

        vagrant@mongo:~/mongo-php-driver$ phpize
        Configuring for:
        PHP Api Version:         20180731
        Zend Module Api No:      20180731
        Zend Extension Api No:   320180731

* Ahora ejecutaremos el script que está dentro del repositorio `configure`.

        vagrant@mongo:~/mongo-php-driver$ ./configure

* Y por último instalaremos el módulo.

        vagrant@mongo:~/mongo-php-driver$ sudo make all

        vagrant@mongo:~/mongo-php-driver$ sudo make install
        Installing shared extensions:     /usr/lib/php/20180731/

* Clonaremos el respositorio de github de Rockmongo y añadiremos esta aplicación a un DocumentRoot

        vagrant@mongo:~$ git clone https://github.com/iwind/rockmongo.git

        vagrant@mongo:~$ sudo mv rockmongo/ /var/www/

* Y en el fichero `config.php` que está dentro del respositorio configuraremos la siguiente línea

        $MONGO["servers"][$i]["mongo_host"] = "0.0.0.0";//mongo host

* Y ya tendriamos instalado rockmongo.
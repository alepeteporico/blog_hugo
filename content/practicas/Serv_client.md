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

        [vagrant@oracle ~]$ scp alejandrogv@192.168.1.15:/home/alejandrogv/Descargas/oracle-database-ee-19c-1.0-1.x86_64.rpm .

* El siguiente paso será obviamente instalarlo.

        [vagrant@oracle ~]$ sudo dnf install https://yum.oracle.com/repo/OracleLinux/OL8/baseos/latest/x86_64/getPackage/oracle-database-preinstall-19c-1.0-1.el8.x86_64.rpm

        [vagrant@oracle ~]$ sudo yum -y localinstall oracle-database-ee-19c-1.0-1.x86_64.rpm
        
* Antes de crear la base de datos de ejemplo debemos tener en cuenta que nos dará error si nuestra memoria RAM es inferior a 2GB. También he experimentado un error ya que no me resolvía el DNS de oracle, por eso he tenido que modificar mi /etc/hosts y añadir la siguiente línea:

        10.0.2.15 myhost

* Ahora si, creamos la base de datos de ejemplo

        [oracle@oracle ~]$ sudo /etc/init.d/oracledb_ORCLCDB-19c configure
        Configuring Oracle Database ORCLCDB.
        Prepare for db operation
        8% complete
        Copying database files
        31% complete
        Creating and starting Oracle instance
        32% complete
        36% complete
        40% complete
        43% complete
        46% complete
        Completing Database Creation
        51% complete
        54% complete
        Creating Pluggable Databases
        58% complete
        77% complete
        Executing Post Configuration Actions
        100% complete
        Database creation complete. For details check the logfiles at:
         /opt/oracle/cfgtoollogs/dbca/ORCLCDB.
        Database Information:
        Global Database Name:ORCLCDB
        System Identifier(SID):ORCLCDB
        Look at the log file "/opt/oracle/cfgtoollogs/dbca/ORCLCDB/ORCLCDB5.log" for further details.

Database configuration completed successfully. The passwords were auto generated, you must change them by connecting to the database using 'sqlplus / as sysdba' as the oracle user.

* Continuemos con los usuarios, accedamos al usuario que se ha creado por defecto al instalar el paquete de oracle con su mismo nombre.

        [vagrant@oracle ~]$ sudo su - oracle

* Y tendremos que modifcar el fichero `~/.bash_profile` añadiendo algunas lineas como las que vemos a continuación

        [oracle@oracle ~]$ cat .bash_profile 
        # .bash_profile
        
        # Get the aliases and functions
        if [ -f ~/.bashrc ]; then
        	. ~/.bashrc
        fi
        
        umask 022
        export ORACLE_SID=ORCLCDB
        export ORACLE_BASE=/opt/oracle/oradata
        export ORACLE_HOME=/opt/oracle/product/19c/dbhome_1
        export PATH=$PATH:$ORACLE_HOME/bin

* Este fichero se ejecuta cada vez que iniciamos sesión en este usuario. sin necesidad de tener que salir ni reiniciar la máquina podemos usar `source` para ejecutarlo

        [oracle@oracle ~]$ source .bash_profile

* Finalmente podremos entrar en sqlplus.

        [oracle@oracle ~]$ sqlplus / as sysdba

        SQL*Plus: Release 19.0.0.0.0 - Production on Mon Apr 5 12:03:44 2021
        Version 19.3.0.0.0

        Copyright (c) 1982, 2019, Oracle.  All rights reserved.

        Connected to an idle instance.

        SQL>

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

* En primer lugar tendremos que añadir un hostname en nuestro servidor añadiendo la siguiente línea a nuestro `/etc/hosts`.

        172.22.100.15   oracle.alegv.bd     oracle

* A continuación, configuraremos nuestro servidor para que escuche las peticiones que se hacen de fuera, si vemos el fichero `/opt/oracle/product/19c/dbhome_1/network/admin/listener.ora` podremos ver que se especifica justo antes de donde aparece el puerto donde escucha que solo escucha las peticiones de myhost, es decir, el localhost.

        LISTENER =
          (DESCRIPTION_LIST =
            (DESCRIPTION =
              (ADDRESS = (PROTOCOL = TCP)(HOST = myhost)(PORT = 1521))
              (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
            )
          )

* Lo modificaremos y podremos nuestro hostname para escuchar todas las peticiones de nuestra interfaz de red local.

        LISTENER =
          (DESCRIPTION_LIST =
            (DESCRIPTION =
              (ADDRESS = (PROTOCOL = TCP)(HOST = oracle.alegv.bd)(PORT = 1521))
              (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
            )
          )

* E iniciamos la escucha.

        [oracle@oracle ~]$ lsnrctl start

        LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 12-APR-2021 17:54:57

        Copyright (c) 1991, 2019, Oracle.  All rights reserved.

        Starting /opt/oracle/product/19c/dbhome_1/bin/tnslsnr: please wait...

        TNSLSNR for Linux: Version 19.0.0.0.0 - Production
        System parameter file is /opt/oracle/product/19c/dbhome_1/network/admin/listener.ora
        Log messages written to /opt/oracle/diag/tnslsnr/oracle/listener/alert/log.xml
        Listening on: (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=oracle.alegv.bd)(PORT=1521)))
        Listening on: (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1521)))

        Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=oracle.alegv.bd)(PORT=1521)))
        STATUS of the LISTENER
        ------------------------
        Alias                     LISTENER
        Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
        Start Date                12-APR-2021 17:54:59
        Uptime                    0 days 0 hr. 0 min. 0 sec
        Trace Level               off
        Security                  ON: Local OS Authentication
        SNMP                      OFF
        Listener Parameter File   /opt/oracle/product/19c/dbhome_1/network/admin/listener.ora
        Listener Log File         /opt/oracle/diag/tnslsnr/oracle/listener/alert/log.xml
        Listening Endpoints Summary...
          (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=oracle.alegv.bd)(PORT=1521)))
          (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1521)))
        The listener supports no services
        The command completed successfully


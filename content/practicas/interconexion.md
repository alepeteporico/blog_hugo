+++
title = "Interconexión de servidores de bases de datos"
description = ""
tags = [
    "ABD"
]
date = "2021-05-05"
menu = "main"
+++

* Realizar un enlace entre dos servidores de bases de datos ORACLE, explicando la configuración necesaria en ambos extremos y demostrando su funcionamiento.

* Realizar un enlace entre dos servidores de bases de datos Postgres, explicando la configuración necesaria en ambos extremos y demostrando su funcionamiento.

* Realizar un enlace entre un servidor ORACLE y otro Postgres o MySQL empleando Heterogeneus Services, explicando la configuración necesaria en ambos extremos y demostrando su funcionamiento.

## Conexión entre ORACLE

* Usaremos dos máquina vagrant con centos 8 e instalaremos oracle 19c en cada una.

* Vamos conigurar el que será nuestro servidor en la máquina oracle1.

        [vagrant@oracle1 ~]$ cat /opt/oracle/product/19c/dbhome_1/network/admin/listener.ora
        SID_LIST_LISTENER=
          (SID_LIST=
            (SID_DESC=
              (GLOBAL_DBNAME=orcl)
              (ORACLE_HOME=/u01/app/oracle/product/19c/dbhome_1)
              (SID_NAME=orcl))
          )
        
        LISTENER =
        (DESCRIPTION_LIST =
          (DESCRIPTION =
            (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
            (ADDRESS = (PROTOCOL = TCP)(HOST = 172.22.100.15)(PORT = 1521))
          )
        )

* Seguidamente haremos lo mismo con nuestro cliente, oracle2.

        [vagrant@oracle2 ~]$ sudo cat /opt/oracle/product/19c/dbhome_1/network/admin/listener.ora
        LISTENER_ORCL =
         (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))

        ORCL =
         (DESCRIPTION = Servidor ORACLE
            (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))
            (CONNECT_DATA =
                (SERVER = DEDICATED)
                (SERVICE_NAME = orcl)
            )
         )

        OracleServer =
         (DESCRIPTION = Servidor Oracle1
            (ADDRESS = (PROTOCOL = TCP)(HOST = 172.22.100.15)(PORT = 1521))
            (CONNECT_DATA =
                (SERVER = DEDICATED)
                (SERVICE_NAME = oracle2)
            )

## Conexión entre Postgres.

* Usaremos dos máquinas vagrant con debian buster.

* primero configuraremos postgres1 que nos servirá como servidor principal, el primer archivo que configuraremos será `/etc/postgresql/11/main/postgresql.conf` y podremos el listener a 0.

        listen_addresses = '0'

* Seguidamente configuraremos `/etc/postgresql/11/main/pg_hba.conf` añadiendo la siguiente línea.

        host     all             all             0.0.0.0/0

* Si queremos entrar a postgres ahora nos dará un error.

        vagrant@postgres1:~$ psql
        psql: could not connect to server: No such file or directory
        	Is the server running locally and accepting
        	connections on Unix domain socket "/var/run/postgresql/.s.PGSQL.5432"?

* Lo que deberemos hacer es crear un nuevo cluster ya que el que tenemos está apagado.

        vagrant@postgres1:~$ sudo pg_dropcluster --stop 11 main

        root@postgres1:~# pg_createcluster --locale es_ES.UTF-8 --start 11 main
        Creating new PostgreSQL cluster 11/main ...
        /usr/lib/postgresql/11/bin/initdb -D /var/lib/postgresql/11/main --auth-local peer --auth-host md5 --locale es_ES.UTF-8
        The files belonging to this database system will be owned by user "postgres".
        This user must also own the server process.

        The database cluster will be initialized with locale "es_ES.UTF-8".
        The default database encoding has accordingly been set to "UTF8".
        The default text search configuration will be set to "spanish".

        Data page checksums are disabled.

        fixing permissions on existing directory /var/lib/postgresql/11/main ... ok
        creating subdirectories ... ok
        selecting default max_connections ... 100
        selecting default shared_buffers ... 128MB
        selecting default timezone ... Etc/UTC
        selecting dynamic shared memory implementation ... posix
        creating configuration files ... ok
        running bootstrap script ... ok
        performing post-bootstrap initialization ... ok
        syncing data to disk ... ok

        Success. You can now start the database server using:

            pg_ctlcluster 11 main start

        Ver Cluster Port Status Owner    Data directory              Log file
        11  main    5432 online postgres /var/lib/postgresql/11/main /var/log/postgresql/postgresql-11-main.log

* Podemos comprobar que ahora podemos entrar sin problemas.

        postgres@postgres1:~$ psql
        psql (11.12 (Debian 11.12-0+deb10u1))
        Type "help" for help.

        postgres=#

* Pasemos a nuestro cliente, postgres2 configuraremos los archivos `/etc/postgresql/11/main/postgresql.conf` y `/etc/postgresql/11/main/pg_hba.conf` tal como hicimos con el servidor.

        vagrant@postgres2:~$ cat /etc/postgresql/11/main/postgresql.conf
        listen_addresses = '*'

        vagrant@postgres2:~$ cat /etc/postgresql/11/main/pg_hba.conf 
        host    all             all             0.0.0.0/0
        host    all             all             all                     md5

* Una permitido el acceso remoto en ambas vamos a proceder a crear bases de datos y usuarios.


#### Postgres1

        postgres=# CREATE USER postgres1 WITH PASSWORD 'postgres1';
        CREATE ROLE
        postgres=# CREATE DATABASE prueba1;
        CREATE DATABASE
        postgres=# GRANT ALL PRIVILEGES ON DATABASE prueba1 to postgres1;
        GRANT

        prueba1=> INSERT INTO Propietarios(NIF,Nombre,Apellidos,Cuota)
        prueba1-> VALUES('61219065B','Mario','Gutiérrez Valencia',300);
        INSERT 0 1
        prueba1=> 
        prueba1=> INSERT INTO Propietarios(NIF,Nombre,Apellidos,Cuota)
        prueba1-> VALUES('20015195C','Alexandra','Angulo Lamas',320);
        INSERT 0 1
        prueba1=> 
        prueba1=> INSERT INTO Propietarios(NIF,Nombre,Apellidos,Cuota)
        prueba1-> VALUES ('19643077L','Miriam','Zafra Valencia',45);
        INSERT 0 1
        prueba1=> 
        prueba1=> INSERT INTO Propietarios(NIF,Nombre,Apellidos,Cuota)
        prueba1-> VALUES ('33599573T','Josue','Reche de los Santos',50);
        INSERT 0 1
        prueba1=> 
        prueba1=> INSERT INTO Propietarios(NIF,Nombre,Apellidos,Cuota)
        prueba1-> VALUES ('X4164637G','Christian','Lopez Reyes',50);
        INSERT 0 1

#### Postgres2

        postgres=# CREATE USER postgres2 WITH PASSWORD 'postgres2';
        CREATE ROLE
        postgres=# CREATE DATABASE prueba2;
        CREATE DATABASE
        postgres=# GRANT ALL PRIVILEGES ON DATABASE prueba2 to postgres2;
        GRANT

        prueba2=> INSERT INTO Propietarios(NIF,Nombre,Apellidos,Cuota)
        prueba2-> VALUES('61219235B','Juan','Sierra Garcia',300);
        INSERT 0 1
        prueba2=> INSERT INTO Propietarios(NIF,Nombre,Apellidos,Cuota)
        prueba2-> VALUES('23554567B','Martina','Delgado Ramos',250);
        INSERT 0 1

* Ahora hagamos la interconexión, en primer lugar en postgres1.

        prueba1=# create extension dblink;
        CREATE EXTENSION

        prueba1=> SELECT * FROM dblink('dbname=prueba2 host=172.22.100.30 user=postgres2 password=postgres2, 'select * from Propietarios') AS Propietarios (NIF varchar, Nombre varchar, Apellidos varchar, Cuota numeric);
            nif    | nombre  |   apellidos   | cuota  
        -----------+---------+---------------+--------
         61219235B | Juan    | Sierra Garcia | 300.00
         23554567B | Martina | Delgado Ramos | 250.00

* Y en postgres2:

        prueba2=# create extension dblink;
        CREATE EXTENSION

        prueba2=> SELECT * FROM dblink('dbname=prueba1 host=172.22.100.25 user=postgres1 password='postgres1', 'select * from Propietarios') AS Propietarios (NIF varchar, Nombre varchar, Apellidos varchar, Cuota numeric);
            nif    |  nombre   |      apellidos      | cuota  
        -----------+-----------+---------------------+--------
         61219065B | Mario     | Gutiérrez Valencia  | 300.00
         20015195C | Alexandra | Angulo Lamas        | 320.00
         19643077L | Miriam    | Zafra Valencia      |  45.00
         33599573T | Josue     | Reche de los Santos |  50.00
         X4164637G | Christian | Lopez Reyes         |  50.00

## Conexión Oracle 19c y Postgres

* Nuestro primer paso será instalar la paquetería necesaria para realizar esta conexión, ya tenemos los dos servidores operativos, así que realizemos este paso, empezemos con Oracle.

        [vagrant@oracle ~]$ sudo dnf install unixODBC postgresql-odbc

* En el fichero `/etc/odbcinst.ini` se encuentra la información de todos los drivers que ofrece ODBC para interconectar bases de datos, comentaremos todo menos lo que este relacionado con postgres.

        [PostgreSQL]
        Description     = ODBC for PostgreSQL
        Driver          = /usr/lib/psqlodbcw.so
        Setup           = /usr/lib/libodbcpsqlS.so
        Driver64        = /usr/lib64/psqlodbcw.so
        Setup64         = /usr/lib64/libodbcpsqlS.so
        FileUsage	= 1

* En el fichero `/etc/odbc.ini` introduciremos información de nuestro servidor postgres como puede ser la dirección IP donde se aloja o el nombre de usuario y contraseña para acceder entre otros.

        [PSQLU]
        Debug           = 0
        CommLog         = 0
        ReadOnly        = 0
        Driver          = PostgreSQL
        Servername	= 172.22.100.25
        Username        = remoto1
        Password        = remoto1
        Port            = 5432
        Database        = prueba
        Trace           = 0
        TraceFile	= /tmp/sql.log

* 

### postgres

* Instalamos la paquetería necesaria

        vagrant@postgres:~$ sudo apt install libaio1 postgresql-server-dev-all build-essential

* Y descargamos los paquetes de oracle que necesitaremos a lo largo de esta configuración.

        postgres@postgres:~$ wget https://download.oracle.com/otn_software/linux/instantclient/211000/instantclient-sdk-linux.x64-21.1.0.0.0.zip

        postgres@postgres:~$ wget https://download.oracle.com/otn_software/linux/instantclient/211000/instantclient-sqlplus-linux.x64-21.1.0.0.0.zip

        postgres@postgres:~$ wget https://download.oracle.com/otn_software/linux/instantclient/211000/instantclient-basic-linux.x64-21.1.0.0.0.zip

* Descomprimiremos usando `unzip` todos estos archivos y nos quedará una carpeta con todo el contenido.

        postgres@postgres:~$ ls -l
        total 8
        drwxr-xr-x 4 postgres postgres 4096 May 28 15:25 instantclient_21_1

* Para que este proceso nos sea mas sencillo vamos a definir una serie de variables de rutas sobre archivos que necesitaremos.

        vagrant@postgres:~$ export ORACLE_HOME=/home/postgres/instantclient_21_1
        vagrant@postgres:~$ export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ORACLE_HOME
        vagrant@postgres:~$ export PATH=$PATH:$ORACLE_HOME

* Realizamos una conexión

vagrant@postgres:/home/postgres$ sqlplus c##ale/ale@172.22.100.15/ORCLCDB

SQL*Plus: Release 21.0.0.0.0 - Production on Fri May 28 15:33:56 2021
Version 21.1.0.0.0

Copyright (c) 1982, 2020, Oracle.  All rights reserved.
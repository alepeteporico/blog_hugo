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

* Para comprobar que tenemos conexión por el puerto 1521 que usa oracle para el listener podemos usar el comando tnsping.

        [oracle@oracle ~]$ tnsping 172.22.100.20

        TNS Ping Utility for Linux: Version 19.0.0.0.0 - Production on 08-JUN-2021 07:35:45

        Copyright (c) 1997, 2019, Oracle.  All rights reserved.

        Used parameter files:
        /opt/oracle/product/19c/dbhome_1/network/admin/sqlnet.ora

        Used HOSTNAME adapter to resolve the alias
        Attempting to contact (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=))(ADDRESS=(PROTOCOL=tcp)(HOST=172.22.100.20)(PORT=1521)))
        OK (0 msec)

* Vamos conigurar el que será nuestro servidor definiendo un alias indicando al servidor que nos conectaremos modificando el fichero `/opt/oracle/product/19c/dbhome_1/network/admin/tnsnames.ora`

        ORCLCDB =
          (DESCRIPTION =
            (ADDRESS = (PROTOCOL = TCP)(HOST = myhost)(PORT = 1521))
            (CONNECT_DATA =
              (SERVER = DEDICATED)
              (SERVICE_NAME = ORCLCDB)
            )
          )
        
        LISTENER_ORCLCDB =
          (ADDRESS = (PROTOCOL = TCP)(HOST = myhost)(PORT = 1521))
        
        
        ORACLE2 =
          (DESCRIPTION =
            (ADDRESS = (PROTOCOL = TCP)(HOST = 172.22.100.20)(PORT = 1521))
            (CONNECT_DATA =
              (SERVER = DEDICATED)
              (SERVICE_NAME = ORCLCDB)
            )
          )

* Vamos a crear un usuario al que daremos privilegios y enlazaremos con nuestro otro servidor.

        SQL> CREATE USER c##remoto IDENTIFIED BY remoto;

        User created.

        SQL> GRANT ALL PRIVILEGES TO c##remoto; 
        
        Grant succeeded.

        SQL> CREATE DATABASE LINK oracle2link
          2  CONNECT TO c##remoto2 IDENTIFIED BY remoto2
          3  USING 'oracle2';

        Database link created.

* Y el enlace estaría hecho, vamos a probar algunas cosas, como por ejemplo crear una tabla en nuestra base de datos copiando de la remota, para ello he creado algún contenido en ella.

        SQL> CREATE TABLE prueba
          2  AS (SELECT *
          3  FROM prueba2@oracle2link);
        
        Tabla creada.

* Ahora realizaremos nuestra conexión desde la otra máquina. entramos y verificamos que tenemos conexión.

        [oracle@oracle ~]$ tnsping 172.22.100.15

        TNS Ping Utility for Linux: Version 19.0.0.0.0 - Production on 08-JUN-2021 09:59:36

        Copyright (c) 1997, 2019, Oracle.  All rights reserved.

        Used parameter files:
        /opt/oracle/product/19c/dbhome_1/network/admin/sqlnet.ora

        Used HOSTNAME adapter to resolve the alias
        Attempting to contact (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=))(ADDRESS=(PROTOCOL=tcp)(HOST=172.22.100.15)(PORT=1521)))
        OK (0 msec)

* Configuramos su fichero `tnsnames.ora` tal como hicimos anteriormente.

        ORCLCDB =
          (DESCRIPTION =
            (ADDRESS = (PROTOCOL = TCP)(HOST = myhost)(PORT = 1521))
            (CONNECT_DATA =
              (SERVER = DEDICATED)
              (SERVICE_NAME = ORCLCDB)
            )
          )

        LISTENER_ORCLCDB =
          (ADDRESS = (PROTOCOL = TCP)(HOST = myhost)(PORT = 1521))


        ORACLE1 =
          (DESCRIPTION =
            (ADDRESS = (PROTOCOL = TCP)(HOST = 172.22.100.15)(PORT = 1521))
            (CONNECT_DATA =
              (SERVER = DEDICATED)
              (SERVICE_NAME = ORCLCDB)
            )
          )

* Nos conectamos a la base de datos y creamos los usuarios, les damos permisos y conectamos a nuestra base de datos remota.

        SQL> CREATE USER c##remoto2 IDENTIFIED BY remoto2;

        User created.

        SQL> GRANT ALL PRIVILEGES TO c##remoto2; 

        Grant succeeded.

        SQL> CREATE DATABASE LINK oracle1link
          2  CONNECT TO c##remoto IDENTIFIED BY remoto
          3  USING 'oracle1';

        Database link created.

* Vamos a realizar la misma prueba que hicimos antes creando una base de datos.

        SQL> CREATE TABLE prueba
          2  AS (SELECT *
          3  FROM prueba1@oracle1link);

        Tabla creada.

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

* Vamos a comprobar la conexión.

        [vagrant@oracle ~]$ sudo isql PSQLU
        +---------------------------------------+
        | Connected!                            |
        |                                       |
        | sql-statement                         |
        | help \[tablename]                      |
        | quit                                  |
        |                                       |
        +---------------------------------------+

* Vamos a configurar un fichero que debemos generar en `/opt/oracle/product/19c/dbhome_1/hs/admin/initPSQLU.ora` donde debemos añadir las siguientes líneas.

        HS_FDS_CONNECT_INFO = PSQLU
        HS_FDS_TRACE_LEVEL = DEBUG
        HS_FDS_SHAREABLE_NAME = /usr/lib64/psqlodbcw.so
        HS_LANGUAGE = AMERICAN_AMERICA.WE8ISO8859P1
        set ODBCINI=/etc/odbc.ini

* Ahora configuramos nuestro fichero listener, donde deberemos añadir la escucha al driver de ODBC y especificando nuestro DNS.

        LISTENER =
          (DESCRIPTION_LIST =
            (DESCRIPTION =
              (ADDRESS = (PROTOCOL = TCP)(HOST = oracle.alegv.bd)(PORT = 1521))
              (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
            )
          )

        SID_LIST_LISTENER=
          (SID_LIST=
              (SID_DESC=
                 (SID_NAME=PSQLU)
                 (ORACLE_HOME=/opt/oracle/product/19c/dbhome_1)
                 (PROGRAM=dg4odbc)
              )
          )

* También vamos a configurar el fichero tnsnames.ora donde definiremos la nueva conexión que realmente será a nuestra propia máquina.

        ORCLCDB =
          (DESCRIPTION =
            (ADDRESS = (PROTOCOL = TCP)(HOST = myhost)(PORT = 1521))
            (CONNECT_DATA =
              (SERVER = DEDICATED)
              (SERVICE_NAME = ORCLCDB)
            )
          )

        LISTENER_ORCLCDB =
          (ADDRESS = (PROTOCOL = TCP)(HOST = myhost)(PORT = 1521))


        ORACLE2 =
          (DESCRIPTION =
            (ADDRESS = (PROTOCOL = TCP)(HOST = 172.22.100.20)(PORT = 1521))
            (CONNECT_DATA =
              (SERVER = DEDICATED)
              (SERVICE_NAME = ORCLCDB)
            )
          )

        PSQLU  =
          (DESCRIPTION=
            (ADDRESS=(PROTOCOL=tcp)(HOST=localhost)(PORT=1521))
            (CONNECT_DATA=(SID=PSQLU))
            (HS=OK)
          )

* Tras esto reiniciamos el servicio, accedemos a nuestra base de datos y comprobamos que funciona el enlace.

        [oracle@oracle ~]$ lsnrctl stop
        [oracle@oracle1 ~]$ lsnrctl start

        SQL> CREATE DATABASE LINK postgreslink
        CONNECT TO "remoto1" IDENTIFIED BY "remoto1"
        USING 'PSQLU';

        Enlace con la base de datos creado.

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

        postgres@postgres:~$ sqlplus c##ale/ale@172.22.100.15/ORCLCDB

        SQL*Plus: Release 21.0.0.0.0 - Production on Tue Jun 8 15:41:37 2021
        Version 21.1.0.0.0

        Copyright (c) 1982, 2020, Oracle.  All rights reserved.

        Hora de Ultima Conexion Correcta: Mar Jun 08 2021 17:36:17 -05:00

        Conectado a:
        Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
        Version 19.3.0.0.0

* Vemos que hemos podido conectarnos con exito, sin embargo no hemos terminado, debemos compliar el programa oracle_fdw que encontraremos en un repositorio en github.

        vagrant@postgres:~$ git clone https://github.com/laurenz/oracle_fdw.git

* Compilamos este programa.

        vagrant@postgres:~/oracle_fdw$ sudo make
        gcc -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -Wno-format-truncation -Wno-stringop-truncation -g -g -O2 -fstack-protector-strong -Wformat -Werror=format-security -fno-omit-frame-pointer -fPIC -I/home/postgres/instantclient_21_1/sdk/include -I/home/postgres/instantclient_21_1/oci/include -I/home/postgres/instantclient_21_1/rdbms/public -I/home/postgres/instantclient_21_1 -I/usr/include/oracle/19.9/client -I/usr/include/oracle/19.9/client64 -I/usr/include/oracle/19.8/client -I/usr/include/oracle/19.8/client64 -I/usr/include/oracle/19.6/client -I/usr/include/oracle/19.6/client64 -I/usr/include/oracle/19.3/client -I/usr/include/oracle/19.3/client64 -I/usr/include/oracle/18.5/client -I/usr/include/oracle/18.5/client64 -I/usr/include/oracle/18.3/client -I/usr/include/oracle/18.3/client64 -I/usr/include/oracle/12.2/client -I/usr/include/oracle/12.2/client64 -I/usr/include/oracle/12.1/client -I/usr/include/oracle/12.1/client64 -I/usr/include/oracle/11.2/client -I/usr/include/oracle/11.2/client64 -I/usr/include/oracle/11.1/client -I/usr/include/oracle/11.1/client64 -I/usr/include/oracle/10.2.0.5/client -I/usr/include/oracle/10.2.0.5/client64 -I/usr/include/oracle/10.2.0.4/client -I/usr/include/oracle/10.2.0.4/client64 -I/usr/include/oracle/10.2.0.3/client -I/usr/include/oracle/10.2.0.3/client64 -I. -I./ -I/usr/include/postgresql/11/server -I/usr/include/postgresql/internal  -Wdate-time -D_FORTIFY_SOURCE=2 -D_GNU_SOURCE -I/usr/include/libxml2  -I/usr/include/mit-krb5  -c -o oracle_fdw.o oracle_fdw.c
        gcc -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -Wno-format-truncation -Wno-stringop-truncation -g -g -O2 -fstack-protector-strong -Wformat -Werror=format-security -fno-omit-frame-pointer -fPIC -I/home/postgres/instantclient_21_1/sdk/include -I/home/postgres/instantclient_21_1/oci/include -I/home/postgres/instantclient_21_1/rdbms/public -I/home/postgres/instantclient_21_1 -I/usr/include/oracle/19.9/client -I/usr/include/oracle/19.9/client64 -I/usr/include/oracle/19.8/client -I/usr/include/oracle/19.8/client64 -I/usr/include/oracle/19.6/client -I/usr/include/oracle/19.6/client64 -I/usr/include/oracle/19.3/client -I/usr/include/oracle/19.3/client64 -I/usr/include/oracle/18.5/client -I/usr/include/oracle/18.5/client64 -I/usr/include/oracle/18.3/client -I/usr/include/oracle/18.3/client64 -I/usr/include/oracle/12.2/client -I/usr/include/oracle/12.2/client64 -I/usr/include/oracle/12.1/client -I/usr/include/oracle/12.1/client64 -I/usr/include/oracle/11.2/client -I/usr/include/oracle/11.2/client64 -I/usr/include/oracle/11.1/client -I/usr/include/oracle/11.1/client64 -I/usr/include/oracle/10.2.0.5/client -I/usr/include/oracle/10.2.0.5/client64 -I/usr/include/oracle/10.2.0.4/client -I/usr/include/oracle/10.2.0.4/client64 -I/usr/include/oracle/10.2.0.3/client -I/usr/include/oracle/10.2.0.3/client64 -I. -I./ -I/usr/include/postgresql/11/server -I/usr/include/postgresql/internal  -Wdate-time -D_FORTIFY_SOURCE=2 -D_GNU_SOURCE -I/usr/include/libxml2  -I/usr/include/mit-krb5  -c -o oracle_utils.o oracle_utils.c
        gcc -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -Wno-format-truncation -Wno-stringop-truncation -g -g -O2 -fstack-protector-strong -Wformat -Werror=format-security -fno-omit-frame-pointer -fPIC -I/home/postgres/instantclient_21_1/sdk/include -I/home/postgres/instantclient_21_1/oci/include -I/home/postgres/instantclient_21_1/rdbms/public -I/home/postgres/instantclient_21_1 -I/usr/include/oracle/19.9/client -I/usr/include/oracle/19.9/client64 -I/usr/include/oracle/19.8/client -I/usr/include/oracle/19.8/client64 -I/usr/include/oracle/19.6/client -I/usr/include/oracle/19.6/client64 -I/usr/include/oracle/19.3/client -I/usr/include/oracle/19.3/client64 -I/usr/include/oracle/18.5/client -I/usr/include/oracle/18.5/client64 -I/usr/include/oracle/18.3/client -I/usr/include/oracle/18.3/client64 -I/usr/include/oracle/12.2/client -I/usr/include/oracle/12.2/client64 -I/usr/include/oracle/12.1/client -I/usr/include/oracle/12.1/client64 -I/usr/include/oracle/11.2/client -I/usr/include/oracle/11.2/client64 -I/usr/include/oracle/11.1/client -I/usr/include/oracle/11.1/client64 -I/usr/include/oracle/10.2.0.5/client -I/usr/include/oracle/10.2.0.5/client64 -I/usr/include/oracle/10.2.0.4/client -I/usr/include/oracle/10.2.0.4/client64 -I/usr/include/oracle/10.2.0.3/client -I/usr/include/oracle/10.2.0.3/client64 -I. -I./ -I/usr/include/postgresql/11/server -I/usr/include/postgresql/internal  -Wdate-time -D_FORTIFY_SOURCE=2 -D_GNU_SOURCE -I/usr/include/libxml2  -I/usr/include/mit-krb5  -c -o oracle_gis.o oracle_gis.c
        gcc -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -Wno-format-truncation -Wno-stringop-truncation -g -g -O2 -fstack-protector-strong -Wformat -Werror=format-security -fno-omit-frame-pointer -fPIC -shared -o oracle_fdw.so oracle_fdw.o oracle_utils.o oracle_gis.o -L/usr/lib/x86_64-linux-gnu  -Wl,-z,relro -Wl,-z,now -L/usr/lib/llvm-7/lib  -L/usr/lib/x86_64-linux-gnu/mit-krb5 -Wl,--as-needed  -L/home/postgres/instantclient_21_1 -L/home/postgres/instantclient_21_1/bin -L/home/postgres/instantclient_21_1/lib -L/home/postgres/instantclient_21_1/lib/amd64 -lclntsh -L/usr/lib/oracle/19.9/client/lib -L/usr/lib/oracle/19.9/client64/lib -L/usr/lib/oracle/19.8/client/lib -L/usr/lib/oracle/19.8/client64/lib -L/usr/lib/oracle/19.6/client/lib -L/usr/lib/oracle/19.6/client64/lib -L/usr/lib/oracle/19.3/client/lib -L/usr/lib/oracle/19.3/client64/lib -L/usr/lib/oracle/18.5/client/lib -L/usr/lib/oracle/18.5/client64/lib -L/usr/lib/oracle/18.3/client/lib -L/usr/lib/oracle/18.3/client64/lib -L/usr/lib/oracle/12.2/client/lib -L/usr/lib/oracle/12.2/client64/lib -L/usr/lib/oracle/12.1/client/lib -L/usr/lib/oracle/12.1/client64/lib -L/usr/lib/oracle/11.2/client/lib -L/usr/lib/oracle/11.2/client64/lib -L/usr/lib/oracle/11.1/client/lib -L/usr/lib/oracle/11.1/client64/lib -L/usr/lib/oracle/10.2.0.5/client/lib -L/usr/lib/oracle/10.2.0.5/client64/lib -L/usr/lib/oracle/10.2.0.4/client/lib -L/usr/lib/oracle/10.2.0.4/client64/lib -L/usr/lib/oracle/10.2.0.3/client/lib -L/usr/lib/oracle/10.2.0.3/client64/lib

----------------------------------------------

        vagrant@postgres:~/oracle_fdw$ sudo make install
        /bin/mkdir -p '/usr/lib/postgresql/11/lib'
        /bin/mkdir -p '/usr/share/postgresql/11/extension'
        /bin/mkdir -p '/usr/share/postgresql/11/extension'
        /bin/mkdir -p '/usr/share/doc/postgresql-doc-11/extension'
        /usr/bin/install -c -m 755  oracle_fdw.so '/usr/lib/postgresql/11/lib/oracle_fdw.so'
        /usr/bin/install -c -m 644 .//oracle_fdw.control '/usr/share/postgresql/11/extension/'
        /usr/bin/install -c -m 644 .//oracle_fdw--1.2.sql .//oracle_fdw--1.0--1.1.sql .//oracle_fdw--1.1--1.2.sql  '/usr/share/postgresql/11/extension/'
        /usr/bin/install -c -m 644 .//README.oracle_fdw '/usr/share/doc/postgresql-doc-11/extension/'

* Crearemos un enlace que posteriormente usaremos.

        postgres@postgres:/home/postgres/oracle_fdw$ psql -d prueba
        psql (11.12 (Debian 11.12-0+deb10u1))
        Type "help" for help.

* Hacemos la conexión creando una extensión.

        prueba=# CREATE EXTENSION oracle_fdw;
        CREATE EXTENSION

* Vamos a comprobar que está creada.

        prueba2=# \dx
                                           List of installed extensions
            Name    | Version |   Schema   |                         Description                          
        ------------+---------+------------+--------------------------------------------------------------

         oracle\_fdw | 1.2     | public     | foreign data wrapper for Oracle access
         plpgsql    | 1.0     | pg\_catalog | PL/pgSQL procedural language
        (2 rows)

* Ahora que está creada la extensión tenemos que crear un esquema donde mas adelante volcaremos las tablas de oracle.

        prueba=# CREATE SCHEMA oracle;
        CREATE SCHEMA

* Una vez creado importamos las tablas.

        prueba=# CREATE SERVER oracle FOREIGN DATA WRAPPER oracle_fdw OPTIONS (dbserver '//172.22.100.15/ORCLCDB');
        CREATE SERVER

* Pero el usuario que estamos usando realmente no existe en nuestra base de datos remota, por ello debemos mapear nuestro usuario local en el gestor remoto.

        prueba=# CREATE USER MAPPING FOR remoto1 SERVER oracle OPTIONS (user 'c##ale', password 'ale');
        CREATE USER MAPPING

* Le damos los permisos necesarios a nuestro usuario sobre el esquema y el servidor.

        prueba=# GRANT ALL PRIVILEGES ON SCHEMA oracle TO remoto1;
        GRANT

        prueba=# GRANT ALL PRIVILEGES ON FOREIGN SERVER oracle TO remoto1;
        GRANT

* Ahora podemos acceder a nuestra base de datos remota.

        postgres@postgres:~$ psql -h localhost -U remoto1 -d prueba
        Password for user remoto1: 
        psql (11.12 (Debian 11.12-0+deb10u1))
        SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, bits: 256, compression: off)
        Type "help" for help.

* Para comprobar su funcionamiento podríamos importar las tablas del esquema remoto de nuestro usuario c##ale.

        prueba1=# IMPORT FOREIGN SCHEMA "C##ALVARO1" FROM SERVER oracle INTO oracle;
        IMPORT FOREIGN SCHEMA
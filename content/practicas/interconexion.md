+++
title = "Interconexión de servidores de bases de datos"
description = ""
tags = [
    "ABD"
]
date = "2022-01-03"
menu = "main"
+++

* Realizar un enlace entre dos servidores de bases de datos ORACLE, explicando la configuración necesaria en ambos extremos y demostrando su funcionamiento.

* Realizar un enlace entre dos servidores de bases de datos Postgres, explicando la configuración necesaria en ambos extremos y demostrando su funcionamiento.

* Realizar un enlace entre un servidor ORACLE y otro Postgres o MySQL empleando Heterogeneus Services, explicando la configuración necesaria en ambos extremos y demostrando su funcionamiento.

## Conexión entre ORACLE

* Usaremos dos máquina con centos 7 e instalaremos oracle 19c en cada una.

* Para que no nos de problemas desactivamos el firewall de centos en las dos máquinas.

~~~
[root@localhost ~]# systemctl mask firewalld
Created symlink from /etc/systemd/system/firewalld.service to /dev/null.
[root@localhost ~]# systemctl stop firewalld
~~~

* Cambiaremos el nombre de dominio de la que será nuestra máquina servidora para posteriormente poder conectarnos mediante resolución dns.

~~~
[root@localhost ~]# hostnamectl set-hostname db.alegv.oracle.com
~~~

* Añadiremos a nuestro cliente este nombre en el `/etc/hosts`.

~~~
172.22.9.214	db.alegv.oracle.com	oracle
~~~

* En el fichero `/opt/oracle/product/19c/dbhome_1/network/admin/listener.ora` indicaremos el nombre de nuestro host.

~~~
# listener.ora Network Configuration File: /opt/oracle/product/19c/dbhome_1/network/admin/listener.ora
# Generated by Oracle configuration tools.

LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = db.alegv.oracle.com)(PORT = 1521))
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
    )
  )
~~~

* Ahora iniciaremos la escucha en nuestro servidor.

~~~
[oracle@db ~]$ lsnrctl start

LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 15-FEB-2022 09:44:37

Copyright (c) 1991, 2019, Oracle.  All rights reserved.

Starting /opt/oracle/product/19c/dbhome_1/bin/tnslsnr: please wait...

TNSLSNR for Linux: Version 19.0.0.0.0 - Production
System parameter file is /opt/oracle/product/19c/dbhome_1/network/admin/listener.ora
Log messages written to /opt/oracle/diag/tnslsnr/db/listener/alert/log.xml
Listening on: (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=db.alegv.oracle.com)(PORT=1521)))
Listening on: (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1521)))

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=db.alegv.oracle.com)(PORT=1521)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
Start Date                15-FEB-2022 09:44:47
Uptime                    0 days 0 hr. 0 min. 6 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /opt/oracle/product/19c/dbhome_1/network/admin/listener.ora
Listener Log File         /opt/oracle/diag/tnslsnr/db/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=db.alegv.oracle.com)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1521)))
The listener supports no services
The command completed successfully
~~~

* Podemos comprobar que tenemos conexión con el comando que vemos a continuación.

~~~
[oracle@localhost ~]$ tnsping 172.22.9.214

TNS Ping Utility for Linux: Version 19.0.0.0.0 - Production on 15-FEB-2022 10:03:13

Copyright (c) 1997, 2019, Oracle.  All rights reserved.

Used parameter files:
/opt/oracle/product/19c/dbhome_1/network/admin/sqlnet.ora

Used HOSTNAME adapter to resolve the alias
Attempting to contact (DESCRIPTION=(CONNECT_DATA=(SERVICE_NAME=))(ADDRESS=(PROTOCOL=tcp)(HOST=172.22.9.214)(PORT=1521)))
OK (40 msec)
~~~

* Por último, desde el cliente nos conectamos al servidor de la siguiente forma:

~~~
[oracle@localhost ~]$ sqlplus c##alegv/alegv@db.alegv.oracle.com/ORCLCDB

SQL*Plus: Release 19.0.0.0.0 - Production on Tue Feb 15 10:03:28 2022
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.

Hora de Ultima Conexion Correcta: Mar Feb 15 2022 09:53:52 +01:00

Conectado a:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0

SQL>
~~~

* Desde el cliente vamos a crear algo de contenido simple, una tabla con un registro

~~~
SQL> CREATE TABLE departamentos(
   depto_id NUMBER(9),
   nombre VARCHAR2(100),
   localidad VARCHAR2(300),
   fecha_creacion DATE DEFAULT SYSDATE
); 

Tabla creada.

SQL> INSERT INTO departamentos (depto_id, nombre, localidad, fecha_creacion)
Values(1, 'SISTEMAS', 'MEXICO DF', SYSDATE);

1 fila creada
~~~

* Ahora vamos a ver desde el servidor con el mismo usuario que esta tabla y registro están creados.

~~~
[oracle@db ~]$ sqlplus / as sysdba

SQL*Plus: Release 19.0.0.0.0 - Production on Tue Feb 15 10:18:28 2022
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.


Conectado a:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0

SQL> DISCONNECT
Desconectado de Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0
SQL> CONNECT c##alegv/alegv
Conectado.
SQL> SELECT * FROM departamentos;

  DEPTO_ID
----------
NOMBRE
--------------------------------------------------------------------------------
LOCALIDAD
--------------------------------------------------------------------------------
FECHA_CR
--------
	 1
SISTEMAS
MEXICO DF
15/02/22
~~~

## Conexión entre Postgres.

* Usaremos dos máquinas vagrant con debian buster.

* primero configuraremos postgres1 que nos servirá como servidor principal, el primer archivo que configuraremos será `/etc/postgresql/13/main/postgresql.conf` y podremos el listener a 0.

        listen_addresses = '0'

* Seguidamente configuraremos `/etc/postgresql/13/main/pg_hba.conf` añadiendo la siguiente línea.

        host     all             all             0.0.0.0/0

* Si queremos entrar a postgres ahora nos dará un error.

        vagrant@postgres1:~$ psql
        psql: could not connect to server: No such file or directory
        	Is the server running locally and accepting
        	connections on Unix domain socket "/var/run/postgresql/.s.PGSQL.5432"?

* Lo que deberemos hacer es crear un nuevo cluster ya que el que tenemos está apagado.

~~~
postgres@postgres1:~$ sudo pg_ctlcluster 13 main restart
~~~

* Podemos comprobar que ahora podemos entrar sin problemas.

~~~
postgres@postgres1:~$ psql
psql (13.5 (Debian 13.5-0+deb11u1))
Type "help" for help.

postgres=# 
~~~

* Pasemos a nuestro cliente, postgres2 configuraremos los archivos `/etc/postgresql/13/main/postgresql.conf` y `/etc/postgresql/13/main/pg_hba.conf` tal como hicimos con el servidor.

        vagrant@postgres2:~$ cat /etc/postgresql/13/main/postgresql.conf
        listen_addresses = '*'

        vagrant@postgres2:~$ cat /etc/postgresql/13/main/pg_hba.conf 
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
        
        postgres=# CREATE TABLE Propietarios
        (
        NIF     VARCHAR(9),
        Nombre  VARCHAR(15),
        Apellidos       VARCHAR(20),
        Cuota   NUMERIC(6,2),
        CONSTRAINT pk_propietarios PRIMARY KEY(NIF),
        CONSTRAINT NIFPropietario_ok CHECK(NIF ~* '^[K,L,M,Z,Y,X][0-9]{7}[A-Z]{1}$' OR NIF ~* '[0-9]{8}[A-Z]')
        );
        CREATE TABLE

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

        prueba1=> SELECT * FROM dblink('dbname=prueba2 host=192.168.121.221 user=postgres2 password=postgres2, 'select * from Propietarios') AS Propietarios (NIF varchar, Nombre varchar, Apellidos varchar, Cuota numeric);
            nif    | nombre  |   apellidos   | cuota  
        -----------+---------+---------------+--------
         61219235B | Juan    | Sierra Garcia | 300.00
         23554567B | Martina | Delgado Ramos | 250.00

* Y en postgres2:

        prueba2=# create extension dblink;
        CREATE EXTENSION

        prueba2=> SELECT * FROM dblink('dbname=prueba1 host=192.168.121.99 user=postgres1 password='postgres1', 'select * from Propietarios') AS Propietarios (NIF varchar, Nombre varchar, Apellidos varchar, Cuota numeric);
            nif    |  nombre   |      apellidos      | cuota  
        -----------+-----------+---------------------+--------
         61219065B | Mario     | Gutiérrez Valencia  | 300.00
         20015195C | Alexandra | Angulo Lamas        | 320.00
         19643077L | Miriam    | Zafra Valencia      |  45.00
         33599573T | Josue     | Reche de los Santos |  50.00
         X4164637G | Christian | Lopez Reyes         |  50.00

## Conexión Oracle 19c y Postgres

* Nuestro primer paso será instalar la paquetería necesaria para realizar esta conexión, ya tenemos los dos servidores operativos, así que realizemos este paso, empezemos con Oracle.

~~~
[root@db ~]# dnf install unixODBC postgresql-odbc
~~~

* En el fichero `/etc/odbcinst.ini` se encuentra la información de todos los drivers que ofrece ODBC para interconectar bases de datos, comentaremos los necesarios.

~~~
[PostgreSQL ANSI]
Description=PostgreSQL ODBC driver (ANSI version)
Driver=psqlodbca.so
Setup=libodbcpsqlS.so
Debug=0
CommLog=1
UsageCount=1

[PostgreSQL Unicode]
Description=PostgreSQL ODBC driver (Unicode version)
Driver=psqlodbcw.so
Setup=libodbcpsqlS.so
Debug=0
CommLog=1
UsageCount=1
~~~

* En el fichero `/etc/odbc.ini` introduciremos información de nuestro servidor postgres como puede ser la dirección IP donde se aloja o el nombre de usuario y contraseña para acceder entre otros.

~~~
[PSQLU]
Debug = 0
CommLog = 0
ReadOnly = 0
Driver = PostgreSQL Unicode
Servername = 192.168.121.125
Username =  alegv1
Password = alegv1
Port = 5432
Database = prueba
Trace = 0
TraceFile = /tmp/sql.log

[Default]
Driver = /usr/lib64/liboplodbcS.so.2
~~~

* Modificamos el fichero `initPSQLU.ora` donde añadiremos algunas variables de entornos necesarias para conectarnos a la base de datos de postgres.

~~~
HS_FDS_CONNECT_INFO = PSQLU
HS_FDS_TRACE_LEVEL = DEBUG
HS_FDS_SHAREABLE_NAME = /usr/lib64/psqlodbcw.so
HS_LANGUAGE = AMERICAN_AMERICA.WE8ISO8859P1
set ODBCINI=/etc/odbc.ini
~~~

* Y seguidamente iremos con el `listener.ora`.

~~~
SID_LIST_LISTENER=
  (SID_LIST=
      (SID_DESC=
         (SID_NAME=PSQLU)
         (ORACLE_HOME=/opt/oracle/product/19c/dbhome_1)
         (PROGRAM=dg4odbc)
      )
  )
~~~

* Necesitamos añadir las siguietes líneas en el fichero `tnsnames.ora`.

~~~
PSQLU  =
  (DESCRIPTION=
    (ADDRESS=(PROTOCOL=tcp)(HOST=localhost)(PORT=1521))
    (CONNECT_DATA=(SID=PSQLU))
    (HS=OK)
  )
~~~



* Vamos a comprobar la conexión.

~~~
[oracle@localhost ~]$ isql -v PSQLU
+---------------------------------------+
| Connected!                            |
|                                       |
| sql-statement                         |
| help [tablename]                      |
| quit                                  |
|                                       |
+---------------------------------------+
~~~

* Vamos a comprobar que podemos hacer una SELECT.

~~~
SQL> SELECT * FROM usuarios;
+------------+--------+
| nombre     | clave  |
+------------+--------+
| Alejandro  | 1      |
+------------+--------+
~~~

* Vamos a configurar un fichero que debemos generar en `/opt/oracle/product/19c/dbhome_1/hs/admin/initPSQLU.ora` donde debemos añadir las siguientes líneas.

~~~
HS_FDS_CONNECT_INFO = PSQLU
HS_FDS_TRACE_LEVEL = DEBUG
HS_FDS_SHAREABLE_NAME = /usr/lib64/psqlodbcw.so
HS_LANGUAGE = AMERICAN_AMERICA.WE8ISO8859P1
set ODBCINI=/etc/odbc.ini
~~~

* Ahora configuramos nuestro fichero listener, donde deberemos añadir la escucha al driver de ODBC y especificando nuestro DNS.

~~~
SID_LIST_LISTENER=
  (SID_LIST=
      (SID_DESC=
         (SID_NAME=PSQLU)
         (ORACLE_HOME=/opt/oracle/product/19c/dbhome_1)
         (PROGRAM=dg4odbc)
      )
  )

LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))
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
~~~

* También vamos a configurar el fichero tnsnames.ora donde definiremos la nueva conexión que realmente será a nuestra propia máquina.

~~~
ORCLCDB =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ORCLCDB)
    )
  )

LISTENER_ORCLCDB =
  (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))


PSQLU =
 (DESCRIPTION=
 (ADDRESS=(PROTOCOL=tcp)(HOST=localhost)(PORT=1521))
 (CONNECT_DATA=(SID=PSQLU))
 (HS=OK)
 )

ORCLCDB =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ORCLCDB)
    )
  )
~~~

* Tras esto reiniciamos el servicio y creamos el enlace.

~~~
[oracle@localhost ~]$ lsnrctl stop
[oracle@localhost ~]$ lsnrctl start

SQL> create public database link conexion1 connect to "alegv1" identified by "alegv1" using 'PSQLU';

Enlace con la base de datos creado.
~~~

* Ahora podremos conectarnos a este usuario y hacer una consulta a postgres.

~~~
SQL> connect c##alegv1/alegv1
Conectado.

SQL> SELECT * FROM usuarios;
+------------+--------+
| nombre     | clave  |
+------------+--------+
| Alejandro  | 1      |
+------------+--------+
~~~
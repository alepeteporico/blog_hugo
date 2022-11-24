+++
title = "Interconexion 2023"
description = ""
tags = [
    "GBD"
]
date = "2022-11-15"
menu = "main"
+++

### Conexión de Oracle a Oracle

* Debemos configurar el fichero tnsnames.ora y añadir la segunda base de datos que está en otra máquina, para ello añadiremos el siguiete contenido al fichero.

```
ORACLE2 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.121.41)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ORCLCDB)
    )
  )
```

* Comprobamos que tenemos conexión a la segunda base de datos.

~~~
root@oracleagv:~# tnsping ORACLE2

TNS Ping Utility for Linux: Version 19.0.0.0.0 - Production on 23-NOV-2022 07:50:31

Copyright (c) 1997, 2019, Oracle.  All rights reserved.

Used parameter files:
/opt/oracle/product/19c/dbhome_1/network/admin/sqlnet.ora


Used TNSNAMES adapter to resolve the alias
Attempting to contact (DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.121.41)(PORT = 1521)) (CONNECT_DATA = (SERVER = DEDICATED) (SERVICE_NAME = ORCLCDB)))
OK (10 msec)
~~~

* En el servidor 1 creamos el usuario y le damos los privilegios necesarios.

~~~
SQL> CREATE USER conexion1 identified by conexion1;

User created.
~~~

* Creamos la conexion con el otro servidor.

~~~
SQL> CREATE DATABASE LINK conexion2link
  2  CONNECT TO conexion2 IDENTIFIED BY conexion2
  3  USING 'ORACLE2';
~~~

* Ya podemos hacer una consulta al servidor 2 de oracle.

~~~
SQL> SELECT * 
  2  FROM SCOTT.EMP@conexion2link
  3  ;

     EMPNO ENAME      JOB	       MGR HIREDATE	    SAL       COMM
---------- ---------- --------- ---------- --------- ---------- ----------
    DEPTNO
----------
      7369 SMITH      CLERK	      7902 17-DEC-80	    800
	20

      7499 ALLEN      SALESMAN	      7698 20-FEB-81	   1600        300
	30

      7521 WARD       SALESMAN	      7698 22-FEB-81	   1250        500
	30


     EMPNO ENAME      JOB	       MGR HIREDATE	    SAL       COMM
---------- ---------- --------- ---------- --------- ---------- ----------
    DEPTNO
----------
      7566 JONES      MANAGER	      7839 02-APR-81	   2975
	20

      7654 MARTIN     SALESMAN	      7698 28-SEP-81	   1250       1400
	30

      7698 BLAKE      MANAGER	      7839 01-MAY-81	   2850
	30


     EMPNO ENAME      JOB	       MGR HIREDATE	    SAL       COMM
---------- ---------- --------- ---------- --------- ---------- ----------
    DEPTNO
----------
      7782 CLARK      MANAGER	      7839 09-JUN-81	   2450
	10

      7788 SCOTT      ANALYST	      7566 09-DEC-82	   3000
	20

      7839 KING       PRESIDENT 	   17-NOV-81	   5000
	10


     EMPNO ENAME      JOB	       MGR HIREDATE	    SAL       COMM
---------- ---------- --------- ---------- --------- ---------- ----------
    DEPTNO
----------
      7844 TURNER     SALESMAN	      7698 08-SEP-81	   1500 	 0
	30

      7876 ADAMS      CLERK	      7788 12-JAN-83	   1100
	20

      7900 JAMES      CLERK	      7698 03-DEC-81	    950
	30


     EMPNO ENAME      JOB	       MGR HIREDATE	    SAL       COMM
---------- ---------- --------- ---------- --------- ---------- ----------
    DEPTNO
----------
      7902 FORD       ANALYST	      7566 03-DEC-81	   3000
	20

      7934 MILLER     CLERK	      7782 23-JAN-82	   1300
	10


14 rows selected.
~~~

### Conexion de Oracle a Postgres

* Empecemos por la conexión de Oracle a postgres y después lo haremos en sentido contrario. Para esto necestiamos una paquetería específica en nuestro servidor Oracle

~~~
vagrant@oracleagv:~$ sudo apt install odbc-postgresql unixodbc
~~~

* Vamos a fijarnos en el fichero `/etc/odbcinst.ini`, aunque no configuraremos nada aquí es importante la información, pues aquí añadimos los drivers necesarios de la base de datos a la que nos queremos conectar y como vemos hay 2 de postgresql. Tendremos que user ambos en el siguiente paso.

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

* Ahora debemos configurar el fichero `/etc/odbc.ini` la conexión, añadiendo: la ip del equipo remoto, usuario y contraseña con que nos vamos a conectar y base de datos a la que nos vamos a conectar. Añadiendo tanto la conexión ANSI como la Unicode.

~~~
[PSQLU]
Debug           = 0
CommLog         = 0
ReadOnly        = 0
Driver          = PostgreSQL Unicode
Servername      = 192.168.121.143
Username        = usuario1
Password        = usuario1
Port            = 5432
Database        = prueba
Trace           = 0
TraceFile       = /tmp/sql.log

[PSQLA]

Debug           = 0
CommLog         = 0
ReadOnly        = 1
Driver          = PostgreSQL ANSI   
Servername      = 192.168.121.143
Username        = usuario1
Password        = usuario1
Port            = 5432
Database        = prueba
Trace           = 0
TraceFile       = /tmp/sql.log

[Default]
Driver = /usr/lib/x86_64-linux-gnu/odbc/liboplodbcS.so
~~~

* Comprobamos que la configuración se ha realizado correctamente.

~~~
vagrant@oracleagv:~$ sudo odbcinst -q -d
[PostgreSQL ANSI]
[PostgreSQL Unicode]

vagrant@oracleagv:~$ sudo odbcinst -q -s
[PSQLU]
[PSQLA]
[Default]
~~~

* Nos dirigimos a nuestra máquina postgres y configuramos el fichero `/etc/postgresql/13/main/postgresql.conf` para que escuche la petición de conexión.

~~~
listen_addresses = '*'
~~~

* Ahora podemos conectarnos desde cualquiera de las dos.

~~~
vagrant@oracleagv:~$ isql -v PSQLU
+---------------------------------------+
| Connected!                            |
|                                       |
| sql-statement                         |
| help [tablename]                      |
| quit                                  |
|                                       |
+---------------------------------------+
SQL>
~~~

~~~
vagrant@oracleagv:~$ isql -v PSQLA
+---------------------------------------+
| Connected!                            |
|                                       |
| sql-statement                         |
| help [tablename]                      |
| quit                                  |
|                                       |
+---------------------------------------+
SQL>
~~~

* El driver ya está funcionando, sin embargo tenemos que configurar Oracle para utilizarlo. Para ello usaremos una funcionalidad llamada `heterogeneous services` que configuraremos en el fichero `/opt/oracle/product/19c/dbhome_1/hs/admin/initdg4odbc.ora`

~~~
HS_FDS_CONNECT_INFO = PSQLU
HS_FDS_TRACE_LEVEL = Debug
HS_FDS_SHAREABLE_NAME = /usr/lib/x86_64-linux-gnu/odbc/psqlodbcw.so
HS_LANGUAGE = AMERICAN_AMERICA.WE8ISO8859P1
#
# ODBC specific environment variables
#
set ODBCINI=/etc/odbc.ini
~~~

* Ahora nos iremos al fichero `/opt/oracle/product/19c/dbhome_1/network/admin/listener.ora` en el que añadiremos el siguiente contenido.

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

* Y por supuesto también debemos configurar el `tnsnames.ora` estos dos ficheros se configuran para realizar la conexión.

~~~
PSQLU =
  (DESCRIPTION=
    (ADDRESS=(PROTOCOL=tcp)(HOST=localhost)(PORT=1521))
    (CONNECT_DATA=(SID=PSQLU))
    (HS=OK)
  )
~~~

* Iniciamos el listener.

~~~
root@oracleagv:~# lsnrctl start

LSNRCTL for Linux: Version 19.0.0.0.0 - Production on 24-NOV-2022 12:08:50

Copyright (c) 1991, 2019, Oracle.  All rights reserved.

Starting /opt/oracle/product/19c/dbhome_1/bin/tnslsnr: please wait...

TNSLSNR for Linux: Version 19.0.0.0.0 - Production
System parameter file is /opt/oracle/product/19c/dbhome_1/network/admin/listener.ora
Log messages written to /opt/oracle/product/19c/dbhome_1/network/log/listener.log
Listening on: (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=oracleagv)(PORT=1521)))
Listening on: (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1521)))

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=oracleagv)(PORT=1521)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 19.0.0.0.0 - Production
Start Date                24-NOV-2022 12:08:51
Uptime                    0 days 0 hr. 0 min. 0 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /opt/oracle/product/19c/dbhome_1/network/admin/listener.ora
Listener Log File         /opt/oracle/product/19c/dbhome_1/network/log/listener.log
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=oracleagv)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1521)))
Services Summary...
Service "PSQLU" has 1 instance(s).
  Instance "PSQLU", status UNKNOWN, has 1 handler(s) for this service...
The command completed successfully
~~~

* Ahora crearemos un link a la base de datos remota como hicimos anteriormente para la conexión oracle-oracle. 

~~~
SQL> CREATE DATABASE LINK linkpostgres
  2  CONNECT TO "usuario1" IDENTIFIED BY "usuario1"
  3  USING 'PSQLU';
~~~

* Ahora debería funcionar sin embargo el link da un fallo al conectarse.

~~~
SQL> SELECT *
  2  FROM "Jockeys"@linkpostgres;
FROM "Jockeys"@linkpostgres
               *
ERROR at line 2:
ORA-28500: connection from ORACLE to a non-Oracle system returned this message:
ORA-02063: preceding line from LINKPOSTGRES
~~~

### Conexión postgres a postgres

* Tenemos nuestros dos postgresql escuchando las peticiones tal como lo hemos hecho anteriormente. Una vez hecho este primer paso vamos a crear el link en una de las bases de datos.

~~~
postgres=# create extension dblink;
CREATE EXTENSION
~~~

* Vamos a hacer una consulta a la base de datos remota

~~~
prueba'> SELECT * FROM dblink('dbname=prueba host=192.168.121.1 user=usuario1 password=usuario1', 'SELECT * FROM clientes');

    nif    |  nombre  |    apellidos     |        direccion        |  localidad   | provincia | telefono  
-----------+----------+------------------+-------------------------+--------------+-----------+-----------
 67701271N | Alvaro   | Caliani Reyes    | C/Tajo nº 18            | Dos Hermanas | Sevilla   | 654230845
 92974943L | Adrian   | Angulo Lamas     | C/Hércules Bloque 3 3ºD | Sevilla      | Sevilla   | 637925632
 62564313N | Fernando | Ruiperez Segovia | C/Alcoba Nº 5           | Dos Hermanas | Sevilla   | 652582684
 93848221X | Sarai    | Aragon Morales   | C/Rosales Nº 7          | Torrox       | Málaga    | 632458625
~~~
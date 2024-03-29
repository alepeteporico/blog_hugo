+++
title = "Auditorias de bases de datos"
description = ""
tags = [
    "GBD"
]
date = "2023-02-16"
menu = "main"
+++

1. Activa desde SQL*Plus la auditoría de los intentos de acceso exitosos al sistema. Comprueba su funcionamiento.

* Vamos a activarlo.

~~~
SQL> ALTER SYSTEM SET audit_trail=db scope=spfile;

System altered.
~~~

* Reiniciamos la base de datos para comprobar.

~~~
SQL> shutdown
Database closed.
Database dismounted.
ORACLE instance shut down.
SQL> startup 
ORACLE instance started.

Total System Global Area 1660941680 bytes
Fixed Size		    9135472 bytes
Variable Size		  973078528 bytes
Database Buffers	  671088640 bytes
Redo Buffers		    7639040 bytes
Database mounted.
Database opened.
~~~

* Usamos el show parameter para ver el estado de este parametro.

~~~
SQL> SHOW PARAMETER AUDIT

NAME				     TYPE	 VALUE
------------------------------------ ----------- ------------------------------
audit_file_dest 		     string	 /opt/oracle/admin/ORCLCDB/adum
						 p
audit_sys_operations		     boolean	 TRUE
audit_syslog_level		     string
audit_trail			     string	 DB
unified_audit_common_systemlog	     string
unified_audit_sga_queue_size	     integer	 1048576
unified_audit_systemlog 	     string
~~~

* Creamos la auditoria.

~~~
SQL> AUDIT CREATE SESSION WHENEVER SUCCESSFUL;

Audit succeeded.
~~~

* Vamos a ver la auditoria después de haber iniciado sesión.

~~~
SQL> SELECT USERNAME, OS_USERNAME, TIMESTAMP, ACTION_NAME, RETURNCODE
FROM dba_audit_session  
WHERE username='SCOTT';
  2    3  
USERNAME
--------------------------------------------------------------------------------
OS_USERNAME
--------------------------------------------------------------------------------
TIMESTAMP ACTION_NAME		       RETURNCODE
--------- ---------------------------- ----------
SCOTT
vagrant
06-MAR-23 LOGON 
~~~

* Para desactivar la auditoria:

~~~
SQL> NOAUDIT CREATE SESSION WHENEVER SUCCESSFUL;

Noaudit succeeded.
~~~

2. Realiza un procedimiento en PL/SQL que te muestre los accesos fallidos junto con el motivo de los mismos, transformando el código de error almacenado en un mensaje de texto comprensible. Contempla todos los motivos posibles para que un acceso sea fallido.

* Procedimiento que muestra el motivo del intento fallido.

~~~
CREATE OR REPLACE PROCEDURE MostrarMotivo(v_codigo NUMBER)
IS
BEGIN

    CASE v_codigo
    WHEN 1017 THEN
        dbms_output.put_line('MOTIVO: CONTRASEÑA INCORRECTA');

    WHEN 28000 THEN
        dbms_output.put_line('MOTIVO: CUENTA BLOQUEADA');

    WHEN 01045 THEN
        dbms_output.put_line('MOTIVO: EL USUARIO NO TIENE PRIVILEGIOS DE CREATE SESSION');

    WHEN 28001 THEN
        dbms_output.put_line('MOTIVO: LA CONTRASEÑA HA EXPIRADO');

    WHEN 3136 THEN
        dbms_output.put_line('MOTIVO: TIEMPO DE ESPERA DE LA CONEXIÓN AGOTADO');

    WHEN 28003 THEN
        dbms_output.put_line('MOTIVO: LA VERIFICACIÓN DE LA CONTRASEÑA FALLO');

    WHEN 28007 THEN
        dbms_output.put_line('MOTIVO: LA CONTRASEÑA NO PUEDE SER REUTILIZADA');

    WHEN 28043 THEN
        dbms_output.put_line('MOTIVO: CREDENCIALES NO VALIDAS PARA LA CONEXIÓN DB-OID');

    WHEN 00911 THEN
        dbms_output.put_line('MOTIVO: CARACTERES NO VALIDOS');

    ELSE
        dbms_output.put_line('MOTIVO: ERROR DESCONOCIDO');
    END CASE;
END;
/
~~~

* procedimiento que muestra los accesos fallidos.

~~~
CREATE OR REPLACE PROCEDURE AccesosFallidos
IS
    CURSOR c_accesos
    IS
    SELECT username, returncode, timestamp
    FROM dba_audit_session 
    WHERE action_name='LOGON' 
    AND returncode != 0 
    ORDER BY timestamp;

    v_motivo VARCHAR2(50);
BEGIN
    FOR v_acceso IN c_accesos LOOP
        dbms_output.put_line('USUARIO: '||v_acceso.username);
        dbms_output.put_line('FECHA: '||TO_CHAR(v_acceso.timestamp,'YY/MM/DD DY HH24:MI'));
        MostrarMotivo(v_acceso.returncode);
        dbms_output.put_line('------------------------------------------------------------');
    END LOOP; 
END;
/
~~~

* Comprobación de ejecución.

~~~
SQL> exec AccesosFallidos;
USUARIO: SCOTT
FECHA: 17/02/23 FRI 12:36
MOTIVO: CONTRASE??A INCORRECTA
------------------------------------------------------------
USUARIO: PRUEBA
FECHA: 05/03/23 SUN 17:23
MOTIVO: CUENTA BLOQUEADA

PL/SQL procedure successfully completed.
~~~

3. Activa la auditoría de las operaciones DML realizadas por SCOTT. Comprueba su funcionamiento.


* Creamos la auditoria.

~~~
SQL> AUDIT INSERT TABLE, UPDATE TABLE, DELETE TABLE, SELECT TABLE BY SCOTT BY ACCESS;

Audit succeeded.
~~~

* Después de realizar algún insert vamos a comprobar que funciona haciendo una `SELECT` sencilla.

~~~
SQL> SELECT obj_name, action_name, timestamp
FROM dba_audit_object
WHERE username='SCOTT';

OBJ_NAME
--------------------------------------------------------------------------------
ACTION_NAME		     TIMESTAMP
---------------------------- ---------
EMP
INSERT			     17-FEB-23
OBJ_NAME
--------------------------------------------------------------------------------
ACTION_NAME		     TIMESTAMP
---------------------------- ---------
DUAL
SELECT			     06-MAR-23
~~~

4. Realiza una auditoría de grano fino para almacenar información sobre la inserción de empleados con sueldo superior a 2000 en la tabla emp de scott.

* Creamos la politica de auditoria.

~~~
BEGIN
    DBMS_FGA.ADD_POLICY (
        object_schema      =>  'SCOTT',
        object_name        =>  'EMP',
        policy_name        =>  'SueldoAlto',
        audit_condition    =>  'SAL > 2000',
        statement_types    =>  'INSERT,UPDATE'
    );
END;
/
~~~

* Creamos el nuevo registro que quedará auditado.

~~~
SQL> INSERT INTO EMP VALUES
(7917, 'JUAN', 'CLERK', 7746,
TO_DATE('23-JAN-1982', 'DD-MON-YYYY'), 2100, NULL, 10);
~~~

* Realizamos la consulta necesaria para comprobar que se ha auditado.

~~~
SQL> SELECT sql_text
FROM dba_fga_audit_trail
WHERE policy_name='SUELDOALTO';

SQL_TEXT
--------------------------------------------------------------------------------
INSERT INTO EMP VALUES
(7917, 'JUAN', 'CLERK', 7746,
TO_DATE('23-JAN-1982', 'DD-MON-YYYY'), 2100, NULL, 10)
~~~

5. Explica la diferencia entre auditar una operación by access o by session ilustrándolo con ejemplos.

* `BY ACCESS`: Creará un registro dentro de la auditoria por cada acción realizada.

* `BY SESSION`: Creará un registro también por acción, pero lo agrupará por cada sesión que se inicie del usuario especificado.

* Creamos una auditoria `BY SESSION`.

~~~
AUDIT INSERT TABLE, UPDATE TABLE, DELETE TABLE, SELECT TABLE BY SCOTT BY SESSION;
~~~

* Realizamos algunas acciones.

~~~
SQL> INSERT INTO DEPT VALUES (50, 'OPERATIONS', 'SAN JUAN');

1 row created.

SQL> UPDATE DEPT SET loc='MAIRENA' WHERE deptno=50;

1 rows updated.

SQL> DELETE FROM DEPT WHERE deptno=50;

1 rows deleted.
~~~

* Vamos a comprobar la auditoria.

~~~
SQL> SELECT owner, obj_name, action_name, timestamp, priv_used
FROM dba_audit_object
WHERE username='SCOTT';  

OWNER
--------------------------------------------------------------------------------
OBJ_NAME
--------------------------------------------------------------------------------
ACTION_NAME		     TIMESTAMP PRIV_USED
---------------------------- --------- ----------------------------------------
SYS
DUAL
SESSION REC		     20-FEB-23

SCOTT
DEPT
SESSION REC		     20-FEB-23

OWNER
--------------------------------------------------------------------------------
OBJ_NAME
--------------------------------------------------------------------------------
ACTION_NAME		     TIMESTAMP PRIV_USED
---------------------------- --------- ----------------------------------------

SCOTT
DEPT
SESSION REC		     20-FEB-23

SCOTT
DEPT

OWNER
--------------------------------------------------------------------------------
OBJ_NAME
--------------------------------------------------------------------------------
ACTION_NAME		     TIMESTAMP PRIV_USED
---------------------------- --------- ----------------------------------------
SESSION REC		     20-FEB-23
~~~

* Y dejamos como ejemplo la que creamos `BY ACCESS` en el ejercicio 3.

~~~
SQL> AUDIT INSERT TABLE, UPDATE TABLE, DELETE TABLE, SELECT TABLE BY SCOTT BY ACCESS;

Audit succeeded.
~~~

* Después de realizar algún insert vamos a comprobar que funciona haciendo una `SELECT` sencilla.

~~~
SQL> SELECT obj_name, action_name, timestamp
FROM dba_audit_object
WHERE username='SCOTT';

OBJ_NAME
--------------------------------------------------------------------------------
ACTION_NAME		     TIMESTAMP
---------------------------- ---------
EMP
INSERT			     17-FEB-23
~~~

6. Documenta las diferencias entre los valores db y db, extended del parámetro audit_trail de ORACLE. Demuéstralas poniendo un ejemplo de la información sobre una operación concreta recopilada con cada uno de ellos.

* No hay mucha diferencia, mas que en una pequeña información ya que db extend también rellena los valores de `SQLBIND` Y `SQLTEXT`

* Para activarlo usamos la siguiente orden:

~~~
SQL> ALTER SYSTEM SET audit_trail = DB, EXTENDED SCOPE=SPFILE;

System altered.
~~~

* Para comprobarlo debemos reiniciar la base de datos.

~~~
SQL> shutdown
Database closed.
Database dismounted.
ORACLE instance shut down.
SQL> startup
ORACLE instance started.

Total System Global Area 1660941680 bytes
Fixed Size		    9135472 bytes
Variable Size		  973078528 bytes
Database Buffers	  671088640 bytes
Redo Buffers		    7639040 bytes
Database mounted.
Database opened.
~~~

* Comprobamos que se ha realizado el cambio.

~~~
SQL> SHOW PARAMETER AUDIT;

NAME				     TYPE	 VALUE
------------------------------------ ----------- ------------------------------
audit_file_dest 		     string	 /opt/oracle/admin/ORCLCDB/adum
						 p
audit_sys_operations		     boolean	 TRUE
audit_syslog_level		     string
audit_trail			     string	 DB, EXTENDED
unified_audit_common_systemlog	     string
unified_audit_sga_queue_size	     integer	 1048576
unified_audit_systemlog 	     string
~~~

* Ya tenemos un ejemplo de una consulta cuando no teníamos el db, extended.

~~~
SQL> SELECT obj_name, action_name, timestamp
FROM dba_audit_object
WHERE username='SCOTT';

OBJ_NAME
--------------------------------------------------------------------------------
ACTION_NAME		     TIMESTAMP
---------------------------- ---------
EMP
INSERT			     17-FEB-23
~~~

* Veamos una donde si tenemos este parametro.

~~~
SQL> select obj_name, action_name, timestamp, sql_text, sql_bind
from dba_audit_object
where username='SCOTT';

OBJ_NAME
--------------------------------------------------------------------------------
ACTION_NAME		     TIMESTAMP
---------------------------- ---------
SQL_TEXT
--------------------------------------------------------------------------------
SQL_BIND
--------------------------------------------------------------------------------
DUAL
SELECT			     21-FEB-23
SELECT DECODE(USER, 'XS$NULL',	XS_SYS_CONTEXT('XS$SESSION','USERNAME'), USER) F
ROM SYS.DUAL
~~~

7. Averigua si en Postgres se pueden realizar los cuatro primeros apartados. Si es así, documenta el proceso adecuadamente.

* No tenemos por defecto forma de auditar nuestra base de datos, a no ser que usemos triggers y procedimientos personalizados. Sin embargo existe una extensión llamada `pgaudit` que vamos a instalar ahora mismo.

* Debemos tener en cuenta que para la instalación necesitamos un PostgreSQL 15. Una vez tengamos esta versión de postgres vamos a realizar la instalación, comenzaremos clonando el repositorio.

~~~
vagrant@buster:~$ git clone https://github.com/pgaudit/pgaudit.git
Cloning into 'pgaudit'...
remote: Enumerating objects: 1148, done.
remote: Counting objects: 100% (555/555), done.
remote: Compressing objects: 100% (139/139), done.
remote: Total 1148 (delta 466), reused 461 (delta 404), pack-reused 593
Receiving objects: 100% (1148/1148), 280.79 KiB | 2.26 MiB/s, done.
Resolving deltas: 100% (722/722), done.
~~~

* Sin embargo esta herramienta parece estar en periodo de testing y tiene fallos, por lo que cuando intentamos instalarla nos da un fallo que no consigo arreglar.

~~~
vagrant@buster:~/pgaudit$ make install USE_PGXS=1 PG_CONFIG=/usr/bin/pg_config
gcc -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Werror=vla -Wendif-labels -Wmissing-format-attribute -Wimplicit-fallthrough=3 -Wcast-function-type -Wformat-security -fno-strict-aliasing -fwrapv -fexcess-precision=standard -Wno-format-truncation -Wno-stringop-truncation -g -g -O2 -fstack-protector-strong -Wformat -Werror=format-security -fno-omit-frame-pointer -fPIC -I. -I./ -I/usr/include/postgresql/15/server -I/usr/include/postgresql/internal  -Wdate-time -D_FORTIFY_SOURCE=2 -D_GNU_SOURCE -I/usr/include/libxml2   -c -o pgaudit.o pgaudit.c
pgaudit.c:11:10: fatal error: postgres.h: No such file or directory
 #include "postgres.h"
          ^~~~~~~~~~~~
~~~

* Gracias a la documentación oficial podemos saber que hacer con esta herramienta por ejemplo para ver los accesos existosos al sistema.

~~~
set pgaudit.role = 'usuario';
~~~

* O para activar auditorias de operaciones DML.

~~~
set pgaudit.log = 'write, ddl';
set pgaudit.log_relation = on;

set pgaudit.log = 'read, ddl';
~~~

* Podemos dirigirnos al [repositorio oficial](https://github.com/pgaudit/pgaudit/blob/master/README.md) con la documentación para saber todas las opciones que tiene esta herramienta.

* Pero vamos a usar un nuevo metodo, para ello instalaremos la siguiente herramienta que contiene varios triggers que crean vistas para auditar postgres.

~~~
postgres@postgresagv:~$ wget https://raw.githubusercontent.com/2ndQuadrant/audit-trigger/master/audit.sql
~~~

* Y lo instalamos dentro de postgres.

~~~
postgres=# \i audit.sql
~~~

### Adutiar accesos fallidos.

* Para realizar esta tarea nos dirigimos al fichero de configuración de postgres `/etc/postgresql/13/main/postgresql.conf` y añadimos la siguiente línea:

~~~
log_statement = 'all'
~~~

* Una vez hecho esto y reiniciado el servidor miramos el fichero de log para ver los accesos fallidos

~~~
vagrant@postgresagv:~$ sudo tail -f /var/log/postgresql/postgresql-13-main.log
2023-03-08 08:12:31.375 UTC [2514] LOG:  database system is ready to accept connections
2023-03-08 08:12:32.431 UTC [2525] postgres@template1 LOG:  statement: 
2023-03-08 08:12:32.942 UTC [2528] postgres@template1 LOG:  statement: 
2023-03-08 08:12:33.453 UTC [2531] postgres@template1 LOG:  statement: 
2023-03-08 08:12:53.122 UTC [2554] aplicacion@empresa FATAL:  password authentication failed for user "aplicacion"
2023-03-08 08:12:53.122 UTC [2554] aplicacion@empresa DETAIL:  Password does not match for user "aplicacion".
	Connection matched pg_hba.conf line 94: "local   all             all                                    md5"
2023-03-08 08:12:58.438 UTC [2567] aplicacion@empresa FATAL:  password authentication failed for user "aplicacion"
2023-03-08 08:12:58.438 UTC [2567] aplicacion@empresa DETAIL:  Password does not match for user "aplicacion".
	Connection matched pg_hba.conf line 94: "local   all             all                                    md5"
~~~

### Auditar operaciones DML

* Ahora si haremos uso de los triggers instalados anteriormente, Creamos el trigger para la tabla dept.

~~~
empresa=# select audit.audit_table('dept');
NOTICE:  trigger "audit_trigger_row" for relation "dept" does not exist, skipping
NOTICE:  trigger "audit_trigger_stm" for relation "dept" does not exist, skipping
NOTICE:  CREATE TRIGGER audit_trigger_row AFTER INSERT OR UPDATE OR DELETE ON dept FOR EACH ROW EXECUTE PROCEDURE audit.if_modified_func('true');
NOTICE:  CREATE TRIGGER audit_trigger_stm AFTER TRUNCATE ON dept FOR EACH STATEMENT EXECUTE PROCEDURE audit.if_modified_func('true');
 audit_table 
-------------
 
(1 row)
~~~

* Realizamos algunas operaciones DML.

~~~
empresa=# select * from dept;
 deptno |   dname    |   loc    
--------+------------+----------
     10 | ACCOUNTING | NEW YORK
     20 | RESEARCH   | DALLAS
     30 | SALES      | CHICAGO
     40 | OPERATIONS | BOSTON
(4 rows)

empresa=# insert into dept values(50,'LIMPIADOR','MORON');
INSERT 0 1
empresa=# delete from dept where deptno=50;
DELETE 1
~~~

* Hacemos una consulta para ver las operaciones que se han realizado que en este caso será en la vista `logged_actions`.

~~~
empresa=# select session_user_name, action, table_name, action_tstamp_clk, client_query
empresa-# from audit.logged_actions;

 session_user_name | action | table_name |       action_tstamp_clk       |                  client_query                   
-------------------+--------+------------+-------------------------------+-------------------------------------------------
 postgres          | D      | dept       | 2023-03-08 08:22:53.249753+00 | delete from dept where deptno=50;
 postgres          | I      | dept       | 2023-03-08 08:23:12.649005+00 | insert into dept values(50,'LIMPIADOR','MORON')+
                   |        |            |                               | ;
(2 rows)
~~~

8. Averigua si en MySQL se pueden realizar los apartados 1, 3 y 4. Si es así, documenta el proceso adecuadamente.

* Instalamos el plugin de auditoria.

~~~
MariaDB [(none)]> INSTALL SONAME 'server_audit';
~~~

* Vamos a auditar los accesos.

~~~
MariaDB [(none)]> SET GLOBAL server_audit_logging=ON;
~~~

* Para auditar las operaciones DDL

~~~
MariaDB [(none)]> SET GLOBAL server_audit_events = 'QUERY_DDL';
~~~

* Vemos los loggins para comprobar las auditorias.

~~~
alejandrogv@alepeteporico:~$ sudo cat /var/lib/mysql/server_audit.log
20230221 17:47:57,alepeteporico,root,localhost,31,63,QUERY,,'SET GLOBAL server_audit_file_rotate_now = ON',0
20230221 17:49:49,alepeteporico,root,localhost,31,64,QUERY,,'mysql­-server_auditing',1064
20230221 17:49:53,alepeteporico,root,localhost,31,0,DISCONNECT,,,0
20230301 08:37:40,alepeteporico,root,localhost,30,57,QUERY,,'SET GLOBAL server_audit_logging=ON',0
~~~

9. Averigua las posibilidades que ofrece MongoDB para auditar los cambios que va sufriendo un documento. Demuestra su funcionamiento.

* Para usar las auditorias necesitamos mongo enterprise. Vamos a realizar la instalación.

~~~
vagrant@buster:~$ sudo apt install gnupg

vagrant@buster:~$ wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
OK

vagrant@buster:~$ echo "deb http://repo.mongodb.com/apt/debian buster/mongodb-enterprise/6.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-enterprise.list
deb http://repo.mongodb.com/apt/debian buster/mongodb-enterprise/6.0 main

vagrant@buster:~$ sudo apt update

vagrant@buster:~$ sudo apt-get install -y mongodb-enterprise
~~~

* Una vez instalado debemos activar las auditorias y el repositorio donde se guardarán. Para ello añadimos lo siguiente el fichero de configuración `/etc/mongod.conf`

~~~
auditLog:
  destination: file   
  format: JSON
  path: /var/lib/mongodb/auditLog.json
~~~

* Después de reiniciar ya se estarían auditando los cambios en el fichero de log. Vamos a hacer algunos cambios.

#### Creación de usuario.

~~~
db.createUser({user: 'admin', pwd: 'admin', roles: [{role: 'userAdminAnyDatabase', db: 'admin'}, {role: 'readWriteAnyDatabase', db: 'admin'}]})
~~~

#### Creación de colección.

~~~
Enterprise test> use prueba
switched to db prueba
Enterprise prueba> db.createCollection("empleados")
{ ok: 1 }
~~~

* Para ver los logs usamos:

~~~
vagrant@mongoagv:~$ sudo cat /var/lib/mongodb/auditLog.json | jq
~~~

* Vemos la creación de un usuario.

~~~
{
  "atype": "createUser",
  "ts": {
    "$date": "2023-03-08T09:09:32.012+00:00"
  },
  "uuid": {
    "$binary": "4lEZ0pSvRWet2HKP/V+QbA==",
    "$type": "04"
  },
  "local": {
    "ip": "127.0.0.1",
    "port": 27017
  },
  "remote": {
    "ip": "127.0.0.1",
    "port": 46796
  },
  "users": [],
  "roles": [],
  "param": {
    "user": "admin",
    "db": "admin",
    "roles": [
      {
        "role": "readWriteAnyDatabase",
        "db": "admin"
      },
      {
        "role": "userAdminAnyDatabase",
        "db": "admin"
      }
    ]
  },
  "result": 0
}
~~~

* Creación de la colección:

~~~
{
  "atype": "authenticate",
  "ts": {
    "$date": "2023-03-08T09:12:34.042+00:00"
  },
  "uuid": {
    "$binary": "ugIel7WaQgKDCE6MQsIiXw==",
    "$type": "04"
  },
  "local": {
    "ip": "127.0.0.1",
    "port": 27017
  },
  "remote": {
    "ip": "127.0.0.1",
    "port": 46796
  },
  "users": [
    {
        "user": "admin",
        "db": "admin"
    }
  ],
  "roles": [
    {
        "role": "readWriteAnyDatabase",
        "db": "admin"
    },
    {
        "role": "userAdminAnyDatabase",
        "db": "admin"
    }
  ],
  "param": {
    "user": "admin",
    "db": "admin",
    "mechanism": "SCRAM-SHA-256"
  },
  "result": 0
}
~~~

10.   Averigua si en MongoDB se pueden auditar los accesos a una colección concreta. Demuestra su funcionamiento.

* Si que tenemos esa posibilidad mediante la siguiente orden.

~~~
db.setLogLevel(level, component)
~~~

* Vamos a ver tanto los levels como los components:

#### levels:

`0`: Nada

`1`: Errores

`2`: Errores y advertencias

`3`: Errores, advertencias y mensajes informativos.

`4`: Errores, advertencias, mensajes informativos y mensajes de depuración

#### components:

**“accessControl”, “command”, “index”, “query”, “replication”, “sharding”, “storage”, “write”, “audit”, “cluster”, “control”, “ftdc”, “geo”, “network”, “query”, “repl”, “security”, “sharding”, “storage”, “write”.**

* Nosotros queremos ver los accesos, por lo que usaremos el componente "accesControl" y por ejemplo el nivel 3.

~~~
db.setLogLevel(3, "accessControl")
~~~
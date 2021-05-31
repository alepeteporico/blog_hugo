+++
title = "Auditoria"
description = ""
tags = [
    "ABD"
]
date = "2021-05-31"
menu = "main"
+++

### Activa desde SQL*Plus la auditoría de los intentos de acceso fallidos al sistema. Comprueba su funcionamiento.

* Primero vamos a visualizar los diferentes parametros de auditorias de los que disponemos.

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

* Nosotros usaremos `audit_trail`

        SQL> ALTER SYSTEM SET audit_trail=db scope=spfile;

        System altered.

* Reiniciamos nuestra base de datos.

        SQL> SHUTDOWN
        Database closed.
        Database dismounted.
        ORACLE instance shut down.
        SQL> STARTUP
        ORACLE instance started.

        Total System Global Area  830470160 bytes
        Fixed Size		    9140240 bytes
        Variable Size		  499122176 bytes
        Database Buffers	  318767104 bytes
        Redo Buffers		    3440640 bytes
        Database mounted.
        Database opened.

* Y comprobamos que este parametro está activado.

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

* Ahora activaremos la auditoria.

        SQL> AUDIT CREATE SESSION WHENEVER NOT SUCCESSFUL;

        Audit succeeded.

* Creamos una auditoria para un usuario que elijamos.

        SQL> AUDIT CREATE SESSION BY ale;  

        Audit succeeded.

* Comprobamos que está activa.

        SQL> SELECT * FROM DBA_PRIV_AUDIT_OPTS;

        USER_NAME
        --------------------------------------------------------------------------------
        PROXY_NAME
        --------------------------------------------------------------------------------
        PRIVILEGE				 SUCCESS    FAILURE
        ---------------------------------------- ---------- ----------

        ALE

        CREATE SESSION				 BY ACCESS  BY ACCESS

* Vamos a hacer algunos intentos de inicio de sesión con este usuario fallido.

        [oracle@oracle ~]$ sqlplus

        SQL*Plus: Release 19.0.0.0.0 - Production on Mon May 31 14:46:51 2021
        Version 19.3.0.0.0

        Copyright (c) 1982, 2019, Oracle.  All rights reserved.

        Enter user-name: ale
        Enter password: 
        ERROR:
        ORA-01017: invalid username/password; logon denied


        Enter user-name: ale
        Enter password: 

        Connected to:
        Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
        Version 19.3.0.0.0

* Y ahora comprobaremos la auditoria para ver los intentos fallidos.

        SQL> SELECT OS_USERNAME, USERNAME, EXTENDED_TIMESTAMP, ACTION_NAME, RETURNCODE
          2  FROM DBA_AUDIT_SESSION;

        OS_USERNAME
        --------------------------------------------------------------------------------
        USERNAME
        --------------------------------------------------------------------------------
        EXTENDED_TIMESTAMP
        ---------------------------------------------------------------------------
        ACTION_NAME		     RETURNCODE
        ---------------------------- ----------
        oracle
        ALE
        31-MAY-21 02.46.57.464628 PM +00:00
        LOGON				      0


        OS_USERNAME
        --------------------------------------------------------------------------------
        USERNAME
        --------------------------------------------------------------------------------
        EXTENDED_TIMESTAMP
        ---------------------------------------------------------------------------
        ACTION_NAME		     RETURNCODE
        ---------------------------- ----------
        oracle
        ERROR
        31-MAY-21 02.45.01.660020 PM +00:00
        LOGON				   1017


        OS_USERNAME
        --------------------------------------------------------------------------------
        USERNAME
        --------------------------------------------------------------------------------
        EXTENDED_TIMESTAMP
        ---------------------------------------------------------------------------
        ACTION_NAME		     RETURNCODE
        ---------------------------- ----------
        oracle
        RALE
        31-MAY-21 02.45.07.774876 PM +00:00
        LOGON				   1017


        OS_USERNAME
        --------------------------------------------------------------------------------
        USERNAME
        --------------------------------------------------------------------------------
        EXTENDED_TIMESTAMP
        ---------------------------------------------------------------------------
        ACTION_NAME		     RETURNCODE
        ---------------------------- ----------
        oracle
        ALE
        31-MAY-21 02.45.11.642752 PM +00:00
        LOGON				   1045


        OS_USERNAME
        --------------------------------------------------------------------------------
        USERNAME
        --------------------------------------------------------------------------------
        EXTENDED_TIMESTAMP
        ---------------------------------------------------------------------------
        ACTION_NAME		     RETURNCODE
        ---------------------------- ----------
        oracle
        ALE
        31-MAY-21 02.45.35.528191 PM +00:00
        LOGON				   1017


        OS_USERNAME
        --------------------------------------------------------------------------------
        USERNAME
        --------------------------------------------------------------------------------
        EXTENDED_TIMESTAMP
        ---------------------------------------------------------------------------
        ACTION_NAME		     RETURNCODE
        ---------------------------- ----------
        oracle
        ALE
        31-MAY-21 02.45.39.220360 PM +00:00
        LOGON				   1045


        OS_USERNAME
        --------------------------------------------------------------------------------
        USERNAME
        --------------------------------------------------------------------------------
        EXTENDED_TIMESTAMP
        ---------------------------------------------------------------------------
        ACTION_NAME		     RETURNCODE
        ---------------------------- ----------
        oracle
        ALE
        31-MAY-21 02.45.52.633937 PM +00:00
        LOGON				   1045


        OS_USERNAME
        --------------------------------------------------------------------------------
        USERNAME
        --------------------------------------------------------------------------------
        EXTENDED_TIMESTAMP
        ---------------------------------------------------------------------------
        ACTION_NAME		     RETURNCODE
        ---------------------------- ----------
        oracle
        ALE
        31-MAY-21 02.46.54.986320 PM +00:00
        LOGON				   1017


        OS_USERNAME
        --------------------------------------------------------------------------------
        USERNAME
        --------------------------------------------------------------------------------
        EXTENDED_TIMESTAMP
        ---------------------------------------------------------------------------
        ACTION_NAME		     RETURNCODE
        ---------------------------- ----------
        oracle
        ALE
        31-MAY-21 02.48.39.814001 PM +00:00
        LOGOFF				      0


        9 rows selected.

* Para desactivar la auditoria lo haríamos usando la siguiente orden:

        SQL> NOAUDIT CREATE SESSION WHENEVER NOT SUCCESSFUL;

        Noaudit succeeded.

### Activa la auditoría de las operaciones DML realizadas por SCOTT. Comprueba su funcionamiento.

* Vamos a realizar la auditoria sobre el usuario SCOTT.

        SQL> AUDIT INSERT TABLE, UPDATE TABLE, DELETE TABLE BY SCOTT BY ACCESS;

        Audit succeeded.

* Al usar el `BY ACCESS` se guardará un registro por cada acción que se haga. vamos a realizar una prueba por ejemplo conectandonos a este usuario y añadiendo contenido a alguna tabla o modificándolo.

SQL> CONN SCOTT/TIGER
Connected.
SQL> INSERT INTO PRUEBA VALUES(10,'textoprueba');

1 row created.

* Vamos a ver las acciones que ha realizado este usuario usando la auditoria.

        SQL> SELECT obj_name, action_name, timestamp
          2  FROM dba_audit_object
          3  WHERE username='SCOTT';

        OBJ_NAME
        --------------------------------------------------------------------------------
        ACTION_NAME		     TIMESTAMP
        ---------------------------- ---------
        PRUEBA
        INSERT			     31-MAY-21

        PRUEBA
        INSERT			     31-MAY-21

        PRUEBA
        INSERT			     31-MAY-21


        OBJ_NAME
        --------------------------------------------------------------------------------
        ACTION_NAME		     TIMESTAMP
        ---------------------------- ---------
        PRUEBA
        INSERT			     31-MAY-21

### Realiza una auditoría de grano fino para almacenar información sobre la inserción de empleados del departamento 10 en la tabla emp de scott.

* Haremos un proceso PL/SQL para la creación de está auditoría.

        SQL> BEGIN
          2  DBMS_FGA.ADD_POLICY (
          3  object_schema      =>  'SCOTT',
          4  object_name        =>  'EMP',
          5  policy_name        =>  'politica1',
          6  audit_condition    =>  'DEPTNO = 10',
          7  statement_types    =>  'INSERT'
          8  );
          9  END;
         10  /

        PL/SQL procedure successfully completed.

* Vamos a hacer alguna inserción en el departamento 10 para posteriormente comprobarlo.

        SQL> INSERT INTO EMP VALUES(8000,'Alvaro','mozo',null,sysdate,1000,1000,10);

        1 row created.

        SQL> INSERT INTO EMP VALUES(8040,'Lila','CM',null,sysdate,1500,1500,10);

        1 row created.

* Comprobemos que la auditoría funciona.

        SQL> SELECT sql_text
          2  FROM dba_fga_audit_trail
          3  WHERE policy_name='politica1';

        SQL_TEXT
        --------------------------------------------------------------------------------
        INSERT INTO EMP VALUES(8000,'Alvaro','mozo',null,sysdate,1000,1000,10);
        INSERT INTO EMP VALUES(8040,'Lila','CM',null,sysdate,1500,1500,10);

### Explica la diferencia entre auditar una operación by access o by session.

* **BY ACCESS:** Realiza un registro de todas las acciones sin distinción de ningún parámetro, simplemente registra todas las acciones que se han realizado. Ya lo vimos anteriormente.

* **BY SESSION:** También se realiza un registro de todas las acciones, sin embargo se agrupan por sesión iniciada, es decir, cada vez que iniciemos sesión empezará a agrupar las acciones que se realizan en esa sesión. Cuando cerremos sesión y volvamos a abrir de nuevo empezará a registrar agrupando sobre otra sesión.

### Documenta las diferencias entre los valores db y db, extended del parámetro audit_trail de ORACLE. Demuéstralas poniendo un ejemplo de la información sobre una operación concreta recopilada con cada uno de ellos.

* db almacena información en `SYS.AUD$`. Y db extend también escribe sobre `SQLBIND` y `SQLTEXT`.

### Averigua si en Postgres se pueden realizar los apartados 1, 3 y 4. Si es así, documenta el proceso adecuadamente.

* No existen las auditorias en postgres tal como hemos visto en Oracle, pero tenemos dos opciones para realizarlas.

* La primera es crear una tabla y una función que actue sobre ella y vaya actualizando sus datos. Creamos un trigger que se disparará cuando se produzcan los cambios que especifiquemos y añadirán información a esta tabla.

* La otra opción podría ser usar una extensión no oficial llamada `pgAudit` podemos encontrar [aquí](https://github.com/pgaudit/pgaudit) el repositorio de github con esta extensión.

### Averigua si en MySQL se pueden realizar los apartados 1, 3 y 4. Si es así, documenta el proceso adecuadamente.

* Vamos a crear una base de datos de auditorias y dentro una tabla que alamcenará la información cuando se disparen el trigger que crearemos posteriormente.

        MariaDB [(none)]> CREATE DATABASE auditoria;
        Query OK, 1 row affected (0.001 sec)

        MariaDB [(none)]> use auditoria;
        Database changed

        MariaDB [auditoria]> CREATE TABLE acceso (
            -> codigo int(10) NOT NULL AUTO_INCREMENT,
            -> user VARCHAR(100),
            -> fecha DATETIME,
            -> PRIMARY KEY (`codigo`)
            -> )
            -> ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
        Query OK, 0 rows affected (0.004 sec)

* Creamos una base de datos y una tabla de prueba sobre la que haremos las pruebas.

        MariaDB [auditoria]> CREATE DATABASE prueba_aud;
        Query OK, 1 row affected (0.001 sec)

        MariaDB [auditoria]> use prueba_aud;
        Database changed
        MariaDB [prueba_aud]> CREATE TABLE algo (
            -> codigo varchar(5),
            -> unacosa varchar(10),
            -> otra varchar(10),
            -> CONSTRAINT pk_codigo PRIMARY KEY (codigo));
        Query OK, 0 rows affected, 1 warning (0.047 sec)

* Ahora si, podemos crear el trigger.

        MariaDB [auditoria]> delimiter $$
        MariaDB [auditoria]> CREATE TRIGGER prueba_aud.root
            -> BEFORE INSERT ON prueba_aud.algo
            -> FOR EACH ROW
            -> BEGIN
            -> INSERT INTO auditoria.acceso(user, fecha)
            -> values (CURRENT_USER(), NOW());
            -> END$$
        Query OK, 0 rows affected (0.008 sec)

* Añadimos contenido a la tabla `algo`.

        MariaDB [prueba_aud]> INSERT INTO algo
            -> VALUES ('3245','aqui','alla');
        Query OK, 1 row affected (0.004 sec)

* Y si volvemos a la base de datos de auditoria y visualizamos la información de la tabla `acceso` veremos que se ha añadido una entrada con el usuario que añadió algo y en que fecha.

        MariaDB [auditoria]> SELECT * FROM acceso;
        +--------+----------------+---------------------+
        | codigo | user           | fecha               |
        +--------+----------------+---------------------+
        |      1 | root@localhost | 2021-05-31 17:29:38 |
        +--------+----------------+---------------------+
        1 row in set (0.000 sec)

### Averigua las posibilidades que ofrece MongoDB para auditar los cambios que va sufriendo un documento.

* Si queremos ver las auditorias que existen podemos usar la siguiente orden:

        --auditFilter

* Si queremos que se audite cuando creamos o borramos una colección podriamos usar lo siguiente:

        { atype: { $in: [ "createCollection", "dropCollection" ] } }

* También podemos auditar con filtros, usando:

        --auditFilter

### Averigua si en MongoDB se pueden auditar los accesos al sistema.

* Usando lo siguiente:

        { atype: "authenticate", "param.db": "test" }

        mongod --dbpath data/db --auth --auditDestination file --auditFilter '{ atype: "authenticate", "param.db": "test" }' --auditFormat BSON --auditPath data/db/auditLog.bson
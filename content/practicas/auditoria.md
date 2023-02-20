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
SQL> AUDIT CREATE SESSION WHENEVER NOT SUCCESSFUL;

Audit succeeded.
~~~

* Vamos a auditar a uno de nuestros usuarios.

~~~
SQL> AUDIT CREATE SESSION BY SCOTT;

Audit succeeded.


SQL> SELECT * FROM DBA_PRIV_AUDIT_OPTS;

USER_NAME
--------------------------------------------------------------------------------
PROXY_NAME
--------------------------------------------------------------------------------
PRIVILEGE				 SUCCESS    FAILURE
---------------------------------------- ---------- ----------


CREATE SESSION				 NOT SET    BY ACCESS

PROFESOR

CREATE SESSION				 BY ACCESS  BY ACCESS

USER_NAME
--------------------------------------------------------------------------------
PROXY_NAME
--------------------------------------------------------------------------------
PRIVILEGE				 SUCCESS    FAILURE
---------------------------------------- ---------- ----------

SCOTT

CREATE SESSION				 BY ACCESS  BY ACCESS
~~~

* Para desactivar la auditoria:

~~~
SQL> NOAUDIT CREATE SESSION WHENEVER NOT SUCCESSFUL;

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

* `BY SESSION`: Creará un registro 

* Tambíen podríamos crearla de la siguiente forma:

~~~
AUDIT INSERT TABLE, UPDATE TABLE, DELETE TABLE, SELECT TABLE BY SCOTT BY SESSION;
~~~

* La diferencia se que `BY SESSION` creara un registro por cada sesión iniciada y `BY ACCESS` lo creará por cada acción realizada.
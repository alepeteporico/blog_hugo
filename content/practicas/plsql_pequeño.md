+++
title = "Pequeño ejercicio plsql"
description = ""
tags = [
    "GBD"
]
date = "2022-12-03"
menu = "main"
+++

1. Hacer un procedimiento que muestre el nombre y el salario del empleado cuyo código es 7082.

~~~
CREATE OR REPLACE PROCEDURE cod_7082
    IS
        vnombre emp.ename%TYPE;
        vsal emp.sal%TYPE;
    BEGIN
        SELECT ename, sal INTO vnombre, vsal
        FROM EMP
            WHERE EMPNO='7082';
        dbms_output.put_line('El empleado: '||vnombre||', gana: '||vsal);
END cod_7082;
~~~

~~~
SQL> exec cod_7082;
El empleado: ALEJANDRO, gana: 2050

PL/SQL procedure successfully completed.
~~~

2. Hacer un procedimiento que reciba como parámetro un código de empleado y devuelva su nombre

~~~
CREATE OR REPLACE PROCEDURE cod_nombre (cod_emp emp.empno%TYPE)
IS
    nombre_emp emp.ename%TYPE;
BEGIN
    SELECT ename INTO nombre_emp
    FROM EMP
        WHERE empno=cod_emp;
    dbms_output.put_line('El nombre de este empleado es: '||nombre_emp);
END cod_nombre;
~~~

~~~
SQL> exec cod_nombre (7900);
El nombre de este empleado es: JAMES

PL/SQL procedure successfully completed.
~~~

3. Hacer un procedimiento que devuelva los nombres de los tres empleados más antiguos

~~~
CREATE OR REPLACE PROCEDURE old_emp
IS
    CURSOR c_empleados IS
        SELECT ENAME
        FROM EMP
        ORDER BY TO_CHAR(HIREDATE, 'yyyy-MM-dd') ASC
        FETCH FIRST 3 ROWS ONLY;
    cont NUMBER:=1;
BEGIN
    FOR v_empleados IN c_empleados
    LOOP
        dbms_output.put_line('Empleado '||cont||': '||v_empleados.ename);
        cont:=cont+1;
    END LOOP;
END old_emp;
~~~

~~~
SQL> exec old_emp
Empleado 1: SMITH
Empleado 2: ALEJANDRO
Empleado 3: ALLEN

PL/SQL procedure successfully completed.
~~~

4. Hacer un procedimiento que reciba el nombre de un tablespace y muestre los nombres de los usuarios que lo tienen como tablespace por defecto (Vista DBA_USERS).

~~~
CREATE OR REPLACE PROCEDURE usuario_tablespace (n_tablespace VARCHAR2)
IS
    CURSOR c_usuarios IS
        SELECT username
        FROM DBA_USERS
        WHERE default_tablespace = n_tablespace;
BEGIN
    FOR v_usuario IN c_usuarios
    LOOP
        dbms_output.put_line(v_usuario.username);
    END LOOP;
END usuario_tablespace;
~~~

~~~
SQL> exec usuario_tablespace('USERS')
GSMCATUSER
MDDATA
BECARIO
SYSBACKUP
REMOTE_SCHEDULER_AGENT
GSMUSER
SYSRAC
GSMROOTUSER
SI_INFORMTN_SCHEMA
AUDSYS
PRUEBA
DIP
ORDPLUGINS
SYSKM
ORDDATA
ORACLE_OCM
CONEXION1
SCOTT
SYSDG
ORDSYS
RAUL

PL/SQL procedure successfully completed.
~~~

5. Modificar el procedimiento anterior para que haga lo mismo pero devolviendo el número de usuarios que tienen ese tablespace como tablespace por defecto. Nota: Hay que convertir el procedimiento en función.

~~~
CREATE OR REPLACE FUNCTION num_usuarios_tablespace (n_tablespace VARCHAR2)
RETURN NUMBER
IS
    num_usuarios NUMBER;
BEGIN
    SELECT COUNT (username) INTO num_usuarios
    FROM DBA_USERS
    WHERE default_tablespace = n_tablespace;
    RETURN num_usuarios;
END;
~~~

~~~
SQL> DECLARE 
    num_usuarios NUMBER;
BEGIN
    num_usuarios:=num_usuarios_tablespace('USERS');
    dbms_output.put_line('En este tablespace hay: ' || num_usuarios||' usuarios'); 
    /

En este tablespace hay: 21 usuarios

PL/SQL procedure successfully completed.
~~~

6. Hacer un procedimiento llamado mostrar_usuarios_por_tablespace que muestre por pantalla un listado de los tablespaces existentes con la lista de usuarios de cada uno y el número de los mismos, así: (Vistas DBA_TABLESPACES y DBA_USERS)

* Procedimiento que dice los usuarios totales de la base de datos.

~~~
CREATE OR REPLACE PROCEDURE usuario_totalesbbdd
IS
    num_usuarios NUMBER;
BEGIN
    SELECT COUNT (username) INTO num_usuarios
    FROM DBA_USERS;
    dbms_output.put_line('Total de usuarios de la BD: '||num_usuarios);
END;
~~~

* Procedimiento del listado.

~~~
CREATE OR REPLACE PROCEDURE mostrar_usuarios_por_tablespace
IS
    CURSOR c_tablespaces IS
        SELECT tablespace_name
        FROM DBA_TABLESPACES;
    num_usuarios NUMBER;
BEGIN
    FOR v_tablespace IN c_tablespaces
    LOOP
        dbms_output.put_line('TABLESPACE '||v_tablespace.tablespace_name||':');
        usuario_tablespace(v_tablespace.tablespace_name);
        dbms_output.put_line('--');
        num_usuarios:=num_usuarios_tablespace(v_tablespace.tablespace_name);
        dbms_output.put_line('Total de usuarios en el Tablespace '||v_tablespace.tablespace_name||': ' || num_usuarios);
        dbms_output.put_line('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
    END LOOP;
    dbms_output.put_line('*************************************************************************');
    usuario_totalesbbdd();
END;
~~~

~~~
SQL> exec mostrar_usuarios_por_tablespace;
TABLESPACE SYSTEM:
SYS
SYSTEM
XS$NULL
OJVMSYS
ALE
LBACSYS
OUTLN
SYS$UMF
--
Total de usuarios en el Tablespace SYSTEM: 8
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
TABLESPACE SYSAUX:
DBSNMP
APPQOSSYS
DBSFWUSER
GGSYS
ANONYMOUS
CTXSYS
DVSYS
DVF
GSMADMIN_INTERNAL
MDSYS
OLAPSYS
XDB
WMSYS
--
Total de usuarios en el Tablespace SYSAUX: 13
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
TABLESPACE UNDOTBS1:
--
Total de usuarios en el Tablespace UNDOTBS1: 0
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
TABLESPACE TEMP:
--
Total de usuarios en el Tablespace TEMP: 0
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
TABLESPACE USERS:
GSMCATUSER
MDDATA
BECARIO
SYSBACKUP
REMOTE_SCHEDULER_AGENT
GSMUSER
SYSRAC
GSMROOTUSER
SI_INFORMTN_SCHEMA
AUDSYS
PRUEBA
DIP
ORDPLUGINS
SYSKM
ORDDATA
ORACLE_OCM
CONEXION1
SCOTT
SYSDG
ORDSYS
RAUL
--
Total de usuarios en el Tablespace USERS: 21
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*************************************************************************
Total de usuarios de la BD: 42
~~~

7. Hacer un procedimiento llamado mostrar_codigo_fuente  que reciba el nombre de otro procedimiento y muestre su código fuente. (DBA_SOURCE)

~~~
CREATE OR REPLACE PROCEDURE mostrar_codigo_fuente(n_procedimiento VARCHAR2)
IS
    v_codigo dba_source.text%TYPE;
    CURSOR c_codigo IS
        SELECT text
        FROM DBA_SOURCE
        WHERE name = n_procedimiento;
BEGIN
    FOR v_texto IN c_codigo
    LOOP
        v_codigo:=v_texto.text;
        dbms_output.put_line(v_codigo);
    END LOOP;
END;
~~~

~~~
SQL> exec mostrar_codigo_fuente('OLD_EMP')                         
PROCEDURE old_emp

IS

CURSOR c_empleados IS

SELECT ENAME

FROM EMP

ORDER BY TO_CHAR(HIREDATE, 'yyyy-MM-dd') ASC

FETCH FIRST 3 ROWS ONLY;

cont NUMBER:=1;

BEGIN

FOR v_empleados IN c_empleados

LOOP

dbms_output.put_line('Empleado '||cont||': '||v_empleados.ename);

cont:=cont+1;

END LOOP;

END old_emp;

PL/SQL procedure successfully completed.
~~~

8. Hacer un procedimiento llamado mostrar_privilegios_usuario que reciba el nombre de un usuario y muestre sus privilegios de sistema y sus privilegios sobre objetos. (DBA_SYS_PRIVS y DBA_TAB_PRIVS)

* Este procedimiento mostrará los privilegios de sistema

~~~
CREATE OR REPLACE PROCEDURE privilegios_sistema(v_usuario VARCHAR2)
IS
    CURSOR c_privilegios IS
        SELECT privilege
        FROM DBA_SYS_PRIVS
        WHERE GRANTEE = v_usuario;
BEGIN
    dbms_output.put_line('PRIVILEGIOS DE SISTEMA:');
    FOR v_privilegio IN c_privilegios
    LOOP
        dbms_output.put_line(v_privilegio.privilege);
    END LOOP;
END;
~~~

* Este procedimiento mostrará los privilegios sobre objetos

~~~
CREATE OR REPLACE PROCEDURE privilegios_objetos(v_usuario VARCHAR2)
IS
    CURSOR c_privilegios IS
        SELECT table_name, privilege
        FROM DBA_TAB_PRIVS
        WHERE GRANTEE = v_usuario;
BEGIN
    dbms_output.put_line('PRIVILEGIOS DE OBJETOS:');
    FOR v_privilegio IN c_privilegios
    LOOP
        dbms_output.put_line('Objeto: '||v_privilegio.table_name||', Privilegio: '||v_privilegio.privilege);
    END LOOP;
END;
~~~

* Procedimiento que muestra la lista de privilegios.

~~~
CREATE OR REPLACE PROCEDURE mostrar_privilegios_usuario(v_usuario VARCHAR2)
IS
BEGIN
    privilegios_sistema(v_usuario);
    dbms_output.put_line('---------------------------');
    privilegios_objetos(v_usuario);
END;
~~~

~~~
SQL> exec mostrar_privilegios_usuario('BECARIO');
PRIVILEGIOS DE SISTEMA:
CREATE USER
CREATE TYPE
CREATE PROFILE
ALTER USER
UNLIMITED TABLESPACE
DROP USER
GRANT ANY PRIVILEGE
CREATE ROLE
ALTER ANY ROLE
GRANT ANY ROLE
CREATE USER
CREATE SESSION
ALTER USER
DROP ANY ROLE
DROP USER
---------------------------
PRIVILEGIOS DE OBJETOS:
Objeto: EMP, Privilegio: INSERT

PL/SQL procedure successfully completed.
~~~

9. Realiza un procedimiento llamado listar_comisiones que nos muestre por pantalla un listado de las comisiones de los empleados agrupados según la localidad donde está ubicado su departamento con el siguiente formato:

* Procedimiento que recibe un nombre de localidad y devuelve el nombre del departamento.

~~~
CREATE OR REPLACE PROCEDURE nomdept_localidad(v_localidad VARCHAR2, nom_dept OUT dept.dname%type)
IS
BEGIN
    SELECT dname INTO nom_dept
    FROM dept
    WHERE loc = v_localidad;
END;
~~~

* Procedimiento que recibiendo un nombre de localidad devuelve el numero de su departamento.

~~~
CREATE OR REPLACE PROCEDURE dept_localidad(v_localidad VARCHAR2, v_dept OUT dept.deptno%type)
IS
BEGIN
    SELECT deptno INTO v_dept
    FROM dept
    WHERE loc = v_localidad;
END;
~~~

* Procedimiento que sabiendo el deptno saca una lista de empleados con sus respectivas comisiones y devuelve el total de las comisiones.

~~~
CREATE OR REPLACE PROCEDURE comision_empleado(v_deptno dept.deptno%type, com_total OUT emp.comm%type)
IS
    CURSOR c_empleados IS
        SELECT ename, comm
        FROM emp
        WHERE deptno = v_deptno;
BEGIN
    com_total:=0;
    FOR v_empleado IN c_empleados
    LOOP
        dbms_output.put_line('      '||v_empleado.ename||' comision: '||v_empleado.comm);
        com_total:=com_total+v_empleado.comm;
    END LOOP;
END;
~~~

* Procedimiento que lista todo.

~~~
CREATE OR REPLACE PROCEDURE listar_comisiones
IS
    nom_dept dept.dname%type;
    num_dept dept.deptno%type;
    com_total emp.comm%type;

    CURSOR c_localidades IS
        SELECT LOC
        FROM DEPT;
BEGIN
    FOR v_localidad IN c_localidades
    LOOP
        dbms_output.put_line('Localidad: '||v_localidad.loc);
        nomdept_localidad(v_localidad.loc, nom_dept);
        dbms_output.put_line('  Departamento: '||nom_dept);
        dept_localidad(v_localidad.loc, num_dept);
        comision_empleado(num_dept, com_total);
        dbms_output.put_line('Total de comisiones en el departamento '||nom_dept||': '||com_total);
        dbms_output.put_line('--------------------------');
    END LOOP;
END;
~~~

~~~
SQL> exec listar_comisiones;
Localidad: NEW YORK
Departamento: ACCOUNTING
CLARK comision:
KING comision:
MILLER comision:
Total de comisiones en el departamento ACCOUNTING:
--------------------------
Localidad: DALLAS
Departamento: RESEARCH
SMITH comision:
JONES comision:
SCOTT comision:
ADAMS comision:
FORD comision:
JUAN comision:
Total de comisiones en el departamento RESEARCH:
--------------------------
Localidad: CHICAGO
Departamento: SALES
ALLEN comision: 300
WARD comision: 500
MARTIN comision: 1400
BLAKE comision:
TURNER comision: 0
JAMES comision:
ALEJANDRO comision:
Total de comisiones en el departamento SALES:
--------------------------
Localidad: BOSTON
Departamento: OPERATIONS
Total de comisiones en el departamento OPERATIONS: 0
--------------------------

PL/SQL procedure successfully completed.
~~~

10. Realiza un procedimiento que reciba el nombre de una tabla y muestre los nombres de las restricciones que tiene, a qué columna afectan y en qué consisten exactamente. (DBA_TABLES, DBA_CONSTRAINTS, DBA_CONS_COLUMNS)

~~~
CREATE OR REPLACE PROCEDURE listar_restricciones (n_tabla VARCHAR2)
IS
    CURSOR c_restricciones IS
        SELECT a.constraint_name, b.column_name, a.constraint_type
        FROM dba_constraints a, dba_cons_columns b, dba_tables c
        WHERE a.constraint_name = b.constraint_name
        AND a.table_name = c.table_name
        AND a.table_name = n_tabla;

BEGIN

    FOR v_restriccion in c_restricciones LOOP
        dbms_output.put_line('Restriccion: ' || v_restriccion.constraint_name);
        dbms_output.put_line('Columna: ' || v_restriccion.column_name);
        dbms_output.put_line('Descripcion: ' || v_restriccion.constraint_type);
    END LOOP;
END;
/
~~~

* Prueba de funcionamiento.

~~~
SQL> exec listar_restricciones ('CARRERAS_PROFESIONALES');
Tabla: CARRERAS_PROFESIONALES
Restriccion: HORA_CARRERA
Columna: FECHA
Descripcion: C
Tabla: CARRERAS_PROFESIONALES
Restriccion: FECHA_CARRERA
Columna: FECHA
Descripcion: C
Tabla: CARRERAS_PROFESIONALES
Restriccion: PK_CARRERAS
Columna: CODCARRERA
Descripcion: P

PL/SQL procedure successfully completed.
~~~

11. Realiza al menos dos de los ejercicios anteriores en Postgres usando PL/pgSQL.

#### Hacer un procedimiento que muestre el nombre y el salario del empleado cuyo código es 7900

~~~
CREATE OR REPLACE FUNCTION cod_7900() RETURNS VOID
AS $CODIGO7900$
    DECLARE
        vnombre emp.ename%TYPE;
        vsal emp.sal%TYPE;
    BEGIN
        SELECT ename, sal INTO vnombre, vsal
        FROM EMP
            WHERE EMPNO='7900';
        RAISE NOTICE '%', 'El empleado: '||vnombre||', gana: '||vsal;
END;
$CODIGO7900$ LANGUAGE plpgsql;
~~~

* Prueba de funcionamiento

~~~
empresa=# SELECT cod_7900();
NOTICE:  El empleado: JAMES, gana: 950.00
 cod_7900 
----------
 
(1 row)
~~~

#### Hacer un procedimiento que reciba como parámetro un código de empleado y devuelva su nombre

~~~
CREATE OR REPLACE FUNCTION cod_nombre (cod_emp emp.empno%TYPE) RETURNS VOID
AS $CODIGONOMBRE$
DECLARE
    nombre_emp emp.ename%TYPE;
BEGIN
    SELECT ename INTO nombre_emp
    FROM EMP
        WHERE empno=cod_emp;
    RAISE NOTICE '%', 'El nombre de este empleado es: '||nombre_emp;
END;
$CODIGONOMBRE$ LANGUAGE plpgsql;
~~~

* Prueba de funcionamiento.

~~~
empresa=# SELECT cod_nombre('7900');
NOTICE:  El nombre de este empleado es: JAMES
 cod_nombre 
------------
 
(1 row)
~~~
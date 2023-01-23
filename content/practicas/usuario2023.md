+++
title = "Gestion de Usuarios BBDD"
description = ""
tags = [
    "GBD"
]
date = "2023-01-04"
menu = "main"
+++

## Parte Individual:

### MongoDB

1. Averigua si existe la posibilidad en MongoDB de limitar el acceso de un usuario a los datos de una colección determinada.

* Al crear un usuario podemos especificar la colección que queremos que pueda acceder y los permisos que le damos sobre ella, como solo lectura o lectura y escritura... Para ello entramos con el usuario administrador, entramos en la base de datos sobre la que queremos darle privilegios y creamos este usuario.

~~~
> use nobel
switched to db nobel

> db.createUser({user: "prueba1", pwd: "prueba1", roles: [{role: "read", db: "nobel"}]})
Successfully added user: {
	"user" : "prueba1",
	"roles" : [
		{
			"role" : "read",
			"db" : "nobel"
		}
	]
}
~~~

* Hemos creado el usuario anterior el cual solo tiene permiso de lectura sobre la colecciones de la base de datos "nobel", ahora entraremos con este usuario a mongo, para ello debemos especificar mínimo el usuario y la base de datos a la que nos queremos conectar, aunque en mi caso también he añadido la contraseña.

~~~
vagrant@mongoagv:~$ mongo -u prueba1 -p prueba1 --authenticationDatabase "nobel"
~~~

* vamos a comprobar que podemos visualizar los datos.

~~~
> db.premios.find().pretty()
{
	"_id" : ObjectId("63b9c93c9cd6ef460b679a17"),
	"year" : "2021",
	"category" : "Chemistry",
	"laureates" : [
		{
			"id" : "1002",
			"firstname" : "Benjamin",
			"surname" : "List",
			"motivation" : "\"for the development of asymmetric organocatalysis\"",
			"share" : "2"
		},
		{
			"id" : "1003",
			"firstname" : "David",
			"surname" : "MacMillan",
			"motivation" : "\"for the development of asymmetric organocatalysis\"",
			"share" : "2"
		}
	]
}
~~~

* Pero si intentamos insertar un registro nos avisa de que no tenemos privilegios suficientes.

~~~
> db.premios.insertOne ({
...       "year": "2023",
...       "category": "Literature",
...       "laureates": [
...          {
...             "id": "1408",
...             "firstname": "Alejandro",
...             "surname": "Prueba",
...             "motivation": "\"Prueba de fallo\"",
...             "share": "2"
...          },
... {
... "id" : "1409",
... "firstname" : "Maria",
... "surname" : "Prueba2",
... "motivation" : "\"Prueba de fallo\"",
... "share" : "2"
... }
... ]
... })
uncaught exception: WriteCommandError({
	"ok" : 0,
	"errmsg" : "not authorized on nobel to execute command { insert: \"premios\", ordered: true, lsid: { id: UUID(\"b1891384-1e6b-476c-a075-489916c31946\") }, $db: \"nobel\" }",
	"code" : 13,
	"codeName" : "Unauthorized"
~~~

* Si queremos asignar nuevos roles a un usuario sobre una base de datos nueva usamos la siguiente orden.

~~~
db.grantRolesToUser('prueba1', 
  [ { db: 'otraBBDD', role: 'readWrite' } ]
)
~~~

2. Averigua si en MongoDB existe el concepto de privilegio del sistema y muestra las diferencias más importantes con ORACLE.

* Se podría decir que si podemos asignar privilegios de sistema a nuestro usuarios en mongodb, si creamos un usuario le podemos asignar distintos roles como hicimos anteriormente para dar permisos de escritura o lectura sobre una colección, pero esta vez son roles de sistema, veremos ejemplos en el siguiente apartado que trata sobre este asunto.


* **Diferencias con oracle:**
  * Aunque tambien podemos dar solo roles especificos usando la funcion "grantRole", tenemos tres roles que agrupan una gran cantidad de ellos en funcion de para que necesitemos el usuario. Mientras que en oracle debemos asignar roles concretos como la creación de usuarios (GRANT CREATE USER) o la inserción de datos (GRANT INSERT), podemos asignarlos a la vez, sin embargo, no tenemos un rol que agrupe varios de ellos como si tenemos en mongo. Como ya hemos dicho, en el siguiente apartado se especificarán estos roles generales, para que sirven y que roles más pequeños los componen.

3. Explica los roles por defecto que incorpora MongoDB y como se asignan a los usuarios.

+ Vamos a ver tres roles que tienen que ver con la administración de la base de datos y como asignarselos a un usuario que creemos, aunque también se especificará que usar para añadir estos roles a usuarios ya creados:
  
+ **dbAdmin** Permite gestionar datos pero no usuarios.

~~~
db.createUser({user: "administrador1", pwd: "administrador1", roles: [{role: "dbAdmin", db: "admin"}]})
~~~

~~~
> db.premios.listIndexes
nobel.premios.listIndexes

> db.createUser({user: "administrador2", pwd: "administrador2", roles: [{role: "userAdmin", db: "admin"}]})
uncaught exception: Error: couldn't add user: not authorized on admin to execute command { createUser: "administrador2", pwd: "xxx", roles: [ { role: "userAdmin", db: "admin" } ], digestPassword: true, writeConcern: { w: "majority", wtimeout: 600000.0 }, lsid: { id: UUID("61ff1096-b904-479a-885d-2b33395a3326") }, $db: "admin" } :
_getErrorWithCode@src/mongo/shell/utils.js:25:13
DB.prototype.createUser@src/mongo/shell/db.js:1367:11
@(shell):1:1
~~~

* Las funciones que puede usar son:
  *  collStats 
  *  dbHash 
  *  dbStats 
  *  killCursors 
  *  listIndexes 
  *  listCollections 
  *  bypassDocumentValidation 
  *  collMod 
  *  compact 
  *  convertToCapped


+ **userAdmin** Tenemos el caso completamente opuesto, un rol que puede gestionar usuarios pero no datos.

~~~
db.createUser({user: "administrador2", pwd: "administrador2", roles: [{role: "userAdmin", db: "admin"}]})
~~~

~~~
db.createUser({user: "administrador3", pwd: "administrador3", roles: [{role: "read", db: "nobel"}]})
Successfully added user: {
	"user" : "administrador3",
	"roles" : [
		{
			"role" : "read",
			"db" : "nobel"
		}
	]
}

> db.grantRolesToUser("administrador1", [ "readWrite", {role: "read", db: "nobel"} ])
~~~

* Las funciones que puede usar son:
  *  changeCustomData 
  *  changePassword 
  *  createRole 
  *  createUser 
  *  dropRole 
  *  dropUser 
  *  grantRole 
  *  revokeRole 
  *  setAuthenticationRestriction 
  *  viewRole 
  *  viewUser

+ **dbOwner** Puede realizar cualquier función de administración en la base de datos, por lo tanto es a la vez **userAdmin** como **dbAdmin**.

* *Podemos usar tambien "dbAdminAnyDatabase" o "userAdminAnyDatabase" para que puedan realizar las acciones sobre cualquier base de datos, o como hemos hecho decir que su base de datos es "admin"*

* Hemos visto como añadirlos a usuarios que creamos nuevos, sin embargo tambiént tenemos la opción de añadir roles especificos a usuarios ya creados tambien podemos dar solo roles especificos usando la funcion "grantRole" como hemos podido ver en el ejemplo de funcionamiento del rol **userAdmin** que dejaré aquí nuevamente.

~~~
> db.grantRolesToUser("administrador1", [ "readWrite", {role: "read", db: "nobel"} ])
~~~

* También podemos crear nuevos roles, vamos a ver un ejemplo que he encontrado en la página oficial de mongo de un rol que permite eliminar cualquier colección de cualquier base de datos que especifiquemos. Y nuevamente, podríamos asignar este rol a cualquier usuario que queramos.

~~~
db.createRole(
   {
     role: "dropSystemViewsAnyDatabase", 
     privileges: [
       {
         actions: [ "dropCollection" ],
         resource: { db: "", collection: "system.views" }
       }
     ],
     roles: []
   }
)
~~~

4. Explica como puede consultarse el diccionario de datos de MongoDB para saber que roles han sido concedidos a un usuario y qué privilegios incluyen.

* Ver los roles de un usuario es una tarea bastante sencilla, solo debemos usar la funcion "getUser"

~~~
> db.getUser("administrador1")
{
	"_id" : "admin.administrador1",
	"userId" : UUID("2ec38b76-6ddf-457c-bab2-c4bb8ba34452"),
	"user" : "administrador1",
	"db" : "admin",
	"roles" : [
		{
			"role" : "read",
			"db" : "nobel"
		},
		{
			"role" : "readWrite",
			"db" : "admin"
		},
		{
			"role" : "dbAdmin",
			"db" : "admin"
		}
	],
	"mechanisms" : [
		"SCRAM-SHA-1",
		"SCRAM-SHA-256"
	]
}
~~~

* Una vez tenemos todos los roles de este usuario podemos visualizar los privilegios que incluyen ese rol, en este caso con la función "getRoles" y dentro de esta función especificando que nos muestro los privilegios como veremos a continuación.

~~~
> db.getRole ( "dbAdmin", { showPrivileges: true } )
{
	"db" : "test",
	"role" : "dbAdmin",
	"roles" : [ ],
	"privileges" : [
		{
			"resource" : {
				"db" : "test",
				"collection" : ""
			},
			"actions" : [
				"bypassDocumentValidation",
				"collMod",
				"collStats",
				"compact",
				"convertToCapped",
				"createCollection",
				"createIndex",
				"dbStats",
				"dropCollection",
				"dropDatabase",
				"dropIndex",
				"enableProfiler",
				"listCollections",
				"listIndexes",
				"planCacheIndexFilter",
				"planCacheRead",
				"planCacheWrite",
				"reIndex",
				"renameCollectionSameDB",
				"storageDetails",
				"validate"
			]
		},
		{
			"resource" : {
				"db" : "test",
				"collection" : "system.profile"
			},
			"actions" : [
				"changeStream",
				"collStats",
				"convertToCapped",
				"createCollection",
				"dbHash",
				"dbStats",
				"dropCollection",
				"find",
				"killCursors",
				"listCollections",
				"listIndexes",
				"planCacheRead"
			]
		}
	],
	"inheritedRoles" : [ ],
	"inheritedPrivileges" : [
		{
			"resource" : {
				"db" : "test",
				"collection" : ""
			},
			"actions" : [
				"bypassDocumentValidation",
				"collMod",
				"collStats",
				"compact",
				"convertToCapped",
				"createCollection",
				"createIndex",
				"dbStats",
				"dropCollection",
				"dropDatabase",
				"dropIndex",
				"enableProfiler",
				"listCollections",
				"listIndexes",
				"planCacheIndexFilter",
				"planCacheRead",
				"planCacheWrite",
				"reIndex",
				"renameCollectionSameDB",
				"storageDetails",
				"validate"
			]
		},
		{
			"resource" : {
				"db" : "test",
				"collection" : "system.profile"
			},
			"actions" : [
				"changeStream",
				"collStats",
				"convertToCapped",
				"createCollection",
				"dbHash",
				"dbStats",
				"dropCollection",
				"find",
				"killCursors",
				"listCollections",
				"listIndexes",
				"planCacheRead"
			]
		}
	],
	"isBuiltin" : true
}
~~~

* Nos muestra esta extensa lista de los privilegios que tiene el rol "dbAdmin", esto podemos hacerlo con cualquier rol.


### Oracle

1. Realiza un procedimiento llamado MostrarObjetosAccesibles que reciba un nombre de usuario y muestre todos los objetos a los que tiene acceso.

~~~
CREATE OR REPLACE PROCEDURE MostrarObjetosAccesibles(v_user VARCHAR2)
IS
    privilegio	VARCHAR2(100);
    nombre_objeto	VARCHAR2(200);

    CURSOR c_objetos IS
    SELECT table_name, privilege
    FROM dba_tab_privs
    WHERE grantee=v_user;

BEGIN
    dbms_output.put_line('EL USUARIO '||v_user||' TIENE ACCESO A:');

    FOR v_objeto IN c_objetos
	LOOP
        nombre_objeto:=v_objeto.table_name;
        privilegio:=v_objeto.privilege;

        dbms_output.put_line('OBJETO: '||nombre_objeto);
		dbms_output.put_line('PRIVILEGIO: '||privilegio);
        dbms_output.put_line('-------------------------------------------');
	END LOOP;
END;
/
~~~


* Comprobación:

~~~
SQL> exec MostrarObjetosAccesibles('PUBLIC');
EL USUARIO PUBLIC TIENE ACCESO A:

OBJETO: USER_ANALYTIC_VIEW_DIM_CLASS
PRIVILEGIO: READ
-------------------------------------------
OBJETO: ALL_ANALYTIC_VIEW_DIM_CLASS
PRIVILEGIO: READ
-------------------------------------------
OBJETO: USER_ATTRIBUTE_DIMENSIONS
PRIVILEGIO: READ
-------------------------------------------
OBJETO: ALL_ATTRIBUTE_DIMENSIONS
PRIVILEGIO: READ
-------------------------------------------
OBJETO: USER_ATTRIBUTE_DIM_ATTRS
PRIVILEGIO: READ

.....
.....
.....
PL/SQL procedure successfully completed.
~~~

2. Realiza un procedimiento que reciba un nombre de usuario, un privilegio y un objeto y nos muestre el mensaje 'SI, DIRECTO' si el usuario tiene ese privilegio sobre objeto concedido directamente, 'SI, POR ROL' si el usuario lo tiene en alguno de los roles que tiene concedidos y un 'NO' si el usuario no tiene dicho privilegio.

~~~
CREATE OR REPLACE PROCEDURE TienePrivilegios(v_user VARCHAR2, v_privilege VARCHAR2, v_object VARCHAR2, cont OUT NUMBER)
IS
BEGIN
    SELECT count(*) into cont
    FROM dba_tab_privs
    WHERE grantee=v_user
    AND privilege=v_privilege
    AND table_name=v_object;
END;
/
~~~

~~~
CREATE OR REPLACE PROCEDURE PrivilegioDeRol(v_user VARCHAR2, v_privilege VARCHAR2, v_object VARCHAR2, cont OUT NUMBER)
IS
BEGIN
    SELECT count(*) into cont
    FROM dba_role_privs
    WHERE grantee=v_user
    AND granted_role in (SELECT role
                     	FROM role_tab_privs
                     	WHERE privilege=v_privilege
                     	AND table_name=v_object);
END;
/
~~~

~~~
CREATE OR REPLACE PROCEDURE privilegios_usuarios(v_user VARCHAR2, v_privilege VARCHAR2, v_object VARCHAR2)
IS
    cont NUMBER:=0;
BEGIN
	TienePrivilegios(v_user, v_privilege, v_object, cont);

    IF cont=0 THEN
		PrivilegioDeRol(v_user, v_privilege, v_object, cont);

    	IF cont=0 THEN
        	dbms_output.put_line('NO');
    	ELSE
    		dbms_output.put_line('SI, POR ROL');
    	END IF;
		
    ELSE
        dbms_output.put_line('SI, DIRECTO');
    END IF;
END;
/
~~~

## Parte grupal

### CASO PRÁCTICO 1:

1. Crea un usuario llamado Becario y, sin usar los roles de ORACLE, dale los siguientes privilegios:
   * Conectarse a la base de datos.	
   * Modificar el número de errores en la introducción de la contraseña de cualquier usuario.	
   * Modificar índices en cualquier esquema (este privilegio podrá pasarlo a quien quiera)	
   * Insertar filas en scott.emp (este privilegio podrá pasarlo a quien quiera)	
   * Crear objetos en cualquier tablespace.	
   * Gestión completa de usuarios, privilegios y roles.

**ORACLE**

* Creación de usuario:

~~~
SQL> CREATE USER Becario IDENTIFIED BY Becario;

User created.
~~~

* Conexión a la base de datos.

~~~
SQL> GRANT CREATE SESSION TO Becario;

Grant succeeded.

SQL> connect Becario/Becario
Connected.
~~~

* Modificar el número de errores en la introducción de la contraseña de cualquier usuario.

~~~
SQL> GRANT CREATE PROFILE TO Becario;

SQL> GRANT ALTER USER TO Becario;

SQL> connect Becario/Becario
Connected.

SQL> CREATE PROFILE numintentos2 LIMIT
  2  FAILED_LOGIN_ATTEMPTS 5;

Profile created.

SQL> ALTER USER Prueba profile numintentos;
~~~

~~~
SQL> connect Prueba
Enter password: 
ERROR:
ORA-01017: invalid username/password; logon denied

SQL> connect Prueba
Enter password: 
ERROR:
ORA-01017: invalid username/password; logon denied

SQL> connect Prueba
Enter password: 
ERROR:
ORA-01017: invalid username/password; logon denied

SQL> connect Prueba
Enter password: 
ERROR:
ORA-01017: invalid username/password; logon denied

SQL> connect Prueba
Enter password: 
ERROR:
ORA-01017: invalid username/password; logon denied

SQL> connect Prueba
Enter password: 
ERROR:
ORA-01017: invalid username/password; logon denied


Warning: You are no longer connected to ORACLE.
~~~

* Modificar índices en cualquier esquema (este privilegio podrá pasarlo a quien quiera)

~~~
SQL> CREATE INDEX index_prueba on emp(ename,sal);

Index created.

SQL> GRANT CONTROL ON index_prueba1 TO USER Becario;

SQL> connect Becario/Becario
Connected.

SQL> ALTER INDEX SCOTT.index_prueba RENAME TO index_prueba1;

Index altered.
~~~

* Insertar filas en scott.emp (este privilegio podrá pasarlo a quien quiera)

~~~
SQL> GRANT INSERT ON SCOTT.EMP TO Becario WITH GRANT OPTION;

SQL> connect Becario/Becario
Connected.

SQL> INSERT INTO SCOTT.EMP VALUES
(7489, 'JUAN', 'ANALYST', 7822,
TO_DATE('18-DEC-1999', 'DD-MON-YYYY'), 900, NULL, 20);

1 row created.
~~~

* Crear objetos en cualquier tablespace.

~~~
SQL> GRANT UNLIMITED TABLESPACE TO Becario;

Grant succeeded.

SQL> GRANT CREATE TYPE TO Becario;

SQL> create type temp_col as table of number 
  2  /

Type created.
~~~

* Gestión completa de usuarios, privilegios y roles.

+ Usuarios:

~~~
SQL> GRANT CREATE USER TO Becario;

Grant succeeded.

SQL> GRANT ALTER USER TO Becario;

Grant succeeded.

SQL> GRANT DROP USER TO Becario;

Grant succeeded.
~~~

~~~
SQL> connect Becario/Becario
Connected.

SQL> CREATE USER prueba2 IDENTIFIED BY prueba2;

User created.

SQL> ALTER USER Prueba2 profile numintentos;

User altered.

SQL> DROP USER Prueba2;

User dropped.
~~~

+ Privilegios:

~~~
SQL> GRANT GRANT ANY PRIVILEGE TO Becario;

Grant succeeded.
~~~

~~~
SQL> connect Becario/Becario
Connected.

SQL> GRANT ALTER TABLESPACE TO prueba;

Grant succeeded.
~~~

+ Roles:

~~~
SQL> GRANT CREATE ROLE TO BECARIO;

Grant succeeded.

SQL> GRANT DROP ANY ROLE TO BECARIO;

Grant succeeded.

SQL> GRANT ALTER ANY ROLE TO BECARIO;

Grant succeeded.

SQL> GRANT GRANT ANY ROLE TO BECARIO;

Grant succeeded.
~~~

~~~
SQL> connect Becario/Becario
Connected.

SQL> CREATE ROLE rol_prueba;

Role created.

SQL> ALTER ROLE rol_prueba NOT IDENTIFIED;

Role altered.

SQL> GRANT rol_prueba, CONNECT TO prueba;

Grant succeeded.

SQL> DROP ROLE rol_prueba;

Role dropped.
~~~

**Postgres**

* Creación de usuario.

~~~
postgres=# CREATE USER becario WITH PASSWORD 'becario';
CREATE ROLE
~~~

* Conexión a la base de datos.

~~~
postgres=# GRANT CONNECT ON DATABASE empresa TO becario; 
GRANT
postgres=# ALTER ROLE becario WITH LOGIN;
ALTER ROLE
~~~

~~~
postgres@alepeteporico:~$ psql -d empresa -U becario
Contraseña para usuario becario: 
psql (13.9 (Debian 13.9-0+deb11u1))
Digite «help» para obtener ayuda.

empresa=#
~~~

* Modificar el número de errores en la introducción de la contraseña de cualquier usuario.
* No podemos realizar esto en postgres, sin embargo desde el usuario administrador si podemos limitar el numero de intentos a un usuario especifico.

~~~
postgres=# ALTER USER becario WITH CONNECTION LIMIT 5;
ALTER ROLE
~~~

* Modificar índices en cualquier esquema (este privilegio podrá pasarlo a quien quiera)
* En este caso si el usuario es dueño de una tabla también es dueño de sus indices.

~~~
empresa=# CREATE INDEX indice_prueba ON emp (deptno,ename);
CREATE INDEX

empresa=# ALTER INDEX indice_prueba RESET ( FASTUPDATE );
ALTER INDEX
~~~

* Insertar filas en scott.emp (este privilegio podrá pasarlo a quien quiera)

~~~
empresa=# GRANT INSERT ON emp TO becario WITH GRANT OPTION;
GRANT
~~~

~~~
postgres@alepeteporico:~$ psql -d empresa -U becario
Contraseña para usuario becario: 
psql (13.9 (Debian 13.9-0+deb11u1))
Digite «help» para obtener ayuda.

empresa=# INSERT INTO emp (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) SELECT 7822, 'JUAN', 'PERISTA', cast(null as INTEGER), to_DATE('17-11-1981','dd-mm-yyyy'), 5000, cast(null as INTEGER), 20
empresa-# ;
INSERT 0 1
~~~

* Crear objetos en cualquier tablespace.

~~~
postgres=# GRANT CREATE ON TABLESPACE pg_global TO becario;
GRANT
~~~

* Gestión completa de usuarios, privilegios y roles.

+ Usuarios:

~~~
postgres=# ALTER ROLE becario WITH SUPERUSER;
ALTER ROLE
~~~

~~~
postgres@alepeteporico:~$ psql -d empresa -U becario
Contraseña para usuario becario: 
psql (13.9 (Debian 13.9-0+deb11u1))
Digite «help» para obtener ayuda.

empresa=# CREATE USER prueba2 WITH PASSWORD 'prueba2';
CREATE ROLE
~~~

+ Roles:

~~~
postgres=# ALTER ROLE becario WITH CREATEROLE;
ALTER ROLE
~~~

~~~
postgres@alepeteporico:~$ psql -d empresa -U becario
Contraseña para usuario becario: 
psql (13.9 (Debian 13.9-0+deb11u1))
Digite «help» para obtener ayuda.

empresa=# CREATE ROLE rol_prueba;
CREATE ROLE
~~~

**MariaDB**

* Creación de usuario:

~~~
MariaDB [(none)]> CREATE USER 'becario' IDENTIFIED BY 'becario';
Query OK, 0 rows affected (0,005 sec)
~~~

* Conexión a la base de datos.

~~~
MariaDB [(none)]> GRANT USAGE ON empresa TO 'becario'@'localhost' IDENTIFIED BY 'becario';
Query OK, 0 rows affected (0,003 sec)

alejandrogv@alepeteporico:~$ mariadb -u becario -p empresa
Enter password: 
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 44
Server version: 10.5.18-MariaDB-0+deb11u1 Debian 11

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [empresa]>
~~~

* Modificar el número de errores en la introducción de la contraseña de cualquier usuario.

OPCIÓN 1:

~~~
MariaDB [(none)]> ALTER USER 'becario'@'localhost'
    -> FAILED_LOGIN_ATTEMPTS 5 PASSWORD_LOCK_TIME UNBOUNDED;
~~~


OPCIÓN 2: En el fichero "/etc/mysql/my.cnf"

~~~
[mysqld]
log_error        = /var/log/error.log
log_warnings     = 5
~~~

* Modificar índices en cualquier esquema (este privilegio podrá pasarlo a quien quiera)
* En mysql no podemos hacer un alter index como tal, pero podemos usar una de las siguientes opciones:

+ ALTER TABLE nombretabla RENAME INDEX nombre_antiguo_indice TO nombre_nuevo_indice.
+ ALTER TABLE nombretabla DROP INDEX nombre_indice
+ ALTER TABLE nombretabla ADD INDEX nombre_indice_nuevo

~~~
MariaDB [(none)]> GRANT ALTER ON *.* TO 'becario'@'localhost' WITH GRANT OPTION;
Query OK, 0 rows affected (0,003 sec)

MariaDB [(none)]> GRANT CREATE ON *.* TO 'becario'@'localhost';
Query OK, 0 rows affected (0,003 sec)

MariaDB [(none)]> GRANT DROP ON *.* TO 'becario'@'localhost';
Query OK, 0 rows affected (0,003 sec)
~~~

~~~
MariaDB [empresa]> CREATE INDEX indice_prueba ON emp (deptno,ename);
Query OK, 0 rows affected (0,022 sec)
Records: 0  Duplicates: 0  Warnings: 0



alejandrogv@alepeteporico:~$ mariadb -u becario -p empresa

MariaDB [empresa]> ALTER TABLE emp RENAME INDEX indice_prueba TO indice2;
Query OK, 0 rows affected (0,014 sec)
Records: 0  Duplicates: 0  Warnings: 0
~~~

* Insertar filas en scott.emp (este privilegio podrá pasarlo a quien quiera)

~~~
MariaDB [empresa]> GRANT INSERT ON emp TO 'becario'@'localhost' IDENTIFIED BY "becario" WITH GRANT OPTION
;
Query OK, 0 rows affected (0,004 sec)
~~~

~~~
alejandrogv@alepeteporico:~$ mariadb -u becario -p empresa

MariaDB [empresa]> INSERT INTO `emp` (`EMPNO`, `ENAME`, `JOB`, `MGR`, `HIREDATE`, `SAL`, `COMM`, `DEPTNO`) VALUES
    -> (7322, 'JUAN', 'CHAPERO', 7902, '1980-12-17', 800, NULL, 20);
Query OK, 1 row affected (0,003 sec)
~~~

* Crear objetos en cualquier tablespace.

~~~
MariaDB [(none)]> GRANT CREATE ON *.* TO 'becario'@'localhost';
Query OK, 0 rows affected (0,003 sec)
~~~

* Gestión completa de usuarios, privilegios y roles.

~~~
GRANT ALL PRIVILEGES ON *.* TO 'becario'@'localhost' WITH GRANT OPTION;
Query OK, 0 rows affected (0,004 sec)

alejandrogv@alepeteporico:~$ mariadb -u becario -p empresa
~~~

+ Usuarios:

~~~
MariaDB [empresa]> CREATE USER prueba2 IDENTIFIED BY 'prueba2';
Query OK, 0 rows affected (0,004 sec)
~~~

+ Privilegios:

~~~
MariaDB [empresa]> GRANT ALL PRIVILEGES ON *.* TO prueba2;
Query OK, 0 rows affected (0,004 sec)
~~~

+ Roles:

~~~
MariaDB [empresa]> CREATE ROLE rol_prueba;
Query OK, 0 rows affected (0,004 sec)
~~~

3. Crea un tablespace TS2 con tamaño de extensión de 256K. Realiza una consulta que genere un script que asigne ese tablespace como tablespace por defecto a los usuarios que no tienen privilegios para consultar ninguna tabla de SCOTT, excepto a SYSTEM.

* Creación del tablespace:
  
~~~
SQL> create tablespace TS2 
  2  DATAFILE 'tbs_ts2.dbf'
  3  SIZE 256k;

Tablespace created.
~~~

* Realizamos la select que asigne este tablespace como tablespace por defecto a los usuarios que no tienen privilegios en ninguna tabla de scott (except SYSTEM)

~~~
SELECT 'ALTER USER "'||username||'" DEFAULT TABLESPACE TS2;'
FROM DBA_USERS
WHERE USERNAME!='SYSTEM'
AND USERNAME not in (SELECT GRANTEE 
                	FROM DBA_TAB_PRIVS 
                    WHERE PRIVILEGE='SELECT' 
                    AND OWNER='SCOTT');
~~~

* Estos serían todos los usuarios afectados por el script.

~~~
ALTER USER "XS$NULL" DEFAULT TABLESPACE TS2;
ALTER USER "SYS" DEFAULT TABLESPACE TS2;
ALTER USER "OJVMSYS" DEFAULT TABLESPACE TS2;
ALTER USER "ALE" DEFAULT TABLESPACE TS2;
ALTER USER "LBACSYS" DEFAULT TABLESPACE TS2;
ALTER USER "OUTLN" DEFAULT TABLESPACE TS2;
ALTER USER "SYS$UMF" DEFAULT TABLESPACE TS2;
ALTER USER "DBSNMP" DEFAULT TABLESPACE TS2;
ALTER USER "APPQOSSYS" DEFAULT TABLESPACE TS2;
ALTER USER "DBSFWUSER" DEFAULT TABLESPACE TS2;
ALTER USER "GGSYS" DEFAULT TABLESPACE TS2;
ALTER USER "ANONYMOUS" DEFAULT TABLESPACE TS2;
ALTER USER "CTXSYS" DEFAULT TABLESPACE TS2;
ALTER USER "DVSYS" DEFAULT TABLESPACE TS2;
ALTER USER "DVF" DEFAULT TABLESPACE TS2;
ALTER USER "GSMADMIN_INTERNAL" DEFAULT TABLESPACE TS2;
ALTER USER "MDSYS" DEFAULT TABLESPACE TS2;
ALTER USER "OLAPSYS" DEFAULT TABLESPACE TS2;
ALTER USER "XDB" DEFAULT TABLESPACE TS2;
ALTER USER "WMSYS" DEFAULT TABLESPACE TS2;
ALTER USER "GSMCATUSER" DEFAULT TABLESPACE TS2;
ALTER USER "MDDATA" DEFAULT TABLESPACE TS2;
ALTER USER "BECARIO" DEFAULT TABLESPACE TS2;
ALTER USER "SYSBACKUP" DEFAULT TABLESPACE TS2;
ALTER USER "REMOTE_SCHEDULER_AGENT" DEFAULT TABLESPACE TS2;
ALTER USER "GSMUSER" DEFAULT TABLESPACE TS2;
ALTER USER "SYSRAC" DEFAULT TABLESPACE TS2;
ALTER USER "GSMROOTUSER" DEFAULT TABLESPACE TS2;
ALTER USER "SI_INFORMTN_SCHEMA" DEFAULT TABLESPACE TS2;
ALTER USER "AUDSYS" DEFAULT TABLESPACE TS2;
ALTER USER "DIP" DEFAULT TABLESPACE TS2;
ALTER USER "ORDPLUGINS" DEFAULT TABLESPACE TS2;
ALTER USER "SYSKM" DEFAULT TABLESPACE TS2;
ALTER USER "ORDDATA" DEFAULT TABLESPACE TS2;
ALTER USER "ORACLE_OCM" DEFAULT TABLESPACE TS2;
ALTER USER "CONEXION1" DEFAULT TABLESPACE TS2;
ALTER USER "SCOTT" DEFAULT TABLESPACE TS2;
ALTER USER "SYSDG" DEFAULT TABLESPACE TS2;
ALTER USER "ORDSYS" DEFAULT TABLESPACE TS2;
ALTER USER "RAUL" DEFAULT TABLESPACE TS2;
ALTER USER "PRUEBA" DEFAULT TABLESPACE TS2;
~~~

### CASO PRÁCTICO 2:

3. Realiza un procedimiento que reciba dos nombres de usuario y genere un script que asigne al primero los privilegios de inserción y modificación sobre todas las tablas del segundo, así como el de ejecución de cualquier procedimiento que tenga el segundo usuario.

#### ORACLE

~~~
CREATE OR REPLACE PROCEDURE HeredarPrivilegios(v_usuario1 VARCHAR2, v_usuario2 VARCHAR2)
IS
	CURSOR c_tablas IS
	SELECT table_name, grantable
	FROM ALL_TABLES
	WHERE owner=v_usuario2;
BEGIN
	FOR v_tabla IN c_tablas
	LOOP
		IF v_tabla.gratable='YES' THEN
			dbms_output.put_line
~~~

4. Realiza un procedimiento que genere un script que cree un rol conteniendo todos los permisos que tenga el usuario cuyo nombre reciba como parámetro, le hayan sido asignados a aquél directamente o a traves de roles. El nuevo rol deberá llamarse BackupPrivsNombreUsuario.

~~~
CREATE OR REPLACE PROCEDURE ContraseñaUsuario(v_usuario VARCHAR2, contraseña OUT VARCHAR2)
IS
BEGIN
	SELECT password INTO contraseña
	FROM dba_users
	WHERE username=v_usuario;
END;
/
~~~

~~~
CREATE OR REPLACE PROCEDURE AsignarPrivilegiosSistema(v_usuario1 VARCHAR2, v_usuario2 VARCHAR2)
IS
	CURSOR c_privilegios IS
	SELECT privilege, admin_option
	FROM dba_sys_privs
	WHERE grantee=v_usuario1;
BEGIN
	FOR v_privilegio IN c_privilegios
	LOOP
		IF v_privilegio.admin_option='YES' THEN
			dbms_output.put_line('GRANT '||v_privilegio.privilege||' TO '||v_usuario2||' WITH ADMIN OPTION;');
		ELSE
			dbms_output.put_line('GRANT '||v_privilegio.privilege||' TO '||v_usuario2||';');
		END IF;
	END LOOP;
END;
/
~~~

~~~
CREATE OR REPLACE PROCEDURE AsignarPrivilegiosObjetos(v_usuario1 VARCHAR2, v_usuario2 VARCHAR2)
IS
	CURSOR c_privilegios IS
	SELECT privilege, grantable, table_name
	FROM dba_tab_privs
	WHERE grantee=v_usuario1
	OR OWNER=v_usuario1;
BEGIN
	FOR v_privilegio IN c_privilegios
	LOOP
		IF v_privilegio.grantable='YES' THEN
			dbms_output.put_line('GRANT '||v_privilegio.privilege||' ON '||v_usuario1||'.'||v_privilegio.table_name||' TO '||v_usuario2||' WITH GRANT OPTION;');
		ELSE
			dbms_output.put_line('GRANT '||v_privilegio.privilege||' ON '||v_usuario1||'.'||v_privilegio.table_name||' TO '||v_usuario2||';');
		END IF;
	END LOOP;
END;
/
~~~

~~~
CREATE OR REPLACE PROCEDURE BackupPrivsNombreUsuario(v_usuario VARCHAR2)
IS
	usuario_backup	VARCHAR2(20);
BEGIN
	usuario_backup:=CONCAT(v_usuario,'_Backup');

	dbms_output.put_line('CREATE USER '||usuario_backup||';');
	AsignarPrivilegiosSistema(v_usuario, usuario_backup);
	AsignarPrivilegiosObjetos(v_usuario, usuario_backup);
END;
/
~~~

* Comprobación de funcionamiento:

~~~
SQL> exec BackupPrivsNombreUsuario('SCOTT');
CREATE USER SCOTT_Backup IDENTIFIED BY ;
GRANT CREATE PROCEDURE TO SCOTT_Backup;
GRANT CREATE SESSION TO SCOTT_Backup;
GRANT CREATE TABLE TO SCOTT_Backup;
GRANT INSERT ON SCOTT.EMP TO SCOTT_Backup WITH GRANT OPTION;

PL/SQL procedure successfully completed.
~~~

### CASO PRÁCTICO 3:

1. Privilegios de sistema:

* Estos permiten realizar una operación o ejecutar un comando concreto. Hay casi 100:

* Para los objetos:
~~~
CREATE, ALTER Y DROP
~~~

~~~
CREATE ANY, ALTER ANY Y DROP ANY
~~~

* Para las tablas:
~~~
SELECT, INSERT, UPDATE, DELETE
~~~

* SINTAXIS PARA CONCEDER ESTOS PERMISOS:

~~~
GRANT CREATE USER TO Becario;
~~~

~~~
GRANT CREATE ALTER ANY USER TO Becario;
~~~

~~~
GRANT SELECT GRANT INSERT ANY TABLE TO Becario;
~~~

* Opción extra:
~~~
WITH GRANT OPTION
~~~

* SINTAXIS PARA REVOCAR ESTOS PERMISOS:

~~~
ROVOKE CREATE USER TO Becario;
~~~

* 
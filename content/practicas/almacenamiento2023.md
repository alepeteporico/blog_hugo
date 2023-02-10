+++
title = "Almacenamiento 2023"
description = ""
tags = [
    "GBD"
]
date = "2023-01-25"
menu = "main"
+++

### ORACLE


1. Establece que los objetos que se creen en el TS1 (creado por Alumno 1) tengan un tamaño inicial de 200K, y que cada extensión sea del doble del tamaño que la anterior. El número máximo de extensiones debe ser de 3.

* Primero apagamos este tablespace para poder modificarlo.

~~~
SQL> ALTER TABLESPACE TS1 OFFLINE;

Tablespace altered.
~~~

* Alteramos el tablespace tal y como se nos pide.

~~~
ALTER TABLESPACE TS1
    DEFAULT STORAGE (
       INITIAL 200K
       MAXEXTENTS 3
       PCTINCREASE 200);
~~~

* Sin embargo, esto nos da un error `ORA-25143: default storage clause is not compatible with allocation policy` creía que el problema estaba en que la segmentación se crea de forma automatica, y trate de cambiarla a manual sin ningún resultado, por ello he eliminiado el tablespace y lo he creado de 0 con estos nuevos parametros.

~~~
CREATE TABLESPACE TS1 
DATAFILE 'ts1_001.dbf' 
SIZE 2M
    DEFAULT STORAGE (
      INITIAL 200K
      MAXEXTENTS 3
      PCTINCREASE 200);
~~~

2. Crea dos tablas en el tablespace recién creado e inserta un registro en cada una de ellas. Comprueba el espacio libre existente en el tablespace. Borra una de las tablas y comprueba si ha aumentado el espacio disponible en el tablespace. Explica la razón.

~~~
CREATE TABLE Carreras_Profesionales
(
CodCarrera	VARCHAR(10),
Fecha	DATE,
ImportePremio	NUMBER(7,2),
ImporteMax	NUMBER(7,2),
EdadMinPart	NUMBER(2),
EdadMaxPart	NUMBER(2),
CONSTRAINT pk_carreras PRIMARY KEY(CodCarrera),
CONSTRAINT fecha_carrera CHECK(TO_CHAR(Fecha,'MM/DD') NOT BETWEEN '03/02' AND '10/20'),
CONSTRAINT hora_carrera CHECK(TO_CHAR(Fecha,'HH24:MI') BETWEEN '09:00' AND '14:00')
) TABLESPACE TS1;


CREATE TABLE Jockeys
(
DNI	VARCHAR(9),
Apellidos	VARCHAR(20),
Nombre	VARCHAR(15),
Peso	NUMBER(4,2),
Altura	NUMBER(3,2),
Telefono	VARCHAR(10),
CONSTRAINT pk_jockeys PRIMARY KEY(DNI),
CONSTRAINT DNIJockey_ok CHECK(REGEXP_LIKE(DNI,'^[K,L,M,Z,Y,X][0-9]{7}[A-Z]{1}$') OR REGEXP_LIKE(DNI,'[0-9]{8}[A-Z]'))
) TABLESPACE TS1;
~~~

* Una vez creadas las tablas hemos añadido algunos registros y vamos a comprobar el espacio libre.

~~~
SQL> SELECT BYTES
  2  FROM DBA_FREE_SPACE
  3  WHERE TABLESPACE_NAME='TS1';

     BYTES
----------
    786432
~~~

* Borramos un tabla y volvemos a hacer la consulta.

~~~
SQL> drop table carreras_profesionales;

Table dropped.

SQL> SELECT BYTES
  2  FROM DBA_FREE_SPACE
  3  WHERE TABLESPACE_NAME='TS1';

     BYTES
----------
    786432
     65536
     65536
~~~

* Vemos que en vez de añadirse el espacio libre a los bytes del segmento del tablespace, se creado dos segmentos nuevos cada uno de 65536 bytes. Esto es así debido a que Oracle considera que este espacio no es lo suficientemente grande como para reutilizarlos para nuevos datos, por tanto crea un espacio denominado "espacio libre fragmentado". Esto a la larga y tras la creación de muchos de estos espacios puede afectar al rendimiento de la base de datos, por lo que es importante la fragmentación de los tablespaces y desfragmentarlos de forma regular. Para hacerlo lo mejor es realizar una reducción en línea.

3. Convierte a TS1 en un tablespace de sólo lectura. Intenta insertar registros en la tabla existente. ¿Qué ocurre?. Intenta ahora borrar la tabla. ¿Qué ocurre? ¿Porqué crees que pasa eso?

* Lo hacemos de solo lectura.

~~~
ALTER TABLESPACE TS1 READ ONLY;
~~~

* Vamos a comprobar que podemos leer los objectos del tablespace, pero no podemos modificarlos o añadir ningún registro.

~~~
SQL> select * from jockeys;

DNI	  APELLIDOS	       NOMBRE		     PESO     ALTURA TELEFONO
--------- -------------------- --------------- ---------- ---------- ----------
77260496T Gonzalez Reyes       Victor		       55	1.68 657983401
18393815W Baquero Begines      Maria		       53	1.58 649239153
86402430D Lauda Perez	       Juan		       50	1.63 629108927
62550577F Vaca Ferreras        Alvaro		       50	1.47 674327184
24246622E Caliani Valle        Carlos		       56	1.55 643892743


SQL> INSERT INTO Jockeys(DNI,Nombre,Apellidos,Peso,Altura,Telefono)
VALUES('29290167N','Daniela','Pavon Caliani',51,1.53,'624374525');  2  
INSERT INTO Jockeys(DNI,Nombre,Apellidos,Peso,Altura,Telefono)
            *
ERROR at line 1:
ORA-00372: file 18 cannot be modified at this time
ORA-01110: data file 18: '/opt/oracle/product/19c/dbhome_1/dbs/ts1.dbf'
~~~

* Hemos puesto el tablespace en modo lectura, así que nos permitirá realizar ninguna operación que no sea leer los objectos del mismo.

4. Crea un espacio de tablas TS2 con dos ficheros en rutas diferentes de 1M cada uno no autoextensibles. Crea en el citado tablespace una tabla con la clausula de almacenamiento que quieras. Inserta registros hasta que se llene el tablespace. ¿Qué ocurre?

~~~
CREATE TABLESPACE TS2
DATAFILE '/opt/oracle/oradata/ORCLCDB/ts2_1.dbf' SIZE 1M,
'/opt/oracle/oradata/ORCLCDB/ts2_2.dbf' SIZE 1M;
~~~

- Creación de tabla.

~~~
CREATE TABLE RELLENAR
(
  RELLENO VARCHAR2(10)  
) TABLESPACE TS2;
~~~

- Añadimos registros hasta llenar el tablespace.

~~~
CREATE OR REPLACE PROCEDURE rellenar_tablespace
IS
  var NUMBER:=0;
  insertar  VARCHAR2(50);
BEGIN
  LOOP
    insertar:='INSERT INTO RELLENAR VALUES ('||var||');';
    dbms_output.put_line(insertar);
    var:=var+1;
  END LOOP;
END;
/
~~~

5. Hacer un procedimiento llamado MostrarUsuariosporTablespace que muestre por pantalla un listado de los tablespaces existentes con la lista de usuarios que tienen asignado cada uno de ellos por defecto y el número de los mismos.

* Lista todos los usuarios y dice el número total de los mismos de un tablespace.

~~~
CREATE OR REPLACE PROCEDURE UsuariosDelTablespace(v_tablespace VARCHAR2)
IS
  v_total NUMBER;
  CURSOR c_usuarios IS
    SELECT username
    FROM dba_users
    WHERE default_tablespace=v_tablespace;
BEGIN
  v_total:=0;
  FOR v_usuario IN c_usuarios
  LOOP
    dbms_output.put_line(v_usuario.username);
    v_total:=v_total+1;
  END LOOP;
  dbms_output.put_line('Total de usuarios en el tablespace '||v_tablespace||': '||v_total);
  dbms_output.put_line('-----------------------------------------------------------------------');
END;
/
~~~

* Lista todos los usuarios de todos los tablespace.

~~~
CREATE OR REPLACE PROCEDURE MostrarUsuariosporTablespace
IS
  CURSOR c_tablespaces IS
    SELECT TABLESPACE_NAME
    FROM DBA_TABLESPACES;
BEGIN
  FOR v_tablespace IN c_tablespaces
  LOOP
    dbms_output.put_line('Tablespace: '||v_tablespace.tablespace_name);
    UsuariosDelTablespace(v_tablespace.tablespace_name);
  END LOOP;
END;
/
~~~

* Ejecución del procedimiento.

~~~
SQL> EXEC MostrarUsuariosporTablespace;
Tablespace: SYSTEM
SYS
SYSTEM
XS$NULL
OJVMSYS
ALE
LBACSYS
OUTLN
SYS$UMF
Total de usuarios en el tablespace SYSTEM: 8
-----------------------------------------------------------------------
Tablespace: SYSAUX
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
Total de usuarios en el tablespace SYSAUX: 13
-----------------------------------------------------------------------
Tablespace: UNDOTBS1
Total de usuarios en el tablespace UNDOTBS1: 0
-----------------------------------------------------------------------
Tablespace: TEMP
Total de usuarios en el tablespace TEMP: 0
-----------------------------------------------------------------------
Tablespace: USERS
GSMCATUSER
MDDATA
SYSBACKUP
REMOTE_SCHEDULER_AGENT
GSMUSER
SYSRAC
GSMROOTUSER
SI_INFORMTN_SCHEMA
AUDSYS
DIP
ORDPLUGINS
SYSKM
ORDDATA
PROFESOR
ORACLE_OCM
SCOTT
SYSDG
ORDSYS
Total de usuarios en el tablespace USERS: 18
-----------------------------------------------------------------------
Tablespace: INDICES
Total de usuarios en el tablespace INDICES: 0
-----------------------------------------------------------------------
Tablespace: TS1
Total de usuarios en el tablespace TS1: 0
-----------------------------------------------------------------------

PL/SQL procedure successfully completed.
~~~

6. Realiza un procedimiento llamado MostrarDetallesIndices que reciba el nombre de una tabla y muestre los detalles sobre los índices que hay definidos sobre las columnas de la misma.

~~~
CREATE OR REPLACE PROCEDURE MostrarDetallesIndices(v_tabla  VARCHAR2)
IS
  CURSOR c_indices IS
    SELECT index_name, tablespace_name, owner
    FROM dba_indexes
    WHERE table_name=v_tabla;
BEGIN
  dbms_output.put_line('TABLA '||v_tabla);
  FOR v_indice IN c_indices
  LOOP
    dbms_output.put_line('Nombre del indice: '||v_indice.index_name);
    dbms_output.put_line('Nombre del tablespace: '||v_indice.tablespace_name);
    dbms_output.put_line('Propietario: '||v_indice.owner);
  END LOOP;
END;
/
~~~

* Ejecución del procedimiento.

~~~
SQL> EXEC MostrarDetallesIndices('JOCKEYS');
TABLA JOCKEYS
Nombre del indice: PK_JOCKEYS
Nombre del tablespace: TS1
Propietario: SYS
Nombre del indice: INDEX_JOCKEYS
Nombre del tablespace: SYSTEM
Propietario: SYS
~~~

### POSTGRES:

7. Averigua si existe el concepto de segmento y el de extensión en Postgres, en qué consiste y las diferencias con los conceptos correspondientes de ORACLE.

* Los segmentos en Oracle son el espacio que ocupa en un tablespace los objetos. En postgres el concepto es totalmente distinto, cuando se crea un segmento, se crea un archivo dentro del directorio que tiene asignado el tablespace en cuestión. Esto tiene inconvenientes, pues no puedes especificar lo que debe ocupar cada objeto (segmento). También tiene sus ventajas que podemos usar, como que cada tabla tendrá su propio segmento o carpeta que no compartira con otra. Cuando el objeto en cuestión supere 1GB de capacidad se creará una carpeta nueva.

### MySQL:

8. Averigua si existe el concepto de espacio de tablas en MySQL y las diferencias con los tablespaces de ORACLE.



## PARTE GRUPAL:

1. Cread un índice para la tabla EMP de SCOTT que agilice las consultas por nombre de empleado en un tablespace creado específicamente para índices. ¿Dónde deberiáis ubicar el fichero de datos asociado? ¿Cómo se os ocurre que podriáis probar si el índice resulta de utilidad?

* Creamos el tablespace especifico para el indice.

~~~
CREATE TABLESPACE INDICES
DATAFILE '/opt/oracle/oradata/ORCLCDB/tsg1.dbf'
SIZE 10M
AUTOEXTEND ON;
~~~

* Guardariamos este tablespace en `/opt/oracle/oradata/ORCLCDB/` este es un sitio seguro para guardar los documentos, aunque si hiciesemos muchas consultas a este índice deberíamos encontrar un equilibrio entre rapidez y seguridad. En mi caso tengo un ssd y va con la suficiente rapidez, sin embargo podríamos añadir un disco duro más rápido y montarlo dentro de la misma carpeta. 

* Le damos permisos al usuario SCOTT sobre el tablespace.

~~~
SQL> ALTER USER SCOTT QUOTA UNLIMITED ON INDICES;

User altered.
~~~

* Creación de índice:

~~~
SQL> CREATE INDEX empleados ON emp(ename)
  2  TABLESPACE INDICES;

Index created.
~~~

* Necesitamos una gran cantidad de registros para comprobar la utilidad del índice, tal como vimos en clase la cantidad de accesos a la tabla al realizar una consulta se reduce muchisimo al tener un índice, el número de accesos a la base de datos sería `log2 n+1`.

7. Explicad en qué consiste el sharding en MongoDB. Intentad montarlo.

**Consiste en un metodo de de distribución de los datos entre varias máquinas cuando el volumen de operaciones y tamaño de la base de datos crece demasido se usa este método para repartir la cargar. Lo que trae varias ventajas como:**

* **División de carga de lectura y escritura**
* **Aumento de la capacidad de almacenamiento**
* **Alta disponibilidad**

**Para poder usar este componente de mongo necesitamos tres instancias que se encargarán de diferentes cuestiones:**

* **Casco: Maneja un subconjunto de datos.**
* **Mongos: Actua como interfaz entre la aplicación del cliente y el cluster.**
* **Servidor de configuración: Almacena metadatos y detalles de la configuración del cluster**

**Esta es la forma recomendada por mongo para usar el `sharding`, sin embargo, debido a la complejidad que supone vamos a realizar una variación usando `ShardingTest` simplemente para ver la funcionalidad de este servicio**

* Primero creamos una carpeta necesaria y le damos los permisos tal y como veremos a continuación.

~~~
vagrant@buster:~$ sudo mkdir /data/db
vagrant@buster:~$ sudo chmod 0755 /data/db
vagrant@buster:~$ sudo grep mongo /etc/passwd
mongodb:x:110:65534::/home/mongodb:/usr/sbin/nologin
vagrant@buster:~$ sudo chown -R 110:65534 /data/db
~~~

* 
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

* 


2. Crea dos tablas en el tablespace recién creado e inserta un registro en cada una de ellas. Comprueba el espacio libre existente en el tablespace. Borra una de las tablas y comprueba si ha aumentado el espacio disponible en el tablespace. Explica la razón.

2. Crea un espacio de tablas TS2 con dos ficheros en rutas diferentes de 1M cada uno no autoextensibles. Crea en el citado tablespace una tabla con la clausula de almacenamiento que quieras. Inserta registros hasta que se llene el tablespace. ¿Qué ocurre?

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
    EXECUTE IMMEDIATE (insertar);

~~~
INSERT INTO ALUMNOS VALUES
('12344345','Alcalde Anta, Elena', 'C/Las Matas, 24','Madrid','917766545');

INSERT INTO ALUMNOS VALUES
('4448242','Cerrato Vela, Luis', 'C/Mina 28 - 3A', 'Madrid','916566545');

INSERT INTO ALUMNOS VALUES
('56882942','Diaz Perez, Maria', 'C/Luis Vives 25', 'Mostoles','915577545');

INSERT INTO ALUMNOS VALUES
('56882934','Diaz Perez, Jose', 'C/Luis Vives 25', 'Mostoles','915577546');
~~~


SELECT tablespace_name,
ROUND(sum(bytes)/1024/1024,0)
FROM dba_free_space
WHERE tablespace_name NOT LIKE 'TEMP%'
GROUP BY tablespace_name;



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
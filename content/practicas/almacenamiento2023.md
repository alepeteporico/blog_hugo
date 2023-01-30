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

* Intenta crear el tablespace TS1 con un fichero de 2M en tu disco que crezca automáticamente cuando sea necesario. ¿Puedes hacer que la gestión de extensiones sea por diccionario? Averigua la razón.

~~~

~~~

* Crea dos tablas en el tablespace recién creado e inserta un registro en cada una de ellas. Comprueba el espacio libre existente en el tablespace. Borra una de las tablas y comprueba si ha aumentado el espacio disponible en el tablespace. Explica la razón.

* Convierte a TS1 en un tablespace de sólo lectura. Intenta insertar registros en la tabla existente. ¿Qué ocurre?. Intenta ahora borrar la tabla. ¿Qué ocurre? ¿Porqué crees que pasa eso?

* Crea un espacio de tablas TS2 con dos ficheros en rutas diferentes de 1M cada uno no autoextensibles. Crea en el citado tablespace una tabla con la clausula de almacenamiento que quieras. Inserta registros hasta que se llene el tablespace. ¿Qué ocurre?

~~~
CREATE TABLESPACE TS2
DATAFILE '/opt/oracle/oradata/ORCLCDB/ts2_1.dbf' SIZE 1M,
'/opt/oracle/oradata/ORCLCDB/ts2_2.dbf' SIZE 1M;
~~~

+ Creación de tabla.

~~~
CREATE TABLE ALUMNOS
(
  DNI VARCHAR2(10) NOT NULL,
  APENOM VARCHAR2(30),
  DIREC VARCHAR2(30),
  POBLA  VARCHAR2(15),
  TELEF  VARCHAR2(10)  
) TABLESPACE TS2;
~~~
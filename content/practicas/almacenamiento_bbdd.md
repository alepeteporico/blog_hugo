+++
title = "Almacenamiento"
description = ""
tags = [
    "ABD"
]
date = "2021-05-10"
menu = "main"
+++

### Muestra los objetos a los que pertenecen las extensiones del tablespace TS2 (creado por tí) y el tamaño de cada una de ellas. Tendrás que crear objetos en él previamente, claro.

* Vamos a crear este Tablespace.

        SQL> CREATE TABLESPACE TS2
          2  DATAFILE '/home/oracle/ts2.dbf'
          3  SIZE 200K
          4  AUTOEXTEND ON
          5  DEFAULT STORAGE (
          6  INITIAL 200K
          7  NEXT 200K
          8  MAXEXTENTS 3
          9  PCTINCREASE 100);

        Tablespace created.

* Vamos a crear una prueba para ver como funciona y añadamos contenido a ver como funciona.

        SQL> CREATE TABLE prueba2 (
          2  clave	VARCHAR(5),
          3  otra_cosa	VARCHAR2(25)
          4  )  TABLESPACE TS2;

        Table created.

        SQL> insert into prueba2 (clave,otra_cosa) values ('1234', 'esto es otra cosa');

        1 row created.

        SQL> insert into prueba2 (clave,otra_cosa) values ('12345', 'mas cosas');           

        1 row created.

* Ahora mediante las siguientes instrucciones comprobaremos el espacio libre que tenemos depués de añadir contenido.

        SQL> SELECT TABLESPACE_NAME,TO_CHAR(SUM(NVL(BYTES,0))/1024/1024, '99,999,990.99') AS "FREE SPACE(IN MB)"
          2  FROM USER_FREE_SPACE 
          3  GROUP BY TABLESPACE_NAME;

        TABLESPACE_NAME 	       FREE SPACE(IN
        ------------------------------ --------------
        SYSTEM					 9.50
        SYSAUX					27.63
        UNDOTBS1				 3.00
        USERS					 1.94
        TS2					 0.06

### Borra la tabla que está llenando TS2 consiguiendo que vuelvan a existir extensiones libres. Añade después otro fichero de datos a TS2.

* Borramos la tabla:

        SQL> DROP TABLE prueba2;

        Table dropped.

* Y volvemos a comprobar el espacio, si nos fijamos en TS2 se ha incrementado el espacio libre respecto a anteriormente.

        SQL> SELECT TABLESPACE_NAME,TO_CHAR(SUM(NVL(BYTES,0))/1024/1024, '99,999,990.99') AS "FREE SPACE(IN MB)"
          2  FROM USER_FREE_SPACE 
          3  GROUP BY TABLESPACE_NAME;

        TABLESPACE_NAME 	       FREE SPACE(IN
        ------------------------------ --------------
        SYSTEM					 9.50
        SYSAUX					27.63
        UNDOTBS1				 3.00
        USERS					 1.94
        TS2					 0.13

* Vamos a añadir otro fichero de datos a nuestro tablespace.

        SQL> alter tablespace TS2 add datafile '/home/oracle/nuevo.dbf' size 15M;

        Tablespace altered.

* Y vamos a comprobar los ficheros que están en funcionamiento.

        SQL> select file_name,tablespace_name
          2  from dba_data_files
          3  where tablespace_name='TS2';

        FILE_NAME
        --------------------------------------------------------------------------------
        TABLESPACE_NAME
        ------------------------------
        /home/oracle/ts2.dbf
        TS2

        /home/oracle/nuevo.dbf
        TS2

### Crea el tablespace TS3 gestionado localmente con un tamaño de extension uniforme de 128K y un fichero de datos asociado. Cambia la ubicación del fichero de datos y modifica la base de datos para que pueda acceder al mismo. Crea en TS3 dos tablas e inserta registros en las mismas. Comprueba que segmentos tiene TS3, qué extensiones tiene cada uno de ellos y en qué ficheros se encuentran.

* Vamos a crear este nuevo tablespace con el fichero que se nos especifica y la extensión uniforme.

        SQL> CREATE TABLESPACE TS3 DATAFILE '/home/oracle/ts3.dbf' SIZE 20M EXTENT MANAGEMENT LOCAL UNIFORM SIZE 128K;

        Tablespace created.

* Si queremos modificar los archivos de este tablespace debemos apagarlo.

        SQL> ALTER TABLESPACE TS3 OFFLINE;

        Tablespace altered.

* Vamos a salir de oracle y modificar la ubicación de este fichero que estará en nuestro hombre como especificamos al crearlo.

        [oracle@oracle ~]$ mv ts3.dbf mod/

* Volvemos a entrar en oracle y modificamos el tablespace para especificar la nueva ruta del arhivo.

        SQL> alter tablespace TS3 rename datafile '/home/oracle/ts3.dbf' to '/home/oracle/mod/ts3.dbf';
        
        Tablespace altered.

* Ahora si podemos activar nuestro tablespace y ver la ruta de nuestro fichero de datos.

        SQL> ALTER TABLESPACE TS3 ONLINE;
        
        Tablespace altered.
        
        SQL> select file_name,tablespace_name
          2  from dba_data_files
          3  where tablespace_name='TS3';
        
        FILE_NAME
        --------------------------------------------------------------------------------
        TABLESPACE_NAME
        ------------------------------
        /home/oracle/mod/ts3.dbf
        TS3

* Ahora crearemos contenido dentro de nuestro tablespace, en concreto dos tablas con contenido.

        SQL> CREATE TABLE prueba3 (
          2  clave	VARCHAR(5),
          3  cosas	VARCHAR(10),
          4  mascosas	VARCHAR(20)
          5  ) TABLESPACE TS3;

        Table created.

        SQL> CREATE TABLE prueba4 (
          2  clave	VARCHAR(5),
          3  cosas	VARCHAR(10),
          4  mascosas	VARCHAR(20)
          5  ) TABLESPACE TS3;

        Table created.

        SQL> insert into prueba4 values ('4','cuatro','four');

        1 row created.

        SQL> insert into prueba4 values ('6','seis','six');

        1 row created.

        SQL> insert into prueba3 values ('3','quepasa','carapasa');

        1 row created.

        SQL> insert into prueba3 values ('2','jia','jau');

        1 row created.

        SQL> insert into prueba3 values ('1','hola','caracola');

        1 row created.

* Comprobamos los segmentos que tiene TS3, las extensiones y en que fichero se encuentran.

        SQL> select de.segment_name,de.extent_id,df.file_name,de.file_id
          2  from dba_data_files  df, dba_extents de
          3  where de.file_id = df.file_id
          4  and de.tablespace_name = 'TS3';

        SEGMENT_NAME
        --------------------------------------------------------------------------------
         EXTENT_ID
        ----------
        FILE_NAME
        --------------------------------------------------------------------------------
           FILE_ID
        ----------
        PRUEBA3
        	 0
        /home/oracle/mod/ts3.dbf
        	15


        SEGMENT_NAME
        --------------------------------------------------------------------------------
         EXTENT_ID
        ----------
        FILE_NAME
        --------------------------------------------------------------------------------
           FILE_ID
        ----------
        PRUEBA4
        	 0
        /home/oracle/mod/ts3.dbf
        	15

### Redimensiona los ficheros asociados a los tres tablespaces que has creado de forma que ocupen el mínimo espacio posible para alojar sus objetos.

* Comprobemos el espacio que tienen nuestros tablespace para poder compararlos después de redimensionarlos.

        SQL> select sum(bytes)/1024||'KB', tablespace_name
          2  from dba_segments
          3  where tablespace_name like 'TS%'
          4  group by tablespace_name;

        SUM(BYTES)/1024||'KB'			   TABLESPACE_NAME
        ------------------------------------------ ------------------------------
        256KB					   TS3
        64KB					   TS2

* Vamos a redimensionar nuestros ficheros.

        SQL> alter database datafile '/home/oracle/ts2.dbf' resize 1M;

        Database altered.

        SQL> alter database datafile '/home/oracle/mod/ts3.dbf' resize 20M;

        Database altered.

* Ahora volvamos a comprobar el espacio de nuestros tablespace.

        SQL> select sum(bytes)/1024||'KB', tablespace_name
          2  from dba_segments
          3  where tablespace_name like 'TS%'
          4  group by tablespace_name;

        SUM(BYTES)/1024||'KB'			   TABLESPACE_NAME
        ------------------------------------------ ------------------------------
        256KB					   TS3
        64KB					   TS2

        SQL> select file_name,tablespace_name,(bytes/1024)||'KB'
          2  from dba_data_files
          3  where tablespace_name like 'TS%';

        FILE_NAME
        --------------------------------------------------------------------------------
        TABLESPACE_NAME 	       (BYTES/1024)||'KB'
        ------------------------------ ------------------------------------------
        /home/oracle/ts2.dbf
        TS2			       1024KB

        /home/oracle/nuevo.dbf
        TS2			       15360KB

        /home/oracle/mod/ts3.dbf
        TS3			       20480KB

### Crea una secuencia para rellenar el campo deptno de la tabla dept de forma coherente con los datos ya existentes. Inserta al menos dos registros haciendo uso de la secuencia.

### Resuelve el siguiente caso práctico en ORACLE:

**En nuestra empresa existen tres departamentos: Informática, Ventas y Producción. En Informática trabajan tres personas: Pepe, Juan y Clara. En Ventas trabajan Ana y Eva y en Producción Jaime y Lidia.**

1. Pepe es el administrador de la base de datos. Juan y Clara son los programadores de la base de datos, que trabajan tanto en la aplicación que usa el departamento de Ventas como en la usada por el departamento de Producción. Ana y Eva tienen permisos para insertar, modificar y borrar registros en las tablas de la aplicación de Ventas que tienes que crear, y se llaman Productos y Ventas, siendo propiedad de Ana. Jaime y Lidia pueden leer la información de esas tablas pero no pueden modificar la información. Crea los usuarios y dale los roles y permisos que creas conveniente. 

* Creamos usuarios y permisos

        SQL> CREATE USER Pepe identified by Pepe;
        SQL> GRANT dba to Pepe;

        SQL> CREATE USER Juan identified by Juan;
        SQL> GRANT resource to Juan;
        SQL> CREATE USER Clara identified by Clara;
        SQL> GRANT resource to Clara;

        SQL> CREATE USER Ana identified by Ana;
        SQL> CREATE USER Eva identified by Eva;
        SQL> GRANT select on Ana.Ventas to Eva;
        SQL> GRANT insert on Ana.Ventas to Eva;
        SQL> GRANT update on Ana.Ventas to Eva;
        SQL> GRANT delete on Ana.Ventas to Eva;
        SQL> GRANT select on Ana.Productos to Eva;
        SQL> GRANT insert on Ana.Productos to Eva;
        SQL> GRANT update on Ana.Productos to Eva;
        SQL> GRANT delete on Ana.Productos to Eva;

        SQL> CREATE USER Jaime identified by Jaime;
        SQL> CREATE USER Lidia identified by Lidia;
        SQL> GRANT select on Ana.Ventas to Jaime;
        SQL> GRANT select on Ana.Ventas to Lidia;
        SQL> GRANT select on Ana.Productos to Jaime;
        SQL> GRANT select on Ana.Productos to Lidia;

* Y seguidamente creamos los roles.

        SQL> CREATE ROLE Produccion;
        SQL> GRANT select on Ana.Ventas to Produccion;
        SQL> GRANT select on Ana.Productos to Produccion;

        SQL> GRANT Produccion to Lidia;
        SQL> GRANT Produccion to Jaime;

        SQL> CREATE ROLE Ventas;
        SQL> GRANT select, insert, update, delete on Ana.Ventas to Ventas;
        SQL> GRANT select, insert, update, delete on Ana.Productos to Ventas;
        SQL> GRANT Ventas to Eva;

2. Los espacios de tablas son System, Producción (ficheros prod1.dbf y prod2.dbf) y Ventas (fichero vent.dbf). Los programadores del departamento de Informática pueden crear objetos en cualquier tablespace de la base de datos, excepto en System. Los demás usuarios solo podrán crear objetos en su tablespace correspondiente teniendo un límite de espacio de 30 M los del departamento de Ventas y 100K los del de Producción. Pepe tiene cuota ilimitada en todos los espacios, aunque el suyo por defecto es System.

* Creamos la tablespace de producción, system y ventas.

        SQL> CREATE TABLESPACE ts_produccion
          2  DATAFILE 'prod1.dbf' SIZE 100M,
          3  'prod2.dbf' SIZE 100M AUTOEXTEND ON;

        Tablespace created.

        SQL> CREATE TABLESPACE ts_venta
          2  DATAFILE 'vent.dbf'
          3  SIZE 100M AUTOEXTEND ON;

        Tablespace created.

* Una vez creadas las tablespace podemos crear las cuotas para los usuarios.

        SQL> ALTER USER ANA QUOTA 30M ON ts_venta;

        User altered.

        SQL> ALTER USER LIDIA QUOTA 100K ON ts_produccion;

        User altered.

        SQL> ALTER USER EVA QUOTA 30M ON ts_venta;

        User altered.

        SQL> ALTER USER JAIME QUOTA 100K ON ts_produccion;

        User altered.

* Pepe tendrá cuota ilimitada, vamos a ponersela

        SQL> ALTER USER Pepe DEFAULT TABLESPACE SYSTEM;

        User altered.

        SQL> GRANT UNLIMITED TABLESPACE TO Pepe;

        Grant succeeded.

* Y los usuarios Juan y Clara debemos quitarles los privilegios de creación de objetos.

        SQL> GRANT UNLIMITED TABLESPACE TO JUAN;

        Grant succeeded.

        SQL> ALTER USER JUAN QUOTA 0 ON SYSTEM;

        User altered.

        SQL> GRANT UNLIMITED TABLESPACE TO CLARA;

        Grant succeeded.

        SQL> ALTER USER CLARA QUOTA 0 ON SYSTEM;

        User altered.

3. Pepe quiere crear una tabla Prueba que ocupe inicialmente 256K en el tablespace Ventas.

        SQL> CREATE TABLE pepe.prueba5 (
          2  clave      VARCHAR(5),
          3  algo	VARCHAR(10),
          4  CONSTRAINT pk_codigo PRIMARY KEY(clave),
          5  STORAGE (INITIAL 256K)
          6  );

4. Pepe decide que los programadores tengan acceso a la tabla Prueba antes creada y puedan ceder ese derecho y el de conectarse a la base de datos a los usuarios que ellos quieran.

        SQL> GRANT SELECT ON PEPE.PRUEBA TO Juan WITH GRANT OPTION;
        SQL> GRANT SELECT ON PEPE.PRUEBA TO Clara WITH GRANT OPTION;
        SQL> GRANT CONNECT TO Clara WITH ADMIN OPTION;
        SQL> GRANT CONNECT TO Juan WITH ADMIN OPTION;

5. Lidia y Jaime dejan la empresa, borra los usuarios y el espacio de tablas correspondiente, detalla los pasos necesarios para que no quede rastro del espacio de tablas.

* Borramos en cascada para eliminar toda alteración que hayan hecho en otras tablas

        SQL> DROP USER lidia cascade;

        User dropped.

        SQL> DROP USER jaime cascade;

        User dropped.

* Y ejecutamos la siguiente instrucción para borrar todo lo que estaba en el tablespace.

        SQL> drop tablespace ts_produccion including contents and datafiles;

        Tablespace dropped.

------------------------------------------------------------------------------

### Averigua si es posible establecer cuotas de uso sobre los tablespaces en Postgres.

* No existe una opción especifica en postgres para administrar quotas, lo que si podríamos hacer es asignar una cuota en el sistema a un usuario sobre la partición donde se encuentra el tablespace que hayamos creado.

* Instalamos en nuestro sistema el paquete `quota`

        vagrant@postgres:~$ sudo apt install quota

* Nos dirigimos al fichero `/etc/fstab` y lo modifcamos de la siguiente forma:

        UUID=d3d2a9a3-92f6-4777-bb0f-1d806e57bfec	/	ext4	rw,discard,errors=remount-ro,usrquota,grpquota	0	1

* Remontamos el raiz para que los cambios en el disco hagan efecto.

        vagrant@postgres:~$ sudo mount -o remount /

* Vamos a habilitar las cuotas

        vagrant@postgres:~$ sudo quotacheck -ugm /
        
        vagrant@postgres:~$ sudo quotaon -v /
        /dev/sda1 [/]: group quotas turned on
        /dev/sda1 [/]: user quotas turned on

* Y para modifcar las cuotas de los usuarios pues simplente usamos el siguiente comando:

        vagrant@postgres:~$ sudo edquota -u vagrant

* Como postgres crea un usuario "real" en el sistema por así decirlo cada vez que creamos uno en la base de datos, pues simplemente añadimos uno cuota al usuario al que queremos restringir el almacenamiento.

### Averigua si existe el concepto de extensión en MySQL y si coincide con el existente en ORACLE.

* Existe lo que se llaman motores de almacenamiento, existen distintos, pero los mas usados son `MyISAM` e `nnoDB`.

* Un motor de almacenamiento es el encargado de almacenar, gestionar y recuperar toda la información de una tabla.

* Veamos todos los que existen.

        MariaDB [(none)]> SHOW ENGINES;
        +--------------------+---------+----------------------------------------------------------------------------------+--------------+------+------------+
        | Engine             | Support | Comment                                                                          | Transactions | XA   | Savepoints |
        +--------------------+---------+----------------------------------------------------------------------------------+--------------+------+------------+
        | MRG_MyISAM         | YES     | Collection of identical MyISAM tables                                            | NO           | NO   | NO         |
        | CSV                | YES     | Stores tables as CSV files                                                       | NO           | NO   | NO         |
        | MEMORY             | YES     | Hash based, stored in memory, useful for temporary tables                        | NO           | NO   | NO         |
        | MyISAM             | YES     | Non-transactional engine with good performance and small data footprint          | NO           | NO   | NO         |
        | Aria               | YES     | Crash-safe tables with MyISAM heritage                                           | NO           | NO   | NO         |
        | InnoDB             | DEFAULT | Supports transactions, row-level locking, foreign keys and encryption for tables | YES          | YES  | YES        |
        | PERFORMANCE_SCHEMA | YES     | Performance Schema                                                               | NO           | NO   | NO         |
        | SEQUENCE           | YES     | Generated tables filled with sequential values                                   | YES          | NO   | YES        |
        +--------------------+---------+----------------------------------------------------------------------------------+--------------+------+------------+
        8 rows in set (0.001 sec)

* Vemos que nos da un listado de los que tenemos a disposición y un poco de las características de los mismos.

### Averigua si en MongoDB puede saberse el espacio disponible para almacenar nuevos documentos.

* Por supuesto, mongo ofrece diferentes opciones para gestionar el almacenamiento y los datos que maneja, veamos algunos de ellos

* Ver el tamaño de los datos en la colección.

        db.collection.dataSize(): 

* Ver el tamaño de los índices.

        db.collection.totalIndexSize():

* Ver el tamaño de un índice.

        db.collection.index.stats().indexSizes: 

* Ver el tamaño de los datos más el de los índices.

        db.collection.totalSize():
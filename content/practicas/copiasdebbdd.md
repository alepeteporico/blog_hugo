+++
title = "Copias de seguridad en bases de datos"
description = ""
tags = [
    "GBD"
]
date = "2023-03-03"
menu = "main"
+++

1. Realiza una copia de seguridad lógica de tu base de datos completa, teniendo en cuenta los siguientes requisitos:

**La copia debe estar encriptada y comprimida.**

**Debe realizarse en un conjunto de ficheros con un tamaño máximo de 60 MB.**

**Programa la operación para que se repita cada día a una hora determinada.**

* Antes de todo debemos permitir a los usuarios crear carpetas y manejarlas.

~~~
SQL> GRANT CREATE ANY DIRECTORY TO SYSTEM;

Grant succeeded.

SQL> CREATE DIRECTORY copias AS '/home/vagrant/backups';

Directory created.

SQL> GRANT READ, WRITE ON DIRECTORY copias TO SYSTEM;

Grant succeeded.
~~~

* Una vez hecho esto también debemos darle permisos para que pueda exportar las bases de datos al usuario system.

~~~
SQL> GRANT DATAPUMP_EXP_FULL_DATABASE TO SYSTEM;

Grant succeeded.
~~~

* Vamos a realizar la copia.

~~~
vagrant@oracleagv:~$ expdp SYSTEM/SYSTEM FULL=y DIRECTORY=copias FILE=copia_total_$(date +"%d%m%Y").sql FILESIZE=60MB ENCRYPTION=ALL ENCRYPTION_PASSWORD=copias COMPRESSION=ALL LOG=copias.log

Export: Release 19.0.0.0.0 - Production on Mon Mar 6 22:12:17 2023
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Legacy Mode Active due to the following parameters:
Legacy Mode Parameter: "file=copia_total_06032023.sql" Location: Command Line, Replaced with: "dumpfile=copia_total_06032023.sql"
Legacy Mode Parameter: "log=copias.log" Location: Command Line, Replaced with: "logfile=copias.log"
Legacy Mode has set reuse_dumpfiles=true parameter.

Warning: Oracle Data Pump operations are not typically needed when connected to the root or seed of a container database.

Starting "SYSTEM"."SYS_EXPORT_FULL_01":  SYSTEM/******** FULL=y DIRECTORY=copias dumpfile=copia_total_06032023.sql FILESIZE=60MB ENCRYPTION=ALL ENCRYPTION_PASSWORD=******** COMPRESSION=ALL logfile=copias.log reuse_dumpfiles=true 
Processing object type DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE_DATA
Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TABLE_DATA
Processing object type DATABASE_EXPORT/SCHEMA/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
Processing object type DATABASE_EXPORT/SCHEMA/TABLE/STATISTICS/TABLE_STATISTICS
Processing object type DATABASE_EXPORT/STATISTICS/MARKER
Processing object type DATABASE_EXPORT/PRE_SYSTEM_IMPCALLOUT/MARKER
Processing object type DATABASE_EXPORT/PRE_INSTANCE_IMPCALLOUT/MARKER
Processing object type DATABASE_EXPORT/TABLESPACE
Processing object type DATABASE_EXPORT/PROFILE
Processing object type DATABASE_EXPORT/RADM_FPTM
Processing object type DATABASE_EXPORT/GRANT/SYSTEM_GRANT/PROC_SYSTEM_GRANT
Processing object type DATABASE_EXPORT/SCHEMA/GRANT/SYSTEM_GRANT
Processing object type DATABASE_EXPORT/SCHEMA/ROLE_GRANT
Processing object type DATABASE_EXPORT/SCHEMA/DEFAULT_ROLE
Processing object type DATABASE_EXPORT/SCHEMA/ON_USER_GRANT
...
...
...
~~~

* Tenemos la copia hecha.

~~~
vagrant@oracleagv:~$ ls backups/
copia_total_06032023.sql  copias.log
~~~

* Para automatizarla vamos a usar contrab.

~~~
crontab -e

30 12 * * * expdp SYSTEM/SYSTEM FULL=y DIRECTORY=copias FILE=copia_total_$(date +"%d%m%Y").sql FILESIZE=60MB ENCRYPTION=ALL ENCRYPTION_PASSWORD=copias COMPRESSION=ALL LOG=copias.log
~~~

2. Restaura la copia de seguridad lógica creada en el punto anterior.

* La restauración es sencilla, ya vimos algo similar en la práctica de movimiento de datos.

~~~
vagrant@oracleagv:~$ impdp SYSTEM/SYSTEM DIRECTORY=copias dumpfile=copia_total_06032023.sql FULL=YES ENCRYPTION_PASSWORD=copias
~~~

* Comprobamos que se ha realizado correctamente.

~~~
vagrant@oracleagv:~$ sqlplus / as sysdba

SQL*Plus: Release 19.0.0.0.0 - Production on Mon Mar 6 22:32:22 2023
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle.  All rights reserved.


Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0

SQL> connect SCOTT/TIGER
Connected.
SQL> SELECT * FROM EMP;

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
~~~

3. Pon tu base de datos en modo ArchiveLog y realiza con RMAN una copia de seguridad física en caliente.

* Ponemos la base de datos en modo `ArchiveLog`

~~~
SQL> ALTER DATABASE ARCHIVELOG;

Database altered.

SQL> ALTER DATABASE OPEN;

Database altered.
~~~

* Podemos comprobar que se encuentra en este modo.

~~~
SQL> SELECT LOG_MODE FROM V$DATABASE;

LOG_MODE
------------
ARCHIVELOG
~~~

* Ahora creamos la copia de seguridad física con `RMAN`. Primero vamos a añadir el directorio donde se creará la copia.

~~~
vagrant@oracleagv:~$ rman target SYSTEM/SYSTEM

Recovery Manager: Release 19.0.0.0.0 - Production on Mon Mar 6 22:57:41 2023
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

connected to target database: ORCLCDB (DBID=2889724655)

RMAN> configure channel device type disk format '/mnt/backups/copias';

new RMAN configuration parameters:
CONFIGURE CHANNEL DEVICE TYPE DISK FORMAT   '/mnt/backups/copias';
new RMAN configuration parameters are successfully stored
~~~

* Y creamos la copias de seguridad.

~~~
RMAN> backup database format '/mnt/backups/%U.dbf';

Starting backup at 07-MAR-23
using channel ORA_DISK_1
channel ORA_DISK_1: starting full datafile backup set
channel ORA_DISK_1: specifying datafile(s) in backup set
input datafile file number=00001 name=/opt/oracle/oradata/ORCLCDB/system01.dbf
input datafile file number=00003 name=/opt/oracle/oradata/ORCLCDB/sysaux01.dbf
input datafile file number=00004 name=/opt/oracle/oradata/ORCLCDB/undotbs01.dbf
input datafile file number=00014 name=/opt/oracle/oradata/ORCLCDB/tsg1.dbf
input datafile file number=00007 name=/opt/oracle/oradata/ORCLCDB/users01.dbf
input datafile file number=00018 name=/opt/oracle/product/19c/dbhome_1/dbs/ts1_001.dbf
channel ORA_DISK_1: starting piece 1 at 07-MAR-23
channel ORA_DISK_1: finished piece 1 at 07-MAR-23
piece handle=/mnt/backups/0c1mel73_1_1.dbf tag=TAG20230307T114331 comment=NONE
channel ORA_DISK_1: backup set complete, elapsed time: 00:00:07
channel ORA_DISK_1: starting full datafile backup set
channel ORA_DISK_1: specifying datafile(s) in backup set
input datafile file number=00010 name=/opt/oracle/oradata/ORCLCDB/ORCLPDB1/sysaux01.dbf
input datafile file number=00009 name=/opt/oracle/oradata/ORCLCDB/ORCLPDB1/system01.dbf
input datafile file number=00011 name=/opt/oracle/oradata/ORCLCDB/ORCLPDB1/undotbs01.dbf
input datafile file number=00012 name=/opt/oracle/oradata/ORCLCDB/ORCLPDB1/users01.dbf
channel ORA_DISK_1: starting piece 1 at 07-MAR-23
channel ORA_DISK_1: finished piece 1 at 07-MAR-23
piece handle=/mnt/backups/0d1mel7a_1_1.dbf tag=TAG20230307T114331 comment=NONE
channel ORA_DISK_1: backup set complete, elapsed time: 00:00:03
channel ORA_DISK_1: starting full datafile backup set
channel ORA_DISK_1: specifying datafile(s) in backup set
input datafile file number=00006 name=/opt/oracle/oradata/ORCLCDB/pdbseed/sysaux01.dbf
input datafile file number=00005 name=/opt/oracle/oradata/ORCLCDB/pdbseed/system01.dbf
input datafile file number=00008 name=/opt/oracle/oradata/ORCLCDB/pdbseed/undotbs01.dbf
channel ORA_DISK_1: starting piece 1 at 07-MAR-23
channel ORA_DISK_1: finished piece 1 at 07-MAR-23
piece handle=/mnt/backups/0e1mel7d_1_1.dbf tag=TAG20230307T114331 comment=NONE
channel ORA_DISK_1: backup set complete, elapsed time: 00:00:03
Finished backup at 07-MAR-23

Starting Control File and SPFILE Autobackup at 07-MAR-23
piece handle=/opt/oracle/product/19c/dbhome_1/dbs/c-2889724655-20230307-00 comment=NONE
Finished Control File and SPFILE Autobackup at 07-MAR-23
~~~

4. Borra un fichero de datos de un tablespace e intenta recuperar la instancia de la base de datos a partir de la copia de seguridad creada en el punto anterior.

* Borramos un tablespace.

~~~
SQL> DROP TABLESPACE INDICES INCLUDING CONTENTS;

Tablespace dropped.
~~~

* Antes de recuperar la instancia debemos apagar y encender RMAN.

~~~
RMAN> shutdown 

database closed
database dismounted
Oracle instance shut down

RMAN> startup mount

connected to target database (not started)
Oracle instance started
database mounted

Total System Global Area    1660941680 bytes

Fixed Size                     9135472 bytes
Variable Size               1140850688 bytes
Database Buffers             503316480 bytes
Redo Buffers                   7639040 bytes
~~~

* Ahora restauraremos la copia usando RMAN.

~~~
RMAN> restore database;

Starting restore at 07-MAR-23
allocated channel: ORA_DISK_1
channel ORA_DISK_1: SID=45 device type=DISK

skipping datafile 5; already restored to file /opt/oracle/oradata/ORCLCDB/pdbseed/system01.dbf
skipping datafile 6; already restored to file /opt/oracle/oradata/ORCLCDB/pdbseed/sysaux01.dbf
skipping datafile 8; already restored to file /opt/oracle/oradata/ORCLCDB/pdbseed/undotbs01.dbf
skipping datafile 9; already restored to file /opt/oracle/oradata/ORCLCDB/ORCLPDB1/system01.dbf
skipping datafile 10; already restored to file /opt/oracle/oradata/ORCLCDB/ORCLPDB1/sysaux01.dbf
skipping datafile 11; already restored to file /opt/oracle/oradata/ORCLCDB/ORCLPDB1/undotbs01.dbf
skipping datafile 12; already restored to file /opt/oracle/oradata/ORCLCDB/ORCLPDB1/users01.dbf
channel ORA_DISK_1: starting datafile backup set restore
channel ORA_DISK_1: specifying datafile(s) to restore from backup set
channel ORA_DISK_1: restoring datafile 00001 to /opt/oracle/oradata/ORCLCDB/system01.dbf
channel ORA_DISK_1: restoring datafile 00003 to /opt/oracle/oradata/ORCLCDB/sysaux01.dbf
channel ORA_DISK_1: restoring datafile 00004 to /opt/oracle/oradata/ORCLCDB/undotbs01.dbf
channel ORA_DISK_1: restoring datafile 00007 to /opt/oracle/oradata/ORCLCDB/users01.dbf
channel ORA_DISK_1: reading from backup piece /mnt/backups/0c1mel73_1_1.dbf
channel ORA_DISK_1: piece handle=/mnt/backups/0c1mel73_1_1.dbf tag=TAG20230307T114331
channel ORA_DISK_1: restored backup piece 1
channel ORA_DISK_1: restore complete, elapsed time: 00:00:15
Finished restore at 07-MAR-23
~~~

* Y no solo tenemos que hacer eso, sino también un recover.

~~~
RMAN> recover database;

Starting recover at 07-MAR-23
using channel ORA_DISK_1

starting media recovery
media recovery complete, elapsed time: 00:00:03

Finished recover at 07-MAR-23
~~~

* Abrimos la base de datos.

~~~
SQL> ALTER DATABASE OPEN;

Database altered.
~~~

* Y comprobamos que se ha restaurado el tablespace.

~~~
SQL> select tablespace_name from dba_tablespaces;

TABLESPACE_NAME
------------------------------
SYSTEM
SYSAUX
UNDOTBS1
TEMP
USERS
INDICES
~~~

5. Borra un fichero de control e intenta recuperar la base de datos a partir de la copia de seguridad creada en el punto anterior.



6. Documenta el empleo de las herramientas de copia de seguridad y restauración de Postgres.

#### Realizar copias de seguridad.

* Podemos realizar una copia de cualquier base de datos con un simple comando.

~~~
postgres@postgresagv:~$ pg_dump prueba > prueba.bak
~~~

* Vamos a ver el fichero.

            postgres@postgresagv:~$ cat prueba.bak 
            --
            -- PostgreSQL database dump
            --

            -- Dumped from database version 13.9 (Debian 13.9-0+deb11u1)
            -- Dumped by pg_dump version 13.9 (Debian 13.9-0+deb11u1)

            SET statement_timeout = 0;
            SET lock_timeout = 0;
            SET idle_in_transaction_session_timeout = 0;
            SET client_encoding = 'UTF8';
            SET standard_conforming_strings = on;
            SELECT pg_catalog.set_config('search_path', '', false);
            SET check_function_bodies = false;
            SET xmloption = content;
            SET client_min_messages = warning;
            SET row_security = off;

            --
            -- Name: export_csv(text, text); Type: FUNCTION; Schema: public; Owner: postgres
            --

            CREATE FUNCTION public.export_csv(name_tab text, ruta text) RETURNS void
                LANGUAGE plpgsql
                AS $$
            DECLARE
                name_tab TEXT;
            BEGIN
                FOR name_tab IN
                    SELECT table_name
                    FROM information_schema.tables
                    WHERE table_schema = 'public'
                    AND table_type = 'BASE TABLE'
                LOOP
                    EXECUTE format (
                        'COPY %I TO %L WITH (FORMAT CSV, DELIMITER '','', HEADER TRUE)', name_tab, ruta || name_tab || '.csv'
                    );
                END LOOP;
            END;
            $$;


            ALTER FUNCTION public.export_csv(name_tab text, ruta text) OWNER TO postgres;

            SET default_tablespace = '';

            SET default_table_access_method = heap;

            --
            -- Name: jockeys; Type: TABLE; Schema: public; Owner: usuario1
            --

            CREATE TABLE public.jockeys (
                dni character varying(9) NOT NULL,
                apellidos character varying(20),
                nombre character varying(15),
                peso numeric(4,2),
                altura numeric(3,2),
                telefono character varying(10)
            );


            ALTER TABLE public.jockeys OWNER TO usuario1;

            --
            -- Name: propietarios; Type: TABLE; Schema: public; Owner: postgres
            --

            CREATE TABLE public.propietarios (
                nif character varying(9) NOT NULL,
                nombre character varying(15),
                apellidos character varying(20),
                cuota numeric(6,2)
            );


            ALTER TABLE public.propietarios OWNER TO postgres;

            --
            -- Data for Name: jockeys; Type: TABLE DATA; Schema: public; Owner: usuario1
            --

            COPY public.jockeys (dni, apellidos, nombre, peso, altura, telefono) FROM stdin;
            77260496T	Gonzalez Reyes	Victor	55.00	1.68	657983401
            18393815W	Baquero Begines	Maria	53.00	1.58	649239153
            86402430D	Lauda Perez	Juan	50.00	1.63	629108927
            62550577F	Vaca Ferreras	Alvaro	50.00	1.47	674327184
            24246622E	Caliani Valle	Carlos	56.00	1.55	643892743
            \.


            --
            -- Data for Name: propietarios; Type: TABLE DATA; Schema: public; Owner: postgres
            --

            COPY public.propietarios (nif, nombre, apellidos, cuota) FROM stdin;
            61219065B	Mario	Gutiérrez Valencia	300.00
            20015195C	Alexandra	Angulo Lamas	320.00
            19643077L	Miriam	Zafra Valencia	45.00
            33599573T	Josue	Reche de los Santos	50.00
            X4164637G	Christian	Lopez Reyes	50.00
            \.


            --
            -- Name: jockeys pk_jockeys; Type: CONSTRAINT; Schema: public; Owner: usuario1
            --

            ALTER TABLE ONLY public.jockeys
                ADD CONSTRAINT pk_jockeys PRIMARY KEY (dni);


            --
            -- Name: propietarios pk_propietarios; Type: CONSTRAINT; Schema: public; Owner: postgres
            --

            ALTER TABLE ONLY public.propietarios
                ADD CONSTRAINT pk_propietarios PRIMARY KEY (nif);


            --
            -- PostgreSQL database dump complete
            --


* Podemos añadir algunas opciones, vamos a ver las mas interesantes, como:

`-a`: Solo exportará los datos, no el esquema de las tablas.

`-c`: Podemos añadir algunas consultas para filtrar los datos.

`-C`: Añadirá algunas ordenes extra, como ALTER TABLE, SET, ALTER ROLE, etc...

`-F`: Con esta opción podremos especificar el formato de salida del fichero resultante entre los que se incluye la opción de que sea un fichero comprimido.

`-h`: El hostname de la base de datos.

`-n`: Esquema que queremos exportar.

`-N`: Excluir un esquema específico.

`-s`: Solo exporta el esquema, no los datos.

`-t`: Tabla específica que queremos exportar.

`-T`: Tabla específica que queremos excluir.

`-v`: Muestra información durante el proceso.

`-Z`: Comprime con gpiz.

* Hay muchos mas, pero estos son los que he considerado más interesantes.

* También podemos usar la siguiente variante para realizar una copia de la base de datos completa:

~~~
postgres@postgresagv:~$ pg_dumpall > pruebatotal.bak
~~~

* Vemos el fichero resultante.

            postgres@postgresagv:~$ cat pruebatotal.bak 
            --
            -- PostgreSQL database cluster dump
            --

            SET default_transaction_read_only = off;

            SET client_encoding = 'UTF8';
            SET standard_conforming_strings = on;

            --
            -- Roles
            --

            CREATE ROLE postgres;
            ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS;
            CREATE ROLE raul;
            ALTER ROLE raul WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'md5807dea4f78fa1de254efdb5846b603bd';
            CREATE ROLE usuario1;
            ALTER ROLE usuario1 WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'md5965e5ac260512ff6693906e07332c4a7';






            --
            -- Databases
            --

            --
            -- Database "template1" dump
            --

            \connect template1

            --
            -- PostgreSQL database dump
            --

            -- Dumped from database version 13.9 (Debian 13.9-0+deb11u1)
            -- Dumped by pg_dump version 13.9 (Debian 13.9-0+deb11u1)

            SET statement_timeout = 0;
            SET lock_timeout = 0;
            SET idle_in_transaction_session_timeout = 0;
            SET client_encoding = 'UTF8';
            SET standard_conforming_strings = on;
            SELECT pg_catalog.set_config('search_path', '', false);
            SET check_function_bodies = false;
            SET xmloption = content;
            SET client_min_messages = warning;
            SET row_security = off;

            --
            -- PostgreSQL database dump complete
            --

            --
            -- Database "gn2" dump
            --

            --
            -- PostgreSQL database dump
            --

            -- Dumped from database version 13.9 (Debian 13.9-0+deb11u1)
            -- Dumped by pg_dump version 13.9 (Debian 13.9-0+deb11u1)

            SET statement_timeout = 0;
            SET lock_timeout = 0;
            SET idle_in_transaction_session_timeout = 0;
            SET client_encoding = 'UTF8';
            SET standard_conforming_strings = on;
            SELECT pg_catalog.set_config('search_path', '', false);
            SET check_function_bodies = false;
            SET xmloption = content;
            SET client_min_messages = warning;
            SET row_security = off;

            --
            -- Name: gn2; Type: DATABASE; Schema: -; Owner: postgres
            --

            CREATE DATABASE gn2 WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'C.UTF-8';


            ALTER DATABASE gn2 OWNER TO postgres;

            \connect gn2

            SET statement_timeout = 0;
            SET lock_timeout = 0;
            SET idle_in_transaction_session_timeout = 0;
            SET client_encoding = 'UTF8';
            SET standard_conforming_strings = on;
            SELECT pg_catalog.set_config('search_path', '', false);
            SET check_function_bodies = false;
            SET xmloption = content;
            SET client_min_messages = warning;
            SET row_security = off;

            SET default_tablespace = '';

            SET default_table_access_method = heap;

            --
            -- Name: asignaturas; Type: TABLE; Schema: public; Owner: raul
            --

            CREATE TABLE public.asignaturas (
                nombre character varying(20),
                dni_profesor character varying(20) NOT NULL
            );


            ALTER TABLE public.asignaturas OWNER TO raul;

            --
            -- Data for Name: asignaturas; Type: TABLE DATA; Schema: public; Owner: raul
            --

            COPY public.asignaturas (nombre, dni_profesor) FROM stdin;
            ASO	28888888
            ABD	27777777
            \.


            --
            -- Name: asignaturas pk_examen; Type: CONSTRAINT; Schema: public; Owner: raul
            --

            ALTER TABLE ONLY public.asignaturas
                ADD CONSTRAINT pk_examen PRIMARY KEY (dni_profesor);


            --
            -- Name: DATABASE gn2; Type: ACL; Schema: -; Owner: postgres
            --

            GRANT ALL ON DATABASE gn2 TO raul;


            --
            -- PostgreSQL database dump complete
            --

            --
            -- Database "postgres" dump
            --

            \connect postgres

            --
            -- PostgreSQL database dump
            --

            -- Dumped from database version 13.9 (Debian 13.9-0+deb11u1)
            -- Dumped by pg_dump version 13.9 (Debian 13.9-0+deb11u1)

            SET statement_timeout = 0;
            SET lock_timeout = 0;
            SET idle_in_transaction_session_timeout = 0;
            SET client_encoding = 'UTF8';
            SET standard_conforming_strings = on;
            SELECT pg_catalog.set_config('search_path', '', false);
            SET check_function_bodies = false;
            SET xmloption = content;
            SET client_min_messages = warning;
            SET row_security = off;

            --
            -- Name: dblink; Type: EXTENSION; Schema: -; Owner: -
            --

            CREATE EXTENSION IF NOT EXISTS dblink WITH SCHEMA public;


            --
            -- Name: EXTENSION dblink; Type: COMMENT; Schema: -; Owner: 
            --

            COMMENT ON EXTENSION dblink IS 'connect to other PostgreSQL databases from within a database';


            --
            -- PostgreSQL database dump complete
            --

            --
            -- Database "prueba" dump
            --

            --
            -- PostgreSQL database dump
            --

            -- Dumped from database version 13.9 (Debian 13.9-0+deb11u1)
            -- Dumped by pg_dump version 13.9 (Debian 13.9-0+deb11u1)

            SET statement_timeout = 0;
            SET lock_timeout = 0;
            SET idle_in_transaction_session_timeout = 0;
            SET client_encoding = 'UTF8';
            SET standard_conforming_strings = on;
            SELECT pg_catalog.set_config('search_path', '', false);
            SET check_function_bodies = false;
            SET xmloption = content;
            SET client_min_messages = warning;
            SET row_security = off;

            --
            -- Name: prueba; Type: DATABASE; Schema: -; Owner: postgres
            --

            CREATE DATABASE prueba WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'C.UTF-8';


            ALTER DATABASE prueba OWNER TO postgres;

            \connect prueba

            SET statement_timeout = 0;
            SET lock_timeout = 0;
            SET idle_in_transaction_session_timeout = 0;
            SET client_encoding = 'UTF8';
            SET standard_conforming_strings = on;
            SELECT pg_catalog.set_config('search_path', '', false);
            SET check_function_bodies = false;
            SET xmloption = content;
            SET client_min_messages = warning;
            SET row_security = off;

            --
            -- Name: export_csv(text, text); Type: FUNCTION; Schema: public; Owner: postgres
            --

            CREATE FUNCTION public.export_csv(name_tab text, ruta text) RETURNS void
                LANGUAGE plpgsql
                AS $$
            DECLARE
                name_tab TEXT;
            BEGIN
                FOR name_tab IN
                    SELECT table_name
                    FROM information_schema.tables
                    WHERE table_schema = 'public'
                    AND table_type = 'BASE TABLE'
                LOOP
                    EXECUTE format (
                        'COPY %I TO %L WITH (FORMAT CSV, DELIMITER '','', HEADER TRUE)', name_tab, ruta || name_tab || '.csv'
                    );
                END LOOP;
            END;
            $$;


            ALTER FUNCTION public.export_csv(name_tab text, ruta text) OWNER TO postgres;

            SET default_tablespace = '';

            SET default_table_access_method = heap;

            --
            -- Name: jockeys; Type: TABLE; Schema: public; Owner: usuario1
            --

            CREATE TABLE public.jockeys (
                dni character varying(9) NOT NULL,
                apellidos character varying(20),
                nombre character varying(15),
                peso numeric(4,2),
                altura numeric(3,2),
                telefono character varying(10)
            );


            ALTER TABLE public.jockeys OWNER TO usuario1;

            --
            -- Name: propietarios; Type: TABLE; Schema: public; Owner: postgres
            --

            CREATE TABLE public.propietarios (
                nif character varying(9) NOT NULL,
                nombre character varying(15),
                apellidos character varying(20),
                cuota numeric(6,2)
            );


            ALTER TABLE public.propietarios OWNER TO postgres;

            --
            -- Data for Name: jockeys; Type: TABLE DATA; Schema: public; Owner: usuario1
            --

            COPY public.jockeys (dni, apellidos, nombre, peso, altura, telefono) FROM stdin;
            77260496T	Gonzalez Reyes	Victor	55.00	1.68	657983401
            18393815W	Baquero Begines	Maria	53.00	1.58	649239153
            86402430D	Lauda Perez	Juan	50.00	1.63	629108927
            62550577F	Vaca Ferreras	Alvaro	50.00	1.47	674327184
            24246622E	Caliani Valle	Carlos	56.00	1.55	643892743
            \.


            --
            -- Data for Name: propietarios; Type: TABLE DATA; Schema: public; Owner: postgres
            --

            COPY public.propietarios (nif, nombre, apellidos, cuota) FROM stdin;
            61219065B	Mario	Gutiérrez Valencia	300.00
            20015195C	Alexandra	Angulo Lamas	320.00
            19643077L	Miriam	Zafra Valencia	45.00
            33599573T	Josue	Reche de los Santos	50.00
            X4164637G	Christian	Lopez Reyes	50.00
            \.


            --
            -- Name: jockeys pk_jockeys; Type: CONSTRAINT; Schema: public; Owner: usuario1
            --

            ALTER TABLE ONLY public.jockeys
                ADD CONSTRAINT pk_jockeys PRIMARY KEY (dni);


            --
            -- Name: propietarios pk_propietarios; Type: CONSTRAINT; Schema: public; Owner: postgres
            --

            ALTER TABLE ONLY public.propietarios
                ADD CONSTRAINT pk_propietarios PRIMARY KEY (nif);


            --
            -- PostgreSQL database dump complete
            --

            --
            -- PostgreSQL database cluster dump complete
            --

* Hasta ahora hemos vista las copias de tipo lógicas, pero tenemos la posibilidad de hacer una copia física. El siguiente comando creará una copia de seguirdad en el directorio `backups` que recién hemos creado en formato gzip y con sus fichero wal, necesarios para la restauración más adelante.

~~~
postgres@postgresagv:~$ pg_basebackup -D /var/lib/postgresql/backups/ -Ft -z -Xs -P
Password: 
40219/40219 kB (100%), 1/1 tablespace
~~~

* Veamos la carpeta de backups

~~~
postgres@postgresagv:~$ ls backups/
backup_manifest  base.tar.gz  pg_wal.tar.gz
~~~

* Si quisieramos programar cualquiera de estas tareas deberiamos usar crontab.

~~~
postgres@postgresagv:~$ crontab -e
~~~

* Y añadimos la siguiente línea que creará un backup lógico semanal:

~~~
0 0 * * 0 pg_dumpall > /var/lib/postgres/backups/backupsemanal-$(date +"%d%m%Y").bak
~~~

### RESTAURACIÓN

* Para restaurar una copia lógica es muy sencillo, veamoslo:

~~~
postgres@bullseye:~$ psql -f pruebatotal.bak postgres
~~~

* Comprobamos que se ha realizado la importación.

~~~
prueba=# select * from jockeys 
prueba-# ;
    dni    |    apellidos    | nombre | peso  | altura | telefono  
-----------+-----------------+--------+-------+--------+-----------
 77260496T | Gonzalez Reyes  | Victor | 55.00 |   1.68 | 657983401
 18393815W | Baquero Begines | Maria  | 53.00 |   1.58 | 649239153
 86402430D | Lauda Perez     | Juan   | 50.00 |   1.63 | 629108927
 62550577F | Vaca Ferreras   | Alvaro | 50.00 |   1.47 | 674327184
 24246622E | Caliani Valle   | Carlos | 56.00 |   1.55 | 643892743
(5 rows)
~~~

7. Documenta el empleo de las herramientas de copia de seguridad y restauración de MySQL.

* Nuevamente tenemos varias formas, sin embargo, la que usamos durante la práctica de movimiento de datos es la mas sencilla y efectiva. Que es mediante el uso de `mysqldump`

* Vamos a ver un ejemplo sencillo de una copia de una base de datos.

~~~
mysqldump -u root -p empresa --log-error=/home/alejandrogv/Escritorio/ASIR/logfile.log > /home/alejandrogv/Escritorio/ASIR/exportacion.sql
~~~

* La orden anterior haría una copia de todos los objetos dentro de la base de datos `empresa` y a parte crear un fichero de log bastante útil si hay problemas.

* Veamos como hacer una copia de todas las bases de datos.

~~~
mysqldump -u root --all-databases --log-error=/home/alejandrogv/Escritorio/ASIR/logfile.log > /home/alejandrogv/Escritorio/ASIR/exportaciontotal.sql
~~~

* Como en postgres, tenemos muchisimos otros parametros. Vamos a ver nuevamente los que me han parecido mas interesantes y útiles.

`-u`: Usuario al que nos conectaremos para realizar la copia.

`-p`: En caso de realizar la copia a una sola base de datos, este parametro nos permite especificar cual.

`--add-drop-database`: Antes de cada sentencia **CREATE DATABASE** añade una **DROP DATABASE** lo cual es útil por si tenemos una base de datos creada con el mismo nombre en nuestro gestor.

`--add-drop-table`: Tiene la misma función y utilidad que la anterior, pero en este caso con las tablas.

`-B`: Nos permite especificar mas de una base de datos.

`-e`: Usa **INSERT** en su formato de multiples registros, por tanto la salida será más limpia y se acelerará el proceso. Ideal para grandes volumenes de registros.

`-f`: Forza continuar con el proceso en caso de fallo.

`-h`: Donde especificamos el hostname de la base de datos a copiar.

`--ignore-table=xxx`: Para poder excluir una tabla.

`-n`: Elimina las sentencias **CREATE DATABASE**.

`-d`: Solo copia los esquemas, no los registros.

`-R`: Se añadirían los procedimientos y funciones de nuestro esquema.

`--triggers`: Se añadirán los triggers.

`-v`: Da información de lo que está pasando durante el proceso.

* Nuevamente podemos usar contrab para automatizarlo.

~~~
root@alepeteporico:~# crontab -e

0 0 * * 0 mysqldump -u root --all-databases --log-error=/home/alejandrogv/Escritorio/ASIR/logfile.log > /home/alejandrogv/Escritorio/ASIR/backupsemanal-$(date +"%d%m%Y").sql
~~~

### RESTAURACIÓN

* Realizamos la copia de todas las bases de datos.

~~~
root@alepeteporico:~# mysqldump -u root --all-databases --add-drop-database --add-drop-table --log-error=/home/alejandrogv/Escritorio/ASIR/logfile.log > /home/alejandrogv/Escritorio/ASIR/exportaciontotal.sql
~~~

* Y la restauramos de forma sencilla.

~~~
root@alepeteporico:~# mysql -u root < /home/alejandrogv/Escritorio/ASIR/exportaciontotal.sql
~~~

* Entramos y comprobamos que todo sigue igual.

~~~
root@alepeteporico:~# mysql -u root
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 32
Server version: 10.5.18-MariaDB-0+deb11u1 Debian 11

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> use empresa
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
MariaDB [empresa]> select * from emp;
+-------+--------+-----------+------+------------+------+------+--------+
| EMPNO | ENAME  | JOB       | MGR  | HIREDATE   | SAL  | COMM | DEPTNO |
+-------+--------+-----------+------+------------+------+------+--------+
|  7369 | SMITH  | CLERK     | 7902 | 1980-12-17 |  800 | NULL |     20 |
|  7499 | ALLEN  | SALESMAN  | 7698 | 1981-02-20 | 1600 |  300 |     30 |
|  7521 | WARD   | SALESMAN  | 7698 | 1981-02-22 | 1250 |  500 |     30 |
|  7566 | JONES  | MANAGER   | 7839 | 1981-04-02 | 2975 | NULL |     20 |
|  7654 | MARTIN | SALESMAN  | 7698 | 1981-09-28 | 1250 | 1400 |     30 |
|  7698 | BLAKE  | MANAGER   | 7839 | 1981-05-01 | 2850 | NULL |     30 |
|  7782 | CLARK  | MANAGER   | 7839 | 1981-06-09 | 2450 | NULL |     10 |
|  7788 | SCOTT  | ANALYST   | 7566 | 1982-12-09 | 3000 | NULL |     20 |
|  7839 | KING   | PRESIDENT | NULL | 1981-11-17 | 5000 | NULL |     10 |
|  7844 | TURNER | SALESMAN  | 7698 | 1980-09-08 | 1500 |    0 |     30 |
|  7876 | ADAMS  | CLERK     | 7788 | 1983-01-12 | 1100 | NULL |     20 |
|  7900 | JAMES  | CLERK     | 7698 | 1981-12-03 |  950 | NULL |     30 |
|  7902 | FORD   | ANALYST   | 7566 | 1981-12-03 | 3000 | NULL |     20 |
|  7934 | MILLER | CLERK     | 7782 | 1982-01-23 | 1300 | NULL |     10 |
|  7322 | JUAN   | CHAPERO   | 7902 | 1980-12-17 |  800 | NULL |     20 |
+-------+--------+-----------+------+------------+------+------+--------+
15 rows in set (0,000 sec)
~~~

8. Documenta el empleo de las herramientas de copia de seguridad y restauración de MongoDB.

* Nuevamente tenemos una herramienta para realizar copias de seguirdad en mongo llamada `mongodump`. Vamos a ver como realizar una copia de una sola colección.

~~~
vagrant@mongoagv:~$ mongodump -d nobel -o backups/nobel_`date +"%Y%m%d_%H%M%S"`
2023-03-06T21:14:33.181+0000	writing nobel.premios to backups/nobel_20230306_211433/nobel/premios.bson
2023-03-06T21:14:33.184+0000	done dumping nobel.premios (658 documents)
~~~

* Y para hacer una copia total de todas las bases de datos.

~~~
vagrant@mongoagv:~$ mongodump -o backups/total_`date +"%Y%m%d_%H%M%S"`
2023-03-06T21:15:22.004+0000	writing admin.system.users to backups/total_20230306_211521/admin/system.users.bson
2023-03-06T21:15:22.005+0000	done dumping admin.system.users (1 document)
2023-03-06T21:15:22.005+0000	writing admin.system.version to backups/total_20230306_211521/admin/system.version.bson
2023-03-06T21:15:22.005+0000	done dumping admin.system.version (2 documents)
2023-03-06T21:15:22.006+0000	writing nobel.premios to backups/total_20230306_211521/nobel/premios.bson
2023-03-06T21:15:22.007+0000	writing prueba.libros to backups/total_20230306_211521/prueba/libros.bson
2023-03-06T21:15:22.010+0000	done dumping prueba.libros (6 documents)
2023-03-06T21:15:22.011+0000	done dumping nobel.premios (658 documents)
~~~

* Vemos las copias que hemos hecho:

~~~
vagrant@mongoagv:~$ tree backups/
backups/
├── nobel_20230306_211433
│   └── nobel
│       ├── premios.bson
│       └── premios.metadata.json
└── total_20230306_211521
    ├── admin
    │   ├── system.users.bson
    │   ├── system.users.metadata.json
    │   ├── system.version.bson
    │   └── system.version.metadata.json
    ├── nobel
    │   ├── premios.bson
    │   └── premios.metadata.json
    └── prueba
        ├── libros.bson
        └── libros.metadata.json
~~~

* Nuevamente podemos hacer uso de contrab para realizar una copia periodica.

~~~
crontab -e

0 0 * * 0 mongodump -o /home/vagrant/backups/total_`date +"%Y%m%d_%H%M%S"`
~~~

### RESTAURACIÓN:

* Vamos a realizar la restauración de una de las colecciones.

~~~
vagrant@mongoagv:~$ mongorestore --db pruebarecuperacion --verbose backups/total_20230306_211521/prueba/
2023-03-06T21:29:24.969+0000	using write concern: &{majority false 0}
2023-03-06T21:29:24.991+0000	The --db and --collection flags are deprecated for this use-case; please use --nsInclude instead, i.e. with --nsInclude=${DATABASE}.${COLLECTION}
2023-03-06T21:29:24.991+0000	building a list of collections to restore from backups/total_20230306_211521/prueba dir
2023-03-06T21:29:24.991+0000	found collection pruebarecuperacion.libros bson to restore to pruebarecuperacion.libros
2023-03-06T21:29:24.991+0000	found collection metadata from pruebarecuperacion.libros to restore to pruebarecuperacion.libros
2023-03-06T21:29:24.991+0000	reading metadata for pruebarecuperacion.libros from backups/total_20230306_211521/prueba/libros.metadata.json
2023-03-06T21:29:24.993+0000	creating collection pruebarecuperacion.libros with no metadata
2023-03-06T21:29:25.038+0000	restoring pruebarecuperacion.libros from backups/total_20230306_211521/prueba/libros.bson
2023-03-06T21:29:25.058+0000	finished restoring pruebarecuperacion.libros (6 documents, 0 failures)
2023-03-06T21:29:25.058+0000	no indexes to restore for collection pruebarecuperacion.libros
2023-03-06T21:29:25.058+0000	6 document(s) restored successfully. 0 document(s) failed to restore.
~~~

* Si queremos recuperar solo una colección usaremos lo siguiente:

~~~
vagrant@mongoagv:~$ mongorestore --db pruebarecuperacion2 --collection coleccion1 --verbose backups/total_20230306_211521/prueba/libros.bson 
2023-03-06T21:31:53.469+0000	using write concern: &{majority false 0}
2023-03-06T21:31:53.472+0000	checking for collection data in backups/total_20230306_211521/prueba/libros.bson
2023-03-06T21:31:53.472+0000	found metadata for collection at backups/total_20230306_211521/prueba/libros.metadata.json
2023-03-06T21:31:53.472+0000	reading metadata for pruebarecuperacion2.coleccion1 from backups/total_20230306_211521/prueba/libros.metadata.json
2023-03-06T21:31:53.472+0000	creating collection pruebarecuperacion2.coleccion1 with no metadata
2023-03-06T21:31:53.509+0000	restoring pruebarecuperacion2.coleccion1 from backups/total_20230306_211521/prueba/libros.bson
2023-03-06T21:31:53.558+0000	finished restoring pruebarecuperacion2.coleccion1 (6 documents, 0 failures)
2023-03-06T21:31:53.558+0000	no indexes to restore for collection pruebarecuperacion2.coleccion1
2023-03-06T21:31:53.558+0000	6 document(s) restored successfully. 0 document(s) failed to restore.
~~~
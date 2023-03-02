+++
title = "Movimiento de datos"
description = ""
tags = [
    "GBD"
]
date = "2023-02-22"
menu = "main"
+++

1. Realiza una exportación del esquema de SCOTT usando Oracle Data Pump con las siguientes condiciones:

**Exporta tanto la estructura de las tablas como los datos de las mismas.**

**Excluye la tabla BONUS y los departamentos con menos de dos empleados.**

**Realiza una estimación previa del tamaño necesario para el fichero de exportación.**

**Programa la operación para dentro de 2 minutos.**

**Genera un archivo de log en el directorio raíz.**


* En primer lugar vamos a ver la ayuda del comando `expdp` que será el que usemos para exportar el esquema y también lo usaremos a posterior.

~~~
vagrant@oracleagv:~$ expdp HELP=Y

Export: Release 19.0.0.0.0 - Production on Wed Feb 22 07:53:37 2023
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.


The Data Pump export utility provides a mechanism for transferring data objects
between Oracle databases. The utility is invoked with the following command:

   Example: expdp scott/tiger DIRECTORY=dmpdir DUMPFILE=scott.dmp

You can control how Export runs by entering the 'expdp' command followed
by various parameters. To specify parameters, you use keywords:

   Format:  expdp KEYWORD=value or KEYWORD=(value1,value2,...,valueN)
   Example: expdp scott/tiger DUMPFILE=scott.dmp DIRECTORY=dmpdir SCHEMAS=scott
               or TABLES=(T1:P1,T1:P2), if T1 is partitioned table

USERID must be the first parameter on the command line.

------------------------------------------------------------------------------

The available keywords and their descriptions follow. Default values are listed within square brackets.

ABORT_STEP
Stop the job after it is initialized or at the indicated object.
Valid values are -1 or N where N is zero or greater.
N corresponds to the object's process order number in the master table.

ACCESS_METHOD
Instructs Export to use a particular method to unload data.
Valid keyword values are: [AUTOMATIC], DIRECT_PATH and EXTERNAL_TABLE.

ATTACH
Attach to an existing job.
For example, ATTACH=job_name.

CLUSTER
Utilize cluster resources and distribute workers across the Oracle RAC [YES].

COMPRESSION
Reduce the size of a dump file.
Valid keyword values are: ALL, DATA_ONLY, [METADATA_ONLY] and NONE.

COMPRESSION_ALGORITHM
Specify the compression algorithm that should be used.
Valid keyword values are: [BASIC], LOW, MEDIUM and HIGH.

CONTENT
Specifies data to unload.
Valid keyword values are: [ALL], DATA_ONLY and METADATA_ONLY.

DATA_OPTIONS
Data layer option flags.
Valid keyword values are: GROUP_PARTITION_TABLE_DATA, VERIFY_STREAM_FORMAT and XML_CLOBS.

DIRECTORY
Directory object to be used for dump and log files.

DUMPFILE
Specify list of destination dump file names [expdat.dmp].
For example, DUMPFILE=scott1.dmp, scott2.dmp, dmpdir:scott3.dmp.

ENCRYPTION
Encrypt part or all of a dump file.
Valid keyword values are: ALL, DATA_ONLY, ENCRYPTED_COLUMNS_ONLY, METADATA_ONLY and NONE.

ENCRYPTION_ALGORITHM
Specify how encryption should be done.
Valid keyword values are: [AES128], AES192 and AES256.

ENCRYPTION_MODE
Method of generating encryption key.
Valid keyword values are: DUAL, PASSWORD and [TRANSPARENT].

ENCRYPTION_PASSWORD
Password key for creating encrypted data within a dump file.

ENCRYPTION_PWD_PROMPT
Specifies whether to prompt for the encryption password [NO].
Terminal echo will be suppressed while standard input is read.

ESTIMATE
Calculate job estimates.
Valid keyword values are: [BLOCKS] and STATISTICS.

ESTIMATE_ONLY
Calculate job estimates without performing the export [NO].

EXCLUDE
Exclude specific object types.
For example, EXCLUDE=SCHEMA:"='HR'".

FILESIZE
Specify the size of each dump file in units of bytes.

FLASHBACK_SCN
SCN used to reset session snapshot.

FLASHBACK_TIME
Time used to find the closest corresponding SCN value.

FULL
Export entire database [NO].

HELP
Display Help messages [NO].

INCLUDE
Include specific object types.
For example, INCLUDE=TABLE_DATA.

JOB_NAME
Name of export job to create.

KEEP_MASTER
Retain the master table after an export job that completes successfully [NO].

LOGFILE
Specify log file name [export.log].

LOGTIME
Specifies that messages displayed during export operations be timestamped.
Valid keyword values are: ALL, [NONE], LOGFILE and STATUS.

METRICS
Report additional job information to the export log file [NO].

NETWORK_LINK
Name of remote database link to the source system.

NOLOGFILE
Do not write log file [NO].

PARALLEL
Change the number of active workers for current job.

PARFILE
Specify parameter file name.

QUERY
Predicate clause used to export a subset of a table.
For example, QUERY=employees:"WHERE department_id > 10".

REMAP_DATA
Specify a data conversion function.
For example, REMAP_DATA=EMP.EMPNO:REMAPPKG.EMPNO.

REUSE_DUMPFILES
Overwrite destination dump file if it exists [NO].

SAMPLE
Percentage of data to be exported. 

SCHEMAS
List of schemas to export [login schema].

SERVICE_NAME
Name of an active Service and associated resource group to constrain Oracle RAC resources.

SOURCE_EDITION
Edition to be used for extracting metadata.

STATUS
Frequency (secs) job status is to be monitored where
the default [0] will show new status when available.

TABLES
Identifies a list of tables to export.
For example, TABLES=HR.EMPLOYEES,SH.SALES:SALES_1995.

TABLESPACES
Identifies a list of tablespaces to export.

TRANSPORTABLE
Specify whether transportable method can be used.
Valid keyword values are: ALWAYS and [NEVER].

TRANSPORT_FULL_CHECK
Verify storage segments of all tables [NO].

TRANSPORT_TABLESPACES
List of tablespaces from which metadata will be unloaded.

VERSION
Version of objects to export.
Valid keyword values are: [COMPATIBLE], LATEST or any valid database version.

VIEWS_AS_TABLES
Identifies one or more views to be exported as tables.
For example, VIEWS_AS_TABLES=HR.EMP_DETAILS_VIEW.

------------------------------------------------------------------------------

The following commands are valid while in interactive mode.
Note: abbreviations are allowed.

ADD_FILE
Add dumpfile to dumpfile set.

CONTINUE_CLIENT
Return to logging mode. Job will be restarted if idle.

EXIT_CLIENT
Quit client session and leave job running.

FILESIZE
Default filesize (bytes) for subsequent ADD_FILE commands.

HELP
Summarize interactive commands.

KILL_JOB
Detach and delete job.

PARALLEL
Change the number of active workers for current job.

REUSE_DUMPFILES
Overwrite destination dump file if it exists [NO]. 

START_JOB
Start or resume current job.
Valid keyword values are: SKIP_CURRENT.

STATUS
Frequency (secs) job status is to be monitored where
the default [0] will show new status when available.

STOP_JOB
Orderly shutdown of job execution and exits the client.
Valid keyword values are: IMMEDIATE.

STOP_WORKER
Stops a hung or stuck worker.

TRACE
Set trace/debug flags for the current job.
~~~

* Primero le damos permisos para crear directorios a SCOTT, que será el usuario que usemos para realizar la exportación.

~~~
SQL> GRANT CREATE ANY DIRECTORY TO SCOTT;

Grant succeeded.
~~~

* Seguidamente nos conectamos a SCOTT y creamos el directorio donde haremos la exportación.

~~~
SQL> connect SCOTT/TIGER
Connected.
SQL> CREATE DIRECTORY DATA_PUMP_EXPORT AS '/opt/oracle/admin/ORCLCDB/dpdump/';

Directory created.
~~~

* Para cumplir con el apartado que nos pide que la acción sea realiada dentro de dos minutos usaremos el comando `at` de linux que nos permitirá programar la tarea.

~~~
at now + 2 minutes
~~~

* El comando de exportación sería el siguiente:

~~~
expdp SCOTT/TIGER DUMPFILE=scott.dmp LOG=exportacionscott.log DIRECTORY=DATA_PUMP_EXPORT SCHEMAS=SCOTT EXCLUDE=TABLE:\"=\'BONUS\'\" ESTIMATE=BLOCKS QUERY=dept:'"WHERE deptno IN \(SELECT deptno FROM EMP GROUP BY deptno HAVING COUNT\(*\)>2\)"'
~~~

* Los dos conjuntados sería una cosa así:

~~~
vagrant@oracleagv:~$ at now + 2 minutes
warning: commands will be executed using /bin/sh
at> expdp SCOTT/TIGER DUMPFILE=scott.dmp LOG=exportacionscott.log DIRECTORY=DATA_PUMP_EXPORT SCHEMAS=SCOTT EXCLUDE=TABLE:\"=\'BONUS\'\" ESTIMATE=BLOCKS QUERY=dept:'"WHERE deptno IN \(SELECT deptno FROM EMP GROUP BY deptno HAVING COUNT\(*\)>2\)"'
at> <EOT>
job 1 at Sat Feb 25 18:46:00 2023
~~~

* Miramos en el log como se ha realizado el proceso.

~~~
vagrant@oracleagv:~$ sudo cat /opt/oracle/admin/ORCLCDB/dpdump/exportacionscott.log 
;;; 
Export: Release 19.0.0.0.0 - Production on Sat Feb 25 18:46:00 2023
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
;;; 
Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
;;; Legacy Mode Active due to the following parameters:
;;; Legacy Mode Parameter: "log=exportacionscott.log" Location: Command Line, Replaced with: "logfile=exportacionscott.log"
;;; Legacy Mode has set reuse_dumpfiles=true parameter.
Starting "SCOTT"."SYS_EXPORT_SCHEMA_01":  SCOTT/******** DUMPFILE=scott.dmp logfile=exportacionscott.log DIRECTORY=DATA_PUMP_EXPORT SCHEMAS=SCOTT EXCLUDE=TABLE:"='BONUS'" ESTIMATE=BLOCKS QUERY=dept:"WHERE deptno IN \(SELECT deptno FROM EMP GROUP BY deptno HAVING COUNT\(*\)>2\)" reuse_dumpfiles=true 
Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
.  estimated "SCOTT"."EMP"                               8.225 KB
.  estimated "SCOTT"."DEPT"                              4.683 KB
.  estimated "SCOTT"."DUMMY"                             4.683 KB
.  estimated "SCOTT"."SALGRADE"                          4.683 KB
Processing object type SCHEMA_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
Processing object type SCHEMA_EXPORT/TABLE/STATISTICS/TABLE_STATISTICS
Processing object type SCHEMA_EXPORT/STATISTICS/MARKER
Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA
Processing object type SCHEMA_EXPORT/TABLE/TABLE
Processing object type SCHEMA_EXPORT/TABLE/COMMENT
Processing object type SCHEMA_EXPORT/TABLE/INDEX/INDEX
. . exported "SCOTT"."EMP"                               8.851 KB      16 rows
. . exported "SCOTT"."DEPT"                                  6 KB       3 rows
. . exported "SCOTT"."DUMMY"                             5.054 KB       1 rows
. . exported "SCOTT"."SALGRADE"                          5.953 KB       5 rows
Master table "SCOTT"."SYS_EXPORT_SCHEMA_01" successfully loaded/unloaded
******************************************************************************
Dump file set for SCOTT.SYS_EXPORT_SCHEMA_01 is:
  /opt/oracle/admin/ORCLCDB/dpdump/scott.dmp
Job "SCOTT"."SYS_EXPORT_SCHEMA_01" successfully completed at Sat Feb 25 18:46:34 2023 elapsed 0 00:00:31
~~~

2. Importa el fichero obtenido anteriormente usando Oracle Data Pump pero en un usuario distinto de la misma base de datos.

* Le damos permisos sobre el directorio al usuario en el que importaremos el esquema.

~~~
SQL> GRANT READ,WRITE ON DIRECTORY DATA_PUMP_EXPORT TO PRUEBA;                          

Grant succeeded.
~~~

* Realizamos la importación.

~~~
vagrant@oracleagv:~$ impdp PRUEBA/PRUEBA dumpfile=scott.dmp schemas=SCOTT directory=DATA_PUMP_EXPORT remap_schema=SCOTT:PRUEBA

Import: Release 19.0.0.0.0 - Production on Sat Feb 25 19:30:47 2023
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production

Warning: Oracle Data Pump operations are not typically needed when connected to the root or seed of a container database.

Master table "PRUEBA"."SYS_IMPORT_SCHEMA_01" successfully loaded/unloaded
Starting "PRUEBA"."SYS_IMPORT_SCHEMA_01":  PRUEBA/******** dumpfile=scott.dmp schemas=SCOTT directory=DATA_PUMP_EXPORT remap_schema=SCOTT:PRUEBA 
Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA
Processing object type SCHEMA_EXPORT/TABLE/TABLE
Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
. . imported "PRUEBA"."EMP"                              8.851 KB      16 rows
. . imported "PRUEBA"."DEPT"                                 6 KB       3 rows
. . imported "PRUEBA"."DUMMY"                            5.054 KB       1 rows
. . imported "PRUEBA"."SALGRADE"                         5.953 KB       5 rows
Processing object type SCHEMA_EXPORT/TABLE/STATISTICS/TABLE_STATISTICS
Processing object type SCHEMA_EXPORT/STATISTICS/MARKER
Job "PRUEBA"."SYS_IMPORT_SCHEMA_01" successfully completed at Sat Feb 25 19:31:02 2023 elapsed 0 00:00:13
~~~

* Entramos la usuario y comprobamos que podemos acceder a la inforación de el esquema de SCOTT.

~~~
SQL> connect PRUEBA/PRUEBA
Connected.

SQL> select * from dept;

    DEPTNO DNAME	  LOC
---------- -------------- -------------
	10 ACCOUNTING	  NEW YORK
	20 RESEARCH	  DALLAS
	30 SALES	  CHICAGO
~~~

3. Realiza una exportación de la estructura de todas las tablas de la base de datos usando el comando expdp de Oracle Data Pump probando al menos cinco de las posibles opciones que ofrece dicho comando y documentándolas adecuadamente.

* Para realizar esta tarea el usuario `SYSTEM` debe tener una contraseña.

~~~
SQL> ALTER USER SYSTEM IDENTIFIED BY SYSTEM
~~~

* Ahora vamos realizar la exportación y desglosaremos cada una de las opciones que hemos añadido.

~~~
vagrant@oracleagv:~$ expdp SYSTEM/SYSTEM DUMPFILE=total.dmp FULL=y LOG=total.log CONTENT=METADATA_ONLY ENCRYPTION_PASSWORD=3Xp0Rt4C10nT0t4L

Export: Release 19.0.0.0.0 - Production on Sat Feb 25 19:58:16 2023
Version 19.3.0.0.0

Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Legacy Mode Active due to the following parameters:
Legacy Mode Parameter: "log=total.log" Location: Command Line, Replaced with: "logfile=total.log"
Legacy Mode has set reuse_dumpfiles=true parameter.

Warning: Oracle Data Pump operations are not typically needed when connected to the root or seed of a container database.

Starting "SYSTEM"."SYS_EXPORT_FULL_01":  SYSTEM/******** DUMPFILE=total.dmp FULL=y logfile=total.log CONTENT=METADATA_ONLY ENCRYPTION_PASSWORD=******** reuse_dumpfiles=true 
Processing object type DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE_DATA
Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE_DATA
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
Processing object type DATABASE_EXPORT/SCHEMA/TABLESPACE_QUOTA
Processing object type DATABASE_EXPORT/RESOURCE_COST
Processing object type DATABASE_EXPORT/TRUSTED_DB_LINK
Processing object type DATABASE_EXPORT/DIRECTORY/DIRECTORY
Processing object type DATABASE_EXPORT/DIRECTORY/GRANT/OWNER_GRANT/OBJECT_GRANT
Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PRE_SYSTEM_ACTIONS/PROCACT_SYSTEM
Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/PROCOBJ
Processing object type DATABASE_EXPORT/SYSTEM_PROCOBJACT/POST_SYSTEM_ACTIONS/PROCACT_SYSTEM
Processing object type DATABASE_EXPORT/SCHEMA/PROCACT_SCHEMA
Processing object type DATABASE_EXPORT/EARLY_OPTIONS/VIEWS_AS_TABLES/TABLE
Processing object type DATABASE_EXPORT/EARLY_POST_INSTANCE_IMPCALLOUT/MARKER
Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE
Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/VIEWS_AS_TABLES/TABLE
Processing object type DATABASE_EXPORT/NORMAL_POST_INSTANCE_IMPCALLOUT/MARKER
Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TABLE
Processing object type DATABASE_EXPORT/SCHEMA/TABLE/COMMENT
Processing object type DATABASE_EXPORT/SCHEMA/TABLE/FGA_POLICY
Processing object type DATABASE_EXPORT/SCHEMA/PROCEDURE/PROCEDURE
Processing object type DATABASE_EXPORT/SCHEMA/PROCEDURE/ALTER_PROCEDURE
Processing object type DATABASE_EXPORT/SCHEMA/TABLE/INDEX/INDEX
Processing object type DATABASE_EXPORT/SCHEMA/TABLE/CONSTRAINT/CONSTRAINT
Processing object type DATABASE_EXPORT/SCHEMA/TABLE/CONSTRAINT/REF_CONSTRAINT
Processing object type DATABASE_EXPORT/SCHEMA/TABLE/TRIGGER
Processing object type DATABASE_EXPORT/FINAL_POST_INSTANCE_IMPCALLOUT/MARKER
Processing object type DATABASE_EXPORT/SCHEMA/POST_SCHEMA/PROCACT_SCHEMA
Processing object type DATABASE_EXPORT/AUDIT_UNIFIED/AUDIT_POLICY_ENABLE
Processing object type DATABASE_EXPORT/AUDIT
Processing object type DATABASE_EXPORT/POST_SYSTEM_IMPCALLOUT/MARKER
. . exported "SYS"."KU$_USER_MAPPING_VIEW"               6.125 KB      40 rows
. . exported "AUDSYS"."AUD$UNIFIED":"SYS_P321"           245.1 KB     128 rows
. . exported "AUDSYS"."AUD$UNIFIED":"SYS_P181"           129.9 KB     159 rows
. . exported "AUDSYS"."AUD$UNIFIED":"SYS_P461"           63.63 KB      30 rows
. . exported "SYS"."AUD$"                                10.78 MB   84628 rows
. . exported "SYSTEM"."REDO_DB"                          25.60 KB       1 rows
. . exported "WMSYS"."WM$WORKSPACES_TABLE$"              12.11 KB       1 rows
. . exported "WMSYS"."WM$HINT_TABLE$"                    9.992 KB      97 rows
. . exported "LBACSYS"."OLS$INSTALLATIONS"               6.968 KB       2 rows
. . exported "WMSYS"."WM$WORKSPACE_PRIV_TABLE$"          7.085 KB      11 rows
. . exported "SYS"."DAM_CONFIG_PARAM$"                   6.539 KB      14 rows
. . exported "SYS"."TSDP_SUBPOL$"                        6.335 KB       1 rows
. . exported "WMSYS"."WM$NEXTVER_TABLE$"                 6.382 KB       1 rows
. . exported "LBACSYS"."OLS$PROPS"                       6.242 KB       5 rows
. . exported "WMSYS"."WM$ENV_VARS$"                      6.023 KB       3 rows
. . exported "SYS"."TSDP_PARAMETER$"                     5.960 KB       1 rows
. . exported "SYS"."TSDP_POLICY$"                        5.929 KB       1 rows
. . exported "WMSYS"."WM$VERSION_HIERARCHY_TABLE$"       5.992 KB       1 rows
. . exported "WMSYS"."WM$EVENTS_INFO$"                   5.820 KB      12 rows
. . exported "LBACSYS"."OLS$AUDIT_ACTIONS"               5.765 KB       8 rows
. . exported "LBACSYS"."OLS$DIP_EVENTS"                  5.546 KB       2 rows
. . exported "AUDSYS"."AUD$UNIFIED":"AUD_UNIFIED_P0"         0 KB       0 rows
. . exported "LBACSYS"."OLS$AUDIT"                           0 KB       0 rows
. . exported "LBACSYS"."OLS$COMPARTMENTS"                    0 KB       0 rows
. . exported "LBACSYS"."OLS$DIP_DEBUG"                       0 KB       0 rows
. . exported "LBACSYS"."OLS$GROUPS"                          0 KB       0 rows
. . exported "LBACSYS"."OLS$LAB"                             0 KB       0 rows
. . exported "LBACSYS"."OLS$LEVELS"                          0 KB       0 rows
. . exported "LBACSYS"."OLS$POL"                             0 KB       0 rows
. . exported "LBACSYS"."OLS$POLICY_ADMIN"                    0 KB       0 rows
. . exported "LBACSYS"."OLS$POLS"                            0 KB       0 rows
. . exported "LBACSYS"."OLS$POLT"                            0 KB       0 rows
. . exported "LBACSYS"."OLS$PROFILE"                         0 KB       0 rows
. . exported "LBACSYS"."OLS$PROFILES"                        0 KB       0 rows
. . exported "LBACSYS"."OLS$PROG"                            0 KB       0 rows
. . exported "LBACSYS"."OLS$SESSINFO"                        0 KB       0 rows
. . exported "LBACSYS"."OLS$USER"                            0 KB       0 rows
. . exported "LBACSYS"."OLS$USER_COMPARTMENTS"               0 KB       0 rows
. . exported "LBACSYS"."OLS$USER_GROUPS"                     0 KB       0 rows
. . exported "LBACSYS"."OLS$USER_LEVELS"                     0 KB       0 rows
. . exported "SYS"."DAM_CLEANUP_EVENTS$"                     0 KB       0 rows
. . exported "SYS"."DAM_CLEANUP_JOBS$"                       0 KB       0 rows
. . exported "SYS"."TSDP_ASSOCIATION$"                       0 KB       0 rows
. . exported "SYS"."TSDP_CONDITION$"                         0 KB       0 rows
. . exported "SYS"."TSDP_FEATURE_POLICY$"                    0 KB       0 rows
. . exported "SYS"."TSDP_PROTECTION$"                        0 KB       0 rows
. . exported "SYS"."TSDP_SENSITIVE_DATA$"                    0 KB       0 rows
. . exported "SYS"."TSDP_SENSITIVE_TYPE$"                    0 KB       0 rows
. . exported "SYS"."TSDP_SOURCE$"                            0 KB       0 rows
. . exported "SYSTEM"."REDO_LOG"                             0 KB       0 rows
. . exported "WMSYS"."WM$BATCH_COMPRESSIBLE_TABLES$"         0 KB       0 rows
. . exported "WMSYS"."WM$CONSTRAINTS_TABLE$"                 0 KB       0 rows
. . exported "WMSYS"."WM$CONS_COLUMNS$"                      0 KB       0 rows
. . exported "WMSYS"."WM$LOCKROWS_INFO$"                     0 KB       0 rows
. . exported "WMSYS"."WM$MODIFIED_TABLES$"                   0 KB       0 rows
. . exported "WMSYS"."WM$MP_GRAPH_WORKSPACES_TABLE$"         0 KB       0 rows
. . exported "WMSYS"."WM$MP_PARENT_WORKSPACES_TABLE$"        0 KB       0 rows
. . exported "WMSYS"."WM$NESTED_COLUMNS_TABLE$"              0 KB       0 rows
. . exported "WMSYS"."WM$RESOLVE_WORKSPACES_TABLE$"          0 KB       0 rows
. . exported "WMSYS"."WM$RIC_LOCKING_TABLE$"                 0 KB       0 rows
. . exported "WMSYS"."WM$RIC_TABLE$"                         0 KB       0 rows
. . exported "WMSYS"."WM$RIC_TRIGGERS_TABLE$"                0 KB       0 rows
. . exported "WMSYS"."WM$UDTRIG_DISPATCH_PROCS$"             0 KB       0 rows
. . exported "WMSYS"."WM$UDTRIG_INFO$"                       0 KB       0 rows
. . exported "WMSYS"."WM$VERSION_TABLE$"                     0 KB       0 rows
. . exported "WMSYS"."WM$VT_ERRORS_TABLE$"                   0 KB       0 rows
. . exported "WMSYS"."WM$WORKSPACE_SAVEPOINTS_TABLE$"        0 KB       0 rows
. . exported "MDSYS"."RDF_PARAM$"                        6.523 KB       3 rows
. . exported "SYS"."AUDTAB$TBS$FOR_EXPORT"               5.960 KB       2 rows
. . exported "SYS"."DBA_SENSITIVE_DATA"                      0 KB       0 rows
. . exported "SYS"."DBA_TSDP_POLICY_PROTECTION"              0 KB       0 rows
. . exported "SYS"."FGA_LOG$FOR_EXPORT"                  17.89 KB       1 rows
. . exported "SYS"."NACL$_ACE_EXP"                           0 KB       0 rows
. . exported "SYS"."NACL$_HOST_EXP"                      6.984 KB       2 rows
. . exported "SYS"."NACL$_WALLET_EXP"                        0 KB       0 rows
. . exported "SYS"."SQL$TEXT_DATAPUMP"                       0 KB       0 rows
. . exported "SYS"."SQL$_DATAPUMP"                           0 KB       0 rows
. . exported "SYS"."SQLOBJ$AUXDATA_DATAPUMP"                 0 KB       0 rows
. . exported "SYS"."SQLOBJ$DATA_DATAPUMP"                    0 KB       0 rows
. . exported "SYS"."SQLOBJ$PLAN_DATAPUMP"                    0 KB       0 rows
. . exported "SYS"."SQLOBJ$_DATAPUMP"                        0 KB       0 rows
. . exported "SYSTEM"."SCHEDULER_JOB_ARGS"                   0 KB       0 rows
. . exported "SYSTEM"."SCHEDULER_PROGRAM_ARGS"               0 KB       0 rows
. . exported "WMSYS"."WM$EXP_MAP"                        7.726 KB       3 rows
. . exported "WMSYS"."WM$METADATA_MAP"                       0 KB       0 rows
Master table "SYSTEM"."SYS_EXPORT_FULL_01" successfully loaded/unloaded
******************************************************************************
Dump file set for SYSTEM.SYS_EXPORT_FULL_01 is:
  /opt/oracle/admin/ORCLCDB/dpdump/total.dmp
Job "SYSTEM"."SYS_EXPORT_FULL_01" successfully completed at Sat Feb 25 20:00:26 2023 elapsed 0 00:02:09
~~~

* `DUMPFILE`: El fichero donde se hará la exportación.

* `LOG`: Fichero de log donde se registrará todo el proceso.

* `FULL`: Especificamos si queremos que se exporte toda la base de datos.

* `CONTENT`: Contenido específico que queremos exportar, en este caso solo los metadatos, lo que significa que hemos exportado la estructura de las tablas pero no el contenido de las mismas

* `ENCRYPTION_PASSWORD`: Encripta el fichero de exportación con la contraseña que especifiquemos.


4. Intenta realizar operaciones similares de importación y exportación con las herramientas proporcionadas con MySQL desde línea de comandos, documentando el proceso.

### EXPORTACIÓN

* Una exportación de la base de datos de scott, excluyendo la tabla bonus y añadiendo un fichero de log por si hay errores.

~~~
root@alepeteporico:~# mysqldump -u root -p empresa --ignore-table=empresa.BONUS --log-error=/home/alejandrogv/Escritorio/ASIR/logfile.log > /home/alejandrogv/Escritorio/ASIR/exportacion.sql
~~~

* Una exportación de todas las bases de datos.

~~~
root@alepeteporico:~# mysqldump -u root --all-databases --log-error=/home/alejandrogv/Escritorio/ASIR/logfile.log > /home/alejandrogv/Escritorio/ASIR/exportaciontotal.sql
~~~

### IMPORTACIÓN

* Creamos una base de datos nueva donde importaremos el esquema de scott.

~~~
MariaDB [(none)]> create database empresa2
    -> ;
Query OK, 1 row affected (0,001 sec)
~~~

* Importaremos la base de datos.

~~~
root@alepeteporico:~# mysql -u root empresa2 < /home/alejandrogv/Escritorio/ASIR/exportacion.sql
~~~

* Comprobamos que se ha realizado la importación.

~~~
MariaDB [(none)]> use empresa2
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
MariaDB [empresa2]> show tables;
+--------------------+
| Tables_in_empresa2 |
+--------------------+
| dept               |
| dummy              |
| emp                |
| salgrade           |
+--------------------+
4 rows in set (0,001 sec)
~~~

5. Intenta realizar operaciones similares de importación y exportación con las herramientas proporcionadas con Postgres desde línea de comandos, documentando el proceso.

### EXPORTACIÓN

* Exportamos una base de datos excluyendo una tabla.

~~~
pg_dump prueba --exclude-table=carreras_profesionales > exportacion.sql
~~~

* Comprobamos que se ha realizado correctamente.

~~~
postgres@postgresagv:~$ cat exportacion.sql 
--
-- PostgreSQL database dump
--

-- Dumped from database version 13.8 (Debian 13.8-0+deb11u1)
-- Dumped by pg_dump version 13.8 (Debian 13.8-0+deb11u1)

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

postgres@postgresagv:~$ cat exportacion.sql
--
-- PostgreSQL database dump
--

-- Dumped from database version 13.8 (Debian 13.8-0+deb11u1)
-- Dumped by pg_dump version 13.8 (Debian 13.8-0+deb11u1)

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
~~~

* Vamos a realizar una exportación de todas las bases de datos.

~~~
postgres@postgresagv:~$ pg_dumpall > exportaciontotal.sql
~~~

* Volvemos a comprobar.

~~~
postgres@postgresagv:~$ cat exportaciontotal.sql 
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

-- Dumped from database version 13.8 (Debian 13.8-0+deb11u1)
-- Dumped by pg_dump version 13.8 (Debian 13.8-0+deb11u1)

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

-- Dumped from database version 13.8 (Debian 13.8-0+deb11u1)
-- Dumped by pg_dump version 13.8 (Debian 13.8-0+deb11u1)

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

-- Dumped from database version 13.8 (Debian 13.8-0+deb11u1)
-- Dumped by pg_dump version 13.8 (Debian 13.8-0+deb11u1)

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

-- Dumped from database version 13.8 (Debian 13.8-0+deb11u1)
-- Dumped by pg_dump version 13.8 (Debian 13.8-0+deb11u1)

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: carreras_profesionales; Type: TABLE; Schema: public; Owner: usuario1
--

CREATE TABLE public.carreras_profesionales (
    codcarrera character varying(10) NOT NULL,
    fecha date,
    hora time without time zone,
    importepremio numeric(7,2),
    importemax numeric(7,2),
    edadminpart numeric(2,0),
    edadmaxpart numeric(2,0),
    CONSTRAINT fecha_carrera CHECK (((to_char((fecha)::timestamp with time zone, 'MM/DD'::text) < '03/02'::text) OR (to_char((fecha)::timestamp with time zone, 'MM/DD'::text) > '10/20'::text))),
    CONSTRAINT hora_carrera CHECK (((to_char((hora)::interval, 'HH24:MM'::text) >= '09:00'::text) AND (to_char((hora)::interval, 'HH24:MM'::text) <= '14:00'::text)))
);


ALTER TABLE public.carreras_profesionales OWNER TO usuario1;

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
-- Data for Name: carreras_profesionales; Type: TABLE DATA; Schema: public; Owner: usuario1
--

COPY public.carreras_profesionales (codcarrera, fecha, hora, importepremio, importemax, edadminpart, edadmaxpart) FROM stdin;
9320671591	2020-12-01	12:40:00	50000.00	4000.00	7	17
\.


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
-- Name: carreras_profesionales pk_carreras; Type: CONSTRAINT; Schema: public; Owner: usuario1
--

ALTER TABLE ONLY public.carreras_profesionales
    ADD CONSTRAINT pk_carreras PRIMARY KEY (codcarrera);


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
-- Name: DATABASE prueba; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON DATABASE prueba TO usuario1;


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database cluster dump complete
--
~~~

### IMPORTACIÓN

* Realizamos la importación de la base de datos.

~~~
postgres@postgresagv:~$ psql -d prueba2 -f exportacion.sql 
SET
SET
SET
SET
SET
 set_config 
------------
 
(1 row)

SET
SET
SET
SET
SET
SET
CREATE TABLE
ALTER TABLE
CREATE TABLE
ALTER TABLE
COPY 5
COPY 5
ALTER TABLE
ALTER TABLE
~~~

* Al entrar y listar las tablas vemos que no se ha creado la que excluimos.

~~~
prueba2=# \dt
            List of relations
 Schema |     Name     | Type  |  Owner   
--------+--------------+-------+----------
 public | jockeys      | table | usuario1
 public | propietarios | table | postgres
(2 rows)
~~~

6. Exporta los documentos de una colección de MongoDB que cumplan una determinada condición e impórtalos en otra base de datos.

### EXPORTACIÓN

* Realizamos la exportación de un documento especifico.

~~~
vagrant@mongoagv:~$ sudo mongoexport --db nobel -c premios --out exportacion.json
~~~

* Ahora podemos añadirle alguna condición podemos usar la opción -q, con la que diremos que solo exporte los libros cuyo año de lanzamiento sea 2019.

~~~
vagrant@mongoagv:~$ sudo mongoexport --db nobel -c premios -q "{\"year\": \"2019\"}" --out libros1819.json
2023-03-02T17:15:12.386+0000	connected to: mongodb://localhost/
2023-03-02T17:15:12.391+0000	exported 6 records
~~~

* Vamos a ver que se han exportado solo los libros que hemos especificado.

~~~
vagrant@mongoagv:~$ cat libros1819.json | jq
{
  "_id": {
    "$oid": "6400d466a0f4120b9c5e8a3c"
  },
  "year": "2019",
  "category": "Chemistry",
  "laureates": [
    {
      "id": "976",
      "firstname": "John",
      "surname": "Goodenough",
      "motivation": "\"for the development of lithium-ion batteries\"",
      "share": "3"
    },
    {
      "id": "977",
      "firstname": "M. Stanley",
      "surname": "Whittingham",
      "motivation": "\"for the development of lithium-ion batteries\"",
      "share": "3"
    },
    {
      "id": "978",
      "firstname": "Akira",
      "surname": "Yoshino",
      "motivation": "\"for the development of lithium-ion batteries\"",
      "share": "3"
    }
  ]
}
{
  "_id": {
    "$oid": "6400d466a0f4120b9c5e8a3d"
  },
  "year": "2019",
  "category": "Economics",
  "laureates": [
    {
      "id": "982",
      "firstname": "Abhijit",
      "surname": "Banerjee",
      "motivation": "\"for their experimental approach to alleviating global poverty\"",
      "share": "3"
    },
    {
      "id": "983",
      "firstname": "Esther",
      "surname": "Duflo",
      "motivation": "\"for their experimental approach to alleviating global poverty\"",
      "share": "3"
    },
    {
      "id": "984",
      "firstname": "Michael",
      "surname": "Kremer",
      "motivation": "\"for their experimental approach to alleviating global poverty\"",
      "share": "3"
    }
  ]
}
{
  "_id": {
    "$oid": "6400d466a0f4120b9c5e8a3e"
  },
  "year": "2019",
  "category": "Literature",
  "laureates": [
    {
      "id": "980",
      "firstname": "Peter",
      "surname": "Handke",
      "motivation": "\"for an influential work that with linguistic ingenuity has explored the periphery and the specificity of human experience\"",
      "share": "1"
    }
  ]
}
{
  "_id": {
    "$oid": "6400d466a0f4120b9c5e8a3f"
  },
  "year": "2019",
  "category": "Peace",
  "laureates": [
    {
      "id": "981",
      "firstname": "Abiy",
      "surname": "Ahmed Ali",
      "motivation": "\"for his efforts to achieve Peace and international cooperation, and in particular for his decisive initiative to resolve the border conflict with neighbouring Eritrea\"",
      "share": "1"
    }
  ]
}
{
  "_id": {
    "$oid": "6400d466a0f4120b9c5e8a40"
  },
  "year": "2019",
  "category": "Physics",
  "overallMotivation": "\"for contributions to our understanding of the evolution of the universe and Earth’s place in the cosmos\"",
  "laureates": [
    {
      "id": "973",
      "firstname": "James",
      "surname": "Peebles",
      "motivation": "\"for theoretical discoveries in physical cosmology\"",
      "share": "2"
    },
    {
      "id": "974",
      "firstname": "Michel",
      "surname": "Mayor",
      "motivation": "\"for the discovery of an exoplanet orbiting a solar-type star\"",
      "share": "4"
    },
    {
      "id": "975",
      "firstname": "Didier",
      "surname": "Queloz",
      "motivation": "\"for the discovery of an exoplanet orbiting a solar-type star\"",
      "share": "4"
    }
  ]
}
{
  "_id": {
    "$oid": "6400d466a0f4120b9c5e8a41"
  },
  "year": "2019",
  "category": "Medicine",
  "laureates": [
    {
      "id": "970",
      "firstname": "William",
      "surname": "Kaelin",
      "motivation": "\"for their discoveries of how cells sense and adapt to oxygen availability\"",
      "share": "3"
    },
    {
      "id": "971",
      "firstname": "Peter",
      "surname": "Ratcliffe",
      "motivation": "\"for their discoveries of how cells sense and adapt to oxygen availability\"",
      "share": "3"
    },
    {
      "id": "972",
      "firstname": "Gregg",
      "surname": "Semenza",
      "motivation": "\"for their discoveries of how cells sense and adapt to oxygen availability\"",
      "share": "3"
    }
  ]
}
~~~

### IMPORTACIÓN
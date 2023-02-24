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

~~~
expdp SCOTT/TIGER DUMPFILE=scott.dmp LOG=exportacionscott.log DIRECTORY=DATA_PUMP_EXPORT SCHEMAS=SCOTT EXCLUDE=TABLE:\"=\'BONUS\'\"
~~~

QUERY='dept:"WHERE (SELECT d.deptno FROM emp e, dept d WHERE )"' ESTIMATE_ONLY=YES

2. Importa el fichero obtenido anteriormente usando Oracle Data Pump pero en un usuario distinto de la misma base de datos.


3. Realiza una exportación de la estructura de todas las tablas de la base de datos usando el comando expdp de Oracle Data Pump probando al menos cinco de las posibles opciones que ofrece dicho comando y documentándolas adecuadamente.

~~~
expdp SYSTEM DUMPFILE=myexp.dmp FULL=y LOG=myexp.log 
~~~

SELECT deptno
FROM dept
WHERE deptno
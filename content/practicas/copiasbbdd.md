+++
title = "COPIAS DE SEGURIDAD Y RECUPERACIÓN"
description = ""
tags = [
    "ABD"
]
date = "2021-06-07"
menu = "main"
+++

* Primero crearemos el directorio donde almacenaremos las copias.

        SQL> CREATE directory COPIA as '/home/backups/';

        Directory created.

* Comprobemos que se ha creado correctamente.

        SQL> select directory_name from dba_directories;

        DIRECTORY_NAME
        --------------------------------------------------------------------------------
        COPIA
        SDO_DIR_WORK
        SDO_DIR_ADMIN
        XMLDIR
        XSDDIR
        OPATCH_INST_DIR
        ORACLE_OCM_CONFIG_DIR2
        ORACLE_BASE
        ORACLE_HOME
        ORACLE_OCM_CONFIG_DIR
        DATA_PUMP_DIR

        DIRECTORY_NAME
        --------------------------------------------------------------------------------
        OPATCH_SCRIPT_DIR
        OPATCH_LOG_DIR
        JAVA$JOX$CUJS$DIRECTORY$

        14 rows selected.

* 

expdp ale/ale dumpfile=copia_oracle_export_%U.dmp logfile=copia_oracle_export.log directory=CARPETA_EXPORT full=y filesize=100M 
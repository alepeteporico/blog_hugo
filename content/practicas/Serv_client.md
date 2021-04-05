+++
title = "Instalación de servidores y clientes"
description = ""
tags = [
    "ABD"
]
date = "2021-04-05"
menu = "main"
+++

Tras la instalación de cada servidor,  debe crearse una base de datos con al menos tres tablas o colecciones y poblarse de datos adecuadamente. Debe crearse un usuario y dotarlo de los privilegios necesarios para acceder remotamente a los datos. Se proporcionará esta información al resto de los miembros del grupo.

* Los clientes deben estar siempre en máquinas diferentes de los respectivos servidores a los que acceden.
* Se documentará todo el proceso de configuración de los servidores.
* Se aportarán pruebas del funcionamiento remoto de cada uno de los clientes.
* Se aportará el código de las aplicaciones realizadas y prueba de funcionamiento de las mismas.

## Instalación servidor Oracle 19c

* Hemos creado una maquina vagrant con centos 8 para instalar nuestro servidor de Oracle 19c, lo descargaremos de la [página oficial de Oracle](https://www.oracle.com/es/database/technologies/oracle19c-linux-downloads.html#license-lightbox) y llevamos el fichero de instalación a nuestra máquina usando scp.

        [vagrant@oracle ~]$ scp alejandrogv@192.168.1.15:/home/alejandrogv/Descargas/oracle-database-ee-19c-1.0-1.x86_64.rpm .

* El siguiente paso será obviamente instalarlo.

        [vagrant@oracle ~]$ sudo dnf install https://yum.oracle.com/repo/OracleLinux/OL8/baseos/latest/x86_64/getPackage/oracle-database-preinstall-19c-1.0-1.el8.x86_64.rpm

        [vagrant@oracle ~]$ sudo yum -y localinstall oracle-database-ee-19c-1.0-1.x86_64.rpm
        
* Antes de crear la base de datos de ejemplo debemos tener en cuenta que nos dará error si nuestra memoria RAM es inferior a 2GB. También he experimentado un error ya que no me resolvía el DNS de oracle, por eso he tenido que modificar mi /etc/hosts y añadir la siguiente línea:

        10.0.2.15 myhost

* Ahora si, creamos la base de datos de ejemplo

        [oracle@oracle ~]$ sudo /etc/init.d/oracledb_ORCLCDB-19c configure
        Configuring Oracle Database ORCLCDB.
        Prepare for db operation
        8% complete
        Copying database files
        31% complete
        Creating and starting Oracle instance
        32% complete
        36% complete
        40% complete
        43% complete
        46% complete
        Completing Database Creation
        51% complete
        54% complete
        Creating Pluggable Databases
        58% complete
        77% complete
        Executing Post Configuration Actions
        100% complete
        Database creation complete. For details check the logfiles at:
         /opt/oracle/cfgtoollogs/dbca/ORCLCDB.
        Database Information:
        Global Database Name:ORCLCDB
        System Identifier(SID):ORCLCDB
        Look at the log file "/opt/oracle/cfgtoollogs/dbca/ORCLCDB/ORCLCDB5.log" for further details.

Database configuration completed successfully. The passwords were auto generated, you must change them by connecting to the database using 'sqlplus / as sysdba' as the oracle user.

* Continuemos con los usuarios, accedamos al usuario que se ha creado por defecto al instalar el paquete de oracle con su mismo nombre.

        [vagrant@oracle ~]$ sudo su - oracle

* Y tendremos que modifcar el fichero `~/.bash_profile` añadiendo algunas lineas como las que vemos a continuación

        [oracle@oracle ~]$ cat .bash_profile 
        # .bash_profile
        
        # Get the aliases and functions
        if [ -f ~/.bashrc ]; then
        	. ~/.bashrc
        fi
        
        umask 022
        export ORACLE_SID=ORCLCDB
        export ORACLE_BASE=/opt/oracle/oradata
        export ORACLE_HOME=/opt/oracle/product/19c/dbhome_1
        export PATH=$PATH:$ORACLE_HOME/bin

* Este fichero se ejecuta cada vez que iniciamos sesión en este usuario. sin necesidad de tener que salir ni reiniciar la máquina podemos usar `source` para ejecutarlo

        [oracle@oracle ~]$ source .bash_profile

* Finalmente podremos entrar en sqlplus.

        [oracle@oracle ~]$ sqlplus / as sysdba

        SQL*Plus: Release 19.0.0.0.0 - Production on Mon Apr 5 12:03:44 2021
        Version 19.3.0.0.0

        Copyright (c) 1982, 2019, Oracle.  All rights reserved.

        Connected to an idle instance.

        SQL>

* Podemos comprobar una pequeña información para ver que nuestra base de datos está operativa

        SQL> SELECT instance_name, host_name, version, startup_time FROM v$instance;

        INSTANCE_NAME
        ----------------
        HOST_NAME
        ----------------------------------------------------------------
        VERSION 	  STARTUP_T
        ----------------- ---------
        ORCLCDB
        oracle
        19.0.0.0.0	  05-APR-21

* Pudiera ser que nos diera un error, esto se puede deber a que la base de datos de prueba no esté montada, para solucionarlo usariamos `STARTUP` y debería solucionarse el problema.

* El siguiente paso será la creación de un usuario y otorgarle permisos al mismo

        SQL> CREATE USER c##ale IDENTIFIED BY ale;      

        User created.

        SQL> GRANT ALL PRIVILEGES TO c##ale;

        Grant succeeded.

* Nos desconectamos de este usuario y entramos en el recien creado para comprobar que funciona

        SQL> DISCONNECT
        Disconnected from Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
        Version 19.3.0.0.0
        SQL> CONNECT c##ale/ale
        Connected.

* 
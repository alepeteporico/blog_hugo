+++
title = "Migración de CentOS 8 a Rocky"
description = ""
tags = [
    "ASO"
]
date = "2021-11-12"
menu = "main"
+++

* Vamos a usar la distribución Rocky porque es una instalación sencilla, esta distribución está sopoprtada de la misma forma que estaba soportada CentOS. Esto nos asegura que tendremos nuestro sistema actualizado tal como teníamos CentOS, es más, esto no es mas que una distribución "hija" de la CentOS creada simplemente para sustituir a esta distribución ya sin soporte. Y es exactamente lo que haremos.

---------------------------------

* Comprobamos la version de centos que tenemos

~~~
[centos@migracion ~]$ hostnamectl
   Static hostname: migracion.openstacklocal
         Icon name: computer-vm
           Chassis: vm
        Machine ID: 954aa6ad559747ffb2849ed9c824d1bb
           Boot ID: 0033540c7f8346c195f6304733d4ac92
    Virtualization: kvm
  Operating System: CentOS Linux 8
       CPE OS Name: cpe:/o:centos:centos:8
            Kernel: Linux 4.18.0-305.3.1.el8.x86_64
      Architecture: x86-64
~~~

* Ahora vamos a descargar un script que realiza la migración, basicamente añade los repositorios de Rocky, comprueba la shell y caracteristicas de nuestro sistema entre otras cosas y realiza la instalación

~~~
[centos@migracion ~]$ wget https://raw.githubusercontent.com/rocky-linux/rocky-tools/main/migrate2rocky/migrate2rocky.sh
~~~

* Le damos permisos de ejecución y lo ejecutamos.

~~~
[centos@migracion ~]$ sudo chmod +x migrate2rocky.sh

[centos@migracion ~]$ sudo ./migrate2rocky.sh -r
~~~

* Al terminar la ejecución del script nos saldrá un mensaje avisando que para realizar los cambios deberemos reinciar y que tenemos un fichero de log para ver si ha habido algún problema.

~~~
Done, please reboot your system.
A log of this installation can be found at /var/log/migrate2rocky.log
~~~

* Comprobamos el fichero de log y verificamos que no ha ocurrido nada durante la migración. Seguidamente reiniciamos el sistema.

~~~
[centos@migracion ~]$ sudo reboot 0
~~~

* Y comprobamos la distribución que estamos usando:

~~~
[centos@migracion ~]$ hostnamectl
   Static hostname: migracion.openstacklocal
         Icon name: computer-vm
           Chassis: vm
        Machine ID: 954aa6ad559747ffb2849ed9c824d1bb
           Boot ID: a57712f850674e759ad2fc6cc7721e31
    Virtualization: kvm
  Operating System: Rocky Linux 8.4 (Green Obsidian)
       CPE OS Name: cpe:/o:rocky:rocky:8.4:GA
            Kernel: Linux 4.18.0-305.25.1.el8_4.x86_64
      Architecture: x86-64
+++
title = "Herramientas de seguridad"
description = ""
tags = [
    "SRI"
]
date = "2021-09-23"
menu = "main"
+++

---

## Sistemas de detección de intrusos

---------------------------

#### Vamos a usar como sistema de detección de intrusos la herramienta SURICATA, parece ser la más usada a día de hoy 

---------------------------

* Por supuesto el primer paso será instalar las dependencias necesarias para nuestro

        vagrant@practica1 sudo apt install flex bison build-essential checkinstall libpcap-dev libnet1-dev libpcre3-dev libnetfilter-queue-dev cmake libdumbnet-dev

* Vamos a descargar el paquete en nuestra máquina.

        vagrant@practica1:~$ wget https://www.snort.org/downloads/snort/daq-2.0.7.tar.gz

* Descomprimimos el archivo y lo compilamos.

        vagrant@practica1:~$ tar xvfz daq-2.0.7.tar.gz

        vagrant@practica1:~$ cd daq-2.0.7/

        vagrant@practica1:~/daq-2.0.7$ autoreconf -f -i
        libtoolize: putting auxiliary files in '.'.
        libtoolize: copying file './ltmain.sh'
        libtoolize: putting macros in AC_CONFIG_MACRO_DIRS, 'm4'.
        libtoolize: copying file 'm4/libtool.m4'
        libtoolize: copying file 'm4/ltoptions.m4'
        libtoolize: copying file 'm4/ltsugar.m4'
        libtoolize: copying file 'm4/ltversion.m4'
        libtoolize: copying file 'm4/lt~obsolete.m4'
        configure.ac:12: installing './compile'
        configure.ac:9: installing './missing'
        api/Makefile.am: installing './depcomp'

        vagrant@practica1:~/daq-2.0.7$ ./configure && make && sudo make install
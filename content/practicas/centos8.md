+++
title = "Actualización de CentOS 7 a CentOS 8"
description = ""
tags = [
    "ASO"
]
date = "2021-02-19"
menu = "main"
+++

**Antes de comenzar debemos instalar si no las tenemos ya las siguientes herramientas:**

        [centos@quijote ~]$ sudo yum install epel-release -y

        [centos@quijote ~]$ sudo yum install yum-utils -y

        [centos@quijote ~]$ sudo yum install rpmconf -y

**Ahora usaremos rpmconf para verificar conflictos en ficheros de configuración:**

        [centos@quijote ~]$ sudo rpmconf -a

**Limpiamos los paquetes innecesarios:**

        [centos@quijote ~]$ sudo package-cleanup --leaves
        [centos@quijote ~]$ sudo package-cleanup --orphans

**Instalamos el nuevo gestor de paquetes que usa CentOS 8, dnf:**

        [centos@quijote ~]$ sudo yum install dnf

**Aunque los dos gestores de paquetes podrían coexistir en el sistema, es mejor que eliminemos yum y usemos unicamente dnf:**

        [centos@quijote ~]$ sudo dnf -y remove yum yum-metadata-parser
        [centos@quijote ~]$ sudo rm -Rf /etc/yum

**Vamos a actualizar los paquetes usando el nuevo gestor:**

        [centos@quijote ~]$ sudo dnf upgrade -y

**Añadimos el paquete para lanzar CentOS 8**

        [centos@quijote ~]$ sudo dnf install http://mirror.centos.org/centos/8/BaseOS/x86_64/os/Packages/centos-linux-repos-8-2.el8.noarch.rpm http://mirror.centos.org/centos/8/BaseOS/x86_64/os/Packages/centos-linux-release-8.3-1.2011.el8.noarch.rpm http://mirror.centos.org/centos/8/BaseOS/x86_64/os/Packages/centos-gpg-keys-8-2.el8.noarch.rpm

**Actualizamos el respositorio EPEL:**

        [centos@quijote ~]$ dnf -y upgrade https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

**Eliminamos los fichero temporales:**

        [centos@quijote ~]$ sudo dnf clean all
    
**Eliminamos el kernel de CentOS 7:**

        [centos@quijote ~]$ sudo rpm -e `rpm -q kernel`

**Y los paquetes conflictivos:**

        [centos@quijote ~]$ sudo rpm -e --nodeps sysvinit-tools

**Ahora al fin, actualizaremos a CentOS 8:**

        [centos@quijote ~]$ sudo dnf -y --releasever=8 --allowerasing --setopt=deltarpm=false distro-sync

**Instalamos el nuevo kernel:**

        [centos@quijote ~]$ sudo dnf -y install kernel-core

**Ahora debemos instalar el paquete minimal de CentOS 8 y actualizar grupos:**

        [centos@quijote ~]$ sudo dnf -y groupupdate "Core" "Minimal Install" --allowerasing --skip-broken

**Finalmente, depués de reiniciar el sistema, comprobamos que la actualización se ha realizado correctamente y tenemos instalado en nuestro sistema CentOS 8**

        [centos@quijote ~]$ sudo cat /etc/os-release
        NAME="CentOS Linux"
        VERSION="8"
        ID="centos"
        ID_LIKE="rhel fedora"
        VERSION_ID="8"
        PLATFORM_ID="platform:el8"
        PRETTY_NAME="CentOS Linux 8"
        ANSI_COLOR="0;31"
        CPE_NAME="cpe:/o:centos:centos:8"
        HOME_URL="https://centos.org/"
        BUG_REPORT_URL="https://bugs.centos.org/"
        CENTOS_MANTISBT_PROJECT="CentOS-8"
        CENTOS_MANTISBT_PROJECT_VERSION="8"

        [centos@quijote ~]$ cat /etc/redhat-release
        CentOS Linux release 8.3.2011

        [centos@quijote ~]$ uname -a
        Linux quijote.novalocal 4.18.0-240.10.1.el8_3.x86_64 #1 SMP Mon Jan 18 17:05:51 UTC 2021 x86_64 x86_64 x86_64 GNU/Linux

        [centos@quijote ~]$ uname -r
        4.18.0-240.10.1.el8_3.x86_64
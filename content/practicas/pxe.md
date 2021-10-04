+++
title = "Instalación y configuración de un servidor PXE en debian"
description = ""
tags = [
    "SO"
]
date = "2021-09-21"
menu = "main"
+++

---

* En la máquina que usaremos como servidor pxe debemos instalar también un servidor dhcp que dará direccionamiento IP a nuestros clientes.

        vagrant@pxe:~$ sudo apt install isc-dhcp-server

* Ahora en el fichero `/etc/dhcp/dhcpd.conf` añadimos la configuración de nuestro dhcp.

~~~
option domain-name «servidorpxe.com»;

option domain-name-servers «server1.servidorpxe.com»;

subnet 192.168.1.100 netmask 255.255.255.0 {

range 192.168.1.10 192.168.1.30;

option routers 192.168.1.1;

option broadcast-address 192.168.1.255;

}

default-lease-time 600;

max-lease-time 7200

authoritative;
~~~

* Vamos a instalar los paquetes necesarios para nuestro servidor pxe

~~~
vagrant@pxe:~$ sudo apt install apache2 tftpd-hpa inetutils-inetd
~~~

* Ahora añadimos al fichero `/etc/default/tftpd-hpa` las siguientes líneas para iniciar el demonio.

~~~
RUN_DAEMON=»yes»

OPTIONS=»-l -s /var/lib/tftpboot»
~~~

* Y en el fichero `/etc/inetd.conf` añadiremos esto:

~~~
tftp    dgram    udp    wait    root    /usr/sbin/in.tftpd /user/sbin/in.tftpd -s /var/lib/fttpboot
~~~

* Ahora al fichero `/etc/dhcp/dhcp.conf` añadiremos al final del archivo el direccionamiento que queremos que de nuestro pxe.

~~~
allow booting;

allow bootp;

option option-128 code 128 = string;

option option-129 code 129 = text;

next-server 192.168.1.100;

filename «pxelinux.0»;
~~~

* 
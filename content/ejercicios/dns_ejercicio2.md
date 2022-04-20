+++
title = "Instalación y configuración de un servidor DNS esclavo "
description = ""
tags = [
    "SRI"
]
date = "2022-04-05"
menu = "main"
+++

* creamos una máquina que actuara de DNS secundario, el primer paso será cambiar el hostname de está maquina.

~~~
vagrant@gutierrezvalencia:~$ hostname -f
gutierrezvalencia.iesgn.org
~~~

* Nos dirigimos al DNS primario y configuramos el fichero `/etc/bind/named.conf.options`

~~~
options {
        directory "/var/cache/bind";
        allow-query { 10.0.0.0/24; };
        allow-transfer { none; };

        auth-nxdomain no;    # conform to RFC1035
        recursion no;

        dnssec-validation auto;

        listen-on-v6 { any; };
};
~~~

* Y también debemos cambiar el `/etc/bind/named.conf.local` para añadir el rol de maestro.

~~~
zone "iesgn.org" {
        type master;
        file "db.iesgn.org";
        allow-transfer { slaves; };
        notify yes;
};

zone "0.0.10.in-addr.arpa" {
        type master;
        file "db.0.0.10";
        allow-transfer { slaves; };
        notify yes;
};
~~~

* Y también debemos añadirlo en las zonas directas e inversas.

~~~
$TTL    86400
@       IN      SOA     alegv.iesgn.org. admin.iesgn.org. (
                         24367          ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                          86400 )       ; Negative Cache TTL
;
@       IN      NS      alegv.iesgn.org.
@       IN      NS      gutierrezvalencia.iesgn.org
@       IN      MX 10   correo.iesgn.org.

$ORIGIN iesgn.org.

alegv   IN      A       10.0.0.10
gutierrezvalencia       IN      A       10.0.0.20
correo  IN      A       10.0.0.200
ftp     IN      A       10.0.0.201
www             IN      CNAME   alegv
departamentos   IN      CNAME   alegv
~~~

~~~
$TTL    86400
@       IN      SOA     alegv.iesgn.org. admin.iesgn.org. (
                         24367          ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                          86400 )       ; Negative Cache TTL
;
@       IN      NS      alegv.iesgn.org.
@       IN      NS      gutierrezvalencia.iesgn.org

$ORIGIN 0.0.10.in-addr.arpa.

10      IN      PTR     alegv.iesgn.org.
20      IN      PTR     gutierrezvalencia.iesgn.org.
200     IN      PTR     correo.iesgn.org.
201     IN      PTR     ftp.iesgn.org.
~~~

* Nos dirigimos al DNS secundario para modificar nuevamente el fichero `named.conf.local`

~~~
include "/etc/bind/zones.rfc1918";

zone "iesgn.org" {
        type slave;
        file "db.iesgn.org";
        masters { 10.0.0.10; };
};

zone "121.168.192.in-addr.arpa" {
        type slave;
        file "db.0.0.10";
        masters { 10.0.0.10; };
};
~~~

* 
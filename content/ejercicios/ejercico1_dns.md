+++
title = "Ejercicio 1 DNS"
description = ""
tags = [
    "SRI"
]
date = "2021-11-08"
menu = "main"
+++

* Empezaremos a añadir las zonas de las que nuestro servidor tiene autoridad en el fichero `/etc/bind/named.conf.local`, dejandolo tal que así (tener en cuenta que hay que descomentar la primera línea).

~~~
include "/etc/bind/zones.rfc1918";

zone "iesgn.org" {
        type master;
        file "db.iesgn.org";
};

zone "0.0.10.in-addr.arpa" {
        type master;
        file "db.0.0.10";
};
~~~

* Ahora definiremos los fichero `db.iesgn.org` y `db.0.0.10` dentro de `/var/cache/bind/` vamos primero con la zona directa:

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
@       IN      MX 10   correo.iesgn.org.

$ORIGIN iesgn.org.

alegv   IN      A       10.0.0.10
correo  IN      A       10.0.0.200
ftp     IN      A       10.0.0.201
www             IN      CNAME   alegv
departamentos   IN      CNAME   alegv
~~~

* Una vez definida la zona directa, vamos con la inversa.

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

$ORIGIN 0.0.10.in-addr.arpa.

10      IN      PTR     alegv.iesgn.org.
200     IN      PTR     correo.iesgn.org.
201     IN      PTR     ftp.iesgn.org.
~~~

* Una vez definido terminada la configuración podemos comprobar si tenemos algún error de sintáxis mediante este comando.

~~~
vagrant@dns:~$ sudo named-checkconf
~~~

* Reiniciamos el servicio y nos dirigimos a nuestro cliente. Añadimos nuestro servidor al fichero `/etc/resolv.conf`

~~~
nameserver 10.0.0.10
~~~

* Y ahora vamos a hacer las consultas necesarias.

### iesgn, alegv y ftp

~~~
vagrant@cliente:~$ dig www.iesgn.org

; <<>> DiG 9.16.15-Debian <<>> www.iesgn.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 6897
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 7d481ec88f3729b901000000618b8b80622467a8ffac1f1e (good)
;; QUESTION SECTION:
;www.iesgn.org.			IN	A

;; ANSWER SECTION:
www.iesgn.org.		86400	IN	CNAME	alegv.iesgn.org.
alegv.iesgn.org.	86400	IN	A	10.0.0.10

;; Query time: 0 msec
;; SERVER: 10.0.0.10#53(10.0.0.10)
;; WHEN: Wed Nov 10 09:06:08 UTC 2021
;; MSG SIZE  rcvd: 106

vagrant@cliente:~$ dig alegv.iesgn.org

; <<>> DiG 9.16.15-Debian <<>> alegv.iesgn.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 31342
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 3c6bda8c4c49fcf201000000618b8bc7b5c6d0ad0c609972 (good)
;; QUESTION SECTION:
;alegv.iesgn.org.		IN	A

;; ANSWER SECTION:
alegv.iesgn.org.	86400	IN	A	10.0.0.10

;; Query time: 0 msec
;; SERVER: 10.0.0.10#53(10.0.0.10)
;; WHEN: Wed Nov 10 09:07:19 UTC 2021
;; MSG SIZE  rcvd: 88

vagrant@cliente:~$ dig ftp.iesgn.org

; <<>> DiG 9.16.15-Debian <<>> ftp.iesgn.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 17031
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: e62c88ee400c76b301000000618b8c147057652ae93beb44 (good)
;; QUESTION SECTION:
;ftp.iesgn.org.			IN	A

;; ANSWER SECTION:
ftp.iesgn.org.		86400	IN	A	10.0.0.201

;; Query time: 0 msec
;; SERVER: 10.0.0.10#53(10.0.0.10)
;; WHEN: Wed Nov 10 09:08:36 UTC 2021
;; MSG SIZE  rcvd: 86
~~~

### DNS con autoridad sobre la zona iesgn.org

~~~
vagrant@cliente:~$ dig ns iesgn.org

; <<>> DiG 9.16.15-Debian <<>> ns iesgn.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 10824
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 2

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 97ab6afc044be94801000000618b8c345c97033a70ba5b1d (good)
;; QUESTION SECTION:
;iesgn.org.			IN	NS

;; ANSWER SECTION:
iesgn.org.		86400	IN	NS	alegv.iesgn.org.

;; ADDITIONAL SECTION:
alegv.iesgn.org.	86400	IN	A	10.0.0.10

;; Query time: 0 msec
;; SERVER: 10.0.0.10#53(10.0.0.10)
;; WHEN: Wed Nov 10 09:09:08 UTC 2021
;; MSG SIZE  rcvd: 102
~~~

### Servidor de correo de iesgn.org

~~~
vagrant@cliente:~$ dig mx iesgn.org

; <<>> DiG 9.16.15-Debian <<>> mx iesgn.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 12374
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 2

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: ce347491f677979901000000618b8c6b721ab4f8f595e621 (good)
;; QUESTION SECTION:
;iesgn.org.			IN	MX

;; ANSWER SECTION:
iesgn.org.		86400	IN	MX	10 correo.iesgn.org.

;; ADDITIONAL SECTION:
correo.iesgn.org.	86400	IN	A	10.0.0.200

;; Query time: 0 msec
;; SERVER: 10.0.0.10#53(10.0.0.10)
;; WHEN: Wed Nov 10 09:10:03 UTC 2021
;; MSG SIZE  rcvd: 105
~~~

### Dirección IP de www.josedomingo.org

~~~
vagrant@cliente:~$ dig www.josedomingo.org

; <<>> DiG 9.16.15-Debian <<>> www.josedomingo.org
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 34579
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 0d868a0123bf14d101000000618b8cb0615d33676ad353c3 (good)
;; QUESTION SECTION:
;www.josedomingo.org.		IN	A

;; ANSWER SECTION:
www.josedomingo.org.	515	IN	CNAME	endor.josedomingo.org.
endor.josedomingo.org.	515	IN	A	37.187.119.60

;; Query time: 4 msec
;; SERVER: 10.0.0.10#53(10.0.0.10)
;; WHEN: Wed Nov 10 09:11:12 UTC 2021
;; MSG SIZE  rcvd: 112
~~~

### Una resolución inversa

~~~
vagrant@cliente:~$ dig -x 10.0.0.200

; <<>> DiG 9.16.15-Debian <<>> -x 10.0.0.200
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 44123
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 037baba9af33611301000000618b8cccb05f226be0cbc559 (good)
;; QUESTION SECTION:
;200.0.0.10.in-addr.arpa.	IN	PTR

;; ANSWER SECTION:
200.0.0.10.in-addr.arpa. 86400	IN	PTR	correo.iesgn.org.

;; Query time: 0 msec
;; SERVER: 10.0.0.10#53(10.0.0.10)
;; WHEN: Wed Nov 10 09:11:40 UTC 2021
;; MSG SIZE  rcvd: 110
~~~
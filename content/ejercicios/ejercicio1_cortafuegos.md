+++
title = "Ejercicio 1 cortafuegos"
description = ""
tags = [
    "SAD"
]
date = "2022-02-03"
menu = "main"
+++

* Añadiremos las siguientes reglas.

~~~
# Limpiamos las tablas
iptables -F
iptables -t nat -F
iptables -Z
iptables -t nat -Z
# Establecemos la política
iptables -P INPUT DROP
iptables -P OUTPUT DROP

iptables -A INPUT -i lo -p icmp -j ACCEPT
iptables -A OUTPUT -o lo -p icmp -j ACCEPT

iptables -A INPUT -s 192.168.121.0/24 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -d 192.168.121.0/24 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

iptables -A INPUT -i eth0 -p icmp --icmp-type echo-reply -j ACCEPT
iptables -A OUTPUT -o eth0 -p icmp --icmp-type echo-request -j ACCEPT

iptables -A INPUT -i eth0 -p udp --sport 53 -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p udp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT

iptables -A INPUT -i eth0 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT

iptables -A INPUT -i eth0 -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT

iptables -A INPUT -i eth0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT
~~~

* Permite poder hacer conexiones ssh al exterior.

~~~
iptables -A INPUT -i eth0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
~~~

* Deniega el acceso a tu servidor web desde una ip concreta.

~~~
iptables -A INPUT ! -s 192.168.121.187/24 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT ! -d 192.168.121.187/24 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT
~~~

~~~
vagrant@pruebas:~$ curl http://192.168.121.131:80
curl: (28) Failed to connect to 192.168.121.131 port 80: Expiró el tiempo de conexión
~~~

* Permite hacer consultas DNS sólo al servidor 192.168.202.2. Comprueba que no puedes hacer un dig @1.1.1.1.

~~~
iptables -A INPUT -s 192.168.202.2/32 -p udp --sport 53 -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -d 192.168.202.2/32 -p udp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
~~~

~~~
root@servidor:~# dig @192.168.202.2 www.google.es

; <<>> DiG 9.16.22-Debian <<>> @192.168.202.2 www.google.es
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 13491
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 4, ADDITIONAL: 9

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: 87fa099632a61629d49631bc620a0c47ffb243a5b6209bd8 (good)
;; QUESTION SECTION:
;www.google.es.			IN	A

;; ANSWER SECTION:
www.google.es.		16	IN	A	216.58.215.131

;; AUTHORITY SECTION:
google.es.		84005	IN	NS	ns3.google.com.
google.es.		84005	IN	NS	ns2.google.com.
google.es.		84005	IN	NS	ns4.google.com.
google.es.		84005	IN	NS	ns1.google.com.

;; ADDITIONAL SECTION:
ns1.google.com.		90004	IN	A	216.239.32.10
ns2.google.com.		90004	IN	A	216.239.34.10
ns3.google.com.		90004	IN	A	216.239.36.10
ns4.google.com.		90004	IN	A	216.239.38.10
ns1.google.com.		90004	IN	AAAA	2001:4860:4802:32::a
ns2.google.com.		90004	IN	AAAA	2001:4860:4802:34::a
ns3.google.com.		90004	IN	AAAA	2001:4860:4802:36::a
ns4.google.com.		90004	IN	AAAA	2001:4860:4802:38::a

;; Query time: 0 msec
;; SERVER: 192.168.202.2#53(192.168.202.2)
;; WHEN: Mon Feb 14 08:01:11 UTC 2022
;; MSG SIZE  rcvd: 344
~~~

~~~
root@bullseye:~# dig @1.1.1.1 www.google.es

; <<>> DiG 9.16.22-Debian <<>> @1.1.1.1 www.google.es
; (1 server found)
;; global options: +cmd
;; connection timed out; no servers could be reached
~~~

* No permitir el acceso al servidor web de www.josedomingo.org (Tienes que utilizar la ip).

~~~
iptables -A OUTPUT -d 37.187.119.60/32 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j DROP
iptables -A INPUT -s 37.187.119.60/32 -p tcp --sport 80 -m state --state ESTABLISHED -j DROP
~~~

~~~
root@bullseye:~# curl www.josedomingo.org
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>301 Moved Permanently</title>
</head><body>
<h1>Moved Permanently</h1>
<p>The document has moved <a href="https://www.josedomingo.org/">here</a>.</p>
<hr>
<address>Apache/2.4.38 (Debian) Server at www.josedomingo.org Port 80</address>
</body></html>
~~~

* ¿Puedes acceder a fp.josedomingo.org? Tampoco podríamos, pues hemos bloqueado la IP donde se alojan estos dos sitios.

~~~
root@bullseye:~# curl fp.josedomingo.org
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>301 Moved Permanently</title>
</head><body>
<h1>Moved Permanently</h1>
<p>The document has moved <a href="https://fp.josedomingo.org/">here</a>.</p>
<hr>
<address>Apache/2.4.38 (Debian) Server at fp.josedomingo.org Port 80</address>
</body></html>
~~~

* Permite mandar un correo usando nuestro servidor de correo: babuino-smtp

~~~
iptables -A OUTPUT -d 192.168.203.3/32 -p tcp --dport 25 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -s 192.168.203.3/32 -p tcp --sport 25 -m state --state ESTABLISHED -j ACCEPT
~~~

* Instala un servidor mariadb, y permite los accesos desde la ip de tu cliente.

~~~
iptables -A INPUT -s 192.168.121.187/24 -p tcp --dport 3306 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -d 192.168.121.187/24 -p tcp --sport 3306 -m state --state ESTABLISHED -j ACCEPT
~~~

~~~
vagrant@pruebas:~$ mysql -h 192.168.121.131 -u remoto1 -p
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 30
Server version: 10.5.12-MariaDB-0+deb11u1 Debian 11

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]>
~~~

~~~
alejandrogv@AlejandroGV:~/vagrant/seguridad/cortafuegos$ mysql -h 192.168.121.131 -u remoto1 -p
Enter password: 

~~~
+++
title = "Ejercicio 2 cortafuegos"
description = ""
tags = [
    "SAD"
]
date = "2022-02-28"
menu = "main"
+++

* En este ejercicio realizaremos todos los que hicimos en iptables en el primero ahora con nftables.

* Lo primero que haremos será añadir una tabla donde filtraremos los paquetes, ponemos la familia `inet` ya que estas reglas deben funcionar tanto en ipv4 como ipv6. 

~~~
root@servidor:~# nft add table inet filter
~~~

* Debemos crear una cadena que acepte los paquete para poder seguir con nuestra conexión ssh.

~~~
nft add chain inet filter input { type filter hook input priority 0 \; counter \; policy accept \; }
nft add chain inet filter output { type filter hook output priority 0 \; counter \; policy accept \; }
~~~

* Una vez hecho eso podemos añadir una regla que permita la conexión ssh.

~~~
nft add rule inet filter input iifname "eth0" tcp dport 22 ct state new,established counter accept
nft add rule inet filter output oifname "eth0" tcp sport 22 ct state established counter accept
~~~

* Y entonces podemos poner la política DROP por defecto.

~~~
nft chain inet filter input { policy drop \; }
nft chain inet filter output { policy drop \; }
~~~

* Una vez hecho esto podemos añadir las demás reglas.

~~~
# ICMP
nft add rule inet filter output oifname "eth0" icmp type echo-request counter accept
nft add rule inet filter input iifname "eth0" icmp type echo-reply counter accept

# DNS
nft add rule inet filter output oifname "eth0" udp dport 53 ct state new,established  counter accept
nft add rule inet filter input iifname "eth0" udp sport 53 ct state established  counter accept

# HTTP
nft add rule inet filter output oifname "eth0" ip protocol tcp tcp dport { 80,443 } ct state new,established  counter accept
nft add rule inet filter input iifname "eth0" ip protocol tcp tcp sport { 80,443 } ct state established  counter accept

nft add rule inet filter output oifname "eth0" tcp sport 80 ct state established counter accept
nft add rule inet filter input iifname "eth0" tcp dport 80 ct state new,established counter accept
~~~

* Permite conexiones ssh al exterior.

~~~
nft add rule inet filter output oifname "eth0" tcp dport 22 ct state new,established  counter accept
nft add rule inet filter input iifname "eth0" tcp sport 22 ct state established  counter accept
~~~

~~~
root@servidor:~# ssh debian@192.168.1.139
debian@192.168.1.139's password: 
Linux zeus 5.10.0-11-amd64 #1 SMP Debian 5.10.92-1 (2022-01-18) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Mon Feb 28 11:49:45 2022
~~~

* Deniega el acceso a tu servidor web desde una ip concreta.

~~~
nft insert rule inet filter output oifname "eth0" ip daddr 192.168.121.187/24 tcp sport 80 ct state established counter drop
nft insert rule inet filter input ip saddr 192.168.121.187/24 tcp dport 80 ct state new,established counter drop
~~~

~~~
vagrant@pruebas:~$ curl http://192.168.121.131:80
curl: (28) Failed to connect to 192.168.121.131 port 80: Expiró el tiempo de conexión
~~~

* Permite hacer consultas DNS sólo al servidor 192.168.202.2. Comprueba que no puedes hacer un dig @1.1.1.1.

~~~
nft add rule inet filter output oifname "eth0" ip daddr 192.168.202.2/32 udp dport 53 ct state new,established  counter accept
nft add rule inet filter input iifname "eth0" ip saddr 192.168.202.2/32 udp sport 53 ct state established  counter accept
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
;; WHEN: Tue Mar 01 10:42:23 UTC 2022
;; MSG SIZE  rcvd: 344
~~~

~~~
root@servidor:~# dig @1.1.1.1 www.google.es

; <<>> DiG 9.16.22-Debian <<>> @1.1.1.1 www.google.es
; (1 server found)
;; global options: +cmd
;; connection timed out; no servers could be reached
~~~

* No permitir el acceso al servidor web de www.josedomingo.org (Tienes que utilizar la ip).

~~~
nft insert rule inet filter output oifname "eth0" ip daddr 37.187.119.60/32 tcp dport 80 ct state new,established counter drop
nft insert rule inet filter input iifname "eth0" ip saddr 37.187.119.60/32 tcp sport 80 ct state established counter drop
~~~

~~~
root@servidor:~# curl www.josedomingo.org
curl: (28) Failed to connect to www.josedomingo.org port 80: Connection timed out
root@servidor:~# curl fp.josedomingo.org
curl: (28) Failed to connect to fp.josedomingo.org port 80: Connection timed out
~~~

* Permite mandar un correo usando nuestro servidor de correo: babuino-smtp

~~~
nft add rule inet filter output oifname "eth0" ip daddr 192.168.203.3/32 tcp dport 25 ct state new,established counter accept
nft add rule inet filter input iifname "eth0" ip saddr 192.168.203.3/32 tcp sport 25 ct state established counter accept
~~~

~~~
root@servidor:~# telnet babuino-smtp.gonzalonazareno.org 25
Trying 192.168.203.3...
Connected to babuino-smtp.gonzalonazareno.org.
Escape character is '^]'.
220 babuino-smtp.gonzalonazareno.org ESMTP Postfix (Debian/GNU)
HELO babuino-smtp.gonzalonazareno.org
250 babuino-smtp.gonzalonazareno.org

~~~

* Instala un servidor mariadb, y permite los accesos desde la ip de tu cliente.

~~~
nft add rule inet filter output oifname "eth0" ip daddr 192.168.121.187/24 tcp sport 3306 ct state established counter accept
nft add rule inet filter input iifname "eth0" ip saddr 192.168.121.187/24 tcp dport 3306 ct state new,established counter accept
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
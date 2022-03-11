+++
title = "Ejercicio 3 cortafuegos"
description = ""
tags = [
    "SAD"
]
date = "2022-03-11"
menu = "main"
+++

* Realizaremos las mismas reglas que en el ejercicio 3, ahora en nftables, para ello usaremos como hicimos el ejercicio 2 la familia inet sobre las tablas de nftables para que valgan tanto para ipv4 como para ipv6. Hagamos las tabalas y cadenas necesarias para empezar.

* Añadimos una regla para tener conexión ssh con la máquina.

~~~
nft add rule inet filter input ip saddr 192.168.1.0/24 tcp dport 22 ct state new,established counter accept
nft add rule inet filter output ip daddr 192.168.1.0/24 tcp sport 22 ct state established counter accept
~~~

* Y la regla SNAT para que la LAN tenga acceso a internet.

~~~
nft add rule inet nat postrouting oifname "ens3" ip saddr 172.16.0.200/16 counter masquerade
~~~

* Ahora podemos crear la tabla y las reglas para hacer una politica DROP.

~~~
nft add table inet filter
nft add table inet nat
nft add chain inet filter input { type filter hook input priority 0 \; counter \; policy drop \; }
nft add chain inet filter output { type filter hook output priority 0 \; counter \; policy drop \; }
nft add chain inet filter forward { type filter hook forward priority 0 \; counter \; policy drop \; }
nft add chain inet nat prerouting { type nat hook prerouting priority 0 \; }
nft add chain inet nat postrouting { type nat hook postrouting priority 100 \; }
~~~

* También debemos permitir el tráfico de la loopback.

~~~
nft add rule inet filter input iifname "lo" counter accept    
nft add rule inet filter output oifname "lo" counter accept
~~~

* Permitimos hacer ping desde el exterior a las dos interfaces.

~~~
nft add rule inet filter input iifname "ens3" icmp type echo-request counter accept
nft add rule inet filter output oifname "ens3" icmp type echo-reply counter accept

nft add rule inet filter input iifname "ens8" icmp type echo-request counter accept
nft add rule inet filter output oifname "ens8" icmp type echo-reply counter accept
~~~

~~~
alejandrogv@AlejandroGV:~$ ping 192.168.1.33
PING 192.168.1.33 (192.168.1.33) 56(84) bytes of data.
64 bytes from 192.168.1.33: icmp_seq=1 ttl=64 time=0.614 ms
^C
--- 192.168.1.33 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.614/0.614/0.614/0.000 ms
alejandrogv@AlejandroGV:~$ ping 192.16.0.1
PING 192.16.0.1 (192.16.0.1) 56(84) bytes of data.
64 bytes from 192.16.0.1: icmp_seq=1 ttl=58 time=7.79 ms
^C
--- 192.16.0.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 7.793/7.793/7.793/0.000 ms
~~~

* Permitir hacer ping desde la LAN.

~~~
nft add rule inet filter input iifname "ens8" icmp type echo-reply counter accept
nft add rule inet filter output oifname "ens8" icmp type echo-request counter accept
~~~

* Se permitirán hacer consultas DNS unicamente al servidor 192.168.202.2

~~~
nft add rule inet filter output oifname "ens3" ip daddr 192.168.202.2/32 udp dport 53 ct state new,established counter accept
nft add rule inet filter input iifname "ens3" ip saddr 192.168.202.2/32 udp sport 53 ct state established counter accept
~~~

~~~
root@servidor:~# dig @192.168.202.2 www.google.es

; <<>> DiG 9.16.22-Debian <<>> www.google.es
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 52486
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 512
;; QUESTION SECTION:
;www.google.es.			IN	A

;; ANSWER SECTION:
www.google.es.		210	IN	A	142.250.201.67

;; Query time: 0 msec
;; SERVER: 192.168.202.2#53(192.168.202.2)
;; WHEN: Mon Mar 14 13:00:46 UTC 2022
;; MSG SIZE  rcvd: 344
~~~

* Permitimos la conexión a nuestro servidor web de la red interna desde el exterior.

~~~
nft add rule inet nat prerouting iifname "ens3" tcp dport 80 counter dnat ip to 172.16.0.200
nft add rule inet filter forward iifname "ens3" oifname "ens8" ip daddr 172.16.0.0/16 tcp dport 80 ct state new,established counter accept
nft add rule inet filter forward iifname "ens8" oifname "ens3" ip saddr 172.16.0.0/16 tcp sport 80 ct state established counter accept
~~~

* Permitimos hacer conexiones ssh desde la máquina del cortafeugos al exterior.

~~~
nft add rule inet filter output oifname "ens3" tcp dport 22 ct state new,established counter accept
nft add rule inet filter input iifname "ens3" tcp sport 22 ct state established counter accept
~~~

~~~
root@debian:~# ssh debian@192.168.1.139
debian@192.168.1.139's password: 
Linux zeus 5.10.0-11-amd64 #1 SMP Debian 5.10.92-1 (2022-01-18) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Mon Mar 14 13:12:06 2022
~~~

* Permitimos que la máquina cortafuegos pueda navergar por internet.

~~~
nft add rule inet filter output oifname "ens3" tcp dport 80 ct state new,established counter accept
nft add rule inet filter input iifname "ens3" tcp sport 80 ct state established counter accept
nft add rule inet filter output oifname "ens3" tcp dport 443 ct state new,established counter accept
nft add rule inet filter input iifname "ens3" tcp sport 443 ct state established counter accept
~~~

* Permitiremos hacer ssh desde el cortafuegos a la LAN.

~~~
nft add rule inet filter output oifname "ens8" tcp dport 22 ct state new,established counter accept
nft add rule inet filter input iifname "ens8" tcp sport 22 ct state established counter accept
~~~

~~~
root@debian:~# ssh hera@172.16.0.200
hera@172.16.0.200's password: 
Activate the web console with: systemctl enable --now cockpit.socket

Last login: Fri Mar 11 04:18:48 2022
[hera@hera ~]$ 
~~~

* Permitimos hacer ping desde la LAN al cortafuegos.

~~~
nft add rule inet filter output oifname "ens8" icmp type echo-reply counter accept
nft add rule inet filter input iifname "ens8" icmp type echo-request counter accept
~~~

~~~
[hera@hera ~]$ ping 192.168.1.33
PING 192.168.1.33 (192.168.1.33) 56(84) bytes of data.
64 bytes from 192.168.1.33: icmp_seq=1 ttl=64 time=0.536 ms
^C
--- 192.168.1.33 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.536/0.536/0.536/0.000 ms
~~~

* Permitiremos que los equipos de la LAN puedan hacer ssh.

~~~
nft add rule inet filter output oifname "ens8" tcp sport 22 ct state established counter accept
nft add rule inet filter input iifname "ens8" tcp dport 22 ct state new,established counter accept
nft add rule inet filter forward iifname "ens8" oifname "ens3" tcp dport 22 ct state new,established counter accept
nft add rule inet filter forward iifname "ens3" oifname "ens8" tcp sport 22 ct state established counter accept
~~~

~~~
[hera@hera ~]$ ssh usuario@192.168.1.33
usuario@192.168.1.33's password: 
Linux debian 5.10.0-12-amd64 #1 SMP Debian 5.10.103-1 (2022-03-07) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Fri Mar 11 12:35:40 2022 from 192.168.1.54
~~~

* Instalaremos un servidor de correo en la LAN y permitiremos su acceso desde el exterior y desde la máquina cortafuegos.

~~~
nft add rule inet filter output oifname "ens8" tcp dport 25 ct state new,established counter accept
nft add rule inet filter input iifname "ens8" tcp sport 25 ct state established counter accept
~~~

* Para que esto funcione también debemos crear una regla DNAT sino no funcionará desde el exterior.

~~~
nft add rule inet nat prerouting iifname "ens3" tcp dport 25 counter dnat ip to 172.16.0.200
nft add rule inet filter forward iifname "ens3" oifname "ens8" ip daddr 172.16.0.0/16 tcp dport 25 ct state new,established counter accept
nft add rule inet filter forward iifname "ens8" oifname "ens3" ip saddr 172.16.0.0/16 tcp sport 25 ct state established counter accept
~~~

~~~
root@debian:~# telnet 172.16.0.200 25
Trying 172.16.0.200...
Connected to 172.16.0.200
Escape character is '^]'.
220 hera ESMTP Postfix (Debian/GNU)
HELO hera
250 hera

~~~

~~~
alejandrogv@AlejandroGV:~$ telnet 172.16.0.200 25
Trying 172.16.0.200...
Connected to 172.16.0.200
Escape character is '^]'.
220 hera ESMTP Postfix (Debian/GNU)
HELO hera
250 hera

~~~

* Permitiremos las conexiones ssh desde exterior a la LAN.

~~~
nft add rule inet nat prerouting iifname "ens3" tcp dport 22 counter dnat ip to 172.16.0.200
nft add rule inet filter forward iifname "ens3" oifname "ens8" ip daddr 172.16.0.0/16 tcp dport 22 ct state new,established counter accept
nft add rule inet filter forward iifname "ens8" oifname "ens3" ip saddr 172.16.0.0/16 tcp sport 22 ct state established counter accept
~~~

~~~
alejandrogv@AlejandroGV:~$ ssh hera@172.16.0.200
hera@172.16.0.200's password: 
Activate the web console with: systemctl enable --now cockpit.socket

Last login: Fri Mar 11 13:41:08 2022
[hera@hera ~]$ 
~~~

* Modificaremos esta regla para que accedamos por el puerto 2222 en vez del 22.

~~~
nft add rule inet nat prerouting iifname "ens3" tcp dport 2222 counter dnat ip to 172.16.0.200:22
~~~

~~~
alejandrogv@AlejandroGV:~$  ssh hera@172.16.0.200 -p 2222
hera@172.16.0.200's password: 
Activate the web console with: systemctl enable --now cockpit.socket

Last login: Fri Mar 11 13:50:53 2022 from 172.16.0.1
~~~

* Solo permitiremos hacer consultas a la 192.168.202.2 desde la LAN.

~~~
nft add rule inet filter forward iifname "ens8" oifname "ens3" ip daddr 192.168.202.2/32 udp dport 53 ct state new,established counter accept
nft add rule inet filter forward iifname "ens3" oifname "ens8" ip saddr 192.168.202.2/32 udp sport 53 ct state established counter accept
~~~

~~~
[hera@hera ~]$ dig www.google.es

; <<>> DiG 9.16.22-Debian <<>> www.google.es
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 42300
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 512
;; QUESTION SECTION:
;www.google.es.			IN	A

;; ANSWER SECTION:
www.google.es.		254	IN	A	142.250.201.67

;; Query time: 12 msec
;; SERVER: 192.168.1.1#53(192.168.1.1)
;; WHEN: Fri Mar 11 13:58:47 CET 2022
;; MSG SIZE  rcvd: 58
~~~

~~~
[hera@hera ~]$ dig @1.1.1.1 www.google.es

; <<>> DiG 9.16.22-Debian <<>> @1.1.1.1 www.google.es
; (1 server found)
;; global options: +cmd
;; connection timed out; no servers could be reached
~~~


* Permitiremos que los equipos de la LAN puedan navegar por internet.

~~~
nft add rule inet filter forward iifname "ens8" oifname "ens3" tcp dport 80 ct state new,established counter accept
nft add rule inet filter forward iifname "ens3" oifname "ens8" tcp sport 80 ct state established counter accept
nft add rule inet filter forward iifname "ens8" oifname "ens3" tcp dport 443 ct state new,established counter accept
nft add rule inet filter forward iifname "ens3" oifname "ens8" tcp sport 443 ct state established counter accept
~~~

~~~
[hera@hera ~]$ curl https://alepeteporico.github.io
<!DOCTYPE html>
<html lang="en-us">
	<head>
		<title> Alepetepórico Blog </title>

		<meta http-equiv="content-type" content="text/html; charset=utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1">
<meta name="generator" content="Hugo 0.80.0" />




<script src="https://code.jquery.com/jquery-3.1.1.min.js"   integrity="sha256-hVVnYaiADRTO2PzUGmuLJr8BLUSjGIZsDYGmIJLv2b8="   crossorigin="anonymous"></script>
~~~
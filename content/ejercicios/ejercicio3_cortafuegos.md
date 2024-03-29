+++
title = "Ejercicio 3 cortafuegos"
description = ""
tags = [
    "SAD"
]
date = "2022-03-10"
menu = "main"
+++

* Tendremos una máquina conectado a dos interfaces red, una que da al exterior y otra interna. Lo una vez preparada debemos hacer una regla snat para que la red interna pueda salir al exterior.

~~~
iptables -t nat -A POSTROUTING -s 172.16.0.0/24 -o ens3 -j MASQUERADE
~~~

* Como hemos estado haciendo vamos a añadir la regla de ssh para poder poner la politica DROP sin problema.

~~~
iptables -A INPUT -s 192.168.1.0/24 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -d 192.168.1.0/24 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
~~~

~~~
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
~~~

* Permitimos el tráfico para la interfaz loopback

~~~
iptables -A INPUT -i lo -p icmp -j ACCEPT
iptables -A OUTPUT -o lo -p icmp -j ACCEPT
~~~

* Peticiones ICMP desde el exterior a las dos interfaces.

~~~
iptables -A OUTPUT -o ens3 -p icmp -m icmp --icmp-type echo-reply -j ACCEPT
iptables -A INPUT -i ens3 -p icmp -m icmp --icmp-type echo-request -j ACCEPT

iptables -A OUTPUT -o ens8 -p icmp -m icmp --icmp-type echo-reply -j ACCEPT
iptables -A INPUT -i ens8 -p icmp -m icmp --icmp-type echo-request -j ACCEPT
~~~

~~~
alejandrogv@AlejandroGV:~$ ping 192.168.1.33
PING 192.168.1.33 (192.168.1.33) 56(84) bytes of data.
64 bytes from 192.168.1.33: icmp_seq=1 ttl=64 time=0.719 ms
^C
--- 192.168.1.33 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.719/0.719/0.719/0.000 ms
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
iptables -A FORWARD -o ens3 -i ens8 -s 192.168.1.0/24 -p icmp -m icmp --icmp-type echo-request -j ACCEPT
iptables -A FORWARD -i ens3 -o ens8 -d 192.168.1.0/24 -p icmp -m icmp --icmp-type echo-reply -j ACCEPT
~~~

* Se permitirán hacer consultas DNS unicamente al servidor 192.168.202.2

~~~
iptables -A INPUT -s 192.168.202.2/32 -p udp --sport 53 -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -d 192.168.202.2/32 -p udp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
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
;; WHEN: Mon Mar 14 12:33:46 UTC 2022
;; MSG SIZE  rcvd: 344
~~~

* Permitimos la conexión web desde la LAN.

~~~
iptables -A FORWARD -i ens8 -o ens3 -s 192.168.1.0/24 -p tcp -m multiport --dport 80,443 -m state --state NEW,ESTABLISHED -m time \
--timestart 10:00 --timestop 16:30 -j ACCEPT
iptables -A FORWARD -o ens8 -i ens3 -d 192.168.1.0/24 -p tcp -m multiport --sport 80,443 -m state --state ESTABLISHED -m time \
--timestart 10:00 --timestop 16:30 -j ACCEPT
~~~

* Permitimos la conexión a nuestro servidor web de la red interna desde el exterior.

~~~
iptables -t nat -A PREROUTING -i ens3 -p tcp --dport 80 -j DNAT --to 172.16.0.200
iptables -A FORWARD -i ens3 -o ens8 -d 172.16.0.200/16 -p tcp --dport 80 -m state --state NEW,ESTABLISHED  -j ACCEPT
iptables -A FORWARD -i ens8 -o ens3 -s 172.16.0.200/16 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT
~~~


* Permitimos hacer conexiones ssh desde la máquina del cortafeugos.

~~~
iptables -A INPUT -i ens3 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o ens3 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
~~~

~~~
root@debian:~# ssh debian@192.168.1.139
The authenticity of host '192.168.1.139 (192.168.1.139)' can't be established.
ECDSA key fingerprint is SHA256:l8TgJ0HFoxGaU0vs9JPTeePVkPecz32d/vMFW77BMmg.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '192.168.1.139' (ECDSA) to the list of known hosts.
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
iptables -A INPUT -i ens3 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o ens3 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i ens3 -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o ens3 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
~~~

* Permitiremos hacer ssh desde el cortafuegos a la LAN.

~~~
iptables -A INPUT -i ens8 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o ens8 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
~~~

~~~
root@debian:~# ssh hera@172.16.0.200
The authenticity of host '172.16.0.200 (172.16.0.200)' can't be established.
ECDSA key fingerprint is SHA256:rs9zJTzdWR4/wPrXHywOC8T85qNX1u+BrvLgmK8x+Jk.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '172.16.0.200' (ECDSA) to the list of known hosts.
hera@172.16.0.200's password: 
Activate the web console with: systemctl enable --now cockpit.socket

Last login: Fri Mar 11 04:18:48 2022
[hera@hera ~]$ 
~~~

* Permitimos hacer ping desde la LAN al cortafuegos.

~~~
iptables -A OUTPUT -o ens8 -p icmp -m icmp --icmp-type echo-reply -j ACCEPT
iptables -A INPUT -i ens8 -p icmp -m icmp --icmp-type echo-request -j ACCEPT
~~~

~~~
[hera@hera ~]$ ping 192.168.1.33
PING 192.168.1.33 (192.168.1.33) 56(84) bytes of data.
64 bytes from 192.168.1.33: icmp_seq=1 ttl=64 time=0.737 ms
^C
--- 192.168.1.33 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.737/0.737/0.737/0.000 ms
~~~

* Permitiremos que los equipos de la LAN puedan hacer ssh.

~~~
iptables -A INPUT -i ens8 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o ens8 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
iptables -A FORWARD -i ens8 -o ens3 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i ens3 -o ens8 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
~~~

~~~
[hera@hera ~]$ ssh usuario@192.168.1.33
The authenticity of host '192.168.1.33 (192.168.1.33)' can't be established.
ECDSA key fingerprint is SHA256:rUbNqLNtKeypIXzgN8I1+J7cJ070BZrtH/m22naYwOg.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '192.168.1.33' (ECDSA) to the list of known hosts.
usuario@192.168.1.33's password: 
Linux debian 5.10.0-12-amd64 #1 SMP Debian 5.10.103-1 (2022-03-07) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Fri Mar 11 11:05:23 2022 from 192.168.1.54
~~~

* Instalaremos un servidor de correo en la LAN y permitiremos su acceso desde el exterior y desde la máquina cortafuegos.

~~~
iptables -A INPUT -i ens8 -p tcp --sport 25 -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o ens8 -p tcp --dport 25 -m state --state NEW,ESTABLISHED -j ACCEPT
~~~

* Para que esto funcione también debemos crear una regla DNAT sino no funcionará desde el exterior.

~~~
iptables -t nat -A PREROUTING -p tcp --dport 25 -i ens3 -j DNAT --to 172.16.0.200
iptables -A FORWARD -i ens3 -o ens8 -p tcp --dport 25 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i ens8 -o ens3 -p tcp --sport 25 -m state --state ESTABLISHED -j ACCEPT
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
iptables -t nat -A PREROUTING -p tcp --dport 22 -i ens3 -j DNAT --to 172.16.0.200
iptables -A FORWARD -i ens3 -o ens8 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i ens8 -o ens3 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
~~~

~~~
alejandrogv@AlejandroGV:~$ ssh hera@172.16.0.200
The authenticity of host '172.16.0.200 (172.16.0.200)' can't be established.
ECDSA key fingerprint is SHA256:rs9zJTzdWR4/wPrXHywOC8T85qNX1u+BrvLgmK8x+Jk.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '172.16.0.200' (ECDSA) to the list of known hosts.
hera@172.16.0.200's password: 
Activate the web console with: systemctl enable --now cockpit.socket

Last login: Fri Mar 11 11:51:37 2022
[hera@hera ~]$ 
~~~

* Modificaremos esta regla para que accedamos por el puerto 2222 en vez del 22.

~~~
iptables -t nat -A PREROUTING -p tcp --dport 2222 -i ens3 -j DNAT --to 172.16.0.200:22
~~~

~~~
alejandrogv@AlejandroGV:~$  ssh hera@172.16.0.200 -p 2222
hera@172.16.0.200's password: 
Activate the web console with: systemctl enable --now cockpit.socket

Last login: Fri Mar 11 05:34:20 2022 from 172.16.0.1
~~~

* Solo permitiremos hacer consultas a la 192.168.202.2 desde la LAN.

~~~
iptables -A FORWARD -i ens8 -o ens3 -d 192.168.202.2 -p udp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i ens3 -o ens8 -s 192.168.202.2 -p udp --sport 53 -m state --state ESTABLISHED -j ACCEPT
~~~

~~~
[hera@hera ~]$ dig @192.168.202.2 www.google.es

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
;; WHEN: Mon Mar 14 12:43:17 UTC 2022
;; MSG SIZE  rcvd: 344
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
iptables -A FORWARD -i ens8 -o ens3 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i ens3 -o ens8 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT
iptables -A FORWARD -i ens8 -o ens3 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i ens3 -o ens8 -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT
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
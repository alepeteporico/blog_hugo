+++
title = "Cortafuegos perimetral sobre el escenario"
description = ""
tags = [
    "SAD"
]
date = "2022-03-21"
menu = "main"
+++

* Política por defecto DROP para las cadenas INPUT, FORWARD y OUTPUT.

~~~
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
~~~

* La máquina Zeus tiene un servidor ssh escuchando por el puerto 22, pero al acceder desde el exterior habrá que conectar al puerto 2222.

~~~
iptables -t nat -A PREROUTING -p tcp --dport 2222 -i eth0 -j DNAT --to 172.22.0.169:22
iptables -A INPUT -i eth0 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
~~~

~~~
alejandrogv@AlejandroGV:~$ ssh -A debian@172.22.0.169 -p 2222
Linux zeus 5.10.0-13-amd64 #1 SMP Debian 5.10.106-1 (2022-03-17) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Mon May 16 08:30:53 2022 from 172.22.9.224
~~~

* Desde Apolo y Hera se debe permitir la conexión ssh por el puerto 22 a la máquina Zeus.

~~~
iptables -A OUTPUT -d 10.0.1.0/24 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -s 10.0.1.0/24 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

iptables -A OUTPUT -d 172.16.0.0/16 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -s 172.16.0.0/16 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
~~~

~~~
[usuario@hera ~]$ ssh debian@zeus
The authenticity of host 'zeus (172.16.0.1)' can't be established.
ECDSA key fingerprint is SHA256:nlCuHwuwtd5wicKE8nV+dWihioEMoIV6HYJSqG22jRA.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'zeus,172.16.0.1' (ECDSA) to the list of known hosts.
Linux zeus 5.10.0-13-amd64 #1 SMP Debian 5.10.106-1 (2022-03-17) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Mon May 16 08:34:26 2022 from 172.22.9.224


usuario@apolo:~$ ssh debian@zeus
The authenticity of host 'zeus (10.0.1.1)' can't be established.
ECDSA key fingerprint is SHA256:nlCuHwuwtd5wicKE8nV+dWihioEMoIV6HYJSqG22jRA.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'zeus,10.0.1.1' (ECDSA) to the list of known hosts.
Linux zeus 5.10.0-13-amd64 #1 SMP Debian 5.10.106-1 (2022-03-17) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Mon May 16 08:37:16 2022 from 172.16.0.200
~~~

* La máquina Zeus debe tener permitido el tráfico para la interfaz loopback.

~~~
iptables -A INPUT -i lo -p icmp -j ACCEPT
iptables -A OUTPUT -o lo -p icmp -j ACCEPT
~~~

~~~
debian@zeus:~$ ping 127.0.0.1
PING 127.0.0.1 (127.0.0.1) 56(84) bytes of data.
64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.099 ms
64 bytes from 127.0.0.1: icmp_seq=2 ttl=64 time=0.060 ms
^C
--- 127.0.0.1 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1026ms
rtt min/avg/max/mdev = 0.060/0.079/0.099/0.019 ms
~~~

* A la máquina Zeus se le puede hacer ping desde la DMZ, pero desde la LAN se le debe rechazar la conexión (REJECT) y desde el exterior se rechazará de manera silenciosa.

~~~
iptables -A INPUT -s 172.16.0.200/16 -p icmp -m icmp --icmp-type echo-request -j ACCEPT
iptables -A OUTPUT -d 172.16.0.200/16 -p icmp -m icmp --icmp-type echo-reply -j ACCEPT

iptables -A INPUT -s 10.0.1.0/24 -p icmp -m icmp --icmp-type echo-request -j REJECT
iptables -A OUTPUT -d 10.0.1.0/24 -p icmp -m icmp --icmp-type echo-reply -j REJECT
~~~

- Exterior:

~~~
alejandrogv@AlejandroGV:~$ ping 172.22.0.169
PING 172.22.0.169 (172.22.0.169) 56(84) bytes of data.
^C
--- 172.22.0.169 ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 2036ms
~~~

- LAN:

~~~
usuario@apolo:~$ ping zeus
PING zeus.alexgv.gonzalonazareno.org (10.0.1.1) 56(84) bytes of data.
^C
--- zeus.alexgv.gonzalonazareno.org ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 2024ms
~~~

- DMZ:

~~~
[usuario@hera ~]$ ping zeus
PING zeus (172.16.0.1) 56(84) bytes of data.
64 bytes from zeus (172.16.0.1): icmp_seq=1 ttl=64 time=0.775 ms
^C
--- zeus ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.775/0.775/0.775/0.000 ms
~~~


* La máquina Zeus puede hacer ping a la LAN, la DMZ y al exterior.

~~~
iptables -A OUTPUT -p icmp -m icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -p icmp -m icmp --icmp-type echo-reply -j ACCEPT
~~~

- Exterior:

~~~
debian@zeus:~$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=114 time=83.7 ms
^C
--- 8.8.8.8 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 83.746/83.746/83.746/0.000 ms
~~~

- LAN:

~~~
debian@zeus:~$ ping apolo
PING apolo (10.0.1.102) 56(84) bytes of data.
64 bytes from apolo (10.0.1.102): icmp_seq=1 ttl=64 time=0.526 ms
^C
--- apolo ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.526/0.526/0.526/0.000 ms
~~~

- DMZ:

~~~
debian@zeus:~$ ping hera
PING hera (172.16.0.200) 56(84) bytes of data.
64 bytes from hera (172.16.0.200): icmp_seq=1 ttl=64 time=0.586 ms
^C
--- hera ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.586/0.586/0.586/0.000 ms
~~~

* Desde la máquina Hera se puede hacer ping y conexión ssh a las máquinas de la LAN.

~~~
iptables -A FORWARD -s 172.16.0.200/16 -d 10.0.1.0/24 -p icmp -m icmp --icmp-type echo-request -j ACCEPT
iptables -A FORWARD -d 172.16.0.200/16 -s 10.0.1.0/24 -p icmp -m icmp --icmp-type echo-reply -j ACCEPT

iptables -A FORWARD -s 172.16.0.200/16 -d 10.0.1.0/24 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -d 172.16.0.200/16 -s 10.0.1.0/24 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
~~~

~~~
[usuario@hera ~]$ ping apolo
PING apolo (10.0.1.102) 56(84) bytes of data.
64 bytes from apolo (10.0.1.102): icmp_seq=1 ttl=63 time=1.44 ms
^C
--- apolo ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 1.441/1.441/1.441/0.000 ms
[usuario@hera ~]$ ssh usuario@apolo
The authenticity of host 'apolo (10.0.1.102)' can't be established.
ECDSA key fingerprint is SHA256:qfzJuZFA97ec7vBFW/Zjn9bE474vwOFmQKuCBK1TaUA.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'apolo,10.0.1.102' (ECDSA) to the list of known hosts.
Linux apolo 5.10.0-12-amd64 #1 SMP Debian 5.10.103-1 (2022-03-07) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Mon May 16 08:41:57 2022 from 10.0.1.1
usuario@apolo:~$
~~~

* Desde cualquier máquina de la LAN se puede conectar por ssh a la máquina Hera.

~~~
iptables -A FORWARD -s 10.0.1.0/24 -d 172.16.0.200/16 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -s 172.16.0.200/16 -d 10.0.1.0/24 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
~~~

~~~
usuario@apolo:~$ ssh usuario@hera
Web console: https://hera.alexgv.gonzalonazareno.org:9090/ or https://172.16.0.200:9090/

Last login: Mon May 16 08:46:44 2022 from 172.16.0.1
[usuario@hera ~]$
~~~

* Configura la máquina Zeus para que las máquinas de LAN y DMZ puedan acceder al exterior.

~~~
iptables -t nat -A POSTROUTING -s 172.16.0.0/16 -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth2 -o eth0 -p icmp -m icmp --icmp-type echo-request -j ACCEPT
iptables -A FORWARD -i eth0 -o eth2 -p icmp -m icmp --icmp-type echo-reply -j ACCEPT

iptables -t nat -A POSTROUTING -s 10.0.1.0/24 -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth1 -o eth0 -p icmp -m icmp --icmp-type echo-request -j ACCEPT
iptables -A FORWARD -i eth0 -o eth1 -p icmp -m icmp --icmp-type echo-reply -j ACCEPT
~~~

~~~
[usuario@hera ~]$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=113 time=250 ms
^C
--- 8.8.8.8 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 250.389/250.389/250.389/0.000 ms

usuario@apolo:~$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=113 time=264 ms
^C
--- 8.8.8.8 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 264.172/264.172/264.172/0.000 ms
~~~

* Las máquinas de la LAN pueden hacer ping al exterior y navegar.

~~~
iptables -A FORWARD -i eth1 -o eth0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -o eth1 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT

iptables -A FORWARD -i eth1 -o eth0 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -o eth1 -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT
~~~

~~~
usuario@apolo:~$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=113 time=46.8 ms
^C
--- 8.8.8.8 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 46.796/46.796/46.796/0.000 ms

usuario@apolo:~$ curl 1.1.1.1
<html>
<head><title>301 Moved Permanently</title></head>
<body>
<center><h1>301 Moved Permanently</h1></center>
<hr><center>cloudflare</center>
</body>
</html>
~~~

* La máquina Hera puede navegar.

~~~
iptables -A FORWARD -i eth2 -o eth0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -o eth2 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT

iptables -A FORWARD -i eth2 -o eth0 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -o eth2 -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT
~~~

~~~
[usuario@hera ~]$ curl 1.1.1.1
<html>
<head><title>301 Moved Permanently</title></head>
<body>
<center><h1>301 Moved Permanently</h1></center>
<hr><center>cloudflare</center>
</body>
</html>
~~~

* Debemos permitir las consultas al escenario.

~~~
iptables -A OUTPUT -p udp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p udp --sport 53 -m state --state ESTABLISHED -j ACCEPT

iptables -t nat -A PREROUTING -p udp -i eth0 --dport 53 -j DNAT --to 10.0.1.102
iptables -A FORWARD -p udp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p udp --sport 53 -m state --state ESTABLISHED -j ACCEPT
~~~

~~~
alejandrogv@AlejandroGV:~$ dig @172.22.0.169 www.alexgv.gonzalonazareno.org

; <<>> DiG 9.16.27-Debian <<>> @172.22.0.169 www.alexgv.gonzalonazareno.org
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 31867
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: ec6144b3134687bb010000006281f58f706fd7405087e533 (good)
;; QUESTION SECTION:
;www.alexgv.gonzalonazareno.org.	IN	A

;; ANSWER SECTION:
www.alexgv.gonzalonazareno.org.	86400 IN CNAME	zeus.alexgv.gonzalonazareno.org.
zeus.alexgv.gonzalonazareno.org. 86400 IN A	172.22.0.169

;; Query time: 3 msec
;; SERVER: 172.22.0.169#53(172.22.0.169)
;; WHEN: Mon May 16 08:56:16 CEST 2022
;; MSG SIZE  rcvd: 122
~~~

* Configura la máquina Zeus para que los servicios web y ftp sean accesibles desde el exterior.

~~~
iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 80 -j DNAT --to 172.16.0.200
iptables -A FORWARD -i eth0 -o eth2 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth2 -o eth0 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT

iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 21 -j DNAT --to 172.16.0.200
iptables -A FORWARD -i eth0 -o eth2 -p tcp --dport 21 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth2 -o eth0 -p tcp --sport 21 -m state --state ESTABLISHED -j ACCEPT
~~~

~~~
alejandrogv@AlejandroGV:~$ telnet 172.22.0.169 21
Trying 172.22.0.169...
Connected to 172.22.0.169.
Escape character is '^]'.
220 (vsFTPd 3.0.3)
~~~

![web](/cortafuegos5/1.png)

* El servidor web y el servidor ftp deben ser accesibles desde la LAN y desde el exterior.

~~~
iptables -A FORWARD -i eth1 -o eth2 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth2 -o eth1 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT

iptables -A FORWARD -i eth1 -o eth2 -p tcp --dport 21 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth2 -o eth1 -p tcp --sport 21 -m state --state ESTABLISHED -j ACCEPT
~~~

* El servidor de correos sólo debe ser accesible desde la LAN.

~~~
iptables -A FORWARD -i eth1 -o eth2 -p tcp --dport 25 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth2 -o eth1 -p tcp --sport 25 -m state --state ESTABLISHED -j ACCEPT
~~~

~~~
alejandrogv@AlejandroGV:~$ telnet 172.16.0.200 25
Trying 172.16.0.200...
Connected to 172.16.0.200.
Escape character is '^]'.
220  hera.localdomain ESMTP Postfix
HELO hera.localdomain
250 hera.localdomain
~~~

* En la máquina Ares instala un servidor mysql si no lo tiene aún. A este servidor se puede acceder desde la DMZ, pero no desde el exterior.

~~~
iptables -A FORWARD -i eth2 -o eth1 -p tcp --dport 3306 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth1 -o eth2 -p tcp --sport 3306 -m state --state ESTABLISHED -j ACCEPT
~~~

~~~
[usuario@hera ~]# mysql -u ale -p -h bd.alexgv.gonzalonazareno.org
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 37
Server version: 10.3.29-MariaDB-0ubuntu0.20.04.1 Ubuntu 20.04

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]>
~~~

* Evita ataques DoS por ICMP Flood, limitando el número de peticiones por segundo desde una misma IP.

~~~
iptables -A INPUT -i eth2 -p icmp -m state --state NEW --icmp-type echo-request -m limit --limit 1/s --limit-burst 1 -j ACCEPT
~~~

~~~
[usuario@hera ~]$ ping 172.16.0.1 -f
PING 172.16.0.1 (172.16.0.1) 56(84) bytes of data.
ping: cannot flood; minimal interval allowed for user is 200ms
~~~

* Evita ataques DoS por SYN Flood.

~~~
iptables -N syn_flood
iptables -A INPUT -p tcp --syn -j syn_flood
iptables -A syn_flood -m limit --limit 1/s --limit-burst 3 -j RETURN
iptables -A syn_flood -j DROP
~~~

~~~
[usuario@hera ~]$ hping3 -a 8.8.8.8 -S --flood 172.16.0.1
[open_sockraw] socket(): Operation not permitted
[main] can't open raw socke
~~~

* Evita que realicen escaneos de puertos a Zeus.

~~~
iptables -A INPUT -p tcp --tcp-flags ALL NONE -m limit --limit 3/m --limit-burst 5 -j LOG --log-prefix "Firewall> Null scan "
iptables -A INPUT -p tcp --tcp-flags ALL NONE  -m recent --name blacklist_60 --set -m comment --comment "Drop/Blacklist Null scan" -j DROP
~~~

~~~
alejandrogv@AlejandroGV:~$ sudo nmap -sN 172.22.0.169
~~~

### Reglas extra para que sigan funcionando nuestros servicios.

* Apolo puede hacer peticiones DNS a otros servidores.

~~~
iptables -A OUTPUT -p tcp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --sport 53 -m state --state ESTABLISHED -j ACCEPT

iptables -A FORWARD -p tcp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p tcp --sport 53 -m state --state ESTABLISHED -j ACCEPT
~~~

* Zeus podrá navegar.

~~~
iptables -A OUTPUT -o eth0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i eth0 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT

iptables -A OUTPUT -o eth0 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i eth0 -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT
~~~

### Debemos implementar que el cortafuegos funcione después de un reinicio de la máquina. 

* Creamos el siguiente fichero con todas las reglas.

~~~
### Limpieza de reglas antiguas
iptables -F
iptables -t nat -F
iptables -Z
iptables -t nat -Z

### Política por defecto
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

### Permitimos conectarnos por ssh al cortafuegos, creando una regla DNAT para que acceda a traves del puerto 2222
iptables -t nat -A PREROUTING -p tcp --dport 2222 -i eth0 -j DNAT --to 172.22.0.169:22
iptables -A INPUT -i eth0 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

### Permitimos la conexion ssh desde Zeus a cualquier maquina de la LAN y la DMZ (para poder seguir usando el escenario)
iptables -A OUTPUT -d 10.0.1.0/24 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -s 10.0.1.0/24 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

iptables -A OUTPUT -d 172.16.0.0/16 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -s 172.16.0.0/16 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

### Permitimos trafico para la interfaz loopback
iptables -A INPUT -i lo -p icmp -j ACCEPT
iptables -A OUTPUT -o lo -p icmp -j ACCEPT

### Desde Apolo y Hera se debe permitir la conexion ssh por el puerto 22 a la maquina Zeus
iptables -A OUTPUT -d 10.0.1.102/24 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
iptables -A INPUT -s 10.0.1.102/24 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT

iptables -A OUTPUT -d 172.16.0.200/16 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
iptables -A INPUT -s 172.16.0.200/16 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT

### A la maquina Zeus se le puede hacer ping desde la DMZ, pero desde la LAN se le debe rechazar la conexión (REJECT) y desde el exterior se rechazara de manera silenciosa
#iptables -A INPUT -s 172.16.0.200/16 -p icmp -m icmp --icmp-type echo-request -j ACCEPT
iptables -A OUTPUT -d 172.16.0.200/16 -p icmp -m icmp --icmp-type echo-reply -j ACCEPT

iptables -A INPUT -s 10.0.1.0/24 -p icmp -m icmp --icmp-type echo-request -j REJECT
iptables -A OUTPUT -d 10.0.1.0/24 -p icmp -m icmp --icmp-type echo-reply -j REJECT

### La maquina Zeus puede hacer ping a la LAN, la DMZ y al exterior
iptables -A OUTPUT -p icmp -m icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -p icmp -m icmp --icmp-type echo-reply -j ACCEPT

### Desde la maquina Hera se puede hacer ping y conexion ssh a las maquinas de la LAN
iptables -A FORWARD -s 172.16.0.200/16 -d 10.0.1.0/24 -p icmp -m icmp --icmp-type echo-request -j ACCEPT
iptables -A FORWARD -d 172.16.0.200/16 -s 10.0.1.0/24 -p icmp -m icmp --icmp-type echo-reply -j ACCEPT

iptables -A FORWARD -s 172.16.0.200/16 -d 10.0.1.0/24 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -d 172.16.0.200/16 -s 10.0.1.0/24 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

### Desde cualquier maquina de la LAN se puede conectar por ssh a la maquina Hera.
iptables -A FORWARD -s 10.0.1.0/24 -d 172.16.0.200/16 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -s 172.16.0.200/16 -d 10.0.1.0/24 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

### Configura la maquina Zeus para que las maquinas de LAN y DMZ puedan acceder al exterior
iptables -t nat -A POSTROUTING -s 172.16.0.0/16 -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth2 -o eth0 -p icmp -m icmp --icmp-type echo-request -j ACCEPT
iptables -A FORWARD -i eth0 -o eth2 -p icmp -m icmp --icmp-type echo-reply -j ACCEPT

iptables -t nat -A POSTROUTING -s 10.0.1.0/24 -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth1 -o eth0 -p icmp -m icmp --icmp-type echo-request -j ACCEPT
iptables -A FORWARD -i eth0 -o eth1 -p icmp -m icmp --icmp-type echo-reply -j ACCEPT

### Las maquinas de la LAN pueden navegar
iptables -A FORWARD -i eth1 -o eth0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -o eth1 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT

iptables -A FORWARD -i eth1 -o eth0 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -o eth1 -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT

### La maquina Hera puede navegar
iptables -A FORWARD -i eth2 -o eth0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -o eth2 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT

iptables -A FORWARD -i eth2 -o eth0 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -o eth2 -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT

### Permitimos las consultas DNS en el escenario, incluyendo las consultas a apolo desde el exterior
iptables -A OUTPUT -p udp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p udp --sport 53 -m state --state ESTABLISHED -j ACCEPT

iptables -t nat -A PREROUTING -p udp -i eth0 --dport 53 -j DNAT --to 10.0.1.102
iptables -A FORWARD -p udp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p udp --sport 53 -m state --state ESTABLISHED -j ACCEPT

### Configura la maquina Zeus para que los servicios web y ftp sean accesibles desde el exterior
iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 80 -j DNAT --to 172.16.0.200
iptables -A FORWARD -i eth0 -o eth2 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth2 -o eth0 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT

iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 21 -j DNAT --to 172.16.0.200
iptables -A FORWARD -i eth0 -o eth2 -p tcp --dport 21 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth2 -o eth0 -p tcp --sport 21 -m state --state ESTABLISHED -j ACCEPT

### El servidor web y el servidor ftp deben ser accesibles desde la LAN
iptables -A FORWARD -i eth1 -o eth2 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth2 -o eth1 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT

iptables -A FORWARD -i eth1 -o eth2 -p tcp --dport 21 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth2 -o eth1 -p tcp --sport 21 -m state --state ESTABLISHED -j ACCEPT

### Al servidor MariaDb en Ares se puede acceder desde la DMZ, pero no desde el exterior
iptables -A FORWARD -i eth2 -o eth1 -p tcp --dport 3306 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth1 -o eth2 -p tcp --sport 3306 -m state --state ESTABLISHED -j ACCEPT

### El servidor de correos solo debe ser accesible desde la LAN
iptables -A FORWARD -i eth1 -o eth2 -p tcp --dport 25 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth2 -o eth1 -p tcp --sport 25 -m state --state ESTABLISHED -j ACCEPT

### Evita ataques DoS por ICMP Flood, limitando el numero de peticiones por segundo desde una misma IP
iptables -A INPUT -i eth2 -p icmp -m state --state NEW --icmp-type echo-request -m limit --limit 1/s --limit-burst 1 -j ACCEPT

### Evita ataques DoS por SYN Flood
iptables -N syn_flood
iptables -A INPUT -p tcp --syn -j syn_flood
iptables -A syn_flood -m limit --limit 1/s --limit-burst 3 -j RETURN
iptables -A syn_flood -j DROP

### Evita que realicen escaneos de puertos a Zeus.
iptables -A INPUT -p tcp --tcp-flags ALL NONE -m limit --limit 3/m --limit-burst 5 -j LOG --log-prefix "Firewall> Null scan "
iptables -A INPUT -p tcp --tcp-flags ALL NONE  -m recent --name blacklist_60 --set -m comment --comment "Drop/Blacklist Null scan" -j DROP

### Apolo puede hacer peticiones DNS a otros servidores.
iptables -A OUTPUT -p tcp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --sport 53 -m state --state ESTABLISHED -j ACCEPT

iptables -A FORWARD -p tcp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p tcp --sport 53 -m state --state ESTABLISHED -j ACCEPT

### Zeus podrá navegar
iptables -A OUTPUT -o eth0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i eth0 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT

iptables -A OUTPUT -o eth0 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i eth0 -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT
~~~

* Cambiamos los permisos.

~~~
root@zeus:/etc# chmod 700 reglas.sh
~~~

* Crearemos una unidad de systemd que se encargue de ejecutar este fichero cada vez que se inicie la máquina.

~~~
[Unit]
Description=reglas del firewall
After=systemd-sysctl.service

[Service]
Type=oneshot
ExecStart=/etc/reglas.sh

[Install]
WantedBy=multi-user.target
~~~

* Habilitamos este servicio.

~~~
systemctl enable reglas.service
~~~
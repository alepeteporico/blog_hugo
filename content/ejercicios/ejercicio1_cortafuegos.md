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
 Limpiamos las tablas
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

* Permite poder hacer conexiones ssh al exterior. (Esta regla ya se contempla anteriormente)

~~~
vagrant@bullseye:~$ sudo iptables -A INPUT -s 192.168.121.0/24 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
vagrant@bullseye:~$ sudo iptables -A OUTPUT -d 192.168.121.0/24 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
~~~

* Deniega el acceso a tu servidor web desde una ip concreta.

~~~
iptables -A OUTPUT -p tcp -d 172.22.0.59 --dport 80 -j DROP

root@bullseye:~# iptables -s 172.22.0.159 -A INPUT -p tcp --dport 80 -m state --state ESTABLISHED -j DROP
root@bullseye:~# iptables -s 172.22.0.159 -A OUTPUT -p tcp --sport 80 -m state --state ESTABLISHED -j DROP
~~~

~~~
alejandrogv@AlejandroGV:~$ curl http://192.168.121.154:80
curl: (28) Failed to connect to 192.168.121.154 port 80: Expiró el tiempo de conexión
~~~

* Permite hacer consultas DNS sólo al servidor 192.168.202.2. Comprueba que no puedes hacer un dig @1.1.1.1.

~~~
iptables -s 172.22.0.159 -A INPUT -p tcp --dport 80 -m state --state ESTABLISHED -j DROP
~~~


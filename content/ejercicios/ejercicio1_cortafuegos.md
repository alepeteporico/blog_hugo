+++
title = "Ejercicio 1 cortafuegos"
description = ""
tags = [
    "SAD"
]
date = "2022-02-03"
menu = "main"
+++

* Permite poder hacer conexiones ssh al exterior.

~~~
vagrant@bullseye:~$ sudo iptables -A INPUT -s 192.168.121.0/24 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
vagrant@bullseye:~$ sudo iptables -A OUTPUT -d 192.168.121.0/24 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
~~~

* Deniega el acceso a tu servidor web desde una ip concreta.

~~~
vagrant@bullseye:~$ sudo iptables -s 172.22.0.159 -A INPUT -p tcp --sport 80 -m state --state ESTABLISHED -j DROP
~~~

~~~
alejandrogv@AlejandroGV:~$ curl http://192.168.121.154:80
curl: (28) Failed to connect to 192.168.121.154 port 80: Expiró el tiempo de conexión
~~~

* Permite hacer consultas DNS sólo al servidor 192.168.202.2. Comprueba que no puedes hacer un dig @1.1.1.1.

~~~
vagrant@bullseye:~$ sudo iptables -A OUTPUT ! -s 192.168.202.2 -p udp --dport 53 -m state --state NEW,ESTABLISHED -j DROP
vagrant@bullseye:~$ sudo iptables -A INPUT ! -s 192.168.202.2 -p udp --sport 53 -m state --state ESTABLISHED -j DROP
~~~
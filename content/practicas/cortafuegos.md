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
iptables -t nat -A PREROUTING -p tcp --dport 2222 -i enp0s8 -j DNAT --to 172.22.0.27:22
iptables -A INPUT -i enp0s8 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o enp0s8 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
~~~

* Desde Apolo y Hera se debe permitir la conexión ssh por el puerto 22 a la máquina Zeus.

~~~
iptables -A OUTPUT -d 10.0.1.0/24 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -s 10.0.1.0/24 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

iptables -A OUTPUT -d 172.16.0.0/16 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -s 172.16.0.0/16 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
~~~

* La máquina Zeus debe tener permitido el tráfico para la interfaz loopback.

~~~
iptables -A OUTPUT -d 10.0.1.102/32 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
iptables -A INPUT -s 10.0.1.102/32 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT

iptables -A OUTPUT -d 172.16.0.200/32 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
iptables -A INPUT -s 172.16.0.200/32 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
~~~

* Permitimos la conexión por la loopback.

~~~
iptables -A INPUT -i lo -p icmp -j ACCEPT
iptables -A OUTPUT -o lo -p icmp -j ACCEPT
~~~

* A la máquina Zeus se le puede hacer ping desde la DMZ, pero desde la LAN se le debe rechazar la conexión (REJECT) y desde el exterior se rechazará de manera silenciosa.

~~~
iptables -A INPUT -s 172.16.0.200/16 -p icmp -m icmp --icmp-type echo-request -j ACCEPT
iptables -A OUTPUT -d 172.16.0.200/16 -p icmp -m icmp --icmp-type echo-reply -j ACCEPT

iptables -A INPUT -s 10.0.1.0/24 -p icmp -m icmp --icmp-type echo-request -j REJECT
iptables -A OUTPUT -d 10.0.1.0/24 -p icmp -m icmp --icmp-type echo-reply -j REJECT
~~~

* La máquina Zeus puede hacer ping a la LAN, la DMZ y al exterior.

~~~
iptables -A OUTPUT -p icmp -m icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -p icmp -m icmp --icmp-type echo-reply -j ACCEPT
~~~

* Desde la máquina Hera se puede hacer ping y conexión ssh a las máquinas de la LAN.

~~~
iptables -A FORWARD -s 172.16.0.200/32 -d 10.0.1.0/24 -p icmp -m icmp --icmp-type echo-request -j ACCEPT
iptables -A FORWARD -d 172.16.0.200/32 -s 10.0.1.0/24 -p icmp -m icmp --icmp-type echo-reply -j ACCEPT

iptables -A FORWARD -s 172.16.0.200/32 -d 10.0.1.0/24 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -d 172.16.0.200/32 -s 10.0.1.0/24 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
~~~

* Desde cualquier máquina de la LAN se puede conectar por ssh a la máquina Hera.

~~~
iptables -A FORWARD -s 10.0.1.0/24 -d 172.16.0.200/32 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -s 172.16.0.200/32 -d 10.0.1.0/24 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
~~~

* Configura la máquina Zeus para que las máquinas de LAN y DMZ puedan acceder al exterior.

~~~
iptables -t nat -A POSTROUTING -s 172.16.0.0/16 -o enp0s8 -j MASQUERADE
iptables -A FORWARD -i enp0s6 -o enp0s8 -p icmp -m icmp --icmp-type echo-request -j ACCEPT
iptables -A FORWARD -i enp0s8 -o enp0s6 -p icmp -m icmp --icmp-type echo-reply -j ACCEPT

iptables -t nat -A POSTROUTING -s 10.0.1.0/24 -o enp0s8 -j MASQUERADE
iptables -A FORWARD -i enp0s7 -o enp0s8 -p icmp -m icmp --icmp-type echo-request -j ACCEPT
iptables -A FORWARD -i enp0s8 -o enp0s7 -p icmp -m icmp --icmp-type echo-reply -j ACCEPT
~~~

* Las máquinas de la LAN pueden hacer ping al exterior y navegar.

~~~
iptables -A FORWARD -i enp0s7 -o enp0s8 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i enp0s8 -o enp0s7 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT

iptables -A FORWARD -i enp0s7 -o enp0s8 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i enp0s8 -o enp0s7 -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT
~~~

* La máquina Hera puede navegar.

~~~
iptables -A FORWARD -i enp0s6 -o enp0s8 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i enp0s8 -o enp0s6 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT

iptables -A FORWARD -i enp0s6 -o enp0s8 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i enp0s8 -o enp0s6 -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT
~~~

* Configura la máquina Zeus para que los servicios web y ftp sean accesibles desde el exterior.

~~~

~~~

* El servidor web y el servidor ftp deben ser accesibles desde la LAN y desde el exterior.

~~~

~~~

* El servidor de correos sólo debe ser accesible desde la LAN.

~~~

~~~

* En la máquina Ares instala un servidor mysql si no lo tiene aún. A este servidor se puede acceder desde la DMZ, pero no desde el exterior.

~~~

~~~

* Evita ataques DoS por ICMP Flood, limitando el número de peticiones por segundo desde una misma IP.

~~~

~~~

* Evita ataques DoS por SYN Flood.

~~~

~~~

* Evita que realicen escaneos de puertos a Zeus.

~~~

~~~

* Debemos implementar que el cortafuegos funcione después de un reinicio de la máquina. 

~~~

~~~
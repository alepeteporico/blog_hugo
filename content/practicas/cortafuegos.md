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
iptables -t nat -A PREROUTING -p tcp --dport 2222 -i eth0 -j DNAT --to 172.22.0.27:22
iptables -A INPUT -i eth0 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
~~~

~~~

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
alejandrogv@AlejandroGV:~$ ping 172.22.0.27
PING 172.22.0.27 (172.22.0.27) 56(84) bytes of data.
^C
--- 172.22.0.27 ping statistics ---
2 packets transmitted, 0 received, 100% packet loss, time 1007ms
~~~

- LAN:

~~~

~~~

- DMZ:

~~~

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
iptables -t nat -A POSTROUTING -s 172.16.0.0/16 -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth2 -o eth0 -p icmp -m icmp --icmp-type echo-request -j ACCEPT
iptables -A FORWARD -i eth0 -o eth2 -p icmp -m icmp --icmp-type echo-reply -j ACCEPT

iptables -t nat -A POSTROUTING -s 10.0.1.0/24 -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth1 -o eth0 -p icmp -m icmp --icmp-type echo-request -j ACCEPT
iptables -A FORWARD -i eth0 -o eth1 -p icmp -m icmp --icmp-type echo-reply -j ACCEPT
~~~

* Las máquinas de la LAN pueden hacer ping al exterior y navegar.

~~~
iptables -A FORWARD -i eth1 -o eth0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -o eth1 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT

iptables -A FORWARD -i eth1 -o eth0 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -o eth1 -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT
~~~

* La máquina Hera puede navegar.

~~~
iptables -A FORWARD -i eth2 -o eth0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -o eth2 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT

iptables -A FORWARD -i eth2 -o eth0 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -o eth2 -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT
~~~

* Debemos permitir las consultas al escenario.

~~~
iptables -A OUTPUT -p udp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p udp --sport 53 -m state --state ESTABLISHED -j ACCEPT

iptables -t nat -A PREROUTING -p udp -i eth0 --dport 53 -j DNAT --to 10.0.1.102
iptables -A FORWARD -p udp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p udp --sport 53 -m state --state ESTABLISHED -j ACCEPT
~~~

* Configura la máquina Zeus para que los servicios web y ftp sean accesibles desde el exterior.

~~~
nat -A PREROUTING -p tcp -i eth0 --dport 80 -j DNAT --to 172.16.0.200
iptables -A FORWARD -i eth0 -o eth2 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth2 -o eth0 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT

iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 21 -j DNAT --to 172.16.0.200
iptables -A FORWARD -i eth0 -o eth2 -p tcp --dport 21 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth2 -o eth0 -p tcp --sport 21 -m state --state ESTABLISHED -j ACCEPT
~~~

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

* En la máquina Ares instala un servidor mysql si no lo tiene aún. A este servidor se puede acceder desde la DMZ, pero no desde el exterior.

~~~
iptables -A FORWARD -i eth2 -o eth1 -p tcp --dport 3306 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth1 -o eth2 -p tcp --sport 3306 -m state --state ESTABLISHED -j ACCEPT
~~~

* Evita ataques DoS por ICMP Flood, limitando el número de peticiones por segundo desde una misma IP.

~~~
iptables -A INPUT -i eth2 -p icmp -m state --state NEW --icmp-type echo-request -m limit --limit 1/s --limit-burst 1 -j ACCEPT
~~~

* Evita ataques DoS por SYN Flood.

~~~
iptables -N syn_flood
iptables -A INPUT -p tcp --syn -j syn_flood
iptables -A syn_flood -m limit --limit 1/s --limit-burst 3 -j RETURN
iptables -A syn_flood -j DROP
~~~

* Evita que realicen escaneos de puertos a Zeus.

~~~
iptables -A INPUT -p tcp --tcp-flags ALL NONE -m limit --limit 3/m --limit-burst 5 -j LOG --log-prefix "Firewall> Null scan "
iptables -A INPUT -p tcp --tcp-flags ALL NONE  -m recent --name blacklist_60 --set -m comment --comment "Drop/Blacklist Null scan" -j DROP
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

* Permitimos las consultas LDAP.

~~~
iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 389 -j DNAT --to 10.0.1.102
iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 636 -j DNAT --to 10.0.1.102

iptables -A OUTPUT -p tcp --dport 389 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --sport 389 -m state --state ESTABLISHED -j ACCEPT

iptables -A OUTPUT -p tcp --dport 636 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --sport 636 -m state --state ESTABLISHED -j ACCEPT

iptables -A FORWARD -p tcp --dport 389 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p tcp --sport 389 -m state --state ESTABLISHED -j ACCEPT

iptables -A FORWARD -p tcp --dport 636 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p tcp --sport 636 -m state --state ESTABLISHED -j ACCEPT
~~~

* Apolo podrá mandar correos al exterior y recibir.

~~~
iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 25 -j DNAT --to 10.0.1.102
iptables -A FORWARD -s 10.0.1.102 -o eth0 -p tcp --dport 25 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -d 10.0.1.102 -p tcp --sport 25 -m state --state ESTABLISHED -j ACCEPT

iptables -A FORWARD -i eth0 -d 10.0.1.102 -p tcp --dport 25 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -s 10.0.1.102 -o eth0 -p tcp --sport 25 -m state --state ESTABLISHED -j ACCEPT
~~~

* Bacula, alojado en zeus podrá conectarse a todas las máquinas de la red interna.

~~~
iptables -A INPUT -p tcp -m multiport --dport 9101,9102,9103 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -m multiport --sport 9101,9102,9103 -m state --state ESTABLISHED -j ACCEPT

iptables -A FORWARD -p tcp -m multiport --dport 9101,9102,9103 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p tcp -m multiport --sport 9101,9102,9103 -m state --state ESTABLISHED -j ACCEPT
~~~

* Debemos implementar que el cortafuegos funcione después de un reinicio de la máquina. 

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

### Permitimos trafico para la interfaz loopback
iptables -A INPUT -i lo -p icmp -j ACCEPT
iptables -A OUTPUT -o lo -p icmp -j ACCEPT

### Permitimos conectarnos por ssh al cortafuegos, creando una regla DNAT para que acceda a traves del puerto 2222
iptables -t nat -A PREROUTING -p tcp --dport 2222 -i eth0 -j DNAT --to 172.22.0.169:22
iptables -A INPUT -i eth0 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

### Permitimos la conexion ssh desde Zeus a cualquier maquina de la LAN y la DMZ (para poder seguir usando el escenario)
iptables -A OUTPUT -d 10.0.1.0/24 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -s 10.0.1.0/24 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

iptables -A OUTPUT -d 172.16.0.0/16 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -s 172.16.0.0/16 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

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

### Al servidor MariaDb en Ares se puede acceder desde la DMZ, pero no desde el exterior
iptables -A FORWARD -i eth2 -o eth1 -p tcp --dport 3306 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth1 -o eth2 -p tcp --sport 3306 -m state --state ESTABLISHED -j ACCEPT

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

### Evita que realicen escaneos de tipo NULL a Zeus
iptables -A INPUT -p tcp --tcp-flags ALL NONE -m limit --limit 3/m --limit-burst 5 -j LOG --log-prefix "Firewall> Null scan "
iptables -A INPUT -p tcp --tcp-flags ALL NONE  -m recent --name blacklist_60 --set -m comment --comment "Drop/Blacklist Null scan" -j DROP

### Permitimos al servidor DNS de Apolo hacer peticiones DNS a otros servidores
iptables -A OUTPUT -p tcp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --sport 53 -m state --state ESTABLISHED -j ACCEPT

iptables -A FORWARD -p tcp --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p tcp --sport 53 -m state --state ESTABLISHED -j ACCEPT

### Permitimos a Zeus navegar
iptables -A OUTPUT -o eth0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i eth0 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT

iptables -A OUTPUT -o eth0 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i eth0 -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT

### Permitimos que se hagan consultas al servidor LDAP desde cualquier maquina del escenario y desde el exterior
iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 389 -j DNAT --to 10.0.1.102
iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 636 -j DNAT --to 10.0.1.102

iptables -A OUTPUT -p tcp --dport 389 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --sport 389 -m state --state ESTABLISHED -j ACCEPT

iptables -A OUTPUT -p tcp --dport 636 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --sport 636 -m state --state ESTABLISHED -j ACCEPT

iptables -A FORWARD -p tcp --dport 389 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p tcp --sport 389 -m state --state ESTABLISHED -j ACCEPT

iptables -A FORWARD -p tcp --dport 636 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p tcp --sport 636 -m state --state ESTABLISHED -j ACCEPT

### Apolo debe ser capaz de mandar correos al exterior
iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 25 -j DNAT --to 10.0.1.102
iptables -A FORWARD -s 10.0.1.102 -o eth0 -p tcp --dport 25 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -d 10.0.1.102 -p tcp --sport 25 -m state --state ESTABLISHED -j ACCEPT

### El director Bacula en Ares debe ser capaz de conectarse a todas las máquinas del escenario
iptables -A OUTPUT -p tcp -m multiport --sport 9101,9102,9103 -m state --state ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dport 9101,9102,9103 -m state --state NEW,ESTABLISHED -j ACCEPT

iptables -A FORWARD -p tcp -m multiport --dport 9101,9102,9103 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p tcp -m multiport --sport 9101,9102,9103 -m state --state ESTABLISHED -j ACCEPT
~~~
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


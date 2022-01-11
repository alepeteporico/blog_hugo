+++
title = "VPN"
description = ""
tags = [
    "SAD"
]
date = "2021-12-09"
menu = "main"
+++

## VPN de acceso remoto con OpenVPN y certificados x509

* Tenemos dos equipos en openstack a los que queremos configurarles una conexión VPN. empezemos con el servidor, este está conectado a una red `10.99.99.0/24` a parte de la red interna que usamos para conectarnos.

~~~
root@servidor-vpn:~# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: ens3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc pfifo_fast state UP group default qlen 1000
    link/ether fa:16:3e:e5:0d:83 brd ff:ff:ff:ff:ff:ff
    altname enp0s3
    inet 10.0.0.233/24 brd 10.0.0.255 scope global dynamic ens3
       valid_lft 84343sec preferred_lft 84343sec
    inet6 fe80::f816:3eff:fee5:d83/64 scope link 
       valid_lft forever preferred_lft forever
3: ens4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 68 qdisc pfifo_fast state UP group default qlen 1000
    link/ether fa:16:3e:f4:7a:58 brd ff:ff:ff:ff:ff:ff
    altname enp0s4
    inet 10.99.99.163/24 brd 10.99.99.255 scope global ens4
       valid_lft forever preferred_lft forever
~~~

* para la autentificación de los extremos vamos a usar certificados digitales con openssl y el parametro Diffie-Helman, vamos a generar el nuestro.

~~~
root@servidor-vpn:~# openssl dhparam -out alegv.pem 1024
Generating DH parameters, 1024 bit long safe prime, generator 2
This is going to take a long time
......................................+.................+.........+..............+...............................................................................................................................................................+...+..............................................................+..........................................................................................................+..............................+.......................+...............................+....................................+.......................................+..............+...................................................+..............+..............+............................+.......+.................................+..............................................................................................................................................................+............+.+..........................+......................................................................................................+........................................+................+.....+........................+.....................................................+..................................................+..........+.........................................+..................................................................................+...........................+.........................................................................................................+...................................................................+.....+.+..+................................+....................+.................................................................................................+.......................+...................+..........+..............+...........+...................................................+.......+........................................................................+......................................+..........................................+.....................+....................................................................+......................................................+.+....+....................+....................................................+.........................................................................................................+.............+.............................................................................+...................................................+.................................................................+.......+........................................................+........+.............+.......................+.......................................................................................................................................................++*++*++*++*++*

root@servidor-vpn:~# openssl genpkey -paramfile alegv.pem -out prueba.pem


~~~

* Usando DH no se pueden autofirmar certificados, por ello lo que haremos será configurar una clave CA y generar el certificado DH autofirmado a partir de este.

~~~
root@servidor-vpn:~# openssl genrsa -out rsakey.pem 1024
Generating RSA private key, 1024 bit long modulus (2 primes)
................+++++
...............................................................+++++
e is 65537 (0x010001)
root@servidor-vpn:~# openssl req -new -key rsakey.pem -out rsa.csr
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:ES
State or Province Name (full name) [Some-State]:Sevilla
Locality Name (eg, city) []:Dos Hermanas
Organization Name (eg, company) [Internet Widgits Pty Ltd]:
Organizational Unit Name (eg, section) []:
Common Name (e.g. server FQDN or YOUR name) []:Alejandrogv
Email Address []:tojandro@gmail.com

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:prueba	
An optional company name []:


~~~
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

* Tenemos dos equipos en vagrant a los que queremos configurarles una conexión VPN. empezemos con el servidor, este está conectado a una red `10.99.99.0/24` a parte de la red que usamos para conectarnos a esta.

~~~
vagrant@servidor:~$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:f5:43:54 brd ff:ff:ff:ff:ff:ff
    altname enp0s5
    altname ens5
    inet 192.168.121.231/24 brd 192.168.121.255 scope global dynamic eth0
       valid_lft 3138sec preferred_lft 3138sec
    inet6 fe80::5054:ff:fef5:4354/64 scope link 
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:2a:f0:f3 brd ff:ff:ff:ff:ff:ff
    altname enp0s6
    altname ens6
    inet 10.99.99.1/24 brd 10.99.99.255 scope global eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::5054:ff:fe2a:f0f3/64 scope link 
       valid_lft forever preferred_lft forever
~~~

* para la autentificación de los extremos vamos a usar certificados digitales con openssl y el parametro Diffie-Helman, lo primero que haremos será crear nuestro certificado autofirmado.

~~~
vagrant@servidor:/etc/openvpn$ sudo openssl req -config /etc/ssl/openssl.cnf -new -x509 -extensions v3_ca -keyout ./ca.key -out ./caalegv.crt
Generating a RSA private key
.....................................+++++
............................................................................................................................................................................................+++++
writing new private key to './ca.key'
Enter PEM pass phrase:
Verifying - Enter PEM pass phrase:
-----
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
Organizational Unit Name (eg, section) []:Gonzalo Nazareno
Common Name (e.g. server FQDN or YOUR name) []:Alejandro
Email Address []:tojandro@gmail.com
~~~

* Y creamos el par de claves.

~~~
vagrant@servidor:/etc/openvpn$ sudo openssl req -new -newkey rsa:2048 -keyout caprueba.key -out caclave.pem -config /etc/ssl/openssl.cnf
Generating a RSA private key
.+++++
.....+++++
writing new private key to 'caprueba.key'
Enter PEM pass phrase:
Verifying - Enter PEM pass phrase:
-----
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
Organizational Unit Name (eg, section) []:Gonzalo Nazareno
Common Name (e.g. server FQDN or YOUR name) []:Alejandro
Email Address []:tojandro@gmail.com

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:admin
An optional company name []:
~~~

* 
+++
title = "OpenStack: Configuración HTTPS"
description = ""
tags = [
    "SAD"
]
date = "2021-05-27"
menu = "main"
+++

### El siguiente paso de nuestro proyecto es configurar de forma adecuada el protocolo HTTPS en nuestro servidor web para nuestra aplicaciones web. Para ello vamos a emitir un certificado wildcard en la AC Gonzalo Nazareno utilizando para la petición la utilidad "gestiona".

* Lo primero que debemos hacer para llevarlo a cabo es dirigirnos a centos donde crearemos los directorios nesarios y crearemos una clave RSA.

        [centos@quijote ~]$ sudo mkdir /etc/ssl/private
        [centos@quijote ~]$ sudo chmod 700 /etc/ssl/private

        Generating RSA private key, 4096 bit long modulus (2 primes)
        ..........................++++
        ...++++
        e is 65537 (0x010001)

        [root@quijote ~]# chmod 400 /etc/ssl/private/openstack.key

* Nuestro siguiente paso será crear un fichero `.csr` que posteriormente será firmado por la autoridad certificadora de IES Gonzalo Nazareno.

        [root@quijote ~]# openssl req -new -key /etc/ssl/private/openstack.key -out /root/openstack.csr

* Ahora subiremos nuestro certificado a gestiona para que sea firmado por la unidad certificadora de IES Gonzalo Nazareno.

![contraseña](/ldap/1.png)


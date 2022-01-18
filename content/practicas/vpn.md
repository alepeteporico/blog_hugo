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

* para la autentificación de los extremos vamos a usar certificados digitales con openssl y el parametro Diffie-Helman, para realizar esto haremos uso de la herramienta easy-rsa.

~~~
vagrant@servidor:~$ sudo apt install easy-rsa
~~~

#### Para OpenVPN necesitamos crear:

* Una clave privada y un certificado x509 para la autoridad certificante que firma (CA)
* Una clave privada y un certificado x509 firmado para el servidor.
* Una clave privada y un certificado x509 firmado para cada cliente.
* Un grupo Diffie-Hellman para el servidor.

## Claves

* Primero descargaremos el repositorio oficial de easy-rsa, ya que usaremos ficheros del mismo:

~~~
vagrant@servidor:~$ wget https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.4/EasyRSA-3.0.4.tgz

vagrant@servidor:~$ tar -xvf EasyRSA-3.0.4.tgz
~~~

* Copiaremos el fichero `vars.example` que usaremos para especificar la información de la propiedad.

~~~
vagrant@servidor:~/claves$ cp ../EasyRSA-3.0.4/vars.example vars
~~~

* Y editaremos el fichero:

~~~
set_var EASYRSA_REQ_COUNTRY     "ES"
set_var EASYRSA_REQ_PROVINCE    "Sevilla"
set_var EASYRSA_REQ_CITY        "Dos Hermanas"
set_var EASYRSA_REQ_ORG "prueba alegv"
set_var EASYRSA_REQ_EMAIL       "tojandro@gmail.com"
set_var EASYRSA_REQ_OU          "alegv"
~~~

* Y después de toda esta previa, crearemos nuestras claves. ejecutando el fichero que veremos a continuación crearemos un directorio pki, donde crearemos nuestras claves y certificados.

~~~
vagrant@servidor:~/claves$ ../EasyRSA-3.0.4/easyrsa init-pki

init-pki complete; you may now create a CA or requests.
Your newly created PKI dir is: /home/vagrant/claves/pki
~~~

* Nuestro siguiente paso será generar los parametros Diffie-Hellman, un algoritmo de intercambio de claves necesario para nuestro servidor Openvpn.

~~~
vagrant@servidor:~/claves$ ../EasyRSA-3.0.4/easyrsa gen-dh
~~~

* Esto ha generado un fichero `dh.pem` dentro del directorio pki, ahora crearemos clave RSA y el certificado de la CA

~~~
vagrant@servidor:~/claves$ ../EasyRSA-3.0.4/easyrsa  build-ca
Can't load /home/vagrant/claves/pki/.rnd into RNG
140246014035264:error:2406F079:random number generator:RAND_load_file:Cannot open file:../crypto/rand/randfile.c:98:Filename=/home/vagrant/claves/pki/.rnd
Generating a RSA private key
....................................................................................+++++
.......+++++
writing new private key to '/home/vagrant/claves/pki/private/ca.key.FH9EOnTN3D'
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
Common Name (eg: your user, host, or server name) [Easy-RSA CA]:pruebavpn

CA creation complete and you may now import and sign cert requests.
Your new CA certificate file for publishing is at:
/home/vagrant/claves/pki/ca.crt
~~~

* Una vez hecho esto, debemos crear una clave rsa con su certificado para el servidor.

~~~
vagrant@servidor:~/claves$ ../EasyRSA-3.0.4/easyrsa gen-req servidor
Generating a RSA private key
..........+++++
...................................................................................................+++++
writing new private key to '/home/vagrant/claves/pki/private/servidor.key.iBXXBpYu8c'
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
Common Name (eg: your user, host, or server name) [servidor]:pruebavpn

Keypair and certificate request completed. Your files are:
req: /home/vagrant/claves/pki/reqs/servidor.req
key: /home/vagrant/claves/pki/private/servidor.key
~~~

* Vemos que esto nos ha creado dos ficheros, uno `servidor.key` y `servidor.req` el .key es la clave privada, mientras que el .req es la petición de firma que debemos firmar, vamos a hacerlo:

~~~
vagrant@servidor:~/claves$ ../EasyRSA-3.0.4/easyrsa sign-req server servidor


You are about to sign the following certificate.
Please check over the details shown below for accuracy. Note that this request
has not been cryptographically verified. Please be sure it came from a trusted
source or that you have verified the request checksum with the sender.

Request subject, to be signed as a server certificate for 3650 days:

subject=
    commonName                = pruebavpn


Type the word 'yes' to continue, or any other input to abort.
  Confirm request details: yes
Using configuration from ../EasyRSA-3.0.4/openssl-easyrsa.cnf
Enter pass phrase for /home/vagrant/claves/pki/private/ca.key:
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :ASN.1 12:'pruebavpn'
Certificate is to be certified until Jan 15 08:09:53 2032 GMT (3650 days)

Write out database with 1 new entries
Data Base Updated

Certificate created at: /home/vagrant/claves/pki/issued/servidor.crts
~~~

## Claves del cliente

* Vamos a realizar algunos de los pasos del servidor en el cliente, crearemos la clave RSA y su propio certificado.

~~~
vagrant@cliente1:~/claves$ ../EasyRSA-3.0.4/easyrsa gen-req cliente1 
Can't load /home/vagrant/claves/pki/.rnd into RNG
140701260715328:error:2406F079:random number generator:RAND_load_file:Cannot open file:../crypto/rand/randfile.c:98:Filename=/home/vagrant/claves/pki/.rnd
Generating a RSA private key
.................................+++++
.......+++++
writing new private key to '/home/vagrant/claves/pki/private/cliente1.key.kpMaGbzsu8'
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
Common Name (eg: your user, host, or server name) [cliente1]:cliente1-algv

Keypair and certificate request completed. Your files are:
req: /home/vagrant/claves/pki/reqs/cliente1.req
key: /home/vagrant/claves/pki/private/cliente1.key
~~~

* Enviaremos el .req al servidor y lo firmaremos con su clave.

~~~
vagrant@servidor:~/claves$ ../EasyRSA-3.0.4/easyrsa sign-req client cliente1


You are about to sign the following certificate.
Please check over the details shown below for accuracy. Note that this request
has not been cryptographically verified. Please be sure it came from a trusted
source or that you have verified the request checksum with the sender.

Request subject, to be signed as a client certificate for 3650 days:

subject=
    commonName                = cliente1-algv


Type the word 'yes' to continue, or any other input to abort.
  Confirm request details: yes
Using configuration from ../EasyRSA-3.0.4/openssl-easyrsa.cnf
Enter pass phrase for /home/vagrant/claves/pki/private/ca.key:
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :ASN.1 12:'cliente1-algv'
Certificate is to be certified until Jan 15 08:57:52 2032 GMT (3650 days)

Write out database with 1 new entries
Data Base Updated

Certificate created at: /home/vagrant/claves/pki/issued/cliente1.crt
~~~

## Configurando las claves

* Ya tenemos todas las claves y certificados necesarios para realizar el tunel, vamos a moverlos al directorio de openvpn de manera apropiada, empezemos en el servidor.

~~~
vagrant@servidor:~$ sudo mkdir /etc/openvpn/keys
vagrant@servidor:~$ sudo cp claves/pki/dh.pem /etc/openvpn/keys/
vagrant@servidor:~$ sudo cp claves/pki/ca.crt /etc/openvpn/keys/
vagrant@servidor:~$ sudo cp claves/pki/private/servidor.key /etc/openvpn/keys/
vagrant@servidor:~$ sudo cp claves/pki/issued/servidor.crt /etc/openvpn/keys/
~~~

* Vayamos con las del cliente.

~~~
vagrant@cliente1:~/claves$ sudo mkdir /etc/openvpn/keys
vagrant@cliente1:~/claves$ sudo mv pki/private/cliente1.key /etc/openvpn/keys/
vagrant@cliente1:~/claves$ sudo mv pki/issued/cliente1.crt /etc/openvpn/keys/
vagrant@cliente1:~/claves$ sudo mv pki/ca.crt /etc/openvpn/keys/
~~~

* 
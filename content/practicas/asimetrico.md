+++
title = "Cifrado asimétrico con gpg y openssl"
description = ""
tags = [
    "SAD"
]
date = "2021-11-11"
menu = "main"
+++

#### Tarea 1: Generación de claves

* Generamos las claves:

~~~
alejandrogv@AlejandroGV:~$ gpg --gen-key
gpg (GnuPG) 2.2.27; Copyright (C) 2021 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Nota: Usa "gpg --full-generate-key" para el diálogo completo de generación de clave.

GnuPG debe construir un ID de usuario para identificar su clave.

Nombre y apellidos: ALejandro Gutiérrez Valencia
Dirección de correo electrónico: tojandro@gmail.com
Está usando el juego de caracteres 'utf-8'.
Ha seleccionado este ID de usuario:
    "ALejandro Gutiérrez Valencia <tojandro@gmail.com>"

¿Cambia (N)ombre, (D)irección o (V)ale/(S)alir? V
Es necesario generar muchos bytes aleatorios. Es una buena idea realizar
alguna otra tarea (trabajar en otra ventana/consola, mover el ratón, usar
la red y los discos) durante la generación de números primos. Esto da al
generador de números aleatorios mayor oportunidad de recoger suficiente
entropía.
Es necesario generar muchos bytes aleatorios. Es una buena idea realizar
alguna otra tarea (trabajar en otra ventana/consola, mover el ratón, usar
la red y los discos) durante la generación de números primos. Esto da al
generador de números aleatorios mayor oportunidad de recoger suficiente
entropía.
gpg: clave F40E3F8DD4E6DA1D marcada como de confianza absoluta
gpg: certificado de revocación guardado como '/home/alejandrogv/.gnupg/openpgp-revocs.d/92237AE50A42DFD422F5A0B1F40E3F8DD4E6DA1D.rev'
claves pública y secreta creadas y firmadas.

pub   rsa3072 2021-11-11 [SC] [caduca: 2023-11-11]
      92237AE50A42DFD422F5A0B1F40E3F8DD4E6DA1D
uid                      ALejandro Gutiérrez Valencia <tojandro@gmail.com>
sub   rsa3072 2021-11-11 [E] [caduca: 2023-11-11]
~~~

* Las claves se generan en la carpeta personal en un directorio oculto llamado gnupg

~~~
alejandrogv@AlejandroGV:~$ ls .gnupg/
crls.d            private-keys-v1.d  pubring.kbx~  sshcontrol  trustdb.gpg
openpgp-revocs.d  pubring.kbx        random_seed   tofu.db
~~~

* Listamos las claves publicas.

~~~
alejandrogv@AlejandroGV:~$ gpg --list-key
/home/alejandrogv/.gnupg/pubring.kbx
------------------------------------
pub   rsa3072 2021-11-11 [SC] [caduca: 2023-11-11]
      92237AE50A42DFD422F5A0B1F40E3F8DD4E6DA1D
uid        [  absoluta ] ALejandro Gutiérrez Valencia <tojandro@gmail.com>
sub   rsa3072 2021-11-11 [E] [caduca: 2023-11-11]
~~~


* podriamos generar las claves con el siguiente comando para que nos diera la opción de darle un tiempo de validez a las mismas.

~~~
alejandrogv@AlejandroGV:~$ gpg --full-generate-key
...
...
...
Por favor, especifique el período de validez de la clave.
         0 = la clave nunca caduca
      <n>  = la clave caduca en n días
      <n>w = la clave caduca en n semanas
      <n>m = la clave caduca en n meses
      <n>y = la clave caduca en n años
¿Validez de la clave (0)? 5
La clave caduca lun 29 mar 2021 14:23:34 CEST
...
...
...
~~~

* Para listar las claves privadas usamos este comando:

~~~
alejandrogv@AlejandroGV:~$ gpg --list-secret-keys
/home/alejandrogv/.gnupg/pubring.kbx
------------------------------------
sec   rsa3072 2021-11-11 [SC] [caduca: 2023-11-11]
      92237AE50A42DFD422F5A0B1F40E3F8DD4E6DA1D
uid        [  absoluta ] ALejandro Gutiérrez Valencia <tojandro@gmail.com>
ssb   rsa3072 2021-11-11 [E] [caduca: 2023-11-11]
~~~

#### Importar / exportar clave pública

* Exportamos la clave en formato ASCII:

~~~
alejandrogv@AlejandroGV:~$ gpg --export -a "Alejandro Gutierrez Valencia" > alejandro_gutierrez.asc
alejandrogv@AlejandroGV:~$ ls -l alejandro_gutierrez.asc 
-rw-r--r-- 1 alejandrogv alejandrogv 4256 nov 11 12:08 alejandro_gutierrez.asc
~~~

* Importamos la clave de un compañero:

~~~
alejandrogv@AlejandroGV:~$ gpg --import Descargas/javier_vega.asc 
gpg: clave 481526C2F14CEF19: "user-javier" sin cambios
gpg: clave 481526C2F14CEF19: clave secreta importada
gpg: Cantidad total procesada: 1
gpg:              sin cambios: 1
gpg:       claves secretas leídas: 1
gpg:   claves secretas importadas: 1
~~~

* Comprobamos que se ha añadido a nuestro anillo de llaves:

~~~
alejandrogv@AlejandroGV:~$ gpg --list-keys
/home/alejandrogv/.gnupg/pubring.kbx
------------------------------------
pub   rsa3072 2021-11-11 [SC] [caduca: 2023-11-11]
      92237AE50A42DFD422F5A0B1F40E3F8DD4E6DA1D
uid        [  absoluta ] ALejandro Gutiérrez Valencia <tojandro@gmail.com>
sub   rsa3072 2021-11-11 [E] [caduca: 2023-11-11]

pub   rsa3072 2021-11-11 [SC] [caduca: 2023-11-11]
      849A2233E8AA7F6971DE3978481526C2F14CEF19
uid        [desconocida] user-javier
sub   rsa3072 2021-11-11 [E] [caduca: 2023-11-11]
~~~

#### Cifrado asimétrico con claves públicas

* Encriptamos un archivo, nos pedirá un ID de usuario, pondremos el del destinatario para cifrar con su clave pública que ya habremos importado.

~~~
alejandrogv@AlejandroGV:~$ gpg -e encriptado.txt 
No ha especificado un ID de usuario (puede usar "-r")

Destinatarios actuales:

Introduzca ID de usuario. Acabe con una línea vacía: user-javier
gpg: E514CEB4A7703200: No hay seguridad de que esta clave pertenezca realmente
al usuario que se nombra

sub  rsa3072/E514CEB4A7703200 2021-11-11 user-javier
 Huella clave primaria: 849A 2233 E8AA 7F69 71DE  3978 4815 26C2 F14C EF19
      Huella de subclave: E065 5900 BDCA 6A34 3FF0  E79E E514 CEB4 A770 3200

No es seguro que la clave pertenezca a la persona que se nombra en el
identificador de usuario. Si *realmente* sabe lo que está haciendo,
puede contestar sí a la siguiente pregunta.

¿Usar esta clave de todas formas? (s/N) s

Destinatarios actuales:
rsa3072/E514CEB4A7703200 2021-11-11 "user-javier"

Introduzca ID de usuario. Acabe con una línea vacía: Alejandro Gutiérrez Valencia

Destinatarios actuales:
rsa3072/30421CCA0BA3A8EC 2021-11-11 "ALejandro Gutiérrez Valencia <tojandro@gmail.com>"
rsa3072/E514CEB4A7703200 2021-11-11 "user-javier"

Introduzca ID de usuario. Acabe con una línea vacía: 
El fichero 'encriptado.txt.gpg' ya existe. ¿Sobreescribir? (s/N) s
~~~

* Desencriptamos el fichero del compañero:

~~~
alejandrogv@AlejandroGV:~$ gpg -d Descargas/fichero.txt.gpg 
gpg: cifrado con clave de 3072 bits RSA, ID E514CEB4A7703200, creada el 2021-11-11
      "user-javier"
Hola Alejandro 
¿Tienes lo que te pedí?
~~~

* Podemos comprobar que si le enviamos el fichero a alguien que no tiene importada nuestra clave importada no podrá descifrarlo.

![desesncriptado_mal](/asimetrica/3.png)

####  Exportar clave a un servidor público de claves PGP

* Para crear la clave de revocación usamos el siguiente comando al que deberemos darle el ID de nuestra clave:

~~~
alejandrogv@AlejandroGV:~$ gpg --gen-revoke 92237AE50A42DFD422F5A0B1F40E3F8DD4E6DA1D
~~~

* Enviamos nuestra clave pública al servidor pgp.rediris.es 

~~~
alejandrogv@AlejandroGV:~$ gpg --keyserver pgp.rediris.es --send-key 92237AE50A42DFD422F5A0B1F40E3F8DD4E6DA1D
gpg: enviando clave F40E3F8DD4E6DA1D a hkp://pgp.rediris.es
~~~

* Borramos la clave de un compañero:

~~~
alejandrogv@AlejandroGV:~$ gpg --delete-key user-javier
alejandrogv@AlejandroGV:~$ gpg --delete-secret-key user-javier
~~~

* Ahora cogeremos la clave del servidor que usamos antes, para ello necesitaremos saber la ID del compañero.

~~~
alejandrogv@AlejandroGV:~$ gpg --keyserver pgp.rediris.org --recv-keys A0BE5CA7A9DC70AD3D619467CC02797F092855F6
~~~

#### Cifrado asimétrico con openssl

* Creamos un par de claves con contraseña en formato PEM usando openssl:

~~~
alejandrogv@AlejandroGV:~$ sudo openssl genrsa -aes128 -out clave.pem 2048
~~~

* Para separar la publica debemos usar el siguiente comando:

~~~
alejandrogv@AlejandroGV:~$ sudo openssl rsa -in clave.pem -pubout -out clave.public.pem
~~~

* Encriptamos el fichero con la clave pública del compañero:

~~~
alejandrogv@AlejandroGV:~$ openssl rsautl -encrypt -in secreto.txt -out secreto.enc -inkey key.public.pem -pubin
~~~

* Desencriptamos el archivo que nos ha enviado nuestro compañero usando nuestra clave.

~~~
alejandrogv@AlejandroGV:~$ sudo openssl rsautl -decrypt -inkey clave.pem -in fichero.enc -out fichero.txt
~~~
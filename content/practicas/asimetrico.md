+++
title = "Cifrado asimétrico"
description = ""
tags = [
    "SAD"
]
date = "2021-03-24"
menu = "main"
+++

#### Tarea 1: Generación de claves

* Generamos las claves:

        alejandrogv@AlejandroGV:~$ gpg --gen-key
        gpg (GnuPG) 2.2.12; Copyright (C) 2018 Free Software Foundation, Inc.
        This is free software: you are free to change and redistribute it.
        There is NO WARRANTY, to the extent permitted by law.

        Nota: Usa "gpg --full-generate-key" para el diálogo completo de generación de clave.

        GnuPG debe construir un ID de usuario para identificar su clave.

        Nombre y apellidos: Alejandro Gutiérrez Valencia
        Dirección de correo electrónico: tojandro@gmail.com
        Está usando el juego de caracteres 'utf-8'.
        Ha seleccionado este ID de usuario:
            "Alejandro Gutiérrez Valencia <tojandro@gmail.com>"

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
        gpg: clave 2DF83E5272EECBAD marcada como de confianza absoluta
        gpg: certificado de revocación guardado como '/home/alejandrogv/.gnupg/openpgp-revocs.d/30C5525AE9451AE80F2C23242DF83E5272EECBAD.rev'
        claves pública y secreta creadas y firmadas.

        pub   rsa3072 2021-03-24 [SC] [caduca: 2023-03-24]
              30C5525AE9451AE80F2C23242DF83E5272EECBAD
        uid                      Alejandro Gutiérrez Valencia <tojandro@gmail.com>
        sub   rsa3072 2021-03-24 [E] [caduca: 2023-03-24]

* Las claves se generan en la carpeta personal en un directorio oculto llamado gnupg

        alejandrogv@AlejandroGV:~$ ls .gnupg/
        crls.d            private-keys-v1.d  pubring.kbx~  sshcontrol  trustdb.gpg
        openpgp-revocs.d  pubring.kbx        random_seed   tofu.db

* Listamos las claves publicas.

        alejandrogv@AlejandroGV:~$ gpg --list-keys
        gpg: comprobando base de datos de confianza
        gpg: marginals needed: 3  completes needed: 1  trust model: pgp
        gpg: nivel: 0  validez:   2  firmada:   2  confianza: 0-, 0q, 0n, 0m, 0f, 2u
        gpg: nivel: 1  validez:   2  firmada:   0  confianza: 1-, 0q, 0n, 0m, 1f, 0u
        gpg: siguiente comprobación de base de datos de confianza el: 2022-10-06
        /home/alejandrogv/.gnupg/pubring.kbx
        ------------------------------------
        pub   rsa3072 2020-10-08 [SC] [caduca: 2022-11-10]
              443D661D9AAF3ABAEDCA93E1C3B291882C4EE5DF
        uid        [  absoluta ] Alejandro Gutierrez Valencia <tojandro@gmail.com>
        sub   rsa3072 2020-10-08 [E] [caduca: 2022-11-10]

        pub   rsa3072 2020-10-07 [SC] [caducó: 2020-11-07]
              DCFB091C5495684E59BC061EA52A681834F0E596
        uid        [  caducada ] José Miguel Calderón Frutos <josemiguelcalderonfrutos@gamil.com>

        pub   rsa3072 2020-10-06 [SC] [caduca: 2022-10-06]
              28ED3C3112ED8846BEDFFAF657112B319F2A6170
        uid        [   total   ] Francisco Javier Madueño Jurado <frandh1997@gmail.com>
        sub   rsa3072 2020-10-06 [E] [caduca: 2022-10-06]

        pub   rsa3072 2020-10-06 [SC] [caduca: 2022-10-06]
              547D6FBDF49CD2340F1D5DB6CFCF1D130D5A52C5
        uid        [   total   ] sergio ibañez <sergio_hd_sony@hotmail.com>
        sub   rsa3072 2020-10-06 [E] [caduca: 2022-10-06]

        pub   rsa3072 2021-03-24 [SC] [caduca: 2023-03-24]
              30C5525AE9451AE80F2C23242DF83E5272EECBAD
        uid        [  absoluta ] Alejandro Gutiérrez Valencia <tojandro@gmail.com>
        sub   rsa3072 2021-03-24 [E] [caduca: 2023-03-24]


* podriamos generar las claves con el siguiente comando para que nos diera la opción de darle un tiempo de validez a las mismas.

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

* Para listar las claves privadas usamos este comando:

        alejandrogv@AlejandroGV:~$ gpg --list-secret-keys
        gpg: comprobando base de datos de confianza
        gpg: marginals needed: 3  completes needed: 1  trust model: pgp
        gpg: nivel: 0  validez:   3  firmada:   2  confianza: 0-, 0q, 0n, 0m, 0f, 3u
        gpg: nivel: 1  validez:   2  firmada:   0  confianza: 1-, 0q, 0n, 0m, 1f, 0u
        gpg: siguiente comprobación de base de datos de confianza el: 2021-03-29
        /home/alejandrogv/.gnupg/pubring.kbx
        ------------------------------------
        sec   rsa3072 2020-10-08 [SC] [caduca: 2022-11-10]
              443D661D9AAF3ABAEDCA93E1C3B291882C4EE5DF
        uid        [  absoluta ] Alejandro Gutierrez Valencia <tojandro@gmail.com>
        ssb   rsa3072 2020-10-08 [E] [caduca: 2022-11-10]


#### Importar / exportar clave pública

* Exportamos la clave en formato ASCII:

        alejandrogv@AlejandroGV:~$ gpg --export -a "Alejandro Gutierrez Valencia" > alejandro_gutierrez.asc

        alejandrogv@AlejandroGV:~$ ls -l alejandro_gutierrez.asc 
        -rw-r--r-- 1 alejandrogv alejandrogv 4256 mar 24 13:27 alejandro_gutierrez.asc

* Importamos la clave de un compañero:

        alejandrogv@AlejandroGV:~$ gpg --import clavepublicafran.asc


* Comprobamos que se ha añadido a nuestro anillo de llaves:

![anillo](/asimetrica/1.png)

#### Cifrado asimétrico con claves públicas

* Encriptamos un archivo, nos pedirá un ID de usuario, pondremos el del destinatario para cifrar con su clave pública que ya habremos importado.

        alejandrogv@AlejandroGV:~$ gpg -e prueba.txt
        No ha especificado un ID de usuario (puede usar "-r")
        Introduzca ID de usuario. Acabe con una línea vacía: Alejandro Gutierrez Valencia
        gpg: omitida: clave pública ya establecida

        Destinatarios actuales:
        rsa3072/3C5DBE21F6961E37 2020-10-08 "Alejandro Gutierrez Valencia <tojandro@gmail.com>"

        Introduzca ID de usuario. Acabe con una línea vacía: 
        El fichero 'prueba.txt.gpg' ya existe. ¿Sobreescribir? (s/N) s

* Desencriptamos el fichero del compañero:

        alejandrogv@AlejandroGV:~$ gpg -d Apuntes.pdf.gpg > apuntes.pdf

![desesncriptado](/asimetrica/2.png)

* Podemos comprobar que si le enviamos el fichero a alguien que no tiene importada nuestra clave importada no podrá descifrarlo.

![desesncriptado_mal](/asimetrica/3.png)

####  Exportar clave a un servidor público de claves PGP

* Para crear la clave de revocación usamos el siguiente comando al que deberemos darle el ID de nuestra clave:

        alejandrogv@AlejandroGV:~$ gpg --gen-revoke 443D661D9AAF3ABAEDCA93E1C3B291882C4EE5DF

* Enviamos nuestra clave pública al servidor pgp.rediris.es 

        alejandrogv@AlejandroGV:~$ gpg --keyserver pgp.rediris.es --send-key 443D661D9AAF3ABAEDCA93E1C3B291882C4EE5DF

* Borramos la clave de un compañero:

        alejandrogv@AlejandroGV:~$ gpg --delete-key Álvaro Vaca Ferreras

* Ahora cogeremos la clave del servidor que usamos antes, para ello necesitaremos saber la ID del compañero.

        alejandrogv@AlejandroGV:~$ gpg --keyserver pgp.rediris.org --recv-keys A0BE5CA7A9DC70AD3D619467CC02797F092855F6

#### Cifrado asimétrico con openssl

* Creamos un par de claves con contraseña en formato PEM usando openssl:

        alejandrogv@AlejandroGV:~$ sudo openssl genrsa -aes128 -out clave.pem 2048

* Para separar la publica debemos usar el siguiente comando:

        alejandrogv@AlejandroGV:~$ sudo openssl rsa -in clave.pem -pubout -out clave.public.pem

* Encriptamos el fichero con la clave pública del compañero:

        alejandrogv@AlejandroGV:~$ openssl rsautl -encrypt -in secreto.txt -out secreto.enc -inkey key.public.pem -pubin

* Desencriptamos el archivo que nos ha enviado nuestro compañero usando nuestra clave.

        alejandrogv@AlejandroGV:~$ sudo openssl rsautl -decrypt -inkey clave.pem -in fichero.enc -out fichero.txt
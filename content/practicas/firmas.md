+++
title = "Integridad, firmas y autentificación"
description = ""
tags = [
    "SAD"
]
date = "2021-11-18"
menu = "main"
+++

### Tarea 1:

* Firmamos un fichero que enviaremos a nuestros compañeros para que comprueben nuestra firma:

~~~
alejandrogv@AlejandroGV:~/Descargas$ gpg --output fichero.sign --sign fichero.txt
~~~

* He enviado un archivo firmado a un compañero que dispone de mi clave pública, los dos hemos verificado la firma.

~~~
alejandrogv@AlejandroGV:~/Descargas$ gpg --verify p2pdf.pdf.sign 
gpg: Firmado el jue 18 nov 2021 12:25:18 CET
gpg:                usando RSA clave 47742CCB469EB70E132966EDEDA6F79F602CACBD
gpg: Firma correcta de "Daniel Miguel Mesa Mejias <danimesamejias@gmail.com>" [desconocido]
gpg: ATENCIÓN: ¡Esta clave no está certificada por una firma de confianza!
gpg:          No hay indicios de que la firma pertenezca al propietario.
Huellas dactilares de la clave primaria: 4774 2CCB 469E B70E 1329  66ED EDA6 F79F 602C ACBD
~~~

* Ahora firmaremos la clave de este compañero:

~~~
alejandrogv@AlejandroGV:~/Descargas$ gpg --sign-key 602CACBD

pub  rsa3072/EDA6F79F602CACBD
     creado: 2021-11-11  caduca: 2023-11-11  uso: SC  
     confianza: desconocido   validez: desconocido
sub  rsa3072/1F89D944C5945202
     creado: 2021-11-11  caduca: 2023-11-11  uso: E   
[desconocida] (1). Daniel Miguel Mesa Mejias <danimesamejias@gmail.com>


pub  rsa3072/EDA6F79F602CACBD
     creado: 2021-11-11  caduca: 2023-11-11  uso: SC  
     confianza: desconocido   validez: desconocido
 Huella clave primaria: 4774 2CCB 469E B70E 1329  66ED EDA6 F79F 602C ACBD

     Daniel Miguel Mesa Mejias <danimesamejias@gmail.com>

Esta clave expirará el 2023-11-11.
¿Está realmente seguro de querer firmar esta clave
con su clave: "alegv <tojandro@gmail.com>" (EAC60E9B2330736A)?

¿Firmar de verdad? (s/N) s
~~~

* Cuando hacemos un gpg --list-key vemos que la confianza a cambiado a total:

~~~
alejandrogv@AlejandroGV:~$ gpg --list-key
/home/alejandrogv/.gnupg/pubring.kbx
------------------------------------
....
....
....
pub   rsa3072 2021-11-11 [SC] [caduca: 2023-11-11]
      47742CCB469EB70E132966EDEDA6F79F602CACBD
uid        [   total   ] Daniel Miguel Mesa Mejias <danimesamejias@gmail.com>
sub   rsa3072 2021-11-11 [E] [caduca: 2023-11-11]
~~~

* Nuestros compañeros también firmarán nuestra clave:

~~~
vagrant@nodo1:~$ gpg --sign-key 2330736A

pub  rsa3072/EAC60E9B2330736A
     created: 2021-11-18  expires: 2023-11-18  usage: SC  
     trust: unknown       validity: unknown
sub  rsa3072/AA2E5C8DE5614F8A
     created: 2021-11-18  expires: 2023-11-18  usage: E  
[ unknown] (1). alegv <tojandro@gmail.com>


pub  rsa3072/EAC60E9B2330736A
     created: 2021-11-18  expires: 2023-11-18  usage: SC  
     trust: unknown       validity: unknown
 Primary key fingerprint: DA5A 4DEF 66D2 5FCE EA83  D8BE EAC6 0E9B 2330 736A

     alegv <tojandro@gmail.com>

This key is due to expire on 2023-11-18.
Are you sure that you want to sign this key with your
key "Daniel Miguel Mesa Mejias <danimesamejias@gmail.com>" (EDA6F79F602CACBD)

Really sign? (y/N) y

vagrant@nodo1:~$ gpg --list-key
...
...
pub   rsa3072 2021-11-18 [SC] [expires: 2023-11-18]
      DA5A4DEF66D25FCEEA83D8BEEAC60E9B2330736A
uid           [  full  ] alegv <tojandro@gmail.com>
sub   rsa3072 2021-11-18 [E] [expires: 2023-11-18]
~~~

* Ahora debemos exportar la calve:

~~~
gpg -a --export danimesamejias@gmail.com > dani.asc
~~~

* Ahora recogemos nuestra clave firmada por nuestros compañeros y la importamos, vamos a ver que nuestra clave está firmada:

        alejandrogv@AlejandroGV:~/Descargas$ gpg --list-sign
        /home/alejandrogv/.gnupg/pubring.kbx
        ------------------------------------
        pub   rsa3072 2020-10-08 [SC] [caduca: 2020-11-07]
              443D661D9AAF3ABAEDCA93E1C3B291882C4EE5DF
        uid        [  absoluta ] Alejandro Gutierrez Valencia <tojandro@gmail.com>
        sig 3        C3B291882C4EE5DF 2020-10-08  Alejandro Gutierrez Valencia <tojandro@gmail.com>
        sig          57112B319F2A6170 2020-10-22  Francisco Javier Madueño Jurado <frandh1997@gmail.com>
        sig          A52A681834F0E596 2020-10-28  José Miguel Calderón Frutos <josemiguelcalderonfrutos@gamil.com
        
* También se pueden ver las firmas de las claves de nuestros compañeros, si no tenemos a alguien que ha firmado su clave en nuestro anillo de claves nos aparecerá como ID de usuario no encontrado:

        alejandrogv@AlejandroGV:~$ gpg --list-sign
        /home/alejandrogv/.gnupg/pubring.kbx
        ------------------------------------
        pub   rsa3072 2020-10-08 [SC] [caduca: 2022-11-10]
              443D661D9AAF3ABAEDCA93E1C3B291882C4EE5DF
        uid        [  absoluta ] Alejandro Gutierrez Valencia <tojandro@gmail.com>
        sig 3        C3B291882C4EE5DF 2020-11-10  Alejandro Gutierrez Valencia <tojandro@gmail.com>
        sig          57112B319F2A6170 2020-10-22  Francisco Javier Madueño Jurado <frandh1997@gmail.com>
        sig          A52A681834F0E596 2020-10-28  José Miguel Calderón Frutos <josemiguelcalderonfrutos@gamil.com>
        sig          CFCF1D130D5A52C5 2020-11-06  sergio ibañez <sergio_hd_sony@hotmail.com>
        sub   rsa3072 2020-10-08 [E] [caduca: 2022-11-10]
        sig          C3B291882C4EE5DF 2020-11-10  Alejandro Gutierrez Valencia <tojandro@gmail.com>

        pub   rsa3072 2020-10-07 [SC] [caducó: 2020-11-07]
              DCFB091C5495684E59BC061EA52A681834F0E596
        uid        [  caducada ] José Miguel Calderón Frutos <josemiguelcalderonfrutos@gamil.com>
        sig 3        A52A681834F0E596 2020-10-08  José Miguel Calderón Frutos <josemiguelcalderonfrutos@gamil.com>
        sig          4F54B5799987B52D 2020-10-22  [ID de usuario no encontrado]
        sig          636AE9EBCB7E3294 2020-10-28  [ID de usuario no encontrado]
        sig          C3B291882C4EE5DF 2020-10-28  Alejandro Gutierrez Valencia <tojandro@gmail.com>

        pub   rsa3072 2020-10-06 [SC] [caduca: 2022-10-06]
              28ED3C3112ED8846BEDFFAF657112B319F2A6170
        uid        [   total   ] Francisco Javier Madueño Jurado <frandh1997@gmail.com>
        sig 3        57112B319F2A6170 2020-10-06  Francisco Javier Madueño Jurado <frandh1997@gmail.com>
        sig          C3B291882C4EE5DF 2020-10-28  Alejandro Gutierrez Valencia <tojandro@gmail.com>
        sub   rsa3072 2020-10-06 [E] [caduca: 2022-10-06]
        sig          57112B319F2A6170 2020-10-06  Francisco Javier Madueño Jurado <frandh1997@gmail.com>

        pub   rsa3072 2020-10-06 [SC] [caduca: 2022-10-06]
              547D6FBDF49CD2340F1D5DB6CFCF1D130D5A52C5
        uid        [   total   ] sergio ibañez <sergio_hd_sony@hotmail.com>
        sig 3        CFCF1D130D5A52C5 2020-10-06  sergio ibañez <sergio_hd_sony@hotmail.com>
        sig          4F54B5799987B52D 2020-10-28  [ID de usuario no encontrado]
        sig          7A01A1F808950F41 2020-11-04  [ID de usuario no encontrado]
        sig          C3B291882C4EE5DF 2020-11-06  Alejandro Gutierrez Valencia <tojandro@gmail.com>
        sub   rsa3072 2020-10-06 [E] [caduca: 2022-10-06]
        sig          CFCF1D130D5A52C5 2020-10-06  sergio ibañez <sergio_hd_sony@hotmail.com>

* Nostros también hemos recibido un fichero firmado de dos compañeros, uno de alguien que pertenece a nuestro anillo de confianza y otro que no, pero otra persona con la que tenemos confianza total:

        alejandrogv@AlejandroGV:~/Descargas$ gpg --verify doc.sig 
        gpg: Firmado el mar 10 nov 2020 08:19:38 CET
        gpg:                usando RSA clave 547D6FBDF49CD2340F1D5DB6CFCF1D130D5A52C5
        gpg: Firma correcta de "sergio ibañez <sergio_hd_sony@hotmail.com>" [total]

* Veamos que sucede con la otro fichero firmado:

        alejandrogv@AlejandroGV:~/Descargas$ gpg --verify saludo.sig 
        gpg: Firmado el mar 10 nov 2020 10:14:48 CET
        gpg:                usando RSA clave AD19812061DA946F8DA70E0C4F54B5799987B52D
        gpg: Imposible comprobar la firma: No public key

### Tarea 2:

* Vamos a añadir nuestra cuenta de correo personal al cliente de evolution:

![correo](/firmas/1.png)

![correo](/firmas/2.png)

* Comprobamos que esté bien configurado:

![config](/firmas/3.png)

* Ahora en la pestaña "editar>preferencias>Cuentas de correo" seleccionamos nuestra cuenta

* Ahora en el apartado de seguridad añadimos los 8 últimos digitos de nuestra clave donde nos pide que intruzcamos el ID de nuestra clave OpenPGP y tenemos que marcar las dos casillas que se ven a continuación:

![seguridad](/firmas/4.png)

* Enviamos un correo a un compañero para comprobar que ha funcionado y al verlo en enviados comprobamos que está firmado:

![envio](/firmas/6.png)

### Tarea 3:

* Tenemos descargada una imagen de debian 10, también hemos descargado de la página oficial su archivo md5sums correspondiente y con el siguiete comando comprobaremos las sumas:

        alejandrogv@AlejandroGV:~/Descargas$ sudo md5sum -c MD5SUMS 2> /dev/null | grep debian-10.6.0-amd64-netinst.iso 
        debian-10.6.0-amd64-netinst.iso: La suma coincide

* Haremos el mismo proceso con con SHA256 y SHA512 y vemos que también coinciden:

        alejandrogv@AlejandroGV:~/Descargas$ sha256sum -c SHA256SUMS 2> /dev/null | grep debian-10.6.0-amd64-netinst.iso 
        debian-10.6.0-amd64-netinst.iso: La suma coincide
        alejandrogv@AlejandroGV:~/Descargas$ sha512sum -c SHA512SUMS 2> /dev/null | grep debian-10.6.0-amd64-netinst.iso 
        debian-10.6.0-amd64-netinst.iso: La suma coincide

### Tarea 4:

#### ¿Qué software utiliza apt secure para realizar la criptografía asimétrica?

* Usa gpg para hacer esta criptografía. Especialmente se usa gpg para cifrar y firmar documentos digitales, especialmente el correo.

#### ¿Para que sirve el comando apt-key? ¿Qué muestra el comando apt-key list?

* Este comando sirve para visualizar y configurar la lista de claves que usa apt para autentificar los paquetes.

* Vemos la salida del comando apt-key list:

        alejandrogv@AlejandroGV:~/Descargas$ apt-key list
        /etc/apt/trusted.gpg
        --------------------
        pub   rsa4096 2018-05-23 [SC] [caducó: 2020-08-21]
              931F F8E7 9F08 7613 4EDD  BDCC A87F F9DF 48BF 1C90
        uid        [  caducada ] Spotify Public Repository Signing Key <tux@spotify.com>

        pub   rsa4096 2019-07-15 [SC] [caducó: 2020-10-07]
              2EBF 997C 15BD A244 B6EB  F5D8 4773 BD5E 130D 1D45
        uid        [  caducada ] Spotify Public Repository Signing Key <tux@spotify.com>

        pub   rsa2048 2015-10-28 [SC]
              BC52 8686 B50D 79E3 39D3  721C EB3E 94AD BE12 29CF
        uid        [desconocida] Microsoft (Release signing) <gpgsecurity@microsoft.com>

        pub   rsa4096 2016-04-22 [SC]
              B9F8 D658 297A F3EF C18D  5CDF A2F6 83C5 2980 AECF
        uid        [desconocida] Oracle Corporation (VirtualBox archive signing key) <info@virtualbox.org>
        sub   rsa4096 2016-04-22 [E]

        /etc/apt/trusted.gpg.d/debian-archive-buster-automatic.gpg
        ----------------------------------------------------------
        pub   rsa4096 2019-04-14 [SC] [caduca: 2027-04-12]
              80D1 5823 B7FD 1561 F9F7  BCDD DC30 D7C2 3CBB ABEE
        uid        [desconocida] Debian Archive Automatic Signing Key (10/buster) <ftpmaster@debian.org>
        sub   rsa4096 2019-04-14 [S] [caduca: 2027-04-12]

        /etc/apt/trusted.gpg.d/debian-archive-buster-security-automatic.gpg
        -------------------------------------------------------------------
        pub   rsa4096 2019-04-14 [SC] [caduca: 2027-04-12]
              5E61 B217 265D A980 7A23  C5FF 4DFA B270 CAA9 6DFA
        uid        [desconocida] Debian Security Archive Automatic Signing Key (10/buster) <ftpmaster@debian.org>
        sub   rsa4096 2019-04-14 [S] [caduca: 2027-04-12]

        /etc/apt/trusted.gpg.d/debian-archive-buster-stable.gpg
        -------------------------------------------------------
        pub   rsa4096 2019-02-05 [SC] [caduca: 2027-02-03]
              6D33 866E DD8F FA41 C014  3AED DCC9 EFBF 77E1 1517
        uid        [desconocida] Debian Stable Release Key (10/buster) <debian-release@lists.debian.org>

        /etc/apt/trusted.gpg.d/debian-archive-jessie-automatic.gpg
        ----------------------------------------------------------
        pub   rsa4096 2014-11-21 [SC] [caduca: 2022-11-19]
              126C 0D24 BD8A 2942 CC7D  F8AC 7638 D044 2B90 D010
        uid        [desconocida] Debian Archive Automatic Signing Key (8/jessie) <ftpmaster@debian.org>

        /etc/apt/trusted.gpg.d/debian-archive-jessie-security-automatic.gpg
        -------------------------------------------------------------------
        pub   rsa4096 2014-11-21 [SC] [caduca: 2022-11-19]
              D211 6914 1CEC D440 F2EB  8DDA 9D6D 8F6B C857 C906
        uid        [desconocida] Debian Security Archive Automatic Signing Key (8/jessie) <ftpmaster@debian.org>

        /etc/apt/trusted.gpg.d/debian-archive-jessie-stable.gpg
        -------------------------------------------------------
        pub   rsa4096 2013-08-17 [SC] [caduca: 2021-08-15]
              75DD C3C4 A499 F1A1 8CB5  F3C8 CBF8 D6FD 518E 17E1
        uid        [desconocida] Jessie Stable Release Key <debian-release@lists.debian.org>

        /etc/apt/trusted.gpg.d/debian-archive-stretch-automatic.gpg
        -----------------------------------------------------------
        pub   rsa4096 2017-05-22 [SC] [caduca: 2025-05-20]
              E1CF 20DD FFE4 B89E 8026  58F1 E0B1 1894 F66A EC98
        uid        [desconocida] Debian Archive Automatic Signing Key (9/stretch) <ftpmaster@debian.org>
        sub   rsa4096 2017-05-22 [S] [caduca: 2025-05-20]

        /etc/apt/trusted.gpg.d/debian-archive-stretch-security-automatic.gpg
        --------------------------------------------------------------------
        pub   rsa4096 2017-05-22 [SC] [caduca: 2025-05-20]
              6ED6 F5CB 5FA6 FB2F 460A  E88E EDA0 D238 8AE2 2BA9
        uid        [desconocida] Debian Security Archive Automatic Signing Key (9/stretch) <ftpmaster@debian.org>
        sub   rsa4096 2017-05-22 [S] [caduca: 2025-05-20]

        /etc/apt/trusted.gpg.d/debian-archive-stretch-stable.gpg
        --------------------------------------------------------
        pub   rsa4096 2017-05-20 [SC] [caduca: 2025-05-18]
              067E 3C45 6BAE 240A CEE8  8F6F EF0F 382A 1A7B 6500
        uid        [desconocida] Debian Stable Release Key (9/stretch) <debian-release@lists.debian.org>

        /etc/apt/trusted.gpg.d/microsoft.gpg
        ------------------------------------
        pub   rsa2048 2015-10-28 [SC]
              BC52 8686 B50D 79E3 39D3  721C EB3E 94AD BE12 29CF
        uid        [desconocida] Microsoft (Release signing) <gpgsecurity@microsoft.com>

        /etc/apt/trusted.gpg.d/spotify-2018-05-23-48BF1C90.gpg
        ------------------------------------------------------
        pub   rsa4096 2018-05-23 [SC] [caducó: 2020-08-21]
              931F F8E7 9F08 7613 4EDD  BDCC A87F F9DF 48BF 1C90
        uid        [  caducada ] Spotify Public Repository Signing Key <tux@spotify.com>

        /etc/apt/trusted.gpg.d/spotify-2019-07-15-4773BD5E130D1D45.gpg
        --------------------------------------------------------------
        pub   rsa4096 2019-07-15 [SC] [caducó: 2020-10-07]
              2EBF 997C 15BD A244 B6EB  F5D8 4773 BD5E 130D 1D45
        uid        [  caducada ] Spotify Public Repository Signing Key <tux@spotify.com>

        /etc/apt/trusted.gpg.d/spotify-2020-09-08-D1742AD60D811D58.gpg
        --------------------------------------------------------------
        pub   rsa4096 2020-09-08 [SC] [caduca: 2021-12-02]
              8FD3 D9A8 D380 0305 A9FF  F259 D174 2AD6 0D81 1D58
        uid        [desconocida] Spotify Public Repository Signing Key <tux@spotify.com>

* Vemos que lista todas las claves que usa apt para verificar los paquetes.

#### ¿En que fichero se guarda el anillo de claves que guarda la herramienta apt-key?

* Se guarda en un fichero cifrado que se localiza en /etc/apt/trusted.gpg, podríamos añadir alguna clave en /etc/apt/trusted.gpg.d

#### ¿Qué contiene el fichero Release de un repositorio de paquetes?. ¿Y el fichero Release.gpg?

* contiene algunos md5sums por cada paquete listado en él. Al realizar un update, APT descarga los archivos Packages.gz, Release y Release.gpg.

#### Explica el proceso por el cual el sistema nos asegura que los ficheros que estamos descargando son legítimos.

* APT comprueba su firma a través del fichero Release.pgp, apt secure añade una firma gpg para el fichero Release en el fichero Release.gpg y para poder realizar esta comprobación APT necesita conocer la llave pública del que firma el archivo.

#### Añade de forma correcta el repositorio de virtualbox añadiendo la clave pública de virtualbox como se indica en la documentación.

* Añadimos en `/etc/apt/sources.list.d/oracle-virtualbox.list` esta línea:

        deb https://download.virtualbox.org/virtualbox/debian buster contrib

* Y ahora al descargar la versión de virtualbox directamente podemos añadir la clave de la siguiete forma:

        wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -

### Tarea 5:

#### Explica los pasos que se producen entre el cliente y el servidor para que el protocolo cifre la información que se transmite? ¿Para qué se utiliza la criptografía simétrica? ¿Y la asimétrica?

* Las conexiones ssh, la conexión ssh es segura ya que para realizarla ya que para usarla la autenticación del cliente y la apertura del entorno de shell correcto si la verificación tiene éxito. EL cliente primero realiza una conexión por TCP verificando que se puede realizar una conexión simétrica segura, esto se hace comprobando que la identidad que muestra el servidor coincide con el almacen de claves RSA.

* Existen varios cifrados simétricos, antes de la conexión el host y el usuario se ponen de acuerdo en cual usar de una lista que se ordena por orden de preferencia. asi que basicamente su función es que los dos usen la misma clave para cifrar y descifrar sus mensajes.

* En cambio el cifrado asimétrico solo es usado temporalmente para intercambiar las claves del cifrado simétrico.

* Así que el cuando un cliente se conecta mediante TCP el servidor está escuchando por ssh en el puerto 22 entonces se usa el cifrado simétrico para verificar su identidad. Una vez hecho esto se inicia lo que se llama la negociación de cifrado de sesión, en la que básicamente elijen que protocolo de cifrado será utilizado y la autentificación del cliente.

#### Explica los dos métodos principales de autentificación: por contraseña y utilizando un par de claves públicas y privadas.

* La autentificación por contraseña es una autentificación básica, simplemente debemos introducir la contraseña del usuario al que nos estamos conectando, este método se puede activar o desactivar en el fichero /etc/ssh/sshd_config y /etc/ssh/ssh_config.

* Basicamente en la autentificación usando par de claves solo debemos generar la clave publica y privada en el ciente y añadir el ID de nuestra clave pública en el servidor en el fichero ~/.ssh/authorized_keys, esto nos permitirá el acceso sin necesidad de saber la contraseña del servidor al que nos estamos conectando.

#### ¿En el cliente para que sirve el contenido que se guarda en el fichero ~/.ssh/know_hosts?

* El cliente ssh mantiene en ~/.ssh/known_hosts una base de datos conteniendo las máquinas a las que el usuario se ha conectado. así sabe que confiamos en ellas.

#### En ocasiones cuando estamos trabajando en el cloud, y reutilizamos una ip flotante nos aparece este mensaje:

        $ ssh debian@172.22.200.74
         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
         @    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
         @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
         IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
         Someone could be eavesdropping on you right now (man-in-the-middle attack)!
         It is also possible that a host key has just been changed.
         The fingerprint for the ECDSA key sent by the remote host is
         SHA256:W05RrybmcnJxD3fbwJOgSNNWATkVftsQl7EzfeKJgNc.
         Please contact your system administrator.
         Add correct host key in /home/jose/.ssh/known_hosts to get rid of this message.
         Offending ECDSA key in /home/jose/.ssh/known_hosts:103
           remove with:
           ssh-keygen -f "/home/jose/.ssh/known_hosts" -R "172.22.200.74"
         ECDSA host key for 172.22.200.74 has changed and you have requested strict checking.

* Esto significa que la clave de este equipo ha cambiado. Este mensaje puede aparecer por ejemplo si nos conectamos a un equipo con una IP con la que ya nos hemos conectado anteriormente, sin embargo es un equipo diferente, la clave e IP de este equipo están almacenadas en el fichero `known_hosts` y al ver que no coinciden nos saltará este mensaje de advertencia.

#### ¿Qué guardamos y para qué sirve el fichero en el servidor ~/.ssh/authorized_keys?

* Hemos visto que guardamos las claves públicas de las máquinas o usuarios que queremos que puedan conectarse a nuestro sistema sin necesidad de saber la contraseña de ninguno de los usuarios del servidor. Si usamos una de las claves que esten añadidas en este fichero para conectarnos a esta máquina se nos permitirá el acceso permanente mediante la clave ssh.   
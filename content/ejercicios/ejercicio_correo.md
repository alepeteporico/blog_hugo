+++
title = "Ejercicio correo"
description = ""
tags = [
    "SRI"
]
date = "2022-01-14"
menu = "main"
+++

### Ejercicio 1: Envío local, entre usuarios del mismo servidor

* Tenemos distintos parametros configurables, como por ejemplo en el fichero `/etc/postfix/main.cf` podemos configurar el parametro `myorigin` que es el dominio donde se va a enviar nuestro correo y `mydestination` se refiere a los dominios que considera que son suyos, si llegara algun correo a a cualquiera de los dominios que añadamos el servidor recibirá estos correos. Y otro que usaremos más adelante es el relayhost, aquí podremos añadir un servidor de correo que redirija nuestros envios.

* Primero instalaremos el paquete postfix, durante la instalación nos pedira que tipo de servidor de correo queremos, elegiremos `Internet site`

![tipo](/ejercicio_correo/1.png)

* Otra cosa que nos pedirá en la instalación es que añadamos el dominio en el que estará nuestro servidor de correo

![dominio](/ejercicio_correo/2.png)

* Vamos a enviar un correo a nuestro dominio

~~~
debian@apolo:~$ mail usuario2@alegv.gonzalonazareno.org
Subject: prueba potente
helo.
Cc:
~~~

* Vamos a comprobar que hemos recibido el correo mirando los logs.

~~~
agrant@bullseye:~$ sudo cat /var/mail/usuario2 
From debian@alegv.gonzalonazareno.org  Fri Jan 14 12:55:42 2022
Return-Path: <debian@alegv.gonzalonazareno.org>
X-Original-To: usuario2@alegv.gonzalonazareno.org
Delivered-To: usuario2@alegv.gonzalonazareno.org
Received: by apolo (Postfix, from userid 1000)
	id 7BB611000B7; Fri, 14 Jan 2022 12:55:42 +0000 (UTC)
To: usuario2@alegv.gonzalonazareno.org
Subject: prueba potente
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Message-Id: <20220114125542.7BB611000B7@apolo>
Date: Fri, 14 Jan 2022 12:55:42 +0000 (UTC)
From: debian@alegv.gonzalonazareno.org
helo
~~~

### Ejercicio 2: Envío de correo desde usuarios del servidor a correos de internet

* Necesitaremos que el servidor de papion, servidor de correo del instituto, mande nuestros correos por nosotros, pues si lo intentamos nosotros el cortafuegos nos lo echará para atras. añadiremos este servidor al relay del fichero `main.cf`.

~~~
relayhost = babuino-smtp.gonzalonazareno.org
~~~

* Y después de eso añadiremos como primer nameserver de nuestro `resolv.conf` y reiniciar el servicio postfix.

~~~
debian@apolo:~$ sudo systemctl restart postfix
~~~

* Ahora mandamos nuestro email, usaremos la opción -r para obligar a la utilidad mail para obligarlo a mandarlo desde nuestro dominio.

~~~
debian@apolo:~$ mail -r debian@alegv.gonzalonazareno.org tojandro@gmail.com
Cc: 
Subject: definitiva
~~~

* Veamos los logs para ver si lo ha enviado correctamente.

~~~
Jan 19 09:10:27 apolo postfix/pickup[4277]: 48534611AD: uid=1000 from=<debian@alegv.gonzalonazareno.org>
Jan 19 09:10:27 apolo postfix/cleanup[4297]: 48534611AD: message-id=<20220119081027.48534611AD@alegv.gonzalonazareno.org>
Jan 19 09:10:27 apolo postfix/qmgr[4278]: 48534611AD: from=<debian@alegv.gonzalonazareno.org>, size=370, nrcpt=1 (queue active)
Jan 19 09:10:27 apolo postfix/smtp[4299]: 48534611AD: to=<tojandro@gmail.com>, relay=babuino-smtp.gonzalonazareno.org[192.168.203.3]:25, delay=0.4, delays=0.26/0.03/0.05/0.07, dsn=2.0.0, status=sent (250 2.0.0 Ok: queued as 689BDFF77A)
~~~

* Veamos una prueba de que nos ha llegado.

![prueba](/ejercicio_correo/3.png)

### Ejercicio 3: Recibir correos desde internet a usuarios del servidor

* Añadimos un registro mx a nuestra zona externa.

~~~
@       IN      MX 10   zeus.alegv.gonzalonazareno.org.
~~~

* También en zeus tenemos que añadir una regla `dnat` para el puerto 25.

~~~
post-up iptables -t nat -A PREROUTING -p tcp -i ens3 --dport 25 -j DNAT --to 10.0.1.102
~~~

* 
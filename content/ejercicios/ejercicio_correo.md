+++
title = "Ejercicio correo"
description = ""
tags = [
    "SRI"
]
date = "2021-01-14"
menu = "main"
+++


* Tenemos distintos parametros configurables, como por ejemplo en el fichero `/etc/postfix/main.cf` podemos configurar el parametro `myorigin` que es el dominio donde se va a enviar nuestro correo y `mydestination` se refiere a los dominios que considera que son suyos, si llegara algun correo a a cualquiera de los dominios que añadamos el servidor recibirá estos correos.

* Vamos a enviar un correo a nuestro dominio

~~~
vagrant@bullseye:~$ mail usuario2@alegv.gonzalonazareno.org
Subject: prueba potente
helo.
Cc:
~~~

* Vamos a comprobar que hemos recibido el correo mirando los logs.

~~~
agrant@bullseye:~$ sudo cat /var/mail/usuario2 
From vagrant@alegv.gonzalonazareno.org  Fri Jan 14 12:55:42 2022
Return-Path: <vagrant@alegv.gonzalonazareno.org>
X-Original-To: usuario2@alegv.gonzalonazareno.org
Delivered-To: usuario2@alegv.gonzalonazareno.org
Received: by bullseye (Postfix, from userid 1000)
	id 7BB611000B7; Fri, 14 Jan 2022 12:55:42 +0000 (UTC)
To: usuario2@alegv.gonzalonazareno.org
Subject: prueba potente
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Message-Id: <20220114125542.7BB611000B7@bullseye>
Date: Fri, 14 Jan 2022 12:55:42 +0000 (UTC)
From: vagrant@alegv.gonzalonazareno.org
helo
~~~

### Instalación y configuración de servidor de correo en apolo

* Primero instalaremos el paquete postfix, durante la instalación nos pedira que tipo de servidor de correo queremos, elegiremos `Internet site`

![tipo](/ejercicio_correo/1.png)

* Otra cosa que nos pedirá en la instalación es que añadamos el dominio en el que estará nuestro servidor de correo

![dominio](/ejercicio_correo/2.png)

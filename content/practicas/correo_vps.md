+++
title = "Servidor de correos"
description = ""
tags = [
    "SRI"
]
date = "2022-06-05"
menu = "main"
+++

## Gestión de correos desde el servidor

* Añadiremos tres registros a nuestra zona DNS (A, MX y SPF).

![A](/correo/1.png)

![MX](/correo/2.png)

![SPF](/correo/3.png)

### Tarea 1

* Ahora nos dirigimos a nuestra máquina e instalamos el servicio de postfix.

~~~
debian@mrrobot:~$ sudo apt install postfix bsd-mailx
~~~

* Vamos a enviar un correo y comprobar que lo recibimos.

~~~
debian@mrrobot:~$ mail tojandro@gmail.com
Subject: prueba
Prueba de postfix
Cc:
~~~

![Correo](/correo/4.png)

* También debemos comprobar el log.

~~~
Jun  7 16:35:08 mrrobot postfix/pickup[3394206]: 7E9D0A06E6: uid=1000 from=<debian>
Jun  7 16:35:08 mrrobot postfix/cleanup[3394223]: 7E9D0A06E6: message-id=<20220607163508.7E9D0A06E6@mail.alejandrogv.site>
Jun  7 16:35:08 mrrobot postfix/qmgr[3394207]: 7E9D0A06E6: from=<debian@mail.alejandrogv.site>, size=429, nrcpt=1 (queue active)
Jun  7 16:35:08 mrrobot postfix/smtp[3394225]: connect to gmail-smtp-in.l.google.com[2a00:1450:400c:c08::1b]:25: Network is unreachable
Jun  7 16:35:09 mrrobot postfix/smtp[3394225]: 7E9D0A06E6: to=<tojandro@gmail.com>, relay=gmail-smtp-in.l.google.com[74.125.140.27]:25, delay=0.88, delays=0.03/0.02/0.38/0.44, dsn=2.0.0, status=sent (250 2.0.0 OK  1654619709 f14-20020a0560001a8e00b0021030c9d5b8si20690073wry.924 - gsmtp)
Jun  7 16:35:09 mrrobot postfix/qmgr[3394207]: 7E9D0A06E6: removed
~~~

### Tarea 2

* Ahora vamos a realizar una prueba de envio desde el exterior.

![Correo](/correo/5.png)

* Primero vemos el log para comprobar que se ha realizado la conexión.

~~~
Jun  7 16:41:16 mrrobot postfix/smtpd[3394417]: connect from mail-yw1-f170.google.com[209.85.128.170]
Jun  7 16:41:16 mrrobot postfix/smtpd[3394417]: E8CD2A06E5: client=mail-yw1-f170.google.com[209.85.128.170]
Jun  7 16:41:16 mrrobot postfix/cleanup[3394422]: E8CD2A06E5: message-id=<CAONuo7DOH0kdR5C6WEv37RHnrGd5ZyE1Dfs28ch4=z98UewTgg@mail.gmail.com>
Jun  7 16:41:16 mrrobot postfix/qmgr[3394207]: E8CD2A06E5: from=<tojandro@gmail.com>, size=2727, nrcpt=1 (queue active)
Jun  7 16:41:16 mrrobot postfix/local[3394423]: E8CD2A06E5: to=<debian@mrrobot.alejandrogv.site>, relay=local, delay=0.02, delays=0.01/0.01/0/0, dsn=2.0.0, status=sent (delivered to mailbox)
Jun  7 16:41:16 mrrobot postfix/qmgr[3394207]: E8CD2A06E5: removed
Jun  7 16:41:50 mrrobot postfix/smtpd[3394417]: disconnect from mail-yw1-f170.google.com[209.85.128.170]
~~~

* Para ver el correo usamos `mail`.

~~~
debian@mrrobot:~$ mail
Mail version 8.1.2 01/15/2001.  Type ? for help.
"/var/mail/debian": 2 messages 2 new
>N  1 tojandro@gmail.co  Wed Feb  2 07:55   70/3415  Re: prueba desde vps
 N  2 tojandro@gmail.co  Tue Jun  7 16:41   55/2855  prueba envio
~~~

~~~
Message 2:
From tojandro@gmail.com  Tue Jun  7 16:41:16 2022
X-Original-To: debian@mrrobot.alejandrogv.site
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=mime-version:from:date:message-id:subject:to;
        bh=oorhvQZO6JD02GWMtJ4wjC5Pqy9VKftZGbjBjQ06SoE=;
        b=KpWFITQImxET5cwlv6DfBqX4njyglNtJAHZrQUkf48c1toGFgE0C9+3SugkFHlEhs6
         ugirK4G0nNBlFBLRU/DsCiUVPB5eCKHtqpp0VSYCt40Z63CuADLrZTaQShrFUhrtzvF9
         ok7aALQAwdxaiAob0f2tQB0zp179E7KxkDLP45LE91jAQ8XXun6CncYADtcHI/HSOQq1
         TlTwUkXqxau3dztyzpfEG+yq3HbGACcV3XR2TTtVx2prA7hgXhJ2Wxw9wcEpy9U4p6xa
         A+Zk7cuBL1jLMtZNk6Oo6NRKLok00/MbfGLfoGiDgejd/Fi71AG5XGBNZg0M6gju1hSA
         vZ/Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to;
        bh=oorhvQZO6JD02GWMtJ4wjC5Pqy9VKftZGbjBjQ06SoE=;
        b=ocizZ/SU8M5QFiU/U2D5znxc6MLmGnNjIOcje17S3MGAGWzOLOJrwpXXJPL2p7I4Do
         tULkekGMtg0Sb59w84/nEJTCah4K8xjgOUu6RH2Dv/TIwP1+JYmVC2Zp7NpLMBARHZdU
         ygMRTppcR+vcotgCx40Fity9CR76dHTLcZP6YGPsjNOR4jD4fd1RoJZZpEmx4DUfkkn8
         DgtciYxktMVUw9LLwpCbq/mpPFvF+PGcvz/sVv74jvgpJjtskio/91rdeMrnP4ULmqZA
         KUnCf/X6akLV3w16/z4gEgfppkAUrhgd9WiwBXwnxFQkF5+SPitnY4HE4sN8CHRBquwD
         GUNA==
X-Gm-Message-State: AOAM530nd5PDSpOzpq/eB7gCdKqVzIFmPpCCMyHLCsHKVKg8qY1K6lMm
	QF2WR1oqKqYDW6fuDsjWIFjdCndkZFzg8c6NwEuV/I3n
X-Google-Smtp-Source: ABdhPJwYv232JDSCSZeDwmOhzIEsY0j+WZmMJnnXpkg8KpBWYqKQlBNbCvmsvlqCENEF5/6jcGkTae9NzTPUXXgwGSI=
X-Received: by 2002:a81:1b87:0:b0:313:39db:beec with SMTP id
 b129-20020a811b87000000b0031339dbbeecmr4279378ywb.142.1654620075357; Tue, 07
 Jun 2022 09:41:15 -0700 (PDT)
MIME-Version: 1.0
From: =?UTF-8?Q?Alejandro_Guti=C3=A9rrez_Valencia?= <tojandro@gmail.com>
Date: Tue, 7 Jun 2022 18:41:04 +0200
Subject: prueba envio
To: Debian <debian@mrrobot.alejandrogv.site>
Content-Type: multipart/alternative; boundary="000000000000d47af205e0de4129"

--000000000000d47af205e0de4129
Content-Type: text/plain; charset="UTF-8"

Prueba de envio desde el exterior

--000000000000d47af205e0de4129
Content-Type: text/html; charset="UTF-8"

<div dir="ltr">Prueba de envio desde el exterior<br></div>

--000000000000d47af205e0de4129--
~~~

## Uso de alias y redirecciones

### Tarea 3

* Vamos a hacer que el sistema nos mande un correo sobre algunas tareas o acciones que nosotros especificaremos, para ello primero usaremos el comando `contrab`.

~~~
root@mrrobot:~# crontab -e
~~~

* Se nos abrirá un fichero que configuraremos para que los correos se envien desde root.

~~~
MAILTO = root
~~~

* A partir de aquí podemos enviar cualquier cosa por correo, por ejemplo, la siguiente línea mandará un correo cada 5 min del contenido del script que hemos especificado cuyo contenido podemos ver abajo.

~~~
* * * * * sleep 300; /root/correo.sh
~~~

~~~
#! /bin/sh

echo "correo de las $(date)"
~~~

* Ahora creamos un alias en el fichero `/etc/aliases` para que se redirijan los correos que se manden a root a nuestro usuario debian.

~~~
root:   debian
~~~

* Aplicamos el cambio.

~~~
root@mrrobot:~# newaliases
~~~

* Comprobamos que llegan.

~~~
 N 51 root@mail.alejand  Tue Jun  7 18:01   22/789   Cron <root@mrrobot> sleep 300; /root/correo.sh
& 51
Message 51:
From root@mail.alejandrogv.site  Tue Jun  7 18:01:01 2022
X-Original-To: root
From: root@mail.alejandrogv.site (Cron Daemon)
To: root@mail.alejandrogv.site
Subject: Cron <root@mrrobot> sleep 300; /root/correo.sh
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Cron-Env: <MAILTO=root>
X-Cron-Env: <SHELL=/bin/sh>
X-Cron-Env: <HOME=/root>
X-Cron-Env: <PATH=/usr/bin:/bin>
X-Cron-Env: <LOGNAME=root>
Date: Tue,  7 Jun 2022 18:01:01 +0000 (UTC)

correo de las Tue Jun  7 18:01:01 UTC 2022
~~~

* Si queremos que lleguen a nuestro correo personal debemos crear un fichero oculto en el home del usuario llamado `.forward` que contenga nuestro correo.

~~~
debian@mrrobot:~$ cat .forward 
tojandro@gmail.com
~~~

* Comprobamos que llegan los correos.

![personal](/correo/6.png)

## Para asegurar el envío

### Tarea 4

* Debemos configurar `DKIM` para autentificar los correos que enviamos. Para ello instalamos primero la paquetería necesaria.

~~~
debian@mrrobot:~$ sudo apt install opendkim opendkim-tools
~~~

* Creamos la clave que se usará para firmar y que tendremos que mover al directorio `/etc/dkimkeys/`.

~~~
debian@mrrobot:~$ sudo opendkim-genkey -s dkim -d alejandrogv.site -b 1024
~~~

* Ahora para configurarlo nos dirigimos al fichero `/etc/opendkim.conf` y configuramos las líneas que aparecen a continuación.

~~~
Domain                  alejandrogv.site
Selector                dkim
KeyFile         /etc/dkimkeys/dkim.private
Socket                  inet:8191@localhost
~~~

* Y debemos configurar también el fichero `/etc/default/opendkim` para añadir el nuevo puerto que usará.

~~~
SOCKET=inet:8891@localhost
~~~

* Por último, vamos al fichero `/etc/postfix/main.cf` y lo configuramos para que firme los correos.

~~~
milter_default_action = accept
milter_protocol = 2
smtpd_milters = inet:localhost:8891
non_smtpd_milters = $smtpd_milters
~~~

* Ahora debemos crear un registro txt en el servidor.

![TXT](/correo/7.png)

* Si usamos esta página podremos comprobar que nuestro registro está bien configurado.

![prueba](/correo/17.png)

* Comprobemoslo enviando un correo y viendo su información.

![prueba](/correo/8.png)

## Para luchar contra el SPAM

* Vamos a instalar una herramienta llamada `spamassasin` para filtrar el spam que llega a nuestro servidor

~~~
debian@mrrobot:~$ sudo apt install spamassassin spamc
~~~

* Nos dirigimos el fichero `/etc/default/spamassassin` y cambiamos el valor de la variable `CRON` a 1.

~~~
CRON=1
~~~

* Ahora, en el fichero `nano /etc/postfix/master.cf` vamos a hacer que este servicio filtre los paquetes.

~~~
smtp      inet  n       -       y       -       -       smtpd
  -o content_filter=spamassassin
submission inet n       -       y       -       -       smtpd
  -o content_filter=spamassassin
spamassassin unix -     n       n       -       -       pipe
  user=debian-spamd argv=/usr/bin/spamc -f -e /usr/sbin/sendmail -oi -f ${sender} ${recipient}
~~~

* En el fichero `/etc/spamassassin/local.cf` descomentamos la siguiente línea.

~~~
rewrite_header Subject *****SPAM*****
~~~

* Enviamos un mensaje con spam y comprobamos que funciona en los logs y en mail.

~~~
Jun  8 17:45:28 mrrobot spamd[3435289]: spamd: identified spam (998.9/5.0) for debian-spamd:112 in 0.2 seconds, 2840 bytes.

debian@mrrobot:~$ mail
 N178 tojandro@gmail.co  Wed Jun  8 17:45  126/6203  *****SPAM***** prueba spam
~~~

## Gestión de correos desde un cliente

### Tarea 8

* Vamos a instalar la herramienta `maildir` para ello instalamos la herramienta `mutt`.

~~~
debian@mrrobot:~$ sudo apt install mutt
~~~

* Seguidamente nos dirigimos al fichero de configuración de postfix `/etc/postfix/main.cf` donde debemos indicar que el buzon que usará será el de maildir.

~~~
home_mailbox = Maildir/
~~~

* Ahora en nuestro home debemos crear un fichero oculto llamado `.muttrc`

~~~
set mbox_type=Maildir
set folder="~/Maildir"
set mask="!^\\.[^.]"
set mbox="~/Maildir"
set record="+.Sent"
set postponed="+.Drafts"
set spoolfile="~/Maildir"
~~~

* Vamos a comprobar que funciona enviando un correo a nuestro servidor desde fuera, para visualizarlo usamos el comando `mutt`.

~~~
debian@mrrobot:~$ mutt
~~~

![prueba](/correo/9.png)

![prueba](/correo/10.png)

### Tarea 9

* Instalaremos y configuraremos dovecot para que nuestros correos tengan autentificación y cifrado.

~~~
debian@mrrobot:~$ sudo apt install dovecot-imapd
~~~

* Necesitamos un certificado, para obtenerlo usaremos let's encrypt.

~~~
debian@mrrobot:~$ sudo certbot certonly --standalone -d mail.alejandrogv.site
~~~

* Añadimos estos certificados a la configuración del servicio en el fichero `/etc/dovecot/conf.d/10-ssl.conf`.

~~~
ssl_cert = </etc/letsencrypt/live/mail.alejandrogv.site/fullchain.pem
ssl_key = </etc/letsencrypt/live/mail.alejandrogv.site/privkey.pem
~~~

* Como nuesto cliente usa maildir debemos configurar dovecot para que lo use también, en el fichero `/etc/dovecot/conf.d/10-mail.conf`

~~~
mail_location = maildir:~/Maildir
~~~

### Tarea 11

* Vamos a configurar postfix para poder enviar correos desde un cliente remoto. Para cifrar estos correos usaremos los certificados de dovecot y añadiremos algunos apartados en el fichero `/etc/postfix/main.cf`.

~~~
smtpd_tls_cert_file=/etc/letsencrypt/live/mail.alejandrogv.site/fullchain.pem
smtpd_tls_key_file=/etc/letsencrypt/live/mail.alejandrogv.site/privkey.pem

smtpd_sasl_auth_enable = yes
smtpd_sasl_type = dovecot
smtpd_sasl_path = private/auth
smtpd_sasl_authenticated_header = yes
broken_sasl_auth_clients = yes
~~~

* En el fichero `/etc/postfix/master.cf` descomentamos las siguientes líneas.

~~~
submission inet n       -       y       -       -       smtpd
  -o content_filter=spamassassin
  -o syslog_name=postfix/submission
  -o smtpd_tls_security_level=encrypt
  -o smtpd_sasl_auth_enable=yes
  -o smtpd_tls_auth_only=yes
  -o smtpd_reject_unlisted_recipient=no
  -o smtpd_client_restrictions=$mua_client_restrictions
  -o smtpd_helo_restrictions=$mua_helo_restrictions
  -o smtpd_sender_restrictions=$mua_sender_restrictions
  -o smtpd_recipient_restrictions=
  -o smtpd_relay_restrictions=permit_sasl_authenticated,reject
  -o milter_macro_daemon_name=ORIGINATING
smtps     inet  n       -       y       -       -       smtpd
  -o syslog_name=postfix/smtps
  -o smtpd_tls_wrappermode=yes
  -o smtpd_sasl_auth_enable=yes
  -o smtpd_reject_unlisted_recipient=no
  -o smtpd_client_restrictions=$mua_client_restrictions
  -o smtpd_helo_restrictions=$mua_helo_restrictions
  -o smtpd_sender_restrictions=$mua_sender_restrictions
  -o smtpd_recipient_restrictions=
  -o smtpd_relay_restrictions=permit_sasl_authenticated,reject
  -o milter_macro_daemon_name=ORIGINATING
~~~

* Ahora debemos indicar a dovecot como autentificarse, para ello modificamos el fichero `/etc/dovecot/conf.d/10-master.conf`

~~~
service lmtp {
  unix_listener /var/spool/postfix/private/auth {
    mode = 0666
  }
~~~

* Reiniciamos el servicio y nos autentificaremos en nuestra máquina anfitriona en evolution.

![autentificacion](/correo/11.png)

![autentificacion](/correo/12.png)

![autentificacion](/correo/13.png)

![autentificacion](/correo/14.png)

* Ahora no consigo que lleguen los correos que mando desde fuera, sin embargo si puedo ver los que mando desde dentro al exterior y que se sincronizan.

![autentificacion](/correo/16.png)

### 
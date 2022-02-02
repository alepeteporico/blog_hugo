+++
title = "Ejercicio correo"
description = ""
tags = [
    "SRI"
]
date = "2022-02-02"
menu = "main"
+++

* Documenta una prueba de funcionamiento, donde envíes desde tu servidor local al exterior. Muestra el log donde se vea el envío. Muestra el correo que has recibido. Muestra el registro SPF.

~~~
debian@mrrobot:~$ mail tojandro@gmail.com
Cc: 
Subject: prueba desde vps
~~~

~~~
debian@mrrobot:~$ cat /var/log/mail.log 
Feb  2 07:39:58 mrrobot postfix/pickup[915259]: E42DCA0AB9: uid=1000 from=<debian@mrrobot.alejandrogv.site>
Feb  2 07:39:58 mrrobot postfix/cleanup[916025]: E42DCA0AB9: message-id=<20220202073958.E42DCA0AB9@mrrobot.alejandrogv.site>
Feb  2 07:39:58 mrrobot postfix/qmgr[915260]: E42DCA0AB9: from=<debian@mrrobot.alejandrogv.site>, size=375, nrcpt=1 (queue active)
Feb  2 07:39:59 mrrobot postfix/smtp[916027]: connect to gmail-smtp-in.l.google.com[2a00:1450:400c:c08::1a]:25: Network is unreachable
Feb  2 07:39:59 mrrobot postfix/smtp[916027]: E42DCA0AB9: to=<tojandro@gmail.com>, relay=gmail-smtp-in.l.google.com[66.102.1.26]:25, delay=0.69, delays=0.02/0.03/0.32/0.32, dsn=2.0.0, status=sent (250 2.0.0 OK  1643787599 q14si3769684wme.70 - gsmtp)
Feb  2 07:39:59 mrrobot postfix/qmgr[915260]: E42DCA0AB9: removed
~~~
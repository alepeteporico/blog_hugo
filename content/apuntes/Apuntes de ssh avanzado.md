+++
title = "Apuntes de SSH"
description = ""
tags = [
    "ASO"
]
date = "2021-05-22"
menu = "main"
+++

### ssh-agent

* Tenemos un par de claves, para añadir a nuestro ssh-agent:

        ssh-add .ssh/clave

* Nos pedirá la frase de paso y se añadiría la identidad, para comprobarlo:

        ssh-add -l

* Pero necesitamos añadir esa clave a la máquina que nos queremos conectar.

        ssh-copy-id -i .ssh/clave usuario@172.22.100.10
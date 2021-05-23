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

### Túneles ssh

* Se usa para saltarnos un cortafuegos o para acceder por un canal abierto y más seguro, entre otras útilidades.

* Para crear el túnel usamos el comando que vemos a continuación, usando el puerto que queramos y este libre, y poniendo primero la IP de la máquina a la que queremos acceder y segundo desde la que accedemos.

        ssh -f -L 1080:192.168.100.10:.80 192.168.100.20 -N

* Si quisieramos eliminarlo es simplemente eliminar un proceso, comprobamos el PID y lo eliminamos:

        ss -lntp | grep 1080

        kill 'pid'
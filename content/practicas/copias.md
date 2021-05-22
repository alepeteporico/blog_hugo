+++
title = "Copias de seguridad con rsync"
description = ""
tags = [
    "ASO"
]
date = "2021-05-22"
menu = "main"
+++

* Usaremos la herramienta rsync para realizar nuestro sistema de copias de seguridad, por supuesto el primer paso que debemos tomar es instalar el paquete de rsync, lo haremos en Dulcinea, usaremos esta máquina para alojar las copias de seguridad.

        debian@dulcinea:~$ sudo apt install rsync
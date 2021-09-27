+++
title = "Instalación y configuración de un servidor PXE en debian"
description = ""
tags = [
    "SO"
]
date = "2021-09-21"
menu = "main"
+++

---

* En la máquina que usaremos como servidor pxe debemos instalar también un servidor dhcp que dará direccionamiento IP a nuestros clientes.

        vagrant@pxe:~$ sudo apt install isc-dhcp-server

* 
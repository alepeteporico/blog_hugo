+++
title = "Control de acceso, autentificación y autorización"
description = ""
tags = [
    "SRI"
]
date = "2021-04-24"
menu = "main"
+++

## Crea un escenario en Vagrant o reutiliza uno de los que tienes en ejercicios anteriores, que tenga un servidor con una red publica, y una privada y un cliente conectada a la red privada. Crea un host virtual departamentos.iesgn.org

* Para está práctica podremos usar la misma máquina de vagrant que usamos para las prácticas del cms y de mapeo.

### A la URL departamentos.iesgn.org/intranet sólo se debe tener acceso desde el cliente de la red local, y no se pueda acceder desde la anfitriona por la red pública. A la URL departamentos.iesgn.org/internet, sin embargo, sólo se debe tener acceso desde la anfitriona por la red pública, y no desde la red local.

* Crearemos un nuevo virtual host en sites-avaiable el cual solo tendrá acceso desde la IP interna de nuestro servidor.


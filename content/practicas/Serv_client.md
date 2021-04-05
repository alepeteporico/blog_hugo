+++
title = "Instalación de servidores y clientes"
description = ""
tags = [
    "ABD"
]
date = "2021-03-16"
menu = "main"
+++

Tras la instalación de cada servidor,  debe crearse una base de datos con al menos tres tablas o colecciones y poblarse de datos adecuadamente. Debe crearse un usuario y dotarlo de los privilegios necesarios para acceder remotamente a los datos. Se proporcionará esta información al resto de los miembros del grupo.

* Los clientes deben estar siempre en máquinas diferentes de los respectivos servidores a los que acceden.
* Se documentará todo el proceso de configuración de los servidores.
* Se aportarán pruebas del funcionamiento remoto de cada uno de los clientes.
* Se aportará el código de las aplicaciones realizadas y prueba de funcionamiento de las mismas.

## Instalación servidor Oracle 19c

* Hemos creado una maquina vagrant con centos 8 para instalar nuestro servidor de Oracle 19c, lo descargaremos de la [página oficial de Oracle](https://www.oracle.com/es/database/technologies/oracle19c-linux-downloads.html#license-lightbox)
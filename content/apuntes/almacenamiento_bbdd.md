+++
title = "Almacenamiento en BBDD"
description = ""
tags = [
    "AGB"
]
date = "2023-01-25"
menu = "main"
+++

![diagrama](/apuntes_almacenamientobbdd/1.png)

## TABLESPACES

* Es una especie de carpeta que contiene las tablas, indices, etc... que corresponde a uno o variows datafiles.

* (No mezclar datos de distinta naturaleza en el mismo tablespace).

* Importantes en la administración por el punto de que se puede activar o desactivar:

~~~
ALTER TABLESPACE X OFFLINE;

ALTER TABLESPACE X ONLINE;
~~~

* 
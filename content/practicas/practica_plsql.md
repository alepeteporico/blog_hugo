+++
title = "Práctica de PLSQL"
description = ""
tags = [
    "ABD"
]
date = "2021-03-29"
menu = "main"
+++

![tablas](/PLSQL/1.png)

1. Realiza una función que reciba el código de un aerogenerador y una fecha y devuelva el total de energía producida en esa fecha. Debes controlar las siguientes excepciones: Aerogenerador inexistente y Aerogenerador en desconexión durante ese día.

~~~
create or replace function EnergiaDiaria (v_codigo AEROGENERADORES.CODIGO%type, v_fecha)
~~~
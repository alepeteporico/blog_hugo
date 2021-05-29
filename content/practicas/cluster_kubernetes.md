+++
title = "Despliegue de un cluster de kubernetes"
description = ""
tags = [
    "HLC
]
date = "2021-05-27"
menu = "main"
+++

* Crearemos 3 máquinas Vagrant que nos servirán, una de controlador y las otras dos de workers.

* En la máquina que usaremos como controlador descargaremos e instalaremos usando `curl` el script que instalará el servicio de k3.

        root@servidor:/usr/local/bin# curl -sfL https://get.k3s.io | sh -

* Podemos comprobar mediante netstat que se ha abierto un puerto `6443` que es el que usa k3s por defecto.

        root@servidor:/usr/local/bin# netstat -tlnp | egrep '6443'
        tcp6       0      0 :::6443                 :::*                    LISTEN      1577/k3s server 

* Vamos a listar todos los nodos que tenemos, así comprobaremos que la instalación se ha realizado correctamente.

        root@servidor:~# k3s kubectl get nodes
        NAME       STATUS   ROLES                  AGE     VERSION
        servidor   Ready    control-plane,master   5m33s   v1.20.7+k3s1

* Vamos a necesitar una cadena llamada `token` que podremos visualizar en el fichero `/var/lib/rancher/k3s/server/node-token`

        root@servidor:~# cat /var/lib/rancher/k3s/server/node-token
        K10011d1572405b0786ba05fe620b91442da52987ce21512d2ae4987bf48b92f163::server:42e92bb7042694445be5a4bc17a05ffb

* Ahora nos dirigimos a uno de los nodos y realizaremos el mismo paso que al principio de descargar el script de instalación, sin embargo añadiremos un par de cosas, lo vincularemos mediante una URL añadiendo la IP de nuestro servidor. Y mediante el token que pudimos ver antes.


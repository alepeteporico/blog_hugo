+++
title = "Contenedores LXC"
description = ""
tags = [
    "HLC"
]
date = "2022-01-19"
menu = "main"
+++

### Ejercicio 1

* Crearemos la primera máquina de nuestro escenario, será un contenedor LXC llamado router. Este contenedor se creará a partir de la plantilla Debian Bullseye. Este contenedor tendrá dos interfaces de red: la primera conectada a una red pública (bridge br0). Por esta interfaz el contenedor tendrá acceso a internet. Además estará conectada la bridge de un red muy aislada que crearás con virsh y tendrá como dirección IP la 10.0.0.1.

* Primero creamos el contenedor llamado router y con debian bullseye

~~~
root@AlejandroGV:~/lxc# lxc-create -n router -t debian -- -r bullseye
~~~

* Ahora crearemos el bridge que usaremos para conectar a está máquina. para ello entraremos en el fichero de configuración del contenedor `/var/lib/lxc/router/config` y añadiremos una red very isolated que ya tenía configurada.

~~~
lxc.net.0.link = virbr11
~~~

* Otro parametro que debemos configurar dentro de este fichero es la RAM y la CPU y el inicio automático cuando se inicia el host, este contenedor tendrá 512 MB de RAM y 2 CPU, añadimos las siguientes líneas:

~~~
lxc.cgroup2.memory.max = 512M
lxc.cgroup2.cpuset.cpus = 2
lxc.start.auto = 1
~~~

* 
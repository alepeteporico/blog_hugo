+++
title = "Cortafuegos perimetral sobre el escenario"
description = ""
tags = [
    "SAD"
]
date = "2022-03-21"
menu = "main"
+++

* Política por defecto DROP para las cadenas INPUT, FORWARD y OUTPUT.

~~~

~~~

* Se pueden usar las extensiones que creamos adecuadas, pero al menos debe implementarse seguimiento de la conexión.

~~~

~~~

* Debemos implementar que el cortafuegos funcione después de un reinicio de la máquina. 

~~~

~~~

* La máquina Zeus tiene un servidor ssh escuchando por el puerto 22, pero al acceder desde el exterior habrá que conectar al puerto 2222.

~~~

~~~

* Desde Apolo y Hera se debe permitir la conexión ssh por el puerto 22 a la máquina Zeus.

~~~

~~~

* La máquina Zeus debe tener permitido el tráfico para la interfaz loopback.

~~~

~~~

* A la máquina Zeus se le puede hacer ping desde la DMZ, pero desde la LAN se le debe rechazar la conexión (REJECT) y desde el exterior se rechazará de manera silenciosa.

~~~

~~~

* La máquina Zeus puede hacer ping a la LAN, la DMZ y al exterior.

~~~

~~~

* Desde la máquina Hera se puede hacer ping y conexión ssh a las máquinas de la LAN.

~~~

~~~

* Desde cualquier máquina de la LAN se puede conectar por ssh a la máquina Hera.

~~~

~~~

* Configura la máquina Zeus para que las máquinas de LAN y DMZ puedan acceder al exterior.

~~~

~~~

* Las máquinas de la LAN pueden hacer ping al exterior y navegar.

~~~

~~~

* La máquina Hera puede navegar. Instala un servidor web, un servidor ftp y un servidor de correos si no los tienes aún.

~~~

~~~

* Configura la máquina Zeus para que los servicios web y ftp sean accesibles desde el exterior.

~~~

~~~

* El servidor web y el servidor ftp deben ser accesibles desde la LAN y desde el exterior.

~~~

~~~

* El servidor de correos sólo debe ser accesible desde la LAN.

~~~

~~~

* En la máquina Ares instala un servidor mysql si no lo tiene aún. A este servidor se puede acceder desde la DMZ, pero no desde el exterior.

~~~

~~~

* Evita ataques DoS por ICMP Flood, limitando el número de peticiones por segundo desde una misma IP.

~~~

~~~

* Evita ataques DoS por SYN Flood.

~~~

~~~

* Evita que realicen escaneos de puertos a Zeus.

~~~

~~~
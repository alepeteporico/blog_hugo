+++
title = "Herramientas de seguridad"
description = ""
tags = [
    "SAD"
]
date = "2021-09-23"
menu = "main"
+++

---

## Sistemas de detección de intrusos

---------------------------

#### Vamos a usar como sistema de detección de intrusos la herramienta SURICATA, parece ser la más usada a día de hoy 

---------------------------

* Por supuesto el primer paso será instalar las dependencias necesarias para nuestro

        vagrant@practica1 sudo apt install flex bison build-essential checkinstall libpcap-dev libnet1-dev libpcre3-dev libnetfilter-queue-dev cmake libdumbnet-dev

* Vamos a descargar el paquete en nuestra máquina.

        vagrant@suricata:~$ wget https://www.openinfosecfoundation.org/download/suricata-6.0.3.tar.gz

* Descomprimimos el archivo.

~~~
vagrant@suricata:~$ tar xvf suricata-6.0.3.tar.gz
~~~

* El siguiente paso sería compilarlo, antes de eso configuraremos el fichero `.configure` mediante el siguiente comando para añadirle a suricata algunas opciones necesarias.


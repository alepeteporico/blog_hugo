+++
title = "Btrfs"
description = ""
tags = [
    "HLC"
]
date = "2021-12-02"
menu = "main"
+++

* Tenemos una maquina con varios discos asociados, lo primero que haremos será instalar la paquetería necesaria para el uso de este sistema de archivos.

~~~
vagrant@maquina1:~$ sudo apt install btrfs-progs arch-install-scripts
~~~

* Montamos en la tabla de particiones los nuevos discos.

~~~
vagrant@maquina1:~$ sudo cfdisk -z /dev/vdb
vagrant@maquina1:~$ sudo cfdisk -z /dev/vdc
vagrant@maquina1:~$ sudo cfdisk -z /dev/vdd
~~~

* Y vamos a crear el sisitema de ficheros de cada una.

~~~
vagrant@maquina1:~$ sudo mkfs.btrfs /dev/vdb1
btrfs-progs v5.10.1 
See http://btrfs.wiki.kernel.org for more information.

Label:              (null)
UUID:               4c153d30-5d89-4342-a2c0-d5429b449f12
Node size:          16384
Sector size:        4096
Filesystem size:    1022.98MiB
Block group profiles:
  Data:             single            8.00MiB
  Metadata:         DUP              51.12MiB
  System:           DUP               8.00MiB
SSD detected:       no
Incompat features:  extref, skinny-metadata
Runtime features:   
Checksum:           crc32c
Number of devices:  1
Devices:
   ID        SIZE  PATH
    1  1022.98MiB  /dev/vdb1
~~~

* Ya tenemos nuestros discos montandos con btrfs, ahora vamos a montar un RAID con ellos usando este sistema de archivos, para ello tendremos que instalar un paquete necesario para ello.

~~~
vagrant@maquina1:~$ sudo apt install cryptsetup btrfs-progs
~~~

* Ahora tenemos la opción de crear un fichero `KeyFile` muy seguro el cual contendrá una clave con la que podremos desbloquear el disco.

~~~
vagrant@maquina1:~$ sudo dd if=/dev/random of=/root/KeyFile bs=1 count=4096
4096+0 records in
4096+0 records out
4096 bytes (4.1 kB, 4.0 KiB) copied, 0.00756422 s, 541 kB/s

vagrant@maquina1:~$ sudo chmod 0400 /root/KeyFile
~~~

* Esto sería más seguro si tuvieramos nuestro disco principal cifrado, ya que a un atacante le resultaría más difícil acceder a el fichero `KeyFile`.

* Nuestro siguiente paso será cifrar nuestros dispositivos con este fichero.

~~~
vagrant@maquina1:~$ sudo cryptsetup luksFormat --key-file /root/KeyFile /dev/vdb1

vagrant@maquina1:~$ sudo cryptsetup luksFormat --key-file /root/KeyFile /dev/vdc1

vagrant@maquina1:~$ sudo cryptsetup luksFormat --key-file /root/KeyFile /dev/vdd1
~~~

(PREGUNTAR JOSEDOM)
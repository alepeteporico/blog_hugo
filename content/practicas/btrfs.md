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
vagrant@maquina1:~$ sudo cfdisk -z /dev/vde
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

### RAID con btrfs

* Ya tenemos nuestros discos montandos con btrfs, ahora vamos a montar un RAID con ellos usando este sistema de archivos, para ello tendremos que instalar un paquete necesario para ello.

~~~
vagrant@maquina1:~$ sudo apt install btrfs-progs
~~~

* A continuación crearemos el raid usando el siguiente comando, podriamos crear el raid sin necesidad de haber montando con btrfs las particiones anteriormente:

~~~
vagrant@maquina1:~$ sudo mkfs.btrfs -L prueba -d raid5 -m raid5 -f /dev/vdb /dev/vdc /dev/vdd
btrfs-progs v5.10.1 
See http://btrfs.wiki.kernel.org for more information.

Label:              prueba
UUID:               67a68e3c-2efd-4739-8e2f-5f7b8805dd43
Node size:          16384
Sector size:        4096
Filesystem size:    3.00GiB
Block group profiles:
  Data:             RAID5           204.75MiB
  Metadata:         RAID5           170.62MiB
  System:           RAID5            16.00MiB
SSD detected:       no
Incompat features:  extref, raid56, skinny-metadata
Runtime features:   
Checksum:           crc32c
Number of devices:  3
Devices:
   ID        SIZE  PATH
    1     1.00GiB  /dev/vdb
    2     1.00GiB  /dev/vdc
    3     1.00GiB  /dev/vdd
~~~

~~~
vagrant@maquina1:~$ sudo btrfs filesystem show
warning, device 2 is missing
Label: none  uuid: 67a68e3c-2efd-4739-8e2f-5f7b8805dd43
	Total devices 2 FS bytes used 128.00KiB
	devid    1 size 1.00GiB used 212.75MiB path /dev/vdc
	devid    2 size 1.00GiB used 212.75MiB path /dev/vdb
   devid    3 size 1.00GiB used 195.69MiB path /dev/vdd

Label: none  uuid: ad71b7ff-a997-423a-b3f4-5e704e6af0e9
	Total devices 3 FS bytes used 128.00KiB
	devid    3 size 1.00GiB used 264.00MiB path /dev/vdd
	*** Some devices missing
~~~

* Ahora montaremos uno de los discos donde escojamos, en mi caso en una carpeta que he creado en `mnt`

~~~
vagrant@maquina1:~$ sudo mount /dev/vdb /mnt/raid/
~~~

* Y como podemos comprobar el RAID está montado ya en esta carpeta, puede verse que al hacer un `df` este disco tiene 2GB debido a que está usando el RAID que hemos creado con anterioridad.

~~~
vagrant@maquina1:~$ sudo df -h /mnt/raid/
ilesystem      Size  Used Avail Use% Mounted on
/dev/vdb        3.0G  3.4M  1.9G   1% /mnt/raid
~~~

* Con el siguiente comando podremos ver mucha mas información detallada, como espacio disponible, espacio total, etc...

~~~
vagrant@maquina1:~$ sudo btrfs filesystem usage /mnt/raid 
Overall:
    Device size:		   3.00GiB
    Device allocated:		 587.06MiB
    Device unallocated:		   2.43GiB
    Device missing:		     0.00B
    Used:			 384.00KiB
    Free (estimated):		   1.82GiB	(min: 1.82GiB)
    Free (statfs, df):		   1.82GiB
    Data ratio:			      1.50
    Metadata ratio:		      1.50
    Global reserve:		   3.25MiB	(used: 0.00B)
    Multiple profiles:		        no

Data,RAID5: Size:204.75MiB, Used:128.00KiB (0.06%)
   /dev/vdb	 102.38MiB
   /dev/vdc	 102.38MiB
   /dev/vdd	 102.38MiB

Metadata,RAID5: Size:170.62MiB, Used:112.00KiB (0.06%)
   /dev/vdb	  85.31MiB
   /dev/vdc	  85.31MiB
   /dev/vdd	  85.31MiB

System,RAID5: Size:16.00MiB, Used:16.00KiB (0.10%)
   /dev/vdb	   8.00MiB
   /dev/vdc	   8.00MiB
   /dev/vdd	   8.00MiB

Unallocated:
   /dev/vdb	 828.31MiB
   /dev/vdc	 828.31MiB
   /dev/vdd	 828.31MiB
~~~

* Si queremos añadir un disco es un comando simple, usamos btrfs y añadimos un `device add` con el disco que queremos añadir y la ruta de montaje que escogimos.

~~~
vagrant@maquina1:~$ sudo btrfs device add -f /dev/vde /mnt/raid/
~~~

~~~
vagrant@maquina1:~$ sudo btrfs filesystem show 
Label: 'prueba'  uuid: 67a68e3c-2efd-4739-8e2f-5f7b8805dd43
	Total devices 3 FS bytes used 256.00KiB
	devid    1 size 1.00GiB used 212.75MiB path /dev/vdb
	devid    2 size 1.00GiB used 212.75MiB path /dev/vdc
	devid    3 size 1.00GiB used 0.00B path /dev/vdd
~~~

* Vemos que se ha añadido correctamente, sin embargo el uso del mismo está a 0, para solucionarlo tenemos que balancear la carga entre los tres dispositivos.

~~~
vagrant@maquina1:~$ sudo btrfs balance start --full-balance /mnt/raid/
Done, had to relocate 3 out of 3 chunks
~~~

~~~
vagrant@maquina1:~$ sudo btrfs filesystem show 
Label: 'prueba'  uuid: 67a68e3c-2efd-4739-8e2f-5f7b8805dd43
	Total devices 3 FS bytes used 256.00KiB
	devid    1 size 1.00GiB used 320.00MiB path /dev/vdb
	devid    2 size 1.00GiB used 320.00MiB path /dev/vdc
	devid    3 size 1.00GiB used 320.00MiB path /dev/vdd
~~~

* Y por si queremos eliminar uno de los discos.

~~~
vagrant@maquina1:/mnt/raid$ sudo btrfs device remove /dev/vdb /mnt/raid/

vagrant@maquina1:/mnt$ sudo btrfs filesystem show 
Label: 'prueba'  uuid: 67a68e3c-2efd-4739-8e2f-5f7b8805dd43
	Total devices 2 FS bytes used 256.00KiB
	devid    2 size 1.00GiB used 448.00MiB path /dev/vdc
	devid    3 size 1.00GiB used 448.00MiB path /dev/vdd
~~~

* Para que el montaje sea persistente lo añadimos al fstab, teniendo en cuenta que el UUID que pondremos será el del raid, aunque también podriamos montar uno de los discos y se montaría el raid entero como hicimos anteriormente.

~~~
UUID=67a68e3c-2efd-4739-8e2f-5f7b8805dd43       /mnt/raid       auto    defaults        0       0
~~~

* Para ver el errores en el raid podemos iniciar el comprobador de errores.

~~~
vagrant@maquina1:/mnt$ sudo btrfs scrub status raid/
scrub started on raid/, fsid 67a68e3c-2efd-4739-8e2f-5f7b8805dd43 (pid=1271)
~~~

* Y seguidamente veremos su estado. .

~~~
vagrant@maquina1:/mnt$ sudo btrfs scrub status raid/
UUID:             67a68e3c-2efd-4739-8e2f-5f7b8805dd43
Scrub started:    Wed Jan  5 09:44:34 2022
Status:           finished
Duration:         0:00:00
Total to scrub:   256.00KiB
Rate:             0.00B/s
Error summary:    no errors found
~~~

* Si un disco fallara la sistitución es muy sencilla, vamos a hacerla con uno de los discos.

~~~
vagrant@maquina1:~$ sudo btrfs replace start /dev/vdc /dev/vde /mnt/raid/
~~~

* Comprobamos que el disco vdc se ha cambiado por el vde.

~~~
vagrant@maquina1:~$ sudo btrfs filesystem show
Label: 'prueba'  uuid: 67a68e3c-2efd-4739-8e2f-5f7b8805dd43
	Total devices 3 FS bytes used 256.00KiB
	devid    1 size 1.00GiB used 219.69MiB path /dev/vdb
	devid    2 size 1.00GiB used 219.69MiB path /dev/vde
	devid    3 size 1.00GiB used 219.69MiB path /dev/vdd
~~~

* Y si quisieramos reparar una unidad dañada podemos usar el siguiente comando:

~~~
vagrant@maquina1:~$ sudo mount -o recovery /dev/vdb /mnt/raid/
~~~

### Ventajas e inconvientes de btrfs sobre mdadm

* Las mayor ventaja que tiene btrfs frente a un raid convencional con mdadm es que debido a la suma de verificación que realiza este sistema de ficheros le permite identificar las copias de un bloque que son incorrectas y esto lo hace un sistema muuchisimo más seguro.

* Otra ventaja que tenemos es que el espejo es por archivo, por lo que podríamos tener archivos sin duplicar si quisieramos dentro del raid. 

* La desventaja por supuesto es la velocidad, mayor seguridad requieren más cálculos, por ello un sistema btrfs va a ser siempre más lento, así que deberíamos priorizar que queremos en nuestro sistema.

### Pruebas de funcionalidades

* Existen dos formas de compresion al vuelo en btrfs, ZLIB y LZO. Estás nos permiten tener los archivos comprimidos, pero a la hora de leerlos se descomprimen automáticamente y seguidamente volverán a comprimirse automáticamente. la diferencia entre las dos es la capacidad de compresión, ZLIB comprime más, pero por ellos consume más recursos. vamos a hacer una prueba de funcionamiento con el disco que tenemos libre, el cual tendrá que estar formateado con btrfs, usando ZLIB.

~~~
vagrant@maquina1:/mnt$ sudo mount -o compress=zlib /dev/vdc1 pruebas/
~~~

* Tenemos un volumen de 1 GB montando

~~~
vagrant@maquina1:/mnt$ sudo btrfs filesystem show pruebas/
Label: none  uuid: f57b08cf-9272-4466-9c9e-b06235ad4c49
	Total devices 1 FS bytes used 128.00KiB
	devid    1 size 1022.98MiB used 126.25MiB path /dev/vdc1
~~~

* Vamos a comprobar como este dispositivo puede almacenar mas información de la que permite ya que esta se comprime. vamos a usar el comando dd para introducir información. 

~~~
root@maquina1:/mnt/pruebas# dd if=/dev/zero of=/mnt/pruebas/fichero
54011523+0 records in
54011523+0 records out
27653899776 bytes (28 GB, 26 GiB) copied, 449.968 s, 61.5 MB/s
~~~

* Como podemos comprobar, aunque nuestro disco es de 1 GB ha podido almacenar un fichero de 26GB.

~~~
root@maquina1:/mnt/pruebas# ls -la
total 27005784
drwxr-xr-x 1 root root          14 Jan  5 11:51 .
drwxr-xr-x 4 root root        4096 Jan  5 11:44 ..
-rw-r--r-- 1 root root 27653899776 Jan  5 11:58 fichero

root@maquina1:/mnt/pruebas# du -h
26G	.
~~~

* Vemos que esos 26GB están ocupando casi todo el dispositivo.

~~~
root@maquina1:/mnt/pruebas# btrfs filesystem show /mnt/pruebas/
Label: none  uuid: f57b08cf-9272-4466-9c9e-b06235ad4c49
	Total devices 1 FS bytes used 874.29MiB
	devid    1 size 1022.98MiB used 1021.94MiB path /dev/vdc1
~~~

* Hay otra funcionalidad llamada copy on write, una técnica que hace que al hacer copias de ficheros y no tener cambios aparentes de ningún tipo. En realidad se mostraría el fichero original, aunque tengamos una copia, esta no ocupa espacio y apenas tarda tiempo en hacerse, vamos a hacer una prueba, si copiamos un fichero que creemos de unos 2GB este debería aumentar el espacio usado y la copia no sería practicamente instantanea. Esto no sucede con COW.

~~~
root@maquina1:/mnt/pruebas# time cp --reflink=always copia1 copia/copia2

real	0m0.329s
user	0m0.002s
sys	0m0.083s

root@maquina1:/mnt/pruebas# df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/vdc1      1023M  102M  820M  11% /mnt/pruebas
~~~

* Pasemos a la deduplicación, esto permite al sistema eliminar bloques de datos duplicados o redundantes, para usarlo primero debemos instalar la herramienta necesaria,

~~~
root@maquina1:/mnt/pruebas# apt install duperemove
~~~

* He creado otro fichero que he duplicado, veamos el espacio en disco.

~~~
root@maquina1:/mnt/pruebas# btrfs filesystem show /mnt/pruebas/
Label: none  uuid: f57b08cf-9272-4466-9c9e-b06235ad4c49
	Total devices 1 FS bytes used 129.23MiB
	devid    1 size 1022.98MiB used 354.25MiB path /dev/vdc1
~~~

* Pasemos ahora el duperemove.

~~~
root@maquina1:/mnt/pruebas# duperemove -dr .
~~~

* Notamos que los ficheros siguen ahí pero el espacio disponible ha subido.

~~~
root@maquina1:/mnt/pruebas# df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/vdc1      1023M   33M  892M   4% /mnt/pruebas
~~~

* Una vez visto esta característica podemos pasar al cifrado. para ello instalamos el siguiente paquete:

~~~
root@maquina1:/mnt/pruebas# apt install cryptsetup
~~~

* Ahora crearemos un fichero con clave de encriptación para el disco.

~~~
root@maquina1:/mnt/pruebas# dd if=/dev/random of=/root/KeyFile bs=1 count=4096
4096+0 records in
4096+0 records out
4096 bytes (4.1 kB, 4.0 KiB) copied, 0.0165403 s, 248 kB/s
~~~

* Hemos desmontado el disco que estabamos usando antes, para encryptarlo usamos el siguiente comando:

~~~
root@maquina1:/mnt# cryptsetup luksFormat --key-file /root/KeyFile /dev/vdc1 
WARNING: Device /dev/vdc1 already contains a 'btrfs' superblock signature.

WARNING!
========
This will overwrite data on /dev/vdc1 irrevocably.

Are you sure? (Type 'yes' in capital letters): YES
~~~

* Y ya tendríamos nuestro disco enciptado.
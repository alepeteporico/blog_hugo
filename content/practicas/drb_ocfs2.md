+++
title = "DRBD y OCFS2"
description = ""
tags = [
    "HLC"
]
date = "2022-05-29"
menu = "main"
+++

### Configura un escenario con dos máquinas. Cada una tiene que tener dos discos adicionales (tamaño 1Gb para que la sincronización sea rápida).

------------------------------------------------------

## Configura en modo Single-primary el recurso wwwdata.

* Primero debemos instalar el paquete necesario para usar `DRBD` en las dos máquinas.

~~~
vagrant@maquina1:~$ sudo apt install drbd-utils
~~~

* Ahora para crear este recurso lo hacemos creando un fichero en `/etc/drbd.d/` al que llamaremos `wwwdata.res`

~~~
resource wwwdata { 
  protocol C;
  meta-disk internal;
  device /dev/drbd1;
  syncer {
    verify-alg sha1;
  }
  net {
    allow-two-primaries;
  }
  on maquina1 {
    disk /dev/vdb;
    address 192.168.121.29:7789;
  }
  on maquina2 {
    disk /dev/vdb;
    address 192.168.121.17:7789;
  }
}
~~~

* Una vez creado este fichero en las dos máquinas, creamos el recurso.

~~~
vagrant@maquina1:~$ sudo drbdadm create-md wwwdata 
initializing activity log
initializing bitmap (32 KB) to all zero
Writing meta data...
New drbd meta data block successfully created.

vagrant@maquina2:~$ sudo drbdadm create-md wwwdata
initializing activity log
initializing bitmap (32 KB) to all zero
Writing meta data...
New drbd meta data block successfully created.
~~~

* No podemos olvidarnos de levantarlo.

~~~
vagrant@maquina1:~$ sudo drbdadm up wwwdata
~~~

* Debemos elegir a una de las dos maquinas como primaria, vamos a elegir la maquina1.

~~~
vagrant@maquina1:~$ sudo drbdadm primary --force wwwdata
~~~

* Se nos indica que le demos formato xfs a este dispositivo, así que vamos a ello, primero debemos instalar el siguiente paquete.

~~~
vagrant@maquina1:~$ sudo apt install xfsprogs
~~~

* Le damos formato al disco y lo montamos.

~~~
vagrant@maquina1:~$ sudo mkfs.xfs /dev/drbd1
meta-data=/dev/drbd1             isize=512    agcount=4, agsize=65532 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=1, sparse=1, rmapbt=0
         =                       reflink=1    bigtime=0
data     =                       bsize=4096   blocks=262127, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0, ftype=1
log      =internal log           bsize=4096   blocks=1566, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
Discarding blocks...Done.

vagrant@maquina1:~$ sudo mount /dev/drbd1 /mnt/drbd/
~~~

* Hemos creado un fichero dentro.

~~~
vagrant@maquina1:~$ cat /mnt/drbd/prueba.txt
prueba de funcionamiento
~~~

* Al intentar montar o darle formato en la maquina2 vemos que nos aparece un mensaje de error, esto es debido a que es la maquina1 la principal, por tanto la maquina2 no tiene permisos para realizar estas operaciones.

~~~
vagrant@maquina2:~$ sudo mkfs.xfs /dev/drbd1
mkfs.xfs: cannot open /dev/drbd1: Read-only file system
vagrant@maquina2:~$ sudo mount /dev/drbd1 /mnt
mount: /mnt: mount(2) system call failed: Wrong medium type.
~~~

* Por tanto en la maquina1 debemos desmontar el dispositivo y poner este servidor como secundario.

~~~
vagrant@maquina1:~$ sudo umount /mnt/drbd 
vagrant@maquina1:~$ sudo drbdadm secondary wwwdata
~~~

* Y hacer a la maquina2 servidor primario tal como hicimos con la 1 anteriormente.

~~~
vagrant@maquina2:~$ sudo drbdadm primary --force wwwdata
~~~

* Y podemos comprobar que si montamos el dispositivo en la maquina2 se sincronizará y aparecerá el fichero que creamos anteriormente.

~~~
vagrant@maquina2:~$ sudo mount /dev/drbd1 /mnt/drbd/

vagrant@maquina2:~$ cat /mnt/drbd/prueba.txt 
prueba de funcionamiento
~~~

## Configura en modo Dual-primary el recurso dbdata.

* Crearemos nuevamente este recurso en la misma localización del anterior, este se llamará `dbdata.res`

~~~
resource dbdata { 
  protocol C;
  meta-disk internal;
  device /dev/drbd2;
  syncer {
    verify-alg sha1;
  }
  net {
    allow-two-primaries;
  }
  on maquina1 {
    disk /dev/vdc;
    address 192.168.121.29:7790;
  }
  on maquina2 {
    disk /dev/vdc;
    address 192.168.121.17:7790;
  }
}
~~~

* Creamos y activamos el recurso en las dos máquinas.

~~~
vagrant@maquina2:~$ sudo drbdadm create-md dbdata
initializing activity log
initializing bitmap (32 KB) to all zero
Writing meta data...
New drbd meta data block successfully created.
vagrant@maquina2:~$ sudo drbdadm up dbdata
~~~

* Y tal como hicimos antes asignamos un servidor primario.

~~~
vagrant@maquina1:~$ sudo drbdadm primary --force dbdata
~~~

* Una vez hecho esto vamos a crear un cluster `OCFS2` y para ello necesitamos dos paquetes que instalaremos en las dos maquinas.

~~~
vagrant@maquina2:~$ sudo apt install ocfs2-tools
~~~

* Ahora debemos definir el cluster debemos darle un nombre y añadir las maquinas que formarán parte de el.

~~~
vagrant@maquina1:~$ sudo o2cb add-cluster pruebaclust
vagrant@maquina1:~$ sudo o2cb add-node pruebaclust maquina1 --ip 192.168.121.29
vagrant@maquina1:~$ sudo o2cb add-node pruebaclust maquina2 --ip 192.168.121.17
~~~

* Configuramos el fichero `/etc/default/o2cb` que debe quedar de la siguiente forma:

~~~
# O2CB_ENABLED: 'true' means to load the driver on boot.
O2CB_ENABLED=true 

# O2CB_BOOTCLUSTER: If not empty, the name of a cluster to start.
O2CB_BOOTCLUSTER=pruebaclust

# O2CB_HEARTBEAT_THRESHOLD: Iterations before a node is considered dead.
O2CB_HEARTBEAT_THRESHOLD=21

# O2CB_IDLE_TIMEOUT_MS: Time in ms before a network connection is considered dead.
O2CB_IDLE_TIMEOUT_MS=30000

# O2CB_KEEPALIVE_DELAY_MS: Max. time in ms before a keepalive packet is sent.
O2CB_KEEPALIVE_DELAY_MS=2000

# O2CB_RECONNECT_DELAY_MS: Min. time in ms between connection attempts.
O2CB_RECONNECT_DELAY_MS=2000
~~~

* El siguiente paso será registrar el cluster en ambas máquinas.

~~~
vagrant@maquina2:~$ sudo o2cb register-cluster pruebaclust
~~~

* Y configurar un par de parametros del kernel en las dos máquinas añadiendo al fichero `/etc/sysctl.conf` las siguientes líneas.

~~~
kernel.panic = 30
kernel.panic_on_oops = 1
~~~

* Y guardamos estos cambios.

~~~
vagrant@maquina1:~$ sudo sysctl -p
~~~

* Ahora si podemos darle formato y montarlo en ambas máquinas.

~~~
vagrant@maquina1:~$ sudo mkfs.ocfs2 --cluster-size 8K -J size=32M -T mail --node-slots 2 --label ocfs2_fs --mount cluster --fs-feature-level=max-features --cluster-stack=o2cb --cluster-name=pruebaclust /dev/drbd2

vagrant@maquina1:~$ sudo mount /dev/drbd2 /mnt/ocfs2/
~~~
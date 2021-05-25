+++
title = "iSCSI"
description = ""
tags = [
    "ASO"
]
date = "2021-05-25"
menu = "main"
+++

#### Configura un escenario con vagrant o similar que incluya varias máquinas que permita realizar la configuración de un servidor iSCSI y dos clientes (uno linux y otro windows). Explica de forma detallada en la tarea los pasos realizados.

* Crea un target con una LUN y conéctala a un cliente GNU/Linux. Explica cómo escaneas desde el cliente buscando los targets disponibles y utiliza la unidad lógica proporcionada, formateándola si es necesario y montándola.

* Utiliza systemd mount para que el target se monte automáticamente al arrancar el cliente

* Crea un target con 2 LUN y autenticación por CHAP y conéctala a un cliente windows. Explica cómo se escanea la red en windows y cómo se utilizan las unidades nuevas (formateándolas con NTFS)

---------------------------------------------

* Tendremos tres máquinas, una debian que actuará como servidor con 3 discos adicionales de 1 GB cada uno, y dos clientes conectados, uno será debian y otro windows.

* Ahora en el servidor instalaremos el paqute tgt.

        vagrant@maquina1:~$ sudo apt install tgt

* Ahora realizaremos nuestra configuración, si lo hicieramos desde línea de comandos al cerrar la sesión se eliminaria nuestra configuración, por ello vamos a configurarlo mediante los ficheros de configuración empezaremos con `/etc/tgt/conf.d/target1.conf` para definir dos targets, uno para el cliente windows y otro para el cliente debian, notaremos que el target 2 tiene una línea que no está en el primero, esto es porque lo usaremos para windows y necesitaremos un usuario y una contraseña para el mismo.

        <target iqn.2021-05.es.alegv:target1>
                backing-store /dev/sdb
        </target>
        <target iqn.2021-05.es.alegv:target2>
                backing-store /dev/sdc
                incominguser admin admin
        </target>

* Después de reiniciar el servicio vamos a ver las targets que acabamos de configurar.

        vagrant@maquina1:~$ sudo systemctl restart tgt

        vagrant@maquina1:~$ sudo tgtadm --op show --mode target
        Target 1: iqn.2021-05.es.alegv:target1
            System information:
                Driver: iscsi
                State: ready
            I_T nexus information:
            LUN information:
                LUN: 0
                    Type: controller
                    SCSI ID: IET     00010000
                    SCSI SN: beaf10
                    Size: 0 MB, Block size: 1
                    Online: Yes
                    Removable media: No
                    Prevent removal: No
                    Readonly: No
                    SWP: No
                    Thin-provisioning: No
                    Backing store type: null
                    Backing store path: None
                    Backing store flags: 
                LUN: 1
                    Type: disk
                    SCSI ID: IET     00010001
                    SCSI SN: beaf11
                    Size: 1074 MB, Block size: 512
                    Online: Yes
                    Removable media: No
                    Prevent removal: No
                    Readonly: No
                    SWP: No
                    Thin-provisioning: No
                    Backing store type: rdwr
                    Backing store path: /dev/sdb
                    Backing store flags: 
            Account information:
            ACL information:
                ALL
        Target 2: iqn.2021-05.es.alegv:target2
            System information:
                Driver: iscsi
                State: ready
            I_T nexus information:
            LUN information:
                LUN: 0
                    Type: controller
                    SCSI ID: IET     00020000
                    SCSI SN: beaf20
                    Size: 0 MB, Block size: 1
                    Online: Yes
                    Removable media: No
                    Prevent removal: No
                    Readonly: No
                    SWP: No
                    Thin-provisioning: No
                    Backing store type: null
                    Backing store path: None
                    Backing store flags: 
                LUN: 1
                    Type: disk
                    SCSI ID: IET     00020001
                    SCSI SN: beaf21
                    Size: 1074 MB, Block size: 512
                    Online: Yes
                    Removable media: No
                    Prevent removal: No
                    Readonly: No
                    SWP: No
                    Thin-provisioning: No
                    Backing store type: rdwr
                    Backing store path: /dev/sdc
                    Backing store flags: 
            Account information:
            ACL information:
                ALL

* Vamos a dirigirnos al cliente linux ahora e instalar el paquete `open-iscsi`.

        vagrant@maquina2:~$ sudo apt-get install open-iscsi

* Podemos comprobar que esta máquina solo tiene un disco duro.

        NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
        sda      8:0    0  20G  0 disk 
        └─sda1   8:1    0  20G  0 part /

* Vamos a ver las targets que tenemos disponibles.

        root@maquina2:~# iscsiadm --mode discovery --type sendtargets --portal 172.22.100.15
        172.22.100.15:3260,1 iqn.2021-05.es.alegv:target1
        172.22.100.15:3260,1 iqn.2021-05.es.alegv:target2

* Vamos a conectarnos a la que queramos.

        root@maquina2:~# sudo iscsiadm --mode node -T iqn.2021-05.es.alegv:target1 --portal 172.22.100.15 --login
        Logging in to [iface: default, target: iqn.2021-05.es.     alegv:target1, portal: 172.22.100.15,3260] (multiple)
        Login to [iface: default, target: iqn.2021-05.es.alegv:target1, portal: 172.22.100.15,3260] successful.

* Si ahora listamos nuestros dispositivos veremos que se ha añadido un nuevo volumen.

        root@maquina2:~# lsblk
        NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
        sda      8:0    0  20G  0 disk 
        └─sda1   8:1    0  20G  0 part /
        sdb      8:16   0   1G  0 disk 

* Vamos a darle formato y montarlo.

        root@maquina2:~# mkfs.ext4 /dev/sdb
        root@maquina2:~# mount /dev/sdb /mnt/prueba

        root@maquina2:~# lsblk
        NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
        sda      8:0    0  20G  0 disk 
        └─sda1   8:1    0  20G  0 part /
        sdb      8:16   0   1G  0 disk /mnt/prueba

### systemd mount

* Ahora mismo está montado pero no permanentemente, modificamos el fichero `/etc/iscsi/iscsid.conf` y cambiamos la línea que veremos a continuación de manual a automatic.

        node.startup = automatic

* Vamos a crear en `/etc/systemd/system/` un fichero al que llamaremos `prueba1.mount` y servirá para crear la unidad.

        [Unit]
        Description= Montaje del target1         

        [Mount]
        What=/dev/sdb
        Where=/prueba1  
        Type=ext4
        Options=_netdev

        [Install]
        WantedBy=multi-user.target

* Ahora reiniciamos el servicio.

        root@maquina2:~# sudo systemctl daemon-reload

* Montaremos nuestro disco y crearemos un enlace simbólico.

        root@maquina2:~# systemctl start prueba1.mount
        root@maquina2:~# systemctl enable prueba1.mount
        Created symlink /etc/systemd/system/multi-user.target.wants/prueba1.mount → /etc/systemd/system/prueba1.mount.

* Vamos a ver que se ha realizado el cambio, podremos comprobarlo porque hemos cambiado el punto de montaje, ahora está en `/prueba1`.

        root@maquina2:~# lsblk
        NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
        sda      8:0    0  20G  0 disk 
        └─sda1   8:1    0  20G  0 part /
        sdb      8:16   0   1G  0 disk /prueba1

* Ahora si podremos abrir nuestro cliente windows y nos dirigiremos a `panel de control > sistema y seguridad > herramientas administrativas > iniciador iSCSI` una vez ahí, en `conexión rápida` añadiremos la IP de nuestro servidor y aparcerán las targets que tenemos configuradas.

![targets](/iscsi/1.png)

* Elegiriamos la 2 que configuramos al principio con usuario y contraseña concienciudamente y clicaremos en opciones avanzadas dentro de las pestaña que aparece habilitando el `inicio de sesion CHAP` y escribiendo nuestro usuario y contraseña configurados anteriormente.

![targets](/iscsi/2.png)

![targets](/iscsi/3.png)

* Después de esto podemos comprobar que este target está activo.

![targets](/iscsi/4.png)

* Para montar este disco iriamos a la aplicacion de particiones.

![targets](/iscsi/5.png)

* Y dentro nos aparecerá una ventana avisando de que se ha encontrado un nuevo disco.

![targets](/iscsi/6.png)

* Le daremos el formato estandar de windows NTFS y comprobaremos que se encuentra en nuestro sistema

![targets](/iscsi/7.png)

![targets](/iscsi/8.png)
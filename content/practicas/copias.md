+++
title = "Copias de seguridad con bacula"
description = ""
tags = [
    "ASO"
]
date = "2021-05-22"
menu = "main"
+++

* Usaremos la herramienta bacula para realizar nuestro sistema de copias de seguridad, por supuesto el primer paso que debemos tomar es instalar el paquete de bacula, lo haremos en Dulcinea, usaremos esta máquina para alojar las copias de seguridad.

        debian@dulcinea:~$ sudo apt-get install bacula-server bacula-client

* Cambiamos los permisos de unos de los scripts que usa bacula

        debian@dulcinea:~$ sudo chmod 755 /etc/bacula/scripts/delete_catalog_backup

* En nuestro Openstack vamos a crear un volumen que asociaremos a Dulcinea y donde almacenaremos nuestras copias de seguridad.

![volumen](/backups/1.png)

* Vamos a añadir este nuevo volumen a la tabla de particiones y montarlo en una ubicación que veamos oportuna, debería ser una ubicación segura

        debian@dulcinea:~$ sudo fdisk /dev/vdb

        Welcome to fdisk (util-linux 2.33.1).
        Changes will remain in memory only, until you decide to write them.
        Be careful before using the write command.

        Device does not contain a recognized partition table.
        Created a new DOS disklabel with disk identifier 0x3a574d62.

        Command (m for help): n
        Partition type
           p   primary (0 primary, 0 extended, 4 free)
           e   extended (container for logical partitions)
        Select (default p): p
        Partition number (1-4, default 1): 
        First sector (2048-31457279, default 2048): 
        Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-31457279, default 31457279): 

        Created a new partition 1 of type 'Linux' and of size 15 GiB.

        Command (m for help): w
        The partition table has been altered.
        Calling ioctl() to re-read partition table.
        Syncing disks.


        debian@dulcinea:/mnt$ sudo mkfs.ext4 /dev/vdb1
        mke2fs 1.44.5 (15-Dec-2018)
        Creating filesystem with 3931904 4k blocks and 983040 inodes
        Filesystem UUID: d566f092-68af-4196-90c6-259845be7c4a
        Superblock backups stored on blocks: 
        	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208

        Allocating group tables: done                            
        Writing inode tables: done                            
        Creating journal (16384 blocks): done
        Writing superblocks and filesystem accounting information: done


        debian@dulcinea:/mnt$ sudo mount /dev/vdb1 backups/

* Podemos comprobar que lo hemos montando en la ubicación específica.

        debian@dulcinea:/mnt$ sudo lsblk
        NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
        vda    254:0    0  10G  0 disk 
        └─vda1 254:1    0  10G  0 part /
        vdb    254:16   0  15G  0 disk 
        └─vdb1 254:17   0  15G  0 part /mnt/backups

* Por supuesto lo añadimos a nuestro fstab por si tenemos que reiniciar el sistema se monte sola esta partición.

        debian@dulcinea:/mnt$ cat /etc/fstab 
        # /etc/fstab: static file system information.
        UUID=9659e5d4-dd87-42af-bf70-0bb6f7b2e31b	/	ext4	errors=remount-ro	0	1
        UUID=d566f092-68af-4196-90c6-259845be7c4a	/mnt/backups	ext4	errors=remount-ro	0	2

* Vamos a crear una serie de directorios dentro de este volumen que usaremos para guardar y organizar nuestras copias de seguirdad.

        debian@dulcinea:/mnt/backups$ tree
        .
        ├── completa
        │   ├── dulcinea
        │   ├── freston
        │   ├── quijote
        │   └── sancho
        ├── diferencial
        │   ├── dulcinea
        │   ├── freston
        │   ├── quijote
        │   └── sancho


* Comencemos con el proceso de copias de seguridad, este deberá realizarse de forma completamente automática, para este fin usaremos el fichero que usamos antes configuraremos una serie de scripts que usen `tar` y realizaremos una copia completa semanalmente, en concreto los viernes y un diferencial diariamente. La hora en que se realizarán las copias serán las 1am, quizás en una empresa es lo mas normal que a esa hora no hay nadie trabajando y el trabajo del día ya se ha realizado y puede realizarse la copia sin que falte nada de ese día.

* 
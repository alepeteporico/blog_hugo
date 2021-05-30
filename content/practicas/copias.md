+++
title = "Copias de seguridad con bacula"
description = ""
tags = [
    "ASO"
]
date = "2021-05-22"
menu = "main"
+++

* Usaremos la herramienta bacula para realizar nuestro sistema de copias de seguridad, por supuesto el primer paso que debemos tomar es instalar el paquete de bacula, instalaremos el cliente en todas las máquinas de nuestro escenario de openstack, aunque usaremos Dulcinea para alojar las copias de seguridad.

        debian@dulcinea:~$ sudo apt-get install bacula-client

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

* Ahora vamos a dirigirnos a Sancho, donde configuraremos nuestro primer cliente usando el fichero `/etc/bacula/bacula-fd.conf`, aunque todos tendrán la misma configuración.

        Director {
          Name = sancho-dir
          Password = "admin"
        }

        #
        # Restricted Director, used by tray-monitor to get the
        #   status of the file daemon
        #
        Director {
          Name = sancho-mon
          Password = "admin"
          Monitor = yes
        }

        #
        # "Global" File daemon configuration specifications
        #
        FileDaemon {                          # this is me
          Name = sancho-fd
          FDport = 9102                  # where we listen for the director
          WorkingDirectory = /var/lib/bacula
          Pid Directory = /run/bacula
          Maximum Concurrent Jobs = 20
          Plugin Directory = /usr/lib/bacula
          FDAddress = 10.0.1.6 #Direccion de este daemon
        }

        # Send all messages except skipped files back to Director
        Messages {
          Name = Standard
          director = sancho-dir = all, !skipped, !restored
        }

* Instalaremos en Dulcinea el servidor.

        debian@dulcinea:~$ sudo apt-get install bacula-sd

* Vamos a definir alguna información en el servidor.

        Storage {                             # definition of myself
          Name = dulcinea-sd
          SDPort = 9103                  # Director's port
          WorkingDirectory = "/var/lib/bacula"
          Pid Directory = "/run/bacula"
          Plugin Directory = "/usr/lib/bacula"
          Maximum Concurrent Jobs = 20
          SDAddress = 10.0.1.8
        }

        Director {
          Name = dulcinea-dir
          Password = "admin"
        }


        Director {
          Name = dulcinea-mon
          Password = "admin"
          Monitor = yes
        }


        Autochanger {
          Name = FileAutochanger1
          Device = Dispositivo
          Changer Command = ""
          Changer Device = /dev/null
        }

        #Definimos el disco de almacenamiento de las copias

        Device {
          Name = Dispositivo
          Media Type = File
          Archive Device = /mnt/backups
          LabelMedia = yes;                   # lets Bacula label unlabeled media
          Random Access = Yes;
          AutomaticMount = yes;               # when device opened, read it
          RemovableMedia = no;
          AlwaysOpen = no;
          Maximum Concurrent Jobs = 5
        }

        Messages {
          Name = Standard
          director = dulcinea-dir = all
        }

* Podemos comprobar que no hay ningún error de sintaxis mediante una herramienta que nos proporciona bacula. 

        debian@dulcinea:~$ sudo bacula-sd /etc/bacula/bacula-sd.conf

* Ahora tenemos que configurar el que es el demonio principal `bacula-dir` antes de instalarlo tenemos que configurar un servidor mariadb

        debian@dulcinea:~$ sudo apt-get install mariadb-server mariadb-client

        debian@dulcinea:~$ sudo apt-get install bacula bacula-common-mysql bacula-director-mysql bacula-server

* Una vez instalado lo necesario vamos a configurar el fichero `/etc/bacula/bacula-dir.conf`.

        Director {                            # define myself
          Name = dulcinea-dir
          DIRport = 9101                # where we listen for UA connections
          QueryFile = "/etc/bacula/scripts/query.sql"
          WorkingDirectory = "/var/lib/bacula"
          PidDirectory = "/run/bacula"
          Maximum Concurrent Jobs = 20
          Password = "5aGsxsTfzMQTaN8Vrk8PR2DSBRY29sDOQ"         # Console password
          Messages = Daemon
          DirAddress = 10.0.1.8
        }


Job {
 Name = "restauracion_dulcinea"
 Type = Restore
 Client=dulcinea-fd
 FileSet= "Copia_Dulcinea"
 Storage = Backup
 Pool = Res-Backup
 Messages = Standard
}

# Quijote

Job {
 Name = "restauracion_quijote"
 Type = Restore
 Client=quijote-fd
 FileSet= "Copia_Quijote"
 Storage = Backup
 Pool = Res-Backup
 Messages = Standard
}

# Freston

Job {
 Name = "restauracion_freston"
 Type = Restore
 Client=freston-fd
 FileSet= "Copia_Freston"
 Storage = VolBackup
 Pool = Vol-Backup
 Messages = Standard
}

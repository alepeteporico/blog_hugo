+++
title = "Copias de seguridad con bacula"
description = ""
tags = [
    "ASO"
]
date = "2022-01-21"
menu = "main"
+++

* Usaremos la herramienta bacula para realizar nuestro sistema de copias de seguridad, por supuesto el primer paso que debemos tomar es instalar el paquete de bacula, instalaremos el cliente en todas las máquinas de nuestro escenario, aunque usaremos zeus para alojar las copias de seguridad.

* Para alojar las copias hemos añadido dos discos que vamos a montar en RAID.

~~~
debian@zeus:~$ df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/md0        9.8G   24K  9.3G   1% /mnt/copias
~~~

* Vamos a crear una serie de directorios dentro de este volumen que usaremos para guardar y organizar nuestras copias de seguirdad.

~~~
ebian@zeus:/mnt/copias$ tree
.
|-- completa
|   |-- apolo
|   |-- ares
|   |-- hera
|   `-- zeus
|-- incremental
|   |-- apolo
|   |-- ares
|   |-- hera
|   `-- zeus
~~~

* Nuestro esquema para realizar las copias de seguridad será una copia completa a la semana y una incremental diaria.

* Ahora vamos a dirigirnos a apolo, donde configuraremos nuestro primer cliente usando el fichero `/etc/bacula/bacula-fd.conf`, aunque todos tendrán la misma configuración.

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


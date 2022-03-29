+++
title = "Copias de seguridad con bacula"
description = ""
tags = [
    "ASO"
]
date = "2022-03-14"
menu = "main"
+++

* Usaremos la herramienta bacula para realizar nuestro sistema de copias de seguridad, por supuesto el primer paso que debemos tomar es instalar el paquete de bacula, instalaremos el cliente en todas las máquinas de nuestro escenario, aunque usaremos zeus para alojar las copias de seguridad.

* Para alojar las copias hemos añadido dos discos que vamos a montar en RAID.

~~~
debian@zeus:~$ df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/md0        9.8G   24K  9.3G   1% /mnt/copias
~~~

* Nuestro esquema para realizar las copias de seguridad será una copia completa a la semana y una incremental diaria.

## Componentes de bacula


* Director: el server o componente central que ejecuta los jobs.

* Jobs: tareas, bien de realización de backups o bien de restauración de estos.

* Bacula-fd: file daemon, o cliente. Sistemas de los que vamos a hacer los backups.

* Bacula-sd: storage daemon, o fileserver. Lugar donde se almacenan los backups físicamente.

* Base de datos: aquí se almacenan los metadatos de todas las tareas realizadas.

## Instalación y configuración de bacula en zeus.

* Instalamos bacula.

~~~
debian@zeus:~$ sudo apt install bacula bacula-common-mysql bacula-director-mysql
~~~

* Vamos a configurar zeus como director de bacula, para ello nos dirigimos al fichero `/etc/bacula/bacula-dir.conf`

~~~
Director {                            # define myself
  Name = zeus-dir
  DIRport = 9101                # where we listen for UA connections
  QueryFile = "/etc/bacula/scripts/query.sql"
  WorkingDirectory = "/var/lib/bacula"
  PidDirectory = "/run/bacula"
  Maximum Concurrent Jobs = 20
  Password = "admin"         # Console password
  Messages = Daemon
  DirAddress = 127.0.0.1
}
~~~

* Más adelante nos encontraremos el recurso JobDefs, que es una plantilla de configuración para los trabajos que vayamos a crear mas tarde de parametros que podemos especificar aquí ya que serán comunes a todos. Definiremos dos, uno para las copias incrementales diarias y otro para las copias completas semanales.

~~~
JobDefs {
  Name = "CopiaDiaria"
  Type = Backup
  Level = Incremental
  Client = zeus-fd
  FileSet = "Full Set"
  Schedule = "Daily"
  Storage = volcopias
  Messages = Standard
  Pool = Daily
  SpoolAttributes = yes
  Priority = 10
  Write Bootstrap = "/var/lib/bacula/%c.bsr"
}

JobDefs {
  Name = "CopiaSemanal"
  Type = Backup
  Level = Full
  Client = zeus-fd
  FileSet = "Full Set"
  Schedule = "Weekly"
  Storage = volcopias
  Messages = Standard
  Pool = Weekly
  SpoolAttributes = yes
  Priority = 10
  Write Bootstrap = "/var/lib/bacula/%c.bsr"
}
~~~

* Ahora definiremos los jobs que usarán esta plantilla, dos para cada maquina.

~~~
# Zeus
Job {
  Name = "Zeus-Diario"
  Client = "zeus-fd"
  JobDefs = "CopiaDiaria"
  FileSet= "Zeus-Datos"
}

Job {
  Name = "Zeus-Semanal"
  Client = "zeus-fd"
  JobDefs = "CopiaSemanal"
  FileSet= "Zeus-Datos"
}

# Ares
Job {
  Name = "Ares-Diario"
  Client = "ares-fd"
  JobDefs = "CopiaDiaria"
  FileSet= "Ares-Datos"
}

Job {
  Name = "Ares-Semanal"
  Client = "ares-fd"
  JobDefs = "CopiaSemanal"
  FileSet= "Ares-Datos"
}

# Apolo
Job {
  Name = "Apolo-Diario"
  Client = "apolo-fd"
  JobDefs = "CopiaDiaria"
  FileSet= "Apolo-Datos"
}

Job {
  Name = "Apolo-Semanal"
  Client = "apolo-fd"
  JobDefs = "CopiaSemanal"
  FileSet= "Apolo-Datos"
}

# Hera
Job {
  Name = "Hera-Diario"
  Client = "hera-fd"
  JobDefs = "CopiaDiaria"
  FileSet= "Hera-Datos"
}

Job {
  Name = "Hera-Semanal"
  Client = "hera-fd"
  JobDefs = "CopiaSemanal"
  FileSet= "Hera-Datos"
}
~~~

* Los jobs que hemos creado son para crear las copias de seguridad, pero necesitamos tambien los de restauración.

~~~
# Zeus
Job {
  Name = "ZeusRestore"
  Type = Restore
  Client=zeus-fd
  Storage = volcopias
  FileSet="Zeus-Datos"
  Pool = Backup-Restore
  Messages = Standard
}

# Ares
Job {
  Name = "AresRestore"
  Type = Restore
  Client=ares-fd
  Storage = volcopias
  FileSet="Ares-Datos"
  Pool = Backup-Restore
  Messages = Standard
}

# Apolo
Job {
  Name = "ApoloRestore"
  Type = Restore
  Client=apolo-fd
  Storage = volcopias
  FileSet="Apolo-Datos"
  Pool = Backup-Restore
  Messages = Standard
}

# Hera
Job {
  Name = "HeraRestore"
  Type = Restore
  Client=hera-fd
  Storage = volcopias
  FileSet="Hera-Datos"
  Pool = Backup-Restore
  Messages = Standard
}
~~~

* Ahora en el apartado FileSet definiremos los directorios que queremos que sean copiados y cuales excluidos. También añadiremos, si queremos, la compresion y de que tipo será.

~~~
FileSet {
 Name = "Full Set"
 Include {
   Options {
     signature = MD5
     compression = GZIP
   }
   File = /home
   File = /etc
   File = /var
   File = /usr/share
 }
 Exclude {
    File = /var/lib/bacula
    File = /nonexistant/path/to/file/archive/dir
    File = /proc
    File = /etc/fstab
    File = /var/run/systemd/generator
    File = /tmp
    File = /sys
    File = /.journal
    File = /.fsck
  }
}

# Zeus
FileSet {
 Name = "Zeus-Datos"
 Include {
   Options {
     signature = MD5
     compression = GZIP
   }
   File = /home
   File = /etc
   File = /var
   File = /usr/share 
}
 Exclude {
   File = /var/lib/bacula
   File = /nonexistant/path/to/file/archive/dir
   File = /proc
   File = /etc/fstab
   File = /var/run/systemd/generator
   File = /var/cache
   File = /var/tmp
   File = /tmp
   File = /sys
   File = /.journal
   File = /.fsck
 }
}

# Ares
FileSet {
 Name = "Ares-Datos"
 Include {
   Options {
     signature = MD5
     compression = GZIP
   }
   File = /home
   File = /etc
   File = /var
   File = /opt
   File = /usr/share
 }
 Exclude {
   File = /nonexistant/path/to/file/archive/dir
   File = /proc
   File = /var/cache
   File = /var/tmp
   File = /etc/fstab
   File = /var/run/systemd/generator
   File = /tmp
   File = /sys
   File = /.journal
   File = /.fsck
 }
}

# Apolo
FileSet {
 Name = "Apolo-Datos"
 Include {
   Options {
     signature = MD5
     compression = GZIP
   }
   File = /home
   File = /etc
   File = /var
   File = /opt
   File = /usr/share
 }
 Exclude {
   File = /var/lib/bacula
   File = /nonexistant/path/to/file/archive/dir
   File = /proc
   File = /etc/fstab
   File = /var/run/systemd/generator
   File = /var/tmp
   File = /tmp
   File = /sys
   File = /.journal
   File = /.fsck
 }
}

# Hera
FileSet {
 Name = "Hera-Datos"
 Include {
   Options {
     signature = MD5
     compression = GZIP
   }
   File = /home
   File = /etc
   File = /var
   File = /usr/share
 }
 Exclude {
   File = /var/lib/bacula
   File = /nonexistant/path/to/file/archive/dir
   File = /proc
   File = /etc/fstab
   File = /var/run/systemd/generator
   File = /var/tmp
   File = /tmp
   File = /sys
   File = /.journal
   File = /.fsck
 }
}
~~~

* Ahora pasamos al apartado Schedule, el cual definirá el periodo de tiempo en que se realizará cada copia.

~~~
Schedule {
 Name = "Daily"
 Run = Level=Incremental Pool=Daily daily at 10:00
}

Schedule {
 Name = "Weekly"
 Run = Level=Full Pool=Weekly mon at 10:30
}
~~~

* Debemos definir los clientes

~~~
# Zeus
Client {
 Name = zeus-fd
 Address = 10.0.1.1
 FDPort = 9102
 Catalog = MyCatalog
 Password = "admin"
 File Retention = 60 days
 Job Retention = 6 months
 AutoPrune = yes
}

# Ares
Client {
 Name = ares-fd
 Address = 10.0.1.101
 FDPort = 9102
 Catalog = MyCatalog
 Password = "admin"
 File Retention = 60 days
 Job Retention = 6 months
 AutoPrune = yes
}

# Apolo
Client {
 Name = apolo-fd
 Address = 10.0.1.102
 FDPort = 9102
 Catalog = MyCatalog
 Password = "admin"
 File Retention = 60 days
 Job Retention = 6 months
 AutoPrune = yes
}

# Hera
Client {
 Name = hera-fd
 Address = 172.16.0.200
 FDPort = 9102
 Catalog = MyCatalog
 Password = "admin"
 File Retention = 60 days
 Job Retention = 6 months
 AutoPrune = yes
}
~~~

* Pasamos con el almacenamiento, primero debemos definir que tipo de almacenamiento queremos.

~~~
Storage {
  Name = volcopias
  Address = 10.0.1.1 
  SDPort = 9103
  Password = "admin"
  Device = FileChgr1  
  Media Type = File
  Maximum Concurrent Jobs = 10
}
~~~

* Saltamos a catalog, donde pondremos las crendenciales de la base de datos.

~~~
Catalog {
  Name = MyCatalog
  dbname = "bacula"; DB Address = "localhost"; dbuser = "bacula"; dbpassword = "admin"
}
~~~

* Y el último apartado que configuraremos serán los pool.

~~~
Pool {
  Name = Daily
  Pool Type = Backup
  Recycle = yes
  AutoPrune = yes
  Volume Retention = 8d
}

Pool {
  Name = Weekly
  Pool Type = Backup
  Recycle = yes
  AutoPrune = yes
  Volume Retention = 32d
}

Pool {
  Name = Backup-Restore
  Pool Type = Backup
  Recycle = yes
  AutoPrune = yes
  Volume Retention = 366 days
  Maximum Volume Bytes = 50G
  Maximum Volumes = 100
  Label Format = "Remoto"
}
~~~

**IMPORTANTE: PUEDES ELIMANAR TODO LO RESTANTE DEL FICHERO QUE VIENE PREDEFINIDO EXCEPTO LOS APARTADOS DE MESSAGE, ESTOS PUEDEN CONFIGURARSE PARA ENVIAR MENSAJES, EN NUESTRO CASO LO DEJAREMOS POR DEFECTO.**

* Una vez terminada la configuración de este fichero vamos a dirigirnos a `/etc/bacula/bacula-sd.conf` donde configuraremos mas detalladamente donde se almacenarán las copias.

~~~
Storage {
  Name = zeus-sd
  SDPort = 9103
  WorkingDirectory = "/var/lib/bacula"
  Pid Directory = "/run/bacula"
  Plugin Directory = "/usr/lib/bacula"
  Maximum Concurrent Jobs = 20
  SDAddress = 10.0.1.1
}
~~~

* Pasemos al apartado Director, definiremos dos, uno para definir los directores autorizados a ejecutar el demonio del almacenamiento y otro que indicará cual puede monitorizarlo.

~~~
Director {
  Name = zeus-dir
  Password = "bacula"
}

Director {
  Name = zeus-mon
  Password = "bacula"
  Monitor = yes
}
~~~

* A continuacion tenemos el autochanger, que hace referencia a uno de los apartados anteriores del director.

~~~
Autochanger {
  Name = FileChgr1
  Device = FileStorage
  Changer Command = ""
  Changer Device = /dev/null
}
~~~

* Y device, que también hace referencia y es donde definiremos donde se encuentra el volumen en el que realizaremos las copias.

~~~
Device {
  Name = FileStorage
  Media Type = File
  Archive Device = /mnt/copias/  
  LabelMedia = yes;
  Random Access = Yes;
  AutomaticMount = yes;
  RemovableMedia = no;
  AlwaysOpen = no;
  Maximum Concurrent Jobs = 5
}
~~~

* Una vez terminado, debemos reiniciar el servicio y habilitarlo.

~~~
debian@zeus:~$ sudo systemctl restart bacula-sd.service
debian@zeus:~$ sudo systemctl enable bacula-sd.service
Synchronizing state of bacula-sd.service with SysV service script with /lib/systemd/systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install enable bacula-sd

debian@zeus:~$ sudo systemctl restart bacula-director.service
debian@zeus:~$ sudo systemctl enable bacula-director.service
Synchronizing state of bacula-director.service with SysV service script with /lib/systemd/systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install enable bacula-director
~~~

## Clientes

* Ya tenemos instalado nuestro servidor, ahora configuraremos los clientes.

### Zeus

* Aunque zeus sea el servidor tambien queremos hacer copias de el, por ello vamos a configurarlo, aquí ya tenemos instalado bacula-client, por lo que directamente nos dirigimos a `/etc/bacula/bacula-fd.conf` y definimos los parametros necesarios.

~~~
Director {
  Name = zeus-dir
  Password = "admin"
}

Director {
  Name = zeus-mon
  Password = "admin"
  Monitor = yes
}

FileDaemon {
  Name = zeus-fd
  FDport = 9102
  WorkingDirectory = /var/lib/bacula
  Pid Directory = /run/bacula
  Maximum Concurrent Jobs = 20
  Plugin Directory = /usr/lib/bacula
  FDAddress = 10.0.1.1
}

Messages {
  Name = Standard
  director = zeus-dir = all, !skipped, !restored
}
~~~

### Ares.

~~~
Director {
  Name = zeus-dir
  Password = "admin"
}

Director {
  Name = zeus-mon
  Password = "admin"
  Monitor = yes
}

FileDaemon {
  Name = ares-fd
  FDport = 9102
  WorkingDirectory = /var/lib/bacula
  Pid Directory = /run/bacula
  Maximum Concurrent Jobs = 20
  Plugin Directory = /usr/lib/bacula
  FDAddress = 10.0.1.101
}

Messages {
  Name = Standard
  director = zeus-dir = all, !skipped, !restored
}
~~~

### Apolo

~~~
Director {
  Name = zeus-dir
  Password = "admin"
}

Director {
  Name = zeus-mon
  Password = "admin"
  Monitor = yes
}

FileDaemon {
  Name = apolo-fd
  FDport = 9102
  WorkingDirectory = /var/lib/bacula
  Pid Directory = /run/bacula
  Maximum Concurrent Jobs = 20
  Plugin Directory = /usr/lib/bacula
  FDAddress = 10.0.1.102
}

Messages {
  Name = Standard
  director = zeus-dir = all, !skipped, !restored
}
~~~

### Hera

~~~
Director {
  Name = zeus-dir
  Password = "admin"
}

Director {
  Name = zeus-mon
  Password = "admin"
  Monitor = yes
}

FileDaemon {
  Name = hera-fd
  FDport = 9102
  WorkingDirectory = /var/lib/bacula
  Pid Directory = /run/bacula
  Maximum Concurrent Jobs = 20
  Plugin Directory = /usr/lib/bacula
  FDAddress = 172.16.0.200
}

Messages {
  Name = Standard
  director = zeus-dir = all, !skipped, !restored
}
~~~

* A parte, en hera tendremos que abrir los puertos en el firewall.

~~~
[usuario@hera ~]$ sudo firewall-cmd --permanent --add-port=9101/tcp
success
[usuario@hera ~]$ sudo firewall-cmd --permanent --add-port=9102/tcp
success
[usuario@hera ~]$ sudo firewall-cmd --permanent --add-port=9103/tcp
success
[usuario@hera ~]$ sudo firewall-cmd --reload
success
~~~

## Comprobaciones

* Vamos a conectarnos desde la consola de bacula en el servidor y ver el estado de algún cliente.

~~~
debian@zeus:~$ sudo bconsole 
Connecting to Director localhost:9101
1000 OK: 103 zeus-dir Version: 9.6.7 (10 December 2020)
Enter a period to cancel a command.
*status client
The defined Client resources are:
     1: zeus-fd
     2: ares-fd
     3: apolo-fd
     4: hera-fd
Select Client (File daemon) resource (1-4): 1
Connecting to Client zeus-fd at 10.0.1.1:9102

zeus-fd Version: 9.6.7 (10 December 2020)  x86_64-pc-linux-gnu debian bullseye/sid
Daemon started 22-mar-22 12:42. Jobs: run=0 running=0.
 Heap: heap=102,400 smbytes=24,371 max_bytes=24,388 bufs=88 max_bufs=88
 Sizes: boffset_t=8 size_t=8 debug=0 trace=0 mode=0,0 bwlimit=0kB/s
 Plugin: bpipe-fd.so 

Running Jobs:
Director connected at: 22-mar-22 12:43
No Jobs running.
====

Terminated Jobs:
====
~~~

## Volumenes

* Debemos crear las etiquetas desde la consola de bacula donde se guardarán las copias, tanto la diaria, como la semanal.

~~~
debian@zeus:~$ sudo bconsole
Connecting to Director localhost:9101
1000 OK: 103 zeus-dir Version: 9.6.7 (10 December 2020)
Enter a period to cancel a command.
*label
Automatically selected Catalog: MyCatalog
Using Catalog "MyCatalog"
Automatically selected Storage: volcopias
Enter new Volume name: copia-diaria
Defined Pools:
     1: Backup-Restore
     2: Daily
     3: Default
     4: File
     5: Scratch
     6: Weekly
Select the Pool (1-6): 2
Connecting to Storage daemon volcopias at 10.0.1.1:9103 ...
Sending label command for Volume "copia-diaria" Slot 0 ...
3000 OK label. VolBytes=216 VolABytes=0 VolType=1 Volume="copia-diaria" Device="FileStorage" (/mnt/copias/)
Catalog record for Volume "copia-diaria", Slot 0  successfully created.
Requesting to mount FileChgr1 ...
3906 File device ""FileStorage" (/mnt/copias/)" is always mounted.
*label
Automatically selected Storage: volcopias
Enter new Volume name: copia-semanal
Defined Pools:
     1: Backup-Restore
     2: Daily
     3: Default
     4: File
     5: Scratch
     6: Weekly
Select the Pool (1-6): 6
Connecting to Storage daemon volcopias at 10.0.1.1:9103 ...
Sending label command for Volume "copia-semanal" Slot 0 ...
3000 OK label. VolBytes=218 VolABytes=0 VolType=1 Volume="copia-semanal" Device="FileStorage" (/mnt/copias/)
Catalog record for Volume "copia-semanal", Slot 0  successfully created.
Requesting to mount FileChgr1 ...
3906 File device ""FileStorage" (/mnt/copias/)" is always mounted.
~~~

* Como acabamos de crearlo no tiene ninguna copia ni nada, daremos un tiempo a que se realizen algunos trabajos y podremos comprobar que se han realizado algunas copias.
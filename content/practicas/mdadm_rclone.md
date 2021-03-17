+++
title = "Práctica mdadm y rclone"
description = ""
tags = [
    "SAD"
]
date = "2021-03-17"
menu = "main"
+++
# RAID 5

## Fichero VagrantFile:

        # -*- mode: ruby -*-

        # vi: set ft=ruby :

        Vagrant.configure("2") do |config|

          config.vm.box = "debian/buster64"

          config.vm.hostname = "practica1"

          config.vm.provider :virtualbox do |v|

            disco = '.vagrant/disco.vdi' 

            v.customize ["createhd","--filename",disco,"--size", 1024]

            v.customize ["storageattach",:id,"--storagectl","SATA Controller","--port",1,"--device",0,"--type","hdd","--medium",disco]

            disco2 = '.vagrant/disco2.vdi'

            v.customize ["createhd","--filename",disco2,"--size", 1024]

            v.customize ["storageattach",:id,"--storagectl","SATA Controller","--port",2,"--device",0,"--type","hdd","--medium",disco2]

            disco3 = '.vagrant/disco3.vdi'

            v.customize ["createhd","--filename",disco3,"--size", 1024]

            v.customize ["storageattach",:id,"--storagectl","SATA Controller","--port",3,"--device",0,"--type","hdd","--medium",disco3]

            disco4 = '.vagrant/disco4.vdi'

            v.customize ["createhd","--filename",disco4,"--size", 1024]

            v.customize ["storageattach",:id,"--storagectl","SATA Controller","--port",4,"--device",0,"--type","hdd","--medium",disco4]

            disco5 = '.vagrant/disco5.vdi'

            v.customize ["createhd","--filename",disco5,"--size", 1024]

            v.customize ["storageattach",:id,"--storagectl","SATA Controller","--port",5,"--device",0,"--type","hdd","--medium",disco5]

          end

        end

* Crea una raid llamado md5 con los discos que hemos conectado a la máquina. ¿Cuantós discos tienes que conectar? ¿Qué diferencia exiiste entre el RAID 5 y el RAID1?

        sudo mdadm --create /dev/md5 -l5 -n3 /dev/sdb /dev/sdc /dev/sdd

### Diferencias RAID 1 y RAID 5

### RAID 1:
1. Se necesitan mínimo 2 discos
2. Se almacenan los datos en modo espejo
3. Escritura lenta y lectura rápida

### RAID 5:
1. Operaciones rápidas, incluso para varios usuarios simultaneamente.
2. Para la tolerancia a fallos usa paridad y suma de verificación.
3. Sus datos se almacenan de forma aleatoria por sus diferentes discos al igual que su paridad para su reconstrucción.
4. Lectura lenta.
5. Requiere mínimo 3 discos.

* * * *

* **Comprueba las características del RAID. Comprueba el estado del RAID. ¿Qué capacidad tiene el RAID que hemos creado?**

**Caracteristicas:**
**Aparecen caracterisiticas tales como la fecha de creación, en espacio del que dispone, los discos que usa, etc...**
        vagrant@practica1:~$ sudo mdadm -D /dev/md5
        /dev/md5:
                   Version : 1.2
             Creation Time : Wed Mar 17 12:26:56 2021
                Raid Level : raid5
                Array Size : 2093056 (2044.00 MiB 2143.29 MB)
             Used Dev Size : 1046528 (1022.00 MiB 1071.64 MB)
              Raid Devices : 3
             Total Devices : 3
               Persistence : Superblock is persistent

               Update Time : Wed Mar 17 12:27:04 2021
                     State : clean 
            Active Devices : 3
           Working Devices : 3
            Failed Devices : 0
             Spare Devices : 0

                    Layout : left-symmetric
                Chunk Size : 512K

        Consistency Policy : resync

                      Name : practica1:5  (local to host practica1)
                      UUID : a0b705b7:452a7c5c:970133fd:48c1d0e0
                    Events : 18

            Number   Major   Minor   RaidDevice State
               0       8       16        0      active sync   /dev/sdb
               1       8       32        1      active sync   /dev/sdc
               3       8       48        2      active sync   /dev/sdd


**Estado:**
**Puede comprobarse que se encuetra activo**
        vagrant@practica1:~$ cat /proc/mdstat
        Personalities : [raid6] [raid5] [raid4] 
        md5 : active raid5 sdd[3] sdc[1] sdb[0]
              2093056 blocks super 1.2 level 5, 512k chunk, algorithm 2 [3/3] [UUU]

        unused devices: <none>


**Nuestro RAID 5 dispone de 3 GB, sin embargo uno se usa para paridad por lo que útiles tenemos 2 GB para almacenar información.**

* Crea un volumen lógico (LVM) de 500Mb en el raid 5.

**Primero creamos el grupo de volumenes**

        vagrant@practica1:~$ sudo vgcreate raid5 /dev/md5
          Physical volume "/dev/md5" successfully created.
          Volume group "raid5" successfully created


**Y seguidamente el volumen lógico**

        vagrant@practica1:~$ sudo lvcreate -L 500M -n disco1 raid5
          Logical volume "disco1" created.

**Vamos a comprobar que se ha creado**

        vagrant@practica1:~$ sudo lvdisplay
          --- Logical volume ---
          LV Path                /dev/raid5/disco1
          LV Name                disco1
          VG Name                raid5
          LV UUID                enxj0F-2UNf-Ot3m-pEyn-K89e-TmXP-E1e9Ow
          LV Write Access        read/write
          LV Creation host, time practica1, 2021-03-17 12:33:34 +0000
          LV Status              available
          # open                 0
          LV Size                500.00 MiB
          Current LE             125
          Segments               1
          Allocation             inherit
          Read ahead sectors     auto
          - currently set to     4096
          Block device           253:0

* Formatea ese volumen con un sistema de archivo xfs.

**Primero debemos instalar este paquete para poder montar en xfs con mkfs**

        vagrant@practica1:~$ sudo apt-get install xfsprogs


**Y formateamos**

        vagrant@practica1:~$ sudo mkfs.xfs /dev/raid5/disco1
        meta-data=/dev/raid5/disco1      isize=512    agcount=8, agsize=16000 blks
                 =                       sectsz=512   attr=2, projid32bit=1
                 =                       crc=1        finobt=1, sparse=1, rmapbt=0
                 =                       reflink=0
        data     =                       bsize=4096   blocks=128000, imaxpct=25
                 =                       sunit=128    swidth=256 blks
        naming   =version 2              bsize=4096   ascii-ci=0, ftype=1
        log      =internal log           bsize=4096   blocks=896, version=2
                 =                       sectsz=512   sunit=0 blks, lazy-count=1
        realtime =none                   extsz=4096   blocks=0, rtextents=0

* Monta el volumen en el directorio /mnt/raid5 y crea un fichero. ¿Qué tendríamos que hacer para que este punto de montaje sea permanente?

        vagrant@practica1:~$ sudo mkdir /mnt/raid5
        vagrant@practica1:~$ sudo mount /dev/raid5/disco1 /mnt/raid5

**Para que este punto de montaje sea permanente necesitamos editar el fichero fstab de la siguiente forma:**

        UUID=ffC3KF-As96-HhdY-fjpD-6TG1-7yjG-ZjitFI /mnt/raid5  xfs     defaults        0       1


* Marca un disco como estropeado. Muestra el estado del raid para comprobar que un disco falla. ¿Podemos acceder al fichero?

**Marcamos uno de los discos como estropeado.**

        vagrant@practica1:~$ sudo mdadm -f /dev/md5 /dev/sdb
        mdadm: set /dev/sdb faulty in /dev/md5

**En la siguiente imagen podemos ver que el sdb falla, pues nos marca que están funcionando 2 de 3.**

        vagrant@practica1:~$ sudo cat /proc/mdstat 
        Personalities : [raid6] [raid5] [raid4] 
        md5 : active raid5 sdd[3] sdc[1] sdb[0](F)
              2093056 blocks super 1.2 level 5, 512k chunk, algorithm 2 [3/2] [_UU]

        unused devices: <none>
        You have mail in /var/mail/vagrant

**Una vez marcado como estropeado, lo tenemos que retirar del raid.**

**Retiramos el disco estropeado**

        vagrant@practica1:~$ sudo mdadm --manage /dev/md5 --remove faulty
        mdadm: hot removed 8:16 from /dev/md5


* Imaginemos que lo cambiamos por un nuevo disco nuevo (el dispositivo de bloque se llama igual), añádelo al array y comprueba como se sincroniza con el anterior.

**Añadimos nuevo dispositivo al raid 5**

        vagrant@practica1:~$ sudo mdadm -a /dev/md5 /dev/sde
        mdadm: added /dev/sde


**Y comprobamos que todo vuelve a la normalidad**

        vagrant@practica1:~$ sudo cat /proc/mdstat 
        Personalities : [raid6] [raid5] [raid4] 
        md5 : active raid5 sde[4] sdd[3] sdc[1]
              2093056 blocks super 1.2 level 5, 512k chunk, algorithm 2 [3/3] [UUU]

        unused devices: <none>

* Añade otro disco como reserva. Vuelve a simular el fallo de un disco y comprueba como automática se realiza la sincronización con el disco de reserva.

**Añadimos otro disco de reserva**

        vagrant@practica1:~$ sudo mdadm -a /dev/md5 /dev/sdf
        mdadm: added /dev/sdf


**Si marcamos uno como estropeado veremos que inmediatamente el otro se pondra a trabajar.**

        vagrant@practica1:~$ sudo mdadm -f /dev/md5 /dev/sde
        mdadm: set /dev/sde faulty in /dev/md5

        vagrant@practica1:~$ sudo mdadm --manage /dev/md5 --remove faulty
        mdadm: hot removed 8:64 from /dev/md5

        vagrant@practica1:~$ sudo cat /proc/mdstat 
        Personalities : [raid6] [raid5] [raid4] 
        md5 : active raid5 sdf[5] sdd[3] sdc[1]
              2093056 blocks super 1.2 level 5, 512k chunk, algorithm 2 [3/3] [UUU]

        unused devices: <none>
        You have new mail in /var/mail/vagrant

* Redimensiona el volumen y el sistema de archivo de 500Mb al tamaño del raid.

**Primero aumentamos de tamaño el volumen lógico y después el sistema de ficheros.**

        vagrant@practica1:~$ sudo lvresize -l +100%FREE /dev/raid5/disco1
          Size of logical volume raid5/disco1 changed from 500.00 MiB (125 extents) to 1.99 GiB (510 extents).
          Logical volume raid5/disco1 successfully resized.

        vagrant@practica1:~$ sudo xfs_growfs /mnt/raid5/
        meta-data=/dev/mapper/raid5-disco1 isize=512    agcount=8, agsize=16000 blks
                 =                       sectsz=512   attr=2, projid32bit=1
                 =                       crc=1        finobt=1, sparse=1, rmapbt=0
                 =                       reflink=0
        data     =                       bsize=4096   blocks=128000, imaxpct=25
                 =                       sunit=128    swidth=256 blks
        naming   =version 2              bsize=4096   ascii-ci=0, ftype=1
        log      =internal log           bsize=4096   blocks=896, version=2
                 =                       sectsz=512   sunit=0 blks, lazy-count=1
        realtime =none                   extsz=4096   blocks=0, rtextents=0
        data blocks changed from 128000 to 522240

**Ahora al hacer un lvdisplay, el tamaño del raid debería ser 2 GB que es el tamaño máximo**

        vagrant@practica1:~$ sudo lvdisplay
          --- Logical volume ---
          LV Path                /dev/raid5/disco1
          LV Name                disco1
          VG Name                raid5
          LV UUID                enxj0F-2UNf-Ot3m-pEyn-K89e-TmXP-E1e9Ow
          LV Write Access        read/write
          LV Creation host, time practica1, 2021-03-17 12:33:34 +0000
          LV Status              available
          # open                 1
          LV Size                1.99 GiB
          Current LE             510
          Segments               1
          Allocation             inherit
          Read ahead sectors     auto
          - currently set to     4096
          Block device           253:0


-------------

# RCLONE

* Instala rclone en tu equipo.

**Instalamos rclone simplemente usando apt install.**

        alejandrogv@AlejandroGV:~$ sudo apt install rclone

* Configura dos proveedores cloud en rclone (dropbox, google drive, mega, …)

**Para configurar este servicio y añadir los clouds usamos este comando:**

        alejandrogv@AlejandroGV:~$ rclone config

**Usamos la opción n para añadir un nuevo servicio, le ponemos un nombre, como drive y elegimos la opción 12.**

        e/n/d/r/c/s/q> n
        name> drive
        ...
        ...
        ...
        12 / Google Drive
           \ "drive"
        ...
        ...
        ...
        Storage> 12

**Dejamos el blanco el client_id y el client_secret.**

**Elegimos la opción 1 para usar todos los archivos de este servicio.**

         1 / Full access all files, excluding Application Data Folder.
           \ "drive"
        ...
        ...
        ...
        scope> 1

**No configuraremos de forma avanzada y usaremos el autoconfig.**

**Acto seguido se nos abrirá una ventana en el navegador donde elegiremos la cuenta de drive que queremos enlazar y le daremos permiso.**

![rclone](/practica1_SAD/1.png)

**Volverá a saltarnos la primera opción donde para añadir Dropbox volvermos a usar la opción n y seguiremos los mismos pasos, solo que tendremos que elegir al pricipio la opción 8.**

**Cuando terminemos usamos q para salir.**

* Muestra distintos comandos de rclone para gestionar los ficheros de los proveedores cloud: lista los ficheros, copia un fichero local a la nube, sincroniza un directorio local con un directorio en la nube, copia ficheros entre los dos proveedores cloud, muestra alguna funcionalidad más,…

**Listamos los ficheros:**

        alejandrogv@AlejandroGV:~$ rclone ls drive:
           539468 06012011214.jpg
           190719 111923323.pdf
           139297 1612356215679.jpg
           602522 1612435729195.jpg
            20726 2018-06-21T09-20 [G Jim <infortic.iesmm@gmail.com>] Fwd: importante: PROYECTO FINAL DE CURSO.pdf
          1727799 A.Circuito2011 017.jpg
            13876 Alejandro 1.docx
        180495956 Almuñecar 087.mov
           128367 Archivo_001.png
        ...
        ...
        ...

**Subimos un fichero local:**

        alejandrogv@AlejandroGV:~$ rclone copy prueba.txt.gpg drive:

![rclone](/practica1_SAD/2.png)

**Sincronizamos una carpeta:**

        alejandrogv@AlejandroGV:~/Escritorio$ rclone sync -P ASIR drive:/ASIR & ASIR
        alejandrogv@AlejandroGV:~/Escritorio$ ls ASIR/
        bbdd  hlc  IWEB  Seguridad  Servicios  sistemas

**Copiamos un archivo de un servicio a otro:**

        alejandrogv@AlejandroGV:~/Escritorio$ rclone copy drive:/volumenes.sh dropbox:

![rclone](/practica1_SAD/3.png)


* Monta en un directorio local de tu ordenador, los ficheros de un proveedor cloud. Comprueba que copiando o borrando ficheros en este directorio se crean o eliminan en el proveedor.

**Usamos el siguiente comando para montar el servicio en un directorio local:**

        alejandrogv@AlejandroGV:~$ sudo rclone mount --vfs-cache-mode writes drive: GoogleDrive &

**Usamos el --vfs para prevenir un error que puede ocasionarse al editar algun archivo del directorio.**
![rclone](/practica1_SAD/3-3.png)

**En la foto anterior podemos ver que se ha montado bien. Si crearamos o borraramos algún archivo en el directorio o en el servicio se sincronizarían los cambios.**
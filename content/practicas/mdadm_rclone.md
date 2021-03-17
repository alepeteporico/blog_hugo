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

        sudo mdadm -D /dev/md5


**Estado:**

        cat /proc/mdstat


**Nuestro RAID 5 dispone de 3 GB, sin embargo uno se usa para paridad por lo que útiles tenemos 2 GB para almacenar información.**

* Crea un volumen lógico (LVM) de 500Mb en el raid 5.

**Primero creamos el grupo de volumenes**

        sudo vgcreate raid5 /dev/md5


**Y seguidamente el volumen lógico**

        sudo lvcreate -L 500M -n disco1 raid5


* Formatea ese volumen con un sistema de archivo xfs. 

**Primero debemos instalar este paquete para poder montar en xfs con mkfs**

        sudo apt-get install xfsprogs


**Y formateamos**

        sudo mkfs.xfs /dev/raid5/disco1


* Monta el volumen en el directorio /mnt/raid5 y crea un fichero. ¿Qué tendríamos que hacer para que este punto de montaje sea permanente?


        sudo mount /dev/raid5/disco1 /mnt/raid5


**Para que este punto de montaje sea permanente necesitamos editar el fichero fstab de la siguiente forma:**

        UUID=ffC3KF-As96-HhdY-fjpD-6TG1-7yjG-ZjitFI /mnt/raid5  xfs     defaults        0       1


* Marca un disco como estropeado. Muestra el estado del raid para comprobar que un disco falla. ¿Podemos acceder al fichero?

**Marcamos uno de los discos como estropeado.**

        sudo mdadm -f /dev/md5 /dev/sdb


**En la siguiente imagen podemos ver que el sdb falla.**
!2.png!

* Una vez marcado como estropeado, lo tenemos que retirar del raid.

**Retiramos el disco estropeado**

        mdadm --manage /dev/md2 --remove faulty


* Imaginemos que lo cambiamos por un nuevo disco nuevo (el dispositivo de bloque se llama igual), añádelo al array y comprueba como se sincroniza con el anterior.

**Añadimos nuevo dispositivo al raid 5**

        sudo mdadm -a /dev/md5 /dev/sde


**Vemos que todo vuelve a la normalidad**
!3.png!

* Añade otro disco como reserva. Vuelve a simular el fallo de un disco y comprueba como automática se realiza la sincronización con el disco de reserva.

**Añadimos otro disco de reserva**

        sudo mdadm -a /dev/md5 /dev/sdf


**Si marcamos uno como estropeado veremos que inmediatamente el otro se pondra a trabajar.**
!4.png!

* Redimensiona el volumen y el sistema de archivo de 500Mb al tamaño del raid.

**Primero aumentamos de tamaño el volumen lógico y después el sistema de ficheros.**

        sudo lvresize -l +100%FREE /dev/raid5/disco1
        sudo xfs_growfs /mnt/raid5/

-------------

# RCLONE

* Instala rclone en tu equipo.

**Instalamos rclone simplemente usando apt install.**

* Configura dos proveedores cloud en rclone (dropbox, google drive, mega, …)

**Para configurar este servicio y añadir los clouds usamos este comando:**

        rclone config

**Usamos la opción n para añadir un nuevo servicio, le ponemos un nombre, como drive y elegimos la opción 12.**

**Dejamos el blanco el client_id y el client_secret.**

**Elegimos la opción 1 para usar todos los archivos de este servicio.**

**No configuraremos de forma avanzada y usaremos el autoconfig.**

**Acto seguido se nos abrirá una ventana en el navegador donde elegiremos la cuenta de drive que queremos enlazar y le daremos permiso.**

**Volverá a saltarnos la primera opción donde para añadir Dropbox volvermos a usar la opción n y seguiremos los mismos pasos, solo que tendremos que elegir al pricipio la opción 8.**

**Cuando terminemos usamos q para salir.**

* Muestra distintos comandos de rclone para gestionar los ficheros de los proveedores cloud: lista los ficheros, copia un fichero local a la nube, sincroniza un directorio local con un directorio en la nube, copia ficheros entre los dos proveedores cloud, muestra alguna funcionalidad más,…

**Listamos los ficheros:**

        rclone ls drive:

!1-1.png!

**Subimos un fichero local:**

        rclone copy fichero.txt dropbox:

**Sincronizamos una carpeta:**

        rclone sync -P ASIR drive:/ASIR &

!2-2.png!

**Copiamos un archivo de un servicio a otro:**

        rclone copy drive:/volumenes.sh dropbox:


* Monta en un directorio local de tu ordenador, los ficheros de un proveedor cloud. Comprueba que copiando o borrando ficheros en este directorio se crean o eliminan en el proveedor.

**Usamos el siguiente comando para montar el servicio en un directorio local:**

        rclone mount --vfs-cache-mode writes drive: GoogleDrive &

**Usamos el --vfs para prevenir un error que puede ocasionarse al editar algun archivo del directorio.**
!3-3.png!

**En la foto anterior podemos ver que se ha montado bien. Si crearamos o borraramos algún archivo en el directorio o en el servicio se sincronizarían los cambios.**
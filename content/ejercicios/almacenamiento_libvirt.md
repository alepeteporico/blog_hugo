+++
title = "Trabajo con almacenamiento en libvirt"
description = ""
tags = [
    "HLC"
]
date = "2022-04-20"
menu = "main"
+++

* Crea un nuevo pool de almacenamiento de tipo lvm, y crea un volumen de 3Gi dentro que sea una volumen lógico. Con virt-install instala una máquina que se llame original_tunombre cuyo disco sea el volumen creado.

~~~
<pool type='logical'>
  <name>pool_lvm</name>
  <capacity unit='bytes'>5368709120</capacity>
  <source>
  <name>debian</name>
  </source>
  <target>
    <path>/home/alejandrogv/libvirt/pool</path>
    <permissions>
      <mode>0711</mode>
      <owner>0</owner>
      <group>0</group>
    </permissions>
  </target>
</pool>
~~~

~~~
virsh -c qemu:///system pool-define --file pool.xml

virsh -c qemu:///system pool-start pool_lvm
~~~

~~~
sudo lvcreate -L 3G -n pool1 debian
~~~

~~~
virt-install --connect qemu:///system --network network=default --name=original_alegv --memory 1024 --vcpus 1 --disk /dev/debian/pool1 --cdrom /home/alejandrogv/Escritorio/ISOS/debian-11.1.0-amd64-netinst.iso
~~~

### Un pantallazo de la definición del dominio original_nombre, donde se vea el dispositivo de disco que está utilizando.

~~~
alejandrogv@AlejandroGV:~$ virsh -c qemu:///system dumpxml --domain original_alegv
...
...
    <disk type='block' device='disk'>
      <driver name='qemu' type='raw' cache='none' io='native'/>
      <source dev='/dev/debian/pool1' index='2'/>
      <backingStore/>
      <target dev='hda' bus='ide'/>
      <alias name='ide0-0-0'/>
      <address type='drive' controller='0' bus='0' target='0' unit='0'/>
    </disk>
...
...
~~~

* Convierte el volumen anterior en un fichero de imagen qcow2 que estará en el pool default.

~~~
sudo qemu-img convert -O qcow2 /dev/debian/pool1 /home/alejandrogv/libvirt/original_alegv.qcow2
~~~

### pantallazo de la definición del dominio nodo1_tunombre, donde se vea el dispositivo de disco que está utilizando (que se vea claramente que has usado aprovisonamiento ligero).

~~~
alejandrogv@AlejandroGV:~/libvirt$ qemu-img info original_alegv.qcow2 
image: original_alegv.qcow2
file format: qcow2
virtual size: 3 GiB (3221225472 bytes)
disk size: 2.24 GiB
cluster_size: 65536
Format specific information:
    compat: 1.1
    compression type: zlib
    lazy refcounts: false
    refcount bits: 16
    corrupt: false
    extended l2: false
~~~

* Crea dos máquinas virtuales (nodo1_tunombre y nodo2_tunombre) que utilicen la imagen construida en el punto anterior como imagen base (aprovisonamiento ligero). Una vez creada accede a las máquinas para cambiarle el nombre.

~~~
qemu-img create -b original_alegv.qcow2 -f qcow2 aprov1_alegv.qcow2

qemu-img create -b original_alegv.qcow2 -f qcow2 aprov2_alegv.qcow2
~~~

~~~
virt-install --connect qemu:///system --network network=default --name=nodo1_alegv --memory 1024 --vcpus 1 --disk aprov1_alegv.qcow2 --import

virt-install --connect qemu:///system --network network=default --name=nodo2_alegv --memory 1024 --vcpus 1 --disk aprov2_alegv.qcow2 --import
~~~

### Un pantallazo donde se compruebe que nodo2_tunombre tiene acceso a internet y que le has cambiado el nombre.

![ping](/redes_libvirt/5.png)

* Transforma la imagen de la máquina nodo1_tunombre a formato raw. Realiza las modificaciones necesarias en la definición de la máquina virtual (virsh edit "maquina"), para que pueda seguir funcionando con el nuevo formato de imagen.

~~~
sudo qemu-img convert aprov1_alegv.qcow2 aprov1_alegv.raw
~~~

### Pantallazo de la definición del dominio nodo1_tunombre, donde se vea el dispositivo de disco que está utilizando. Y una captura de pantalla donde se vea que está funcionando.

~~~
alejandrogv@AlejandroGV:~/libvirt$ sudo virsh edit --domain nodo1_alegv
...
...
    <disk type='file' device='disk'>
      <driver name='qemu' type='raw'/>
      <source file='/home/alejandrogv/libvirt/aprov1_alegv.raw'/>
      <target dev='hda' bus='ide'/>
      <address type='drive' controller='0' bus='0' target='0' unit='0'/>
    </disk>
...
...
~~~

![ping](/redes_libvirt/6.png)

* Redimensiona la imagen de la máquina nodo2_tunombre, añadiendo 1 GiB y utiliza la herramienta guestfish para redimensionar también el sistema de ficheros definido dentro de la imagen.

~~~
sudo apt install libguestfs-tools
~~~

- Miramos la indormacion de la imagen que está usando el nodo 2.

~~~
alejandrogv@AlejandroGV:~/libvirt$ qemu-img info aprov2_alegv.qcow2 
image: aprov2_alegv.qcow2
file format: qcow2
virtual size: 3 GiB (3221225472 bytes)
disk size: 81.1 MiB
cluster_size: 65536
backing file: original_alegv.qcow2
backing file format: qcow2
Format specific information:
    compat: 1.1
    compression type: zlib
    lazy refcounts: false
    refcount bits: 16
    corrupt: false
    extended l2: false
~~~

- Creamos una nueva imagen de 4G

~~~
qemu-img create -f qcow2 -o preallocation=metadata aprov3_alegv.qcow2 4G
~~~

- Usamos la herramienta requerida para redimensionar el disco nuevo a partir del antiguo.

~~~
sudo virt-resize --expand /dev/sda1 aprov2_alegv.qcow2 aprov3_alegv.qcow2
~~~

- Debemos cambiarles los nombres.

~~~
alejandrogv@AlejandroGV:~/libvirt$ mv aprov2_alegv.qcow2 aprov2_alegv_antiguo.qcow2 
alejandrogv@AlejandroGV:~/libvirt$ mv aprov3_alegv.qcow2 aprov2_alegv.qcow2
~~~

### Pantallazo de la ejecución de nodo2_tunombre, donde se vea el comando lsblk, y df -h. Para comprobar que se ha redimensionado el dispositivo de bloque y el sistema de fichero.

![ping](/redes_libvirt/7.png)

* Crea un snapshot de la máquina nodo2_tunombre, modifica algún fichero de la máquina y alguna caracteristica de la misma (por ejemplo cantidad e memoria). Recupera el estado de la máquina desde el snapshot y comprueba que lo cambios se han perdido.

- El formato raw no tiene soporte para crear snapshots usando virsh. Por ello debemos volver a cambiar el formato por el qcow2.

~~~
sudo qemu-img convert aprov1_alegv.raw aprov1_alegv.qcow2
~~~

- Creamos la snapshot.

~~~
virsh snapshot-create-as --domain nodo1_alegv --name nodo1_alegv_snap --description "snapshot para ejercicio"
~~~

- Después de algunos cambios volvemos a la snapshot

~~~
virsh -c qemu:///system snapshot-revert --domain nodo1_alegv --snapshotname nodo1_alegv_snap --running
~~~

### Muestra información del volumen donde se vea que se ha creado un snapshot. Explica los cambios que has hecho en la máquina y demuestra que al recuperar el estado del snapshot se han recuperado los cambios.

~~~
alejandrogv@AlejandroGV:~/libvirt$ virsh -c qemu:///system snapshot-list --domain nodo1_alegv 
 Nombre             Hora de creación            Estado
---------------------------------------------------------
 nodo1_alegv_snap   2022-04-26 12:02:25 +0200   running
~~~

- He añadido el doble de RAM a la maquina.

![ping](/redes_libvirt/8.png)

~~~
alejandrogv@AlejandroGV:~/libvirt$ virsh -c qemu:///system dumpxml --domain nodo1_alegv
...
...
<memory unit='KiB'>2097152</memory>
...
...
~~~

- Y hemos creado una carpeta

![ping](/redes_libvirt/9.png)

- Comprobamos que se han desecho los cambios.

~~~
alejandrogv@AlejandroGV:~/libvirt$ virsh -c qemu:///system dumpxml --domain nodo1_alegv
...
...
<memory unit='KiB'>1048576</memory>
...
...
~~~

![ping](/redes_libvirt/10.png)

* Crea un nuevo pool de tipo “dir” llamado discos_externos, crea un volumen de 1Gb dentro de este pool, y añádelo “en caliente” a la máquina nodo2_tunombre. Formatea el disco y móntalo.

- Creamos el pool y lo iniciamos

~~~
alejandrogv@AlejandroGV:~/libvirt$ virsh -c qemu:///system pool-define-as --name discos_externos --target /home/alejandrogv/libvirt/pool-dir --type dir

alejandrogv@AlejandroGV:~/libvirt$ virsh -c qemu:///system pool-start --pool discos_externos
~~~

- Creamos el volumen y lo añadimos a nodo2.

~~~
qemu-img create -f raw /home/alejandrogv/libvirt/pool-dir/vol.raw 1G

virsh -c qemu:///system attach-disk --domain nodo2_alegv --source /home/alejandrogv/libvirt/pool-dir/vol.raw --target sdb --persistent
~~~

- Le damos formato y lo montamos.

![ping](/redes_libvirt/12.png)

### Demuestra que tenemos un nuevo disco y ha sido montado.

![ping](/redes_libvirt/11.png)


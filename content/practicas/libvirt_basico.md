+++
title = "Uso básico de libvirt"
description = ""
tags = [
    "HLC"
]
date = "2021-09-30"
menu = "main"
+++

---

## Creación de la red.

* **La red que vamos a crear para este ejercicio será tipo NAT, tendrá direccionamiento `10.0.1.0/24` y de tipo virtio.**

* Veamos el contenido del fichero xml de configuración de la red.

~~~
<network>
  <name>red_interna</name>
  <bridge name="virbr20"/>
  <forward mode="nat"/>
  <ip address="10.0.1.0" netmask="255.255.255.0">
    <dhcp>
      <range start="10.0.1.2" end="10.0.1.254"/>
    </dhcp>
  </ip>
</network>
~~~

* Creamos esta red.

~~~
alejandrogv@AlejandroGV:~/libvirt$ virsh -c qemu:///system net-create red_interna.xml
~~~

## Creación de escenario.

* **Usaremos una imagen ya creada para montar nuestro escenario**

* Tenemos una imagen con extensión `qcow2` para montarla usaremos ndb y nuestro primer paso será habilitar este módulo.

~~~
modprobe nbd max_part=8
~~~

* Conectamos la imagen con un dispositivo de bloques.

~~~
alejandrogv@AlejandroGV:~/libvirt$ sudo qemu-nbd --connect=/dev/nbd0 debiantest.qcow2
~~~

* Y montamos esta partición donde queramos.

~~~
alejandrogv@AlejandroGV:~/libvirt$ sudo mount /dev/nbd0p1 volumen/
~~~

* para añadir nuestra clave antes tendremos que crear la carpeta `.ssh` en el home del usuario y añadir el authorized_keys

~~~
alejandrogv@AlejandroGV:~/libvirt$ cat volumen/home/usuario/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABA.....
~~~

* Y por supuesto modificamos el fichero hostname y hosts para cambiar el nombre de la máquina.

~~~
alejandrogv@AlejandroGV:~/libvirt$ sudo cat volumen/etc/hosts
127.0.0.1	maquina1_alejandro
127.0.1.1	localhost

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

alejandrogv@AlejandroGV:~/libvirt$ sudo cat volumen/etc/hostname 
maquina_alejandro
~~~

* Desmontamos la imagen y directamente cambiaría nuestro fichero qcow.

~~~
alejandrogv@AlejandroGV:~/libvirt$ sudo umount volumen

alejandrogv@AlejandroGV:~/libvirt$ sudo qemu-nbd --disconnect /dev/nbd0
/dev/nbd0 disconnected

alejandrogv@AlejandroGV:~/libvirt$ sudo rmmod nbd
~~~

* El siguiente paso sería crear un volumen en el pool por defecto con esta imagen. Para ello debemos saber el espacio que ocupa nuestra imagen.

~~~
alejandrogv@AlejandroGV:~/libvirt$ qemu-img info debiantest.qcow2 
image: debiantest.qcow2
file format: qcow2
virtual size: 10 GiB (10737418240 bytes)
disk size: 2.31 GiB
cluster_size: 65536
Format specific information:
    compat: 1.1
    compression type: zlib
    lazy refcounts: false
    refcount bits: 16
    corrupt: false
    extended l2: false
~~~

* Creamos un volumen con las caracteriscas que necesitamos.

~~~
alejandrogv@AlejandroGV:~/libvirt$ virsh -c qemu:///system vol-create-as --format qcow2 --name ejercicio1 --capacity 10GiB --pool default
Se ha creado el volumen ejercicio1
~~~

* Ahora volcamos el contenido de nuestra imagen al volumen.

~~~
alejandrogv@AlejandroGV:~/libvirt$ virsh -c qemu:///system vol-upload ejercicio1 debiantest.qcow2 --pool default
~~~

* Creamos un dominio mediante un fichero xml.

~~~
<domain type="kvm">
  <name>dominio1</name>
  <memory unit="G">1</memory>
  <vcpu>1</vcpu>
  <os>
    <type arch="x86_64">hvm</type>
  </os>
  <devices>
    <emulator>/usr/bin/kvm</emulator>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2'/>
      <source file='/var/lib/libvirt/images/ejercicio1'/>
      <target dev='vda'/>
      <model type='virtio'/>
    </disk>
    <interface type="network">
      <source network="red_interna"/>
      <mac address="52:54:00:86:c6:a9"/>
      <model type='virtio'/>
    </interface>
    <graphics type='vnc' port='-1' autoport='yes' listen='0.0.0.0' />
  </devices>
</domain>
~~~

* Definimos el dominio.

~~~
alejandrogv@AlejandroGV:~/libvirt$ virsh -c qemu:///system define dominio1.xml 
Domain 'dominio1' defined from dominio1.xml
~~~

* iniciamos el dominio.

~~~
alejandrogv@AlejandroGV:~/libvirt$ virsh -c qemu:///system start dominio1
Domain 'dominio1' started
~~~
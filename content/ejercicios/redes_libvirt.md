+++
title = "Trabajo con redes en libvirt"
description = ""
tags = [
    "HLC"
]
date = "2022-04-20"
menu = "main"
+++

* Crea una máquina virtual conectada a la red_interna del ejercicio anterior, utilizando virt-install. Está máquina se debe llamar nodo1_tunombre.

~~~
virt-install --connect qemu:///system --cdrom ../Escritorio/ISOS/debian-11.1.0-amd64-netinst.iso --disk size=10 --network network=red_interna --name nodo1_ale --memory 512 --vcpus 1
~~~

* Crea un clon de la máquina anterior con virt-clone, esta máquina se debe llamar nodo2_tunombre.

~~~
virt-clone --original=nodo1_ale --name=nodo2_ale --auto-clone
~~~

* Crea una red aislada (very isolated) que nos permita unir el nodo1 y el nodo2, pero que no esté conectada al host.

~~~
<network>
  <name>very_isolated</name>
  <bridge name="virbr21"/>
</network>
~~~

* Añade una interfaz a cada máquina (en caliente) y configúralas de forma estática usando el direccionamiento 192.168.10.0/24. Desconecta la segunda máquina de la red red_interna.

~~~
alejandrogv@AlejandroGV:~/libvirt$ virsh -c qemu:///system attach-interface nodo1_ale network very_isolated
La interfaz ha sido asociada exitosamente

alejandrogv@AlejandroGV:~/libvirt$ virsh -c qemu:///system attach-interface nodo2_ale network very_isolated
La interfaz ha sido asociada exitosamente
~~~

~~~
alejandrogv@AlejandroGV:~/libvirt$ virsh -c qemu:///system detach-interface nodo2_ale network red_interna
~~~

* Añade un bridge externo a tu máquina (llámalo br0). Conecta a este bridge tu máquina física.

~~~
4: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether f2:58:58:62:26:28 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.54/24 brd 192.168.1.255 scope global dynamic br0
       valid_lft 85739sec preferred_lft 85739sec
    inet6 fe80::f058:58ff:fe62:2628/64 scope link 
       valid_lft forever preferred_lft forever
~~~

### Cuando termines el punto 2, un pantallazo donde se vea un ping a la segunda máquina desde la primera.

![ping](/redes_libvirt/1.png)

### Cuando termines el punto 3, un pantallazo donde se vea un ping a la segunda máquina desde la primera.

![ping](/redes_libvirt/2.png)

### Cuando termines el punto 3, pantallazo con la ejecución de ip a en la segunda máquina.

![ping](/redes_libvirt/3.png)


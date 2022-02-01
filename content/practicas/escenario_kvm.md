+++
title = "Escenario KVM"
description = ""
tags = [
    "HLC"
]
date = "2021-11-08"
menu = "main"
+++

* Definamos nuestra red interna llamada `interna_agv` en un fichero xml.

~~~
<network>
  <name>interna_agv</name>
  <forward mode="bridge"/>
  <bridge name="br0"/>
</network>
~~~

* Vamos a crear la red.

~~~
alejandrogv@AlejandroGV:~/kvm/redes$ virsh -c qemu:///system net-create --file interna_agv.xml 
La red interna_agv ha sido creada desde interna_agv.xml
~~~

* Y hacemos lo mismo con la red DMZ.

~~~
<network>
  <name>interna_agv</name>
  <forward mode="bridge"/>
  <bridge name="br0"/>
</network>
~~~

~~~
alejandrogv@AlejandroGV:~/kvm/redes$ virsh -c qemu:///system net-create --file dmz.xml 
La red dmz_agv ha sido creada desde dmz.xml
~~~

* Creamos la máquina:

~~~
virt-install --cdrom /home/alejandrogv/Escritorio/ISOS/debian-11.1.0-amd64-netinst.iso --memory 512 --vcpus 1 --network network=bridge --network network=interna_agv --network network=dmz_agv --disk size=10 --name  zeus
~~~

* una vez detro lo primero que haremos será habilitar la NAT, para ello descomentaremos la siguiente línea del fichero `/etc/sysctl.conf`

~~~
net.ipv4.ip_forward=1
~~~

* Para asegurarnos de que el bit de forwarding se activa también podemos usar el siguiente comando:

~~~
root@zeus:~# echo 1 > /proc/sys/net/ipv4/ip_forward
~~~

* Ahora añadiremos las reglas de iptables:

~~~
root@zeus:~# iptables -t nat -A POSTROUTING -s 172.16.0.0/16 -o ens3 -j MASQUERADE
root@zeus:~# iptables -t nat -A POSTROUTING -s 10.0.1.0/24 -o ens3 -j MASQUERADE
~~~

* Configuramos las interfaces de red en el `/etc/network/interfaces`.

~~~
# The primary network interface
allow-hotplug ens3
iface ens3 inet dhcp

# Additional interfaces, just in case we're using
# multiple networks
auto ens4
iface ens4 inet static
 address 10.0.1.1
 netmask 255.255.255.0
 broadcast 10.0.1.255
 gateway 10.0.1.1

auto ens5
iface ens5 inet static
 address 172.16.0.1
 netmask 255.255.0.0
 broadcast 172.16.255.255
 gateway 172.16.0.1
~~~

* Ahora instalariamos las demás máquinas y configurariamos sus interfaces tal y como hemos hecho aquí.
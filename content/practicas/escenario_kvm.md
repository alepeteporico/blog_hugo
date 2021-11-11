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

* 
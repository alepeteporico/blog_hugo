+++
title = "Ejercicios de Anisble con vagrant"
description = ""
tags = [
    "SRI"
]
date = "2022-06-18"
menu = "main"
+++

### Ejercicio 1

* [repositorio](https://github.com/alepeteporico/ejercicos_ansible/tree/main/ejercicio1) del ansible

* Salida de la ejecución del playbook.

~~~
alejandrogv@AlejandroGV:~/vagrant/servicios/ejercicios_ansible/ejercicio1$ ansible-playbook site.yaml 
[WARNING]: Found both group and host with same name: ejercicio1

PLAY [ejercicio1] ***************************************************************************************

TASK [Gathering Facts] **********************************************************************************
ok: [ejercicio1]

TASK [Crear usuario alejandro] **************************************************************************
ok: [ejercicio1]

TASK [Descarga latest.zip] ******************************************************************************
ok: [ejercicio1]

TASK [Actualización] ************************************************************************************
ok: [ejercicio1]

TASK [Instala los paquetes necesarios] ******************************************************************
ok: [ejercicio1]

TASK [Descomprime latest.zip] ***************************************************************************
ok: [ejercicio1]

TASK [Crear una base de datos] **************************************************************************
ok: [ejercicio1]

TASK [Crear usuario de la bd] ***************************************************************************
changed: [ejercicio1]

TASK [Clonar repositorio github] ************************************************************************
changed: [ejercicio1]

PLAY RECAP **********************************************************************************************
ejercicio1                 : ok=9    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
~~~

### Ejercicio 2

* Vagrantfile del escenario

~~~
Vagrant.configure("2") do |config|
    config.vm.define :router do |router|
        router.vm.box = "debian/bullseye64"
        router.vm.hostname = "router"
        router.vm.synced_folder ".", "/vagrant", disabled: true
        router.vm.network :public_network,
          :dev => "br0",
          :mode => "bridge",
          :type => "bridge"
        router.vm.network :private_network,
          :libvirt__network_name => "ansible2",
          :libvirt__dhcp_enabled => false,
          :ip => "10.0.0.1",
          :libvirt__forward_mode => "veryisolated"
    end
    config.vm.define :cliente do |cliente|
      cliente.vm.box = "debian/bullseye64"
      cliente.vm.hostname = "backend1"
      cliente.vm.synced_folder ".", "/vagrant", disabled: true
      cliente.vm.network :private_network,
        :libvirt__network_name => "ansible2",
        :libvirt__dhcp_enabled => false,
        :ip => "10.0.0.2",
        :libvirt__forward_mode => "veryisolated"
    end
end
~~~

* Comprobación de que se pueden hacer ping.

~~~
vagrant@router:~$ ping 10.0.0.2
PING 10.0.0.2 (10.0.0.2) 56(84) bytes of data.
64 bytes from 10.0.0.2: icmp_seq=1 ttl=64 time=1.21 ms
64 bytes from 10.0.0.2: icmp_seq=2 ttl=64 time=0.633 ms
^C
--- 10.0.0.2 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 0.633/0.923/1.214/0.290 ms
~~~

### Ejercicio 3

* Comprobacion que cliente tiene acceso a internet haciendo ping a un nombre de una página web. Asegurate que no está saliendo por eth0 (muestra las rutas).

~~~
vagrant@backend1:~$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=113 time=42.6 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=113 time=43.0 ms
^C
--- 8.8.8.8 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 42.641/42.814/42.988/0.173 ms
vagrant@backend1:~$ ip r
default via 10.0.0.1 dev eth1 onlink 
10.0.0.0/24 dev eth1 proto kernel scope link src 10.0.0.2 
192.168.121.0/24 dev eth0 proto kernel scope link src 192.168.121.141
~~~

* Entrega una captura de pantalla accediendo por ssh a las dos máquinas. Configura el sistema para que podamos acceder acceder a las máquinas por ssh.

~~~
alejandrogv@AlejandroGV:~$ ssh -A vagrant@192.168.121.31
The authenticity of host '192.168.121.31 (192.168.121.31)' can't be established.
ECDSA key fingerprint is SHA256:BiRfF41Pfbq7zDdL+xYKeaSCClt1Fi8Ahx9xARAfIt8.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Failed to add the host to the list of known hosts (/home/alejandrogv/.ssh/known_hosts).
Linux router 5.10.0-13-amd64 #1 SMP Debian 5.10.106-1 (2022-03-17) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Mon Jun 20 10:50:41 2022 from 192.168.121.1
vagrant@router:~$ ssh vagrant@10.0.0.2
The authenticity of host '10.0.0.2 (10.0.0.2)' can't be established.
ECDSA key fingerprint is SHA256:umJF5Ck6/7dibTStEk/ZQyiPaOYEXROfe7CNFEmVt44.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '10.0.0.2' (ECDSA) to the list of known hosts.
Linux backend1 5.10.0-13-amd64 #1 SMP Debian 5.10.106-1 (2022-03-17) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Mon Jun 20 10:52:38 2022 from 192.168.121.1
vagrant@backend1:~$ 
~~~

* [repositorio](https://github.com/alepeteporico/ejercicos_ansible/tree/main/ejercicio3) del ansible
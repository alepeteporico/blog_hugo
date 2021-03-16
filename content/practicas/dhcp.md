+++
title = "Servidor DHCP"
description = ""
tags = [
    "SRI"
]
date = "2021-03-16"
menu = "main"
+++

* Lee el documento Teoría: Servidor DHCP y explica el funcionamiento del servidor DHCP resumido en este gráfico.

**En primer lugar el cliente manda una petición para ver si hay un servidor DHCP que pueda darle una dirección.**

**El servidor reciviría esa petición y le dice al cliente que hay un servidor DHCP y puede ofrecerle una IP, por tanto el cliente pide una IP al servidor.**

**Por último el servidor al recibir esa última petición le concede una IP dentro de su rango.**

* Entrega el fichero Vagrantfile que define el escenario.

        Vagrant.configure("2") do |config|
          config.vm.define :servidor do |servidor|
            servidor.vm.box = "debian/buster64"
            servidor.vm.hostname = "servidor"
            servidor.vm.network "public_network",:bridge=>"enp2s0"
            servidor.vm.network "private_network", ip: "192.168.100.1",
              virtualbox__intnet: "interna"
          end
          config.vm.define :nodo_lan1 do |nodo_lan1|
            nodo_lan1.vm.box = "debian/buster64"
            nodo_lan1.vm.hostname = "nodolan1"
            nodo_lan1.vm.network "private_network", type: "dhcp",
              virtualbox__intnet: "interna"
          end
        end     


* Muestra el fichero de configuración del servidor, la lista de concesiones, la modificación en la configuración que has hecho en el cliente para que tome la configuración de forma automática y muestra la salida del comando ` ip address`.

**Instalamos el servidor dhcp:**

    sudo apt install isc-dhcp-server


**Configuramos el fichero "/etc/default/isc-dhcp-server" y añadimos en INTERFACESv4 la eth2 que es la tarjeta privada.**

    vagrant@servidor:~$ cat /etc/default/isc-dhcp-server 
    # Defaults for dhcp initscript
    # sourced by /etc/init.d/dhcp
    # installed at /etc/default/isc-dhcp-server by the maintainer scripts
    #
    # This is a POSIX shell fragment
    #
    # On what interfaces showld the DHCP server (dhcpd) serve DHCP requests?
    # Separate multiple interfaces with spaces, e.g. "eh0 eth1".
    INTERFACES="eth2"


**Configuramos el fichero "/etc/dhcp/dhcpd.conf", he modificado el max-lease-time y el default-lease-time para que el tiempo de concesión sea de 12 horas, después hemos especificado las direcciones de subnet y el rango de ips que queremos.**

    subnet 192.168.100.0 netmask 255.255.255.0 {
      range 192.168.100.2 192.168.100.253;
      option domain-name-servers 8.8.8.8, 8.8.4.4;
      option domain-name "servidor.interno";
      option routers 192.168.100.1;
      option broadcast-address 192.168.100.253;
      default-lease-time 43200;
      max-lease-time 43200;
    }


**Después de reiniciar el servicio vemos la salida del comando ip**

    vagrant@servidor:~$ ip a
    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
        inet 127.0.0.1/8 scope host lo
           valid_lft forever preferred_lft forever
        inet6 ::1/128 scope host 
           valid_lft forever preferred_lft forever
    2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
        link/ether 08:00:27:8d:c0:4d brd ff:ff:ff:ff:ff:ff
        inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic eth0
           valid_lft 85566sec preferred_lft 85566sec
        inet6 fe80::a00:27ff:fe8d:c04d/64 scope link 
           valid_lft forever preferred_lft forever
    3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
        link/ether 08:00:27:b5:11:a3 brd ff:ff:ff:ff:ff:ff
        inet 192.168.1.124/24 brd 192.168.1.255 scope global dynamic eth1
           valid_lft 85587sec preferred_lft 85587sec
        inet6 fe80::a00:27ff:feb5:11a3/64 scope link 
           valid_lft forever preferred_lft forever
    4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
        link/ether 08:00:27:06:d7:88 brd ff:ff:ff:ff:ff:ff
        inet 192.168.100.1/24 brd 192.168.100.255 scope global eth2
           valid_lft forever preferred_lft forever
        inet6 fe80::a00:27ff:fe06:d788/64 scope link 
           valid_lft forever preferred_lft forever


* Configura el servidor para que funcione como router y NAT, de esta forma los clientes tengan internet. Muestra las rutas por defecto del servidor y el cliente. Realiza una prueba de funcionamiento para comprobar que el cliente tiene acceso a internet (utiliza nombres, para comprobar que tiene resolución DNS).

**Ahora debemos configurar esta máquina servidor para que actue como router, para ello descomentaremos la siguiente línea del fichero "/etc/sysctl.conf":**

    # Uncomment the next line to enable packet forwarding for IPv4
    net.ipv4.ip_forward=1


**Para configurar NAT en nuestro servidor debemos modificar el fichero "/etc/network/interfaces" y añadir la siguiente línea:**

    up iptables -t nat -A POSTROUTING -s 192.168.100.0/24 -o eth1 -j MASQUERADE


**Después de reiniciar el servicio de red nuestro siguiente paso deberá ser configurar las rutas de nuestras máquinas, primero hay que borrar la default via, para ello veremos la tabla de enrutamiento con el comando ip r:**

    vagrant@servidor:~$ ip r
    default via 10.0.2.2 dev eth0 
    10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 
    192.168.1.0/24 dev eth1 proto kernel scope link src 192.168.1.124 
    192.168.100.0/24 dev eth2 proto kernel scope link src 192.168.100.1


**Borrariamos el default via con el siguiente comando:**

    vagrant@servidor:~$ sudo ip route del default via 10.0.2.2 dev eth0


**Y añadiriamos una nueva con el siguiente:**

    vagrant@servidor:~$ sudo ip route add default via 192.168.1.1 dev eth1


**Volvemos a comprobar el comando ip r y veremos que el default via ha cambiado:**

    vagrant@servidor:~$ ip r
    default via 192.168.1.1 dev eth1 
    10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 
    192.168.1.0/24 dev eth1 proto kernel scope link src 192.168.1.124 
    192.168.100.0/24 dev eth2 proto kernel scope link src 192.168.100.1


**Realizaremos el mismo proceso con la tabla de enrutamiento en el cliente:**

    vagrant@nodolan1:~$ ip r
    default via 10.0.2.2 dev eth0 
    10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 
    192.168.100.0/24 dev eth1 proto kernel scope link src 192.168.100.2


    vagrant@nodolan1:~$ sudo ip route del default via 10.0.2.2 dev eth0


    vagrant@nodolan1:~$ sudo ip route add default via 192.168.100.1 dev eth1


    vagrant@nodolan1:~$ ip r
    default via 192.168.100.1 dev eth1 
    10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 
    192.168.100.0/24 dev eth1 proto kernel scope link src 192.168.100.2


**Hacemos ping a www.google.es y con su funcionamiento comprobaremos que tenemos salida a internet y resuelve nombres de dominio.**

    vagrant@nodolan1:~$ ping www.google.es
    PING www.google.es (216.58.201.163) 56(84) bytes of data.
    64 bytes from mad08s06-in-f3.1e100.net (216.58.201.163): icmp_seq=1 ttl=63 time=9.58 ms
    64 bytes from mad08s06-in-f3.1e100.net (216.58.201.163): icmp_seq=2 ttl=63 time=9.54 ms


* Realizar una captura, desde el servidor usando tcpdump, de los cuatro paquetes que corresponden a una concesión: DISCOVER, OFFER, REQUEST, ACK.

**Dejaremos el siguiente comando ejecutandose en el servidor para realizar la captura de tcpdump:**

    vagrant@servidor:~$ sudo tcpdump -i eth2 port 67 or port 68


**Mientras tanto en el cliente pediremos que se nos renueve la concesión, debemos eliminar la que ya tenemos y pedir una nueva:**

    vagrant@nodolan1:~$ sudo dhclient -r && sudo dhclient

**La salida de tcpdump sería la siguiente:**

    18:08:06.054194 IP 192.168.100.3.bootpc > 192.168.100.1.bootps: BOOTP/DHCP, Request from 08:00:27:2a:11:2b (oui Unknown), length 300
    18:08:06.140538 IP 0.0.0.0.bootpc > 255.255.255.255.bootps: BOOTP/DHCP, Request from 08:00:27:2a:11:2b (oui Unknown), length 300
    18:08:07.150812 IP 192.168.100.1.bootps > 192.168.100.3.bootpc: BOOTP/DHCP, Reply, length 302
    18:08:07.151785 IP 0.0.0.0.bootpc > 255.255.255.255.bootps: BOOTP/DHCP, Request from 08:00:27:2a:11:2b (oui Unknown), length 300
    18:08:07.154588 IP 192.168.100.1.bootps > 192.168.100.3.bootpc: BOOTP/DHCP, Reply, length 302

**La primera línea captura el dhcp discover.**

**En la segunda línea puede verse como el servidor responde a petición con un dhcp offer.**

**En la tercera se realiza la petición del cliente al servidor con un dhcp request.**

**Y por úlitmo se realiza la concesión al cliente mediante el paquete dhcp ack.**

* Los clientes toman una configuración, y a continuación apagamos el servidor dhcp. ¿qué ocurre con el cliente windows? ¿Y con el cliente linux?

https://www.youtube.com/watch?v=XBQpHuai3RA&feature=youtu.be

* Indica las modificaciones realizadas en los ficheros de configuración y entrega una comprobación de que el cliente ha tomado esa dirección.

**Para crear una reserva debemos añadir lo siguiente al fichero /etc/dhcp/dhcpd.conf**

    host nodolan {
    hardware ethernet 08:00:27:2a:11:2b;
    fixed-address 192.168.100.100;
    }

**Reiniciamos el servicio dhcp y cuando pase el tiempo de concesión o al pedir una nueva ip veremos que cambia la IP de nuestro cliente:**

    3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
        link/ether 08:00:27:2a:11:2b brd ff:ff:ff:ff:ff:ff
        inet 192.168.100.100/24 brd 192.168.100.253 scope global dynamic eth1
           valid_lft 23sec preferred_lft 23sec
        inet6 fe80::a00:27ff:fe2a:112b/64 scope link 
           valid_lft forever preferred_lft forever

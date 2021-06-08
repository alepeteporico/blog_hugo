+++
title = "Cortafuegos - OpenStack"
description = ""
tags = [
    "SAD"
]
date = "2021-06-07"
menu = "main"
+++

* Nuestro primer paso será instalar nftables.

        debian@dulcinea:~$ sudo apt install nftables

* Activamos y habilitamos este servicio.

        debian@dulcinea:~$ sudo systemctl start nftables
        debian@dulcinea:~$ sudo systemctl enable nftables

* Configuraremos la política por defecto a DROP.

        nft chain inet filter input { policy drop \; }
        nft chain inet filter forward { policy drop \; }
        nft chain inet filter output { policy drop \; }

* Añadimos las reglas de NAT.

        root@dulcinea:~# nft add table nat
        root@dulcinea:~# nft add chain nat postrouting { type nat hook postrouting priority 100 \; }
        root@dulcinea:~# nft add rule ip nat postrouting oifname "eth0" ip saddr 10.0.1.0/24 counter snat to 10.0.0.6
        root@dulcinea:~# nft add rule ip nat postrouting oifname "eth0" ip saddr 10.0.2.0/24 counter snat to 10.0.0.6

* También necesitaremos configurar las reglas dnat para que los servicios de DNS, http y https salgan al exterior.

        root@dulcinea:~# nft add chain nat prerouting { type nat hook prerouting priority 0 \; }
        root@dulcinea:~# nft add rule ip nat prerouting iifname "eth0" udp dport 53 counter dnat to 10.0.1.9
        root@dulcinea:~# nft add rule ip nat prerouting iifname "eth0" tcp dport 80 counter dnat to 10.0.2.5
        root@dulcinea:~# nft add rule ip nat prerouting iifname "eth0" tcp dport 443 counter dnat to 10.0.2.5

* Añadiremos una regla para que las máquinas de nuestra red interna puedan hacerse ping a la DMZ.

        debian@dulcinea:~$ sudo nft add rule inet filter forward ip saddr 10.0.1.0/24 iifname "eth1" ip daddr 10.0.2.0/24 oifname "eth2" icmp type echo-request counter accept

        debian@dulcinea:~$ sudo nft add rule inet filter forward ip saddr 10.0.2.0/24 iifname "eth2" ip daddr 10.0.1.0/24 oifname "eth1" icmp type echo-reply counter accept

* Vamos a comprobarlo.

        ubuntu@sancho:~$ ping 10.0.2.5
        PING 10.0.2.5 (10.0.2.5) 56(84) bytes of data.
        64 bytes from 10.0.2.5: icmp_seq=1 ttl=63 time=2.77 ms
        ^C
        --- 10.0.2.5 ping statistics ---
        1 packets transmitted, 1 received, 0% packet loss, time 0ms
        rtt min/avg/max/mdev = 2.770/2.770/2.770/0.000 ms

* También configuraremos lo contrario, desde la DMZ se podrá hacer ping a la red interna.

        debian@dulcinea:~$ sudo nft add rule inet filter forward ip saddr 10.0.2.0/24 iifname "eth2" ip daddr 10.0.1.0/24 oifname "eth1" icmp type echo-request counter accept
        debian@dulcinea:~$ sudo nft add rule inet filter forward ip saddr 10.0.2.0/24 iifname "eth2" ip daddr 10.0.1.0/24 oifname "eth1" icmp type echo-request counter accept


* Comprobemoslo.

        [centos@quijote ~]$ ping 10.0.1.6
        PING 10.0.1.6 (10.0.1.6) 56(84) bytes of data.
        64 bytes from 10.0.1.6: icmp_seq=1 ttl=63 time=1.56 ms
        ^C64 bytes from 10.0.1.6: icmp_seq=2 ttl=63 time=1.84 ms

        --- 10.0.1.6 ping statistics ---
        2 packets transmitted, 2 received, 0% packet loss, time 3ms
        rtt min/avg/max/mdev = 1.556/1.699/1.843/0.149 ms

* Y también podrán hacer ping al exterior.

        debian@dulcinea:~$ sudo nft add rule inet filter forward ip saddr 10.0.1.0/24 iifname "eth1" oifname "eth0" icmp type echo-request counter accept
        debian@dulcinea:~$ sudo nft add rule inet filter forward ip daddr 10.0.1.0/24 iifname "eth0" oifname "eth1" icmp type echo-reply counter accept

        debian@dulcinea:~$ sudo nft add rule inet filter forward ip saddr 10.0.2.0/24 iifname "eth2" oifname "eth0" icmp type echo-request counter accept
        debian@dulcinea:~$ sudo nft add rule inet filter forward ip daddr 10.0.2.0/24 iifname "eth0" oifname "eth2" icmp type echo-reply counter accept

* Vamos a realizar las pruebas.

        ubuntu@sancho:~$ ping 8.8.8.8
        PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
        64 bytes from 8.8.8.8: icmp_seq=1 ttl=111 time=42.5 ms
        64 bytes from 8.8.8.8: icmp_seq=2 ttl=111 time=43.1 ms
        ^C
        --- 8.8.8.8 ping statistics ---
        2 packets transmitted, 2 received, 0% packet loss, time 1002ms
        rtt min/avg/max/mdev = 42.471/42.762/43.053/0.291 ms

* Y también debemos permitirselo a Dulciena.

        debian@dulcinea:~$ sudo nft add rule inet filter input iifname "eth0" icmp type echo-request counter accept
        debian@dulcinea:~$ sudo nft add rule inet filter output oifname "eth0" icmp type echo-reply counter accept

* 
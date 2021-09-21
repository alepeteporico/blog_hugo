+++
title = "Instalación de debian 11 con LVM"
description = ""
tags = [
    "SO"
]
date = "2021-09-16"
menu = "main"
+++

---


* Empezamos la instalación y seguimos todos los pasos normalmente hasta llegar a la configuración de los discos, la haremos manualmente y en mi caso he creado una máquina virtual para simular lo que hice en mi máquina anfitriona, para ello he creado una partición sin usar simulando que tengo en ella una partición con Windows 10.

![](/instalacion/1.png)

* Seguidamente elegiremos la opción de "Configurar el gestor de volúmenes lógicos" y crearemos un grupo de volúmenes.

![](/instalacion/2.png)

* Elegimos el espacio libre que teníamos en el disco, este será nuestro grupo de volúmenes, aunque podríamos primero particionar este espacio libre y después crear un grupo de volúmenes con estas particiones, nosotros lo haremos al revés.

![](/instalacion/3.png)

* Ahora dentro de este grupo de volúmenes crearemos de volúmenes lógicos, uno para el sistema y otro para la SWAP

![](/instalacion/9.png)

![](/instalacion/4.png)

* Tenemos creados los volúmenes lógicos como hemos visto en la anterior captura, pero debemos asignarle para  que la usaremos y donde las montaremos.

![](/instalacion/5.png)

![](/instalacion/6.png)

![](/instalacion/7.png)

* Una vez hecho esto ya tendremos configurado LVM en nuestro sistema como queremos, no hemos usado todo el espacio que teníamos, por lo que mas tarde  podremos aumentar el tamaño de alguno de los volúmenes.

![](/instalacion/8.png)

* Seguiremos la instalación con normalidad y arrancaremos nuestro debian buster, en mi caso tuve un problema que al parecer es muy común. Al arrancar llegaba un momento en que el sistema dejaba de responder, aparecía una pantalla en negro con el cursor arriba a la izquierda, sin posibilidad de hacer nada. Para arreglarlo entre en modo recovery y deshabilite los drivers de nouveau, que al parecer daban conflicto. para hacerlo modifique el fichero "/etc/default/grub" y modificaremos las dos líneas que vemos a continuación tal y como aparecen.

        GRUB_CMDLINE_LINUX_DEFAULT="nouveau.modeset=0"
        GRUB_CMDLINE_LINUX="nouveau.modeset=0"

* Con este cambio ya arrancará nuestro sistema con normalidad y podremos acceder al entorno gráfico, nuestra primera tarea dentro de el será instalar el firmware de la tarjeta inalámbrica, la cual al principio de la instalación nos advirtió que no se instalarían, aquí vemos la imagen.

![](/instalacion/11.png)

* Para instalarlo deberemos añadir en el fichero sources.list los repositorios de backports e instalar el firmware que corresponde con el siguiente comando.

        apt -t buster-backports install firmware-iwlwifi

* Vamos a comprobar ahora dentro de nuestro sistema que se han creado bien el volumnen de grupo y los volumenes lógicos que creamos durante la instalación.

        alejandrogv@AlejandroGV:~$ sudo lvdisplay
        [sudo] password for alejandrogv: 
          --- Logical volume ---
          LV Path                /dev/debian/sistema
          LV Name                sistema
          VG Name                debian
          LV UUID                Unl5nE-NC34-bTKL-p8vd-oJ2O-DbMZ-JBVcy2
          LV Write Access        read/write
          LV Creation host, time AlejandroGV, 2020-09-21 12:31:54 +0200
          LV Status              available
          # open                 1
          LV Size                240,73 GiB
          Current LE             61628
          Segments               2
          Allocation             inherit
          Read ahead sectors     auto
          - currently set to     256
          Block device           254:0
        
          --- Logical volume ---
          LV Path                /dev/debian/SWAP
          LV Name                SWAP
          VG Name                debian
          LV UUID                ZmBsPh-u7wQ-t5c4-JbSE-x8gx-LKT1-Fjk9eM
          LV Write Access        read/write
          LV Creation host, time AlejandroGV, 2020-09-21 12:32:38 +0200
          LV Status              available
          # open                 2
          LV Size                <8,01 GiB
          Current LE             2050
          Segments               1
          Allocation             inherit
          Read ahead sectors     auto
          - currently set to     256
          Block device           254:1
        
          --- Logical volume ---
          LV Path                /dev/debian/extra
          LV Name                extra
          VG Name                debian
          LV UUID                0A0ORH-z5wS-3API-P2W1-fvCb-MwzX-YXqeSm
          LV Write Access        read/write
          LV Creation host, time AlejandroGV, 2020-09-23 08:47:44 +0200
          LV Status              available
          # open                 0
          LV Size                19,07 GiB
          Current LE             4882
          Segments               1
          Allocation             inherit
          Read ahead sectors     auto
          - currently set to     256
          Block device           254:2
        
        alejandrogv@AlejandroGV:~$ sudo vgdisplay
          --- Volume group ---
          VG Name               debian
          System ID             
          Format                lvm2
          Metadata Areas        1
          Metadata Sequence No  5
          VG Access             read/write
          VG Status             resizable
          MAX LV                0
          Cur LV                3
          Open LV               2
          Max PV                0
          Cur PV                1
          Act PV                1
          VG Size               379,55 GiB
          PE Size               4,00 MiB
          Total PE              97166
          Alloc PE / Size       68560 / 267,81 GiB
          Free  PE / Size       28606 / 111,74 GiB
          VG UUID               Yf5ekK-GyCd-6BbU-5nft-FWZ4-uVGE-OMxO6J

* Aparentemente solo faltarían dos cosas por estar a punto, los controladores de la GPU Nvidia y la configuración del network manager. Veamos que le ocurría a network manager, este parecía estar deshabilitado. Aunque el equipo tenía conexión el error exacto que daba network manager era "cableado sin gestionar" y en efecto no podía gestionarse nada desde network manager. Para solucionar el problema debemos editar el fichero "/etc/NetworkManager/NetworkManager.conf" y cambiar a true la opción managed. Una vez hecho esto reiniciamos el servicio y podremos comprobar que todo funciona correctamente.

        [main]
        plugins=ifupdown,keyfile

        [ifupdown]
        managed=true

* Por último tenemos los drivers de la gráfica, el primer paso para su instalación será añadir al fichero `/etc/apt/sources.list` los repositorios non-free y los backports, vamos a visualizar como quedaría este fichero.

        deb https://deb.debian.org/debian/ bullseye main contrib non-free
        # deb-src http://deb.debian.org/debian/ buster main

        #deb http://security.debian.org/debian-security buster/updates main
        # deb-src http://security.debian.org/debian-security buster/updates main

        # buster-updates, previously known as 'volatile'
        deb https://deb.debian.org/debian/ bullseye-updates main contrib non-free
        # deb-src http://deb.debian.org/debian/ buster-updates main

        deb https://deb.debian.org/debian/ bullseye-backports main contrib non-free

* Ahora actualizamos e instalamos el paquete `nvidia-detect`

        alejandrogv@AlejandroGV:~$ sudo apt install nvidia-detect

* Vamos a visualizar la salida de este comando que nos dirá que paquete o paquetes debemos instalar para el correcto funcionamiento de nuestra gráfica.

        alejandrogv@AlejandroGV:~$ nvidia-detect 
        Detected NVIDIA GPUs:
        01:00.0 3D controller [0302]: NVIDIA Corporation GP107M [GeForce GTX 1050 Mobile] [10de:1c8d] (rev a1)

        Checking card:  NVIDIA Corporation GP107M [GeForce GTX 1050 Mobile] (rev a1)
        Your card is supported by all driver versions.
        Your card is also supported by the Tesla 460 drivers series.
        Your card is also supported by the Tesla 450 drivers series.
        Your card is also supported by the Tesla 418 drivers series.
        It is recommended to install the
            nvidia-driver
        package.

* Vamos a instalar el paquete que se nos recomienda de `nvidia-driver` y a reiniciar el sistema para que inicie con la nueva configuración.

        alejandrogv@AlejandroGV:~$ sudo apt install nvidia-driver

* Una vez reiniciado el sistema podemos usar el comando `nvidia-settings` que abrirá una ventana donde podremos comprobar que nuestro sistema reconoce nuestra tarjeta gráfica.

![](/instalacion/14.png)

* Veamos todos los dispositivos que tenemos conectados y nuestro sitema reconoce.
        
        alejandrogv@AlejandroGV:~$ sudo lshw -short
        [sudo] password for alejandrogv: 
        H/W path           Device           Class          Description
        ==============================================================
                                            system         TUF GAMING FX504GD_FX80GD
        /0                                  bus            FX504GD
        /0/0                                memory         64KiB BIOS
        /0/3a                               memory         8GiB System Memory
        /0/3a/0                             memory         8GiB SODIMM DDR4 Synchronous 2667 MHz (0,4 ns)
        /0/3a/1                             memory         [empty]
        /0/3a/2                             memory         [empty]
        /0/3a/3                             memory         [empty]
        /0/45                               memory         384KiB L1 cache
        /0/46                               memory         1536KiB L2 cache
        /0/47                               memory         9MiB L3 cache
        /0/48                               processor      Intel(R) Core(TM) i7-8750H CPU @ 2.20GHz
        /0/100                              bridge         8th Gen Core Processor Host Bridge/DRAM Registers
        /0/100/1                            bridge         6th-10th Gen Core Processor PCIe Controller (x16)
        /0/100/1/0                          display        GP107M [GeForce GTX 1050 Mobile]
        /0/100/2                            display        CoffeeLake-H GT2 [UHD Graphics 630]
        /0/100/4                            generic        Xeon E3-1200 v5/E3-1500 v5/6th Gen Core Processor Ther
        /0/100/8                            generic        Xeon E3-1200 v5/v6 / E3-1500 v5 / 6th/7th/8th Gen Core
        /0/100/12                           generic        Cannon Lake PCH Thermal Controller
        /0/100/14                           bus            Cannon Lake PCH USB 3.1 xHCI Host Controller
        /0/100/14/0        usb1             bus            xHCI Host Controller
        /0/100/14/0/3                       input          USB Optical Mouse
        /0/100/14/0/7                       multimedia     USB2.0 HD UVC WebCam
        /0/100/14/0/e                       communication  Bluetooth 9460/9560 Jefferson Peak (JfP)
        /0/100/14/1        usb2             bus            xHCI Host Controller
        /0/100/14.2                         memory         RAM memory
        /0/100/14.3        wlo1             network        Wireless-AC 9560 [Jefferson Peak]
        /0/100/15                           bus            Cannon Lake PCH Serial IO I2C Controller #0
        /0/100/16                           communication  Cannon Lake PCH HECI Controller
        /0/100/17          scsi4            storage        Cannon Lake Mobile PCH SATA AHCI Controller
        /0/100/17/0.0.0    /dev/sda         disk           1TB ST1000LM035-1RK1
        /0/100/17/0.0.0/1  /dev/sda1        volume         449MiB Windows NTFS volume
        /0/100/17/0.0.0/2  /dev/sda2        volume         99MiB Windows FAT volume
        /0/100/17/0.0.0/3  /dev/sda3        volume         15MiB reserved partition
        /0/100/17/0.0.0/4  /dev/sda4        volume         550GiB Windows NTFS volume
        /0/100/17/0.0.0/5  /dev/sda5        volume         845MiB Windows NTFS volume
        /0/100/17/0.0.0/6  /dev/sda6        volume         379GiB LVM Physical Volume
        /0/100/1d                           bridge         Cannon Lake PCH PCI Express Root Port #15
        /0/100/1d/0        enp2s0           network        RTL8111/8168/8411 PCI Express Gigabit Ethernet Control
        /0/100/1f                           bridge         HM470 Chipset LPC/eSPI Controller
        /0/100/1f.3                         multimedia     Cannon Lake PCH cAVS
        /0/100/1f.4                         bus            Cannon Lake PCH SMBus Controller
        /0/100/1f.5                         bus            Cannon Lake PCH SPI Controller
        /0/1                                system         PnP device PNP0c02
        /0/2                                system         PnP device PNP0b00
        /0/3                                generic        PnP device INT3f0d
        /0/4                                input          PnP device PNP0303
        /0/5                                system         PnP device PNP0c02
        /0/6                                system         PnP device PNP0c02
        /0/7                                system         PnP device PNP0c02
        /0/8                                system         PnP device PNP0c02
        /1                                  power          To Be Filled By O.E.M.
        /2                 docker0          network        Ethernet interface
        /3                 br-e810e8ffd8ef  network        Ethernet interface
        /4                 br-36e9732e1158  network        Ethernet interface
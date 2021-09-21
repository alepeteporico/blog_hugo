+++
title = "Módulo de Vbox no carga con el kernel"
description = ""
tags = [
    "Vbox"
]
date = "2021-04-04"
menu = "main"
+++

* Al intentar encender una máquina vagrant o en Vbox nos da un fallo:

        alejandrogv@AlejandroGV:~/vagrant/servicios/dhcp$ vagrant up
        The provider 'virtualbox' that was requested to back the machine
        'servidor' is reporting that it isn't usable on this system. The
        reason is shown below:

        VirtualBox is complaining that the kernel module is not loaded. Please
        run `VBoxManage --version` or open the VirtualBox GUI to see the error
        message which should contain instructions on how to fix this error.

* Aunque ejecutemos el comando que se nos indica caundo ejecutamos `VBoxManage --version` podría ser que nos apareciera el siguente mensaje:

        alejandrogv@AlejandroGV:~/vagrant/servicios/dhcp$ sudo /sbin/rcvboxdrv setup
        [sudo] password for alejandrogv: 
        vboxdrv.sh: Stopping VirtualBox services.
        vboxdrv.sh: Starting VirtualBox services.
        vboxdrv.sh: Building VirtualBox kernel modules.
        This system is currently not set up to build kernel modules.
        Please install the Linux kernel "header" files matching the current kernel
        for adding new hardware support to the system.
        The distribution packages containing the headers are probably:
            linux-headers-amd64 linux-headers-4.19.0-16-amd64

* Instalariamos los headers que se nos indican. El problema erradicaba en estos headers, quizás hayamos trasteado con el kernel y aunque hubiera sido hace tiempo y hayamos usado con normalidad Vbox después de haberlo hecho quizás una actualización haya desconfigurado algo. Después de tener instalados los headers de nuestro kernel volvemos a ejecutar el comando anterior.

        alejandrogv@AlejandroGV:~/vagrant/servicios/dhcp$ sudo /sbin/rcvboxdrv setup
        vboxdrv.sh: Stopping VirtualBox services.
        vboxdrv.sh: Starting VirtualBox services.
        vboxdrv.sh: Building VirtualBox kernel modules.

* Después de esto no deberíamos tener mas problemas.
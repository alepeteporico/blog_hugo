+++
title = "Recolección de logs mediante journald"
description = ""
tags = [
    "ASO"
]
date = "2022-02-04"
menu = "main"
+++

* Vamos a usar el paquete `systemd-journal-remote` primero deberemos instalarlo en nuestro servidor principal, hemos escogido zeus y también deberemos instalarlo en nuestros clientes.

~~~
debian@zeus:~$ sudo apt install systemd-journal-remote
~~~

* Vamos a habilitar dos componentes de systemd necesarios para recibir los logs.

~~~
debian@zeus:~$ sudo systemctl enable --now systemd-journal-remote.socket
Created symlink /etc/systemd/system/sockets.target.wants/systemd-journal-remote.socket -> /lib/systemd/system/systemd-journal-remote.socket.

debian@zeus:~$ sudo systemctl enable systemd-journal-remote.service
~~~

* Y en los clientes también debemos habilitar uno.

~~~
[hera@hera ~]$ sudo systemctl enable systemd-journal-upload.service
~~~

* Si tuvieramos un cortafuegos deberiamos abrir los puertos 80 y 19532.

* El siguiente paso será instalar una serie de certificados ya que lo usaremos para la comunicación entre las máquinas. Para ello usaremos la herramienta certbot

~~~
debian@apolo:~$ sudo apt install certbot
~~~

* 
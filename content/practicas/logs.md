+++
title = "Recolección de logs mediante journald"
description = ""
tags = [
    "ASO"
]
date = "2022-02-04"
menu = "main"
+++

* Vamos a usar el paquete `systemd-journal-remote` primero deberemos instalarlo en nuestro servidor principal, hemos escogido ares y también deberemos instalarlo en nuestros clientes.

~~~
usuario@ares:~$ sudo apt install systemd-journal-remote
~~~

* Vamos a habilitar dos componentes de systemd necesarios para recibir los logs.

~~~
usuario@ares:~$ sudo systemctl enable --now systemd-journal-remote.socket
Created symlink /etc/systemd/system/sockets.target.wants/systemd-journal-remote.socket -> /lib/systemd/system/systemd-journal-remote.socket.

usuario@ares:~$ sudo systemctl enable systemd-journal-remote.service
~~~

* Y en los clientes también debemos habilitar uno.

~~~
[hera@hera ~]$ sudo systemctl enable systemd-journal-upload.service
~~~

* Si tuvieramos un cortafuegos deberiamos abrir los puertos 80 y 19532.

* Vamos a configurar este servicio, copiaremos y modificaremos el fichero `/lib/systemd/system/systemd-journal-remote.service` a `/etc/systemd/system/`

~~~
usuario@ares:~$ sudo cp /lib/systemd/system/systemd-journal-remote.service /etc/systemd/system/
~~~

~~~
[Unit]
Description=Journal Remote Sink Service
Documentation=man:systemd-journal-remote(8) man:journal-remote.conf(5)
Requires=systemd-journal-remote.socket

[Service]
ExecStart=/lib/systemd/systemd-journal-remote --listen-http=-3 --output=/var/log/journal/remote/
User=systemd-journal-remote
Group=systemd-journal-remote
PrivateTmp=yes
PrivateDevices=yes
PrivateNetwork=yes
WatchdogSec=3min

# If there are many split up journal files we need a lot of fds to access them
# all in parallel.
#LimitNOFILE=524288

[Install]
Also=systemd-journal-remote.socket
~~~

* Aquí entre otras cosas, hemos configurado por ejemplo el tiempo entre peticiones de recolección y donde se guardarán, si no está creada la carpeta debemos hacerlo y darle los permisos adecuados.

~~~
usuario@ares:~$ sudo mkdir /var/log/journal/remote
usuario@ares:~$ sudo chown systemd-journal-remote /var/log/journal/remote
~~~

## Clientes

* Nos dirigimos a los clientes y lo primero que debemos hacer en cada uno de ellos es crear un usuario llamado systemd-journal-upload

* Debian/Ubuntu:

~~~
root@zeus:~# adduser --system --home /run/systemd --no-create-home --disabled-login --group systemd-journal-upload
~~~

* Rocky:

~~~
[usuario@hera ~]$ sudo adduser --system --home /run/systemd --no-create-home --user-group systemd-journal-upload
~~~

* Vamos ahora a realizar la configuración del fichero `/etc/systemd/journal-upload.conf`.

~~~
[Upload]
URL= http://ares.alexgv.gonzalonazareno.org:19532
~~~

* Comprobamos que funciona y nos crea los logs.

~~~
usuario@ares:~$ sudo ls /var/log/journal/remote/
remote-10.0.1.102@2bc4c2351838445f94e4412a3b4cc6ae-0000000000000001-0005d6317eedcd10.journal
remote-10.0.1.102.journal
remote-10.0.1.1@7842b9b73d4641e7b4acdba2cc86b03c-0000000000000001-0005d6317eedcd10.journal
remote-10.0.1.1.journal
remote-172.16.0.200.journal
~~~

* Si queremos ver los logs usamos este comando:

~~~
usuario@ares:~$ sudo journalctl --file=/var/log/journal/remote/remote-10.0.1.102.journal
~~~
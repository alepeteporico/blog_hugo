+++
title = "Gestión de paquetería en debian"
description = ""
tags = [
    "ASO"
]
date = "2021-10-01"
menu = "main"
+++

---

## APT, APTITUDE Y DPKG

1. Que acciones consigo al realizar apt update y apt upgrade. Explica detalladamente.

* **update:** actualiza la lista de paquetes que están disponibles y la versión actual usando los repositorios que se alojan en el fichero `sources.list`

* **upgrade:** Esta opción la usaríamos después del update, pues la lista de paquetes y sus versiones estaría actualizada y este comando instalaría estas nuevas versiones

2. Lista la relación de paquetes que pueden ser actualizados. ¿Qué información puedes sacar a tenor de lo mostrado en el listado?.

~~~
vagrant@paqueteria:~$ sudo apt list --upgradable 
Listing... Done
~~~

3. Indica la versión instalada, candidata así como la prioridad del paquete openssh-client.

~~~
vagrant@paqueteria:~$ sudo apt-cache policy openssh-client
openssh-client:
  Installed: 1:8.4p1-5
  Candidate: 1:8.4p1-5
  Version table:
 *** 1:8.4p1-5 500
        500 http://deb.debian.org/debian bullseye/main amd64 Packages
        100 /var/lib/dpkg/status
~~~

4. ¿Cómo puedes sacar información de un paquete oficial instalado o que no este instalado?

* Instalado:

~~~
vagrant@paqueteria:~$ apt-cache search openssh-client
backuppc - high-performance, enterprise-grade system for backing up PCs
debian-goodies - Small toolbox-style utilities for Debian systems
openssh-client - secure shell (SSH) client, for secure access to remote machines
ssh-askpass-gnome - interactive X program to prompt users for a passphrase for ssh-add
openssh-client-ssh1 - secure shell (SSH) client for legacy SSH1 protocol
~~~

* No instalado:

~~~
vagrant@paqueteria:~$ apt-cache search sl
2048 - Slide and add puzzle game for text mode
2048-qt - mathematics based puzzle game
fonts-3270 - monospaced font based on IBM 3270 terminals
4g8 - Packet Capture and Interception for Switched Networks
9base - Plan 9 userland tools
abcm2ps - Translates ABC music description files to PostScript
abcmidi - converter from ABC to MIDI format and back
...
...
...
~~~

5. Saca toda la información que puedas del paquete openssh-client que tienes actualmente instalado en tu máquina.

~~~
vagrant@paqueteria:~$ apt-cache show openssh-client
Package: openssh-client
Source: openssh
Version: 1:8.4p1-5
Installed-Size: 4298
Maintainer: Debian OpenSSH Maintainers <debian-ssh@lists.debian.org>
Architecture: amd64
Replaces: openssh-sk-helper, ssh, ssh-krb5
Provides: rsh-client, ssh-client
Depends: adduser (>= 3.10), dpkg (>= 1.7.0), passwd, libc6 (>= 2.26), libedit2 (>= 2.11-20080614-0), libfido2-1 (>= 1.5.0), libgssapi-krb5-2 (>= 1.17), libselinux1 (>= 3.1~), libssl1.1 (>= 1.1.1), zlib1g (>= 1:1.1.4)
Recommends: xauth
Suggests: keychain, libpam-ssh, monkeysphere, ssh-askpass
Conflicts: sftp
Breaks: openssh-sk-helper
Description-en: secure shell (SSH) client, for secure access to remote machines
 This is the portable version of OpenSSH, a free implementation of
 the Secure Shell protocol as specified by the IETF secsh working
 group.
 .
 Ssh (Secure Shell) is a program for logging into a remote machine
 and for executing commands on a remote machine.
 It provides secure encrypted communications between two untrusted
 hosts over an insecure network. X11 connections and arbitrary TCP/IP
 ports can also be forwarded over the secure channel.
 It can be used to provide applications with a secure communication
 channel.
 .
 This package provides the ssh, scp and sftp clients, the ssh-agent
 and ssh-add programs to make public key authentication more convenient,
 and the ssh-keygen, ssh-keyscan, ssh-copy-id and ssh-argv0 utilities.
 .
 In some countries it may be illegal to use any encryption at all
 without a special permit.
 .
 ssh replaces the insecure rsh, rcp and rlogin programs, which are
 obsolete for most purposes.
Description-md5: 8cde3280ebad71c16b3e8c661dae6c6d
Multi-Arch: foreign
Homepage: http://www.openssh.com/
Tag: implemented-in::c, interface::commandline, interface::shell,
 network::client, protocol::sftp, protocol::ssh, role::program,
 security::authentication, security::cryptography, uitoolkit::ncurses,
 use::login, use::transmission, works-with::file
Section: net
Priority: standard
Filename: pool/main/o/openssh/openssh-client_8.4p1-5_amd64.deb
Size: 929360
MD5sum: 195353baf9867672cb9f93251ab0aa50
SHA256: 5305403ffbb3dfafb3d455e4d23027cf4b1a44595cfa7ae0e760374445fd049
~~~

6. Saca toda la información que puedas del paquete openssh-client candidato a actualizar en tu máquina.

7. Lista todo el contenido referente al paquete openssh-client actual de tu máquina. Utiliza para ello tanto dpkg como apt.

~~~
vagrant@paqueteria:~$ dpkg -l 'openssh-client'
Desired=Unknown/Install/Remove/Purge/Hold
| Status=Not/Inst/Conf-files/Unpacked/halF-conf/Half-inst/trig-aWait/Trig-pend
|/ Err?=(none)/Reinst-required (Status,Err: uppercase=bad)
||/ Name           Version      Architecture Description
+++-==============-============-============-===============================================================
ii  openssh-client 1:8.4p1-5    amd64        secure shell (SSH) client, for secure access to remote machines
~~~

8. Listar el contenido de un paquete sin la necesidad de instalarlo o descargarlo.

~~~
vagrant@paqueteria:~$ sudo apt list sl
Listing... Done
sl/stable 5.02-1+b1 amd64
~~~

9. Simula la instalación del paquete openssh-client.

~~~
vagrant@paqueteria:~$ sudo apt -s install sl
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following NEW packages will be installed:
  sl
0 upgraded, 1 newly installed, 0 to remove and 0 not upgraded.
Inst sl (5.02-1+b1 Debian:11.0/stable [amd64])
Conf sl (5.02-1+b1 Debian:11.0/stable [amd64])
~~~

10. ¿Qué comando te informa de los posible bugs que presente un determinado paquete?

~~~
vagrant@paqueteria:~$ sudo apt-listbugs list python3
Retrieving bug reports... Done
Parsing Found/Fixed information... Done
~~~

11. Después de realizar un apt update && apt upgrade. Si quisieras actualizar únicamente los paquetes que tienen de cadena openssh. ¿Qué procedimiento seguirías?. Realiza esta acción, con las estructuras repetitivas que te ofrece bash, así como con el comando xargs.

12. ¿Cómo encontrarías qué paquetes dependen de un paquete específico?

~~~
vagrant@paqueteria:~$ sudo apt-cache depends ssh
ssh
  PreDepends: dpkg
  Depends: openssh-client
  Depends: openssh-server
~~~

13. ¿Cómo procederías para encontrar el paquete al que pertenece un determinado fichero?

~~~
vagrant@paqueteria:~$ sudo apt-file search /etc/ssh/ssh_config
openssh-client: /etc/ssh/ssh_config
~~~

14. ¿Que procedimientos emplearías para liberar la caché en cuanto a descargas de paquetería?

~~~
vagrant@paqueteria:~$ sudo apt clean
~~~

15. Realiza la instalación del paquete keyboard-configuration pasando previamente los valores de los parámetros de configuración como variables de entorno.

16. Reconfigura el paquete locales de tu equipo, añadiendo una localización que no exista previamente. Comprueba a modificar las variables de entorno correspondientes para que la sesión del usuario utilice otra localización.

17. Interrumpe la configuración de un paquete y explica los pasos a dar para continuar la instalación.

18. Explica la instrucción que utilizarías para hacer una actualización completa de todos los paquetes de tu sistema de manera completamente no interactiva

~~~
vagrant@paqueteria:~$ sudo apt update && sudo apt upgrade -y
~~~

19. Bloquea la actualización de determinados paquetes.

~~~
vagrant@paqueteria:~$ echo "tree hold" | sudo dpkg --set-selections
vagrant@paqueteria:~$ dpkg --get-selections tree
tree						hold
~~~

## Trabajo con ficheros .deb

1. Descarga un paquete sin instalarlo, es decir, descarga el fichero .deb correspondiente. Indica diferentes formas de hacerlo.

* Con apt-get

~~~
vagrant@paqueteria:~$ sudo apt-get install --download-only sl
vagrant@paqueteria:~$ ls
sl_5.02-1+b1_amd64.deb
~~~

* Con wget

~~~
vagrant@paqueteria:~$ wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.10.tar.gz
~~~

2. ¿Cómo puedes ver el contenido, que no extraerlo, de lo que se instalará en el sistema de un paquete deb?

~~~
vagrant@paqueteria:~$ dpkg -c sl_5.02-1+b1_amd64.deb 
drwxr-xr-x root/root         0 2019-08-07 06:15 ./
drwxr-xr-x root/root         0 2019-08-07 06:15 ./usr/
drwxr-xr-x root/root         0 2019-08-07 06:15 ./usr/games/
-rwxr-xr-x root/root     26568 2019-08-07 06:15 ./usr/games/sl
drwxr-xr-x root/root         0 2019-08-07 06:15 ./usr/share/
drwxr-xr-x root/root         0 2019-08-07 06:15 ./usr/share/doc/
drwxr-xr-x root/root         0 2019-08-07 06:15 ./usr/share/doc/sl/
-rw-r--r-- root/root       360 2019-01-29 12:15 ./usr/share/doc/sl/README
-rw-r--r-- root/root       190 2019-01-29 12:15 ./usr/share/doc/sl/README.Debian
-rw-r--r-- root/root       417 2019-01-29 12:15 ./usr/share/doc/sl/README.jp
-rw-r--r-- root/root       209 2019-08-07 06:15 ./usr/share/doc/sl/changelog.Debian.amd64.gz
-rw-r--r-- root/root      1777 2019-08-07 06:15 ./usr/share/doc/sl/changelog.Debian.gz
-rw-r--r-- root/root       598 2019-01-29 12:15 ./usr/share/doc/sl/copyright
drwxr-xr-x root/root         0 2019-08-07 06:15 ./usr/share/man/
drwxr-xr-x root/root         0 2019-08-07 06:15 ./usr/share/man/de/
drwxr-xr-x root/root         0 2019-08-07 06:15 ./usr/share/man/de/man6/
-rw-r--r-- root/root       641 2019-08-07 06:15 ./usr/share/man/de/man6/LS.6.gz
-rw-r--r-- root/root       663 2019-08-07 06:15 ./usr/share/man/de/man6/sl.6.gz
drwxr-xr-x root/root         0 2019-08-07 06:15 ./usr/share/man/de.UTF-8/
drwxr-xr-x root/root         0 2019-08-07 06:15 ./usr/share/man/de.UTF-8/man6/
-rw-r--r-- root/root       641 2019-08-07 06:15 ./usr/share/man/de.UTF-8/man6/LS.6.gz
-rw-r--r-- root/root       663 2019-08-07 06:15 ./usr/share/man/de.UTF-8/man6/sl.6.gz
drwxr-xr-x root/root         0 2019-08-07 06:15 ./usr/share/man/ja/
drwxr-xr-x root/root         0 2019-08-07 06:15 ./usr/share/man/ja/man6/
-rw-r--r-- root/root       567 2019-08-07 06:15 ./usr/share/man/ja/man6/LS.6.gz
-rw-r--r-- root/root       582 2019-08-07 06:15 ./usr/share/man/ja/man6/sl.6.gz
drwxr-xr-x root/root         0 2019-08-07 06:15 ./usr/share/man/ja.UTF-8/
drwxr-xr-x root/root         0 2019-08-07 06:15 ./usr/share/man/ja.UTF-8/man6/
-rw-r--r-- root/root       567 2019-08-07 06:15 ./usr/share/man/ja.UTF-8/man6/LS.6.gz
-rw-r--r-- root/root       582 2019-08-07 06:15 ./usr/share/man/ja.UTF-8/man6/sl.6.gz
drwxr-xr-x root/root         0 2019-08-07 06:15 ./usr/share/man/man6/
-rw-r--r-- root/root       511 2019-08-07 06:15 ./usr/share/man/man6/LS.6.gz
-rw-r--r-- root/root       523 2019-08-07 06:15 ./usr/share/man/man6/sl.6.gz
~~~

3. Sobre el fichero .deb descargado, utiliza el comando ar. ar permite extraer el contenido de una paquete deb. Indica el procedimiento para visualizar con ar el contenido del paquete deb. Con el paquete que has descargado y utilizando el comando ar, descomprime el paquete. ¿Qué información dispones después de la extracción?. Indica la finalidad de lo extraído.

4. Indica el procedimiento para descomprimir lo extraído por ar del punto anterior. ¿Qué información contiene?
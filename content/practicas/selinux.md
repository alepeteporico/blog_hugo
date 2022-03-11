+++
title = "SElinux"
description = ""
tags = [
    "ASO"
]
date = "2022-02-18"
menu = "main"
+++


* En esta práctica vamos a habilitar SELinux en un servidor rocky, en este servidor tendremos alojados un SAMBA y NFS, tendremos que asegurarnos que esto servicios funcionan correctamente con SELinux activado y nuestros clientes pueden usarlos sin problemas.

* Hemos instalado y configurado un servidor samba y nfs en una máquina servidor.

~~~
[vagrant@server ~]$ sudo systemctl status smb.service 
● smb.service - Samba SMB Daemon
   Loaded: loaded (/usr/lib/systemd/system/smb.service; enabled; vendor preset: disabled)
   Active: active (running) since Fri 2022-03-11 11:52:49 UTC; 2h 13min ago
     Docs: man:smbd(8)
           man:samba(7)
           man:smb.conf(5)
 Main PID: 1065 (smbd)
   Status: "smbd: ready to serve connections..."
    Tasks: 4 (limit: 11402)
   Memory: 19.3M
   CGroup: /system.slice/smb.service
           ├─1065 /usr/sbin/smbd --foreground --no-process-group
           ├─1131 /usr/sbin/smbd --foreground --no-process-group
           ├─1132 /usr/sbin/smbd --foreground --no-process-group
           └─1149 /usr/sbin/smbd --foreground --no-process-group

Mar 11 11:52:48 server.alegv.com systemd[1]: Starting Samba SMB Daemon...
Mar 11 11:52:49 server.alegv.com smbd[1065]: [2022/03/11 11:52:49.218381,  0] ../../lib/util/become_daem>
Mar 11 11:52:49 server.alegv.com systemd[1]: Started Samba SMB Daemon.
Mar 11 11:52:49 server.alegv.com smbd[1065]:   daemon_ready: daemon 'smbd' finished starting up and read>

[vagrant@server ~]$ sudo systemctl status nfs-server.service 
● nfs-server.service - NFS server and services
   Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; vendor preset: disabled)
  Drop-In: /run/systemd/generator/nfs-server.service.d
           └─order-with-mounts.conf
   Active: active (exited) since Fri 2022-03-11 11:52:46 UTC; 2h 14min ago
  Process: 1055 ExecStart=/bin/sh -c if systemctl -q is-active gssproxy; then systemctl reload gssproxy >
  Process: 1043 ExecStart=/usr/sbin/rpc.nfsd (code=exited, status=0/SUCCESS)
  Process: 1040 ExecStartPre=/usr/sbin/exportfs -r (code=exited, status=0/SUCCESS)
 Main PID: 1055 (code=exited, status=0/SUCCESS)
    Tasks: 0 (limit: 11402)
   Memory: 0B
   CGroup: /system.slice/nfs-server.service

Mar 11 11:52:45 server.alegv.com systemd[1]: Starting NFS server and services...
Mar 11 11:52:46 server.alegv.com systemd[1]: Started NFS server and services.
~~~

* Hemos creado una carpeta `/home/shared-storage/` para nfs y `/srv/samba/private/` para samba

* Una vez configurado el servicio debemos permitir que los servicios necesarios puedan pasar el firewall, abriendo ciertos puertos.

~~~
[vagrant@server ~]$ sudo firewall-cmd --permanent --add-port=2049/tcp
[vagrant@server ~]$ sudo firewall-cmd --add-service={nfs,nfs3,mountd,rpc-bind} --permanent
[vagrant@server ~]$ sudo firewall-cmd --add-service=samba --zone=public --permanent
[vagrant@server ~]$ sudo firewall-cmd --reload
~~~

* Vamos a comprobar la conexión desde nuestro cliente una vez configurado el mismo.

* Primero vemos que podemos conectarnos a samba y crear contenido dentro.

~~~
vagrant@pruebas:~$ smbclient //192.168.121.244/private -U cliente
Enter WORKGROUP\cliente's password: 
Try "help" to get a list of possible commands.
smb: \> ls
  .                                   D        0  Tue Mar  1 12:16:04 2022
  ..                                  D        0  Fri Feb 18 08:13:38 2022
  carpeta                             D        0  Fri Feb 18 08:43:42 2022
  prueba                              D        0  Tue Mar  1 12:16:04 2022

		73364480 blocks of size 1024. 70874636 blocks available
smb: \>
~~~

* Ahora comprobamos el servidor nfs, vamos a crear algunos ficheros y coomprobar que también se han creado en nuestro servidor.

~~~
vagrant@pruebas:~$ ls /mnt/network-drive/
hola.txt testfile.txt
~~~

~~~
[vagrant@server ~]$ ls /home/shared-storage/
hola.txt  testfile.txt
~~~

* Hemos visto que los dos servicios funcionan correctamente, vamos a comprobar que nuestro selinux está en modo enforcing.

~~~
[vagrant@server ~]$ sudo sestatus
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   enforcing
Mode from config file:          enforcing
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Memory protection checking:     actual (secure)
Max kernel policy version:      33
~~~

* Esa ha sido la comprobación de que samba y NFS funcionan por defecto con SElinux en modo enforcing, existen distintos parametros (o booleanos) que podemos configurar, veamos los que existen en samba y nfs.

~~~
[vagrant@server ~]$ getsebool -a| grep samba
samba_create_home_dirs --> off
samba_domain_controller --> off
samba_enable_home_dirs --> off
samba_export_all_ro --> off
samba_export_all_rw --> off
samba_load_libgfapi --> off
samba_portmapper --> off
samba_run_unconfined --> off
samba_share_fusefs --> off
samba_share_nfs --> off
sanlock_use_samba --> off
tmpreaper_use_samba --> off
use_samba_home_dirs --> off
virt_use_samba --> off

[vagrant@server ~]$ getsebool -a| grep nfs
cobbler_use_nfs --> off
colord_use_nfs --> off
conman_use_nfs --> off
ftpd_use_nfs --> off
git_cgi_use_nfs --> off
git_system_use_nfs --> off
httpd_use_nfs --> off
ksmtuned_use_nfs --> off
logrotate_use_nfs --> off
mpd_use_nfs --> off
nagios_use_nfs --> off
nfs_export_all_ro --> on
nfs_export_all_rw --> on
nfsd_anon_write --> off
openshift_use_nfs --> off
polipo_use_nfs --> off
samba_share_nfs --> off
sanlock_use_nfs --> off
sge_use_nfs --> off
tmpreaper_use_nfs --> off
use_nfs_home_dirs --> off
virt_use_nfs --> off
xen_use_nfs --> off
~~~

* Para poder gestionarlos vamos a instalar el siguiente paquete.

~~~
[vagrant@server ~]$ sudo dnf install policycoreutils-python-utils
~~~

* Ahora podemos encender los que queramos usando el siguiente comando.

~~~
[vagrant@server ~]$ sudo setsebool samba_create_home_dirs on

[vagrant@server ~]$ getsebool -a| grep samba
samba_create_home_dirs --> on
~~~

* Así podremos activar y desactivar distintos módulos a nuestro antojo, quizás queremos que un servicio funcione pero no completamente, para ello usamos esta utilidad.
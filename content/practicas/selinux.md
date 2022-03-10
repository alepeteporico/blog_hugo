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


* Vamos a comprobar que nuestro selinux no permite conexiones samba ni nfs.

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

* Para poder gestionar selinux vamos a instalar el siguiente paquete.

~~~
[vagrant@server ~]$ sudo dnf install policycoreutils-python-utils
~~~

* Mediante el comando semanage vamos a hacer que la carpeta de samba tenga permisos de lectura y escritura añadiendo el directorio que usamos para el directorio a la política de selinux `samba_share_t`

~~~
[vagrant@server ~]$ sudo semanage fcontext -a -t samba_share_t "/srv/samba(/.*)?"
~~~

* También se necesitan una serie de booleanos para que nuestro servicio funcione correctamente, en el caso de samba el booleano que debemos cambiar es el `smbd_anon_write`.

~~~
[vagrant@server ~]$ sudo setsebool -P smbd_anon_write=1


~~~
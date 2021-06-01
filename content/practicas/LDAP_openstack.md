+++
title = "LDAP"
description = ""
tags = [
    "ASO"
]
date = "2021-05-31"
menu = "main"
+++

* Para esta práctica vamos a usar las claves y certificados que generamos en la [práctica de seguridad de https](https://alepeteporico.github.io/practicas/https_openstack/)

        [root@quijote ~]# scp /etc/ssl/certs/gonzalonazareno.crt debian@10.0.1.9
        [root@quijote ~]# scp /etc/ssl/certs/openstack.crt debian@10.0.1.9
        [root@quijote ~]# scp /etc/ssl/private/openstack.key debian@10.0.1.9

* Vamos a mover estos certificados a un sitio apropiado.

        debian@freston:~$ sudo mv gonzalonazareno.crt /etc/ssl/certs/
        debian@freston:~$ sudo mv openstack.crt /etc/ssl/certs/
        debian@freston:~$ sudo mv openstack.key /etc/ssl/private/

* Vamos a crear unas acl para que el usuario `openldap` que es el encargado de ejecutar los servicios de sldap tenga permisos sobre estos certificados.

        debian@freston:~$ sudo setfacl -m u:openldap:r-x /etc/ssl/private
        debian@freston:~$ sudo setfacl -m u:openldap:r-x /etc/ssl/private/openstack.key

* Vamos a crear un fichero donde especificaremos las modificaciones de seguridad que se llevarán a cabo.

        debian@freston:~$ cat seguro.ldif 
        dn: cn=config
        changetype: modify
        replace: olcTLSCACertificateFile
        olcTLSCACertificateFile: /etc/ssl/certs/gonzalonazareno.crt           
        -
        replace: olcTLSCertificateKeyFile
        olcTLSCertificateKeyFile: /etc/ssl/private/openstack.key
        -
        replace: olcTLSCertificateFile
        olcTLSCertificateFile: /etc/ssl/certs/openstack.crt

* Ahora importaremos este archivo para modificar la configuración:

        debian@freston:~$ sudo ldapmodify -Y EXTERNAL -H ldapi:/// -f seguro.ldif 
        SASL/EXTERNAL authentication started
        SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
        SASL SSF: 0
        modifying entry "cn=config"

* Vamos a añadir en el fichero de configuración `/etc/default/sldap` el protocolo ldaps.

        SLAPD_SERVICES="ldap:/// ldapi:/// ldaps:///"

* Reiniciaremos el servicio y comprobamos su estado.

        debian@freston:~$ sudo systemctl restart slapd.service

        debian@freston:~$ sudo systemctl status slapd.service 
        ● slapd.service - LSB: OpenLDAP standalone server (Lightweight Directory Access Protocol)
           Loaded: loaded (/etc/init.d/slapd; generated)
           Active: active (running) since Tue 2021-06-01 11:17:18 UTC; 12s ago
             Docs: man:systemd-sysv-generator(8)
          Process: 19378 ExecStart=/etc/init.d/slapd start (code=exited, status=0/SUCCESS)
            Tasks: 3 (limit: 562)
           Memory: 3.3M
           CGroup: /system.slice/slapd.service
                   └─19387 /usr/sbin/slapd -h ldap:/// ldapi:/// ldaps:/// -g openldap -u openldap -F /etc/ldap/s

        Jun 01 11:17:18 freston systemd[1]: Starting LSB: OpenLDAP standalone server (Lightweight Directory Acces
        Jun 01 11:17:18 freston slapd[19383]: @(#) $OpenLDAP: slapd  (Feb 14 2021 18:32:34) $
                                                      Debian OpenLDAP Maintainers <pkg-openldap-devel@lists.aliot
        Jun 01 11:17:18 freston slapd[19387]: slapd starting
        Jun 01 11:17:18 freston slapd[19378]: Starting OpenLDAP: slapd.
        Jun 01 11:17:18 freston systemd[1]: Started LSB: OpenLDAP standalone server (Lightweight Directory Access

* Podemos comprobar que se está usando el puerto 636, que es el puerto que usa ldap para funcionar de forma segura.

        debian@freston:~$ sudo netstat -tlnp | egrep 'slapd'
        tcp        0      0 0.0.0.0:389             0.0.0.0:*               LISTEN      19387/slapd         
        tcp        0      0 0.0.0.0:636             0.0.0.0:*               LISTEN      19387/slapd         
        tcp6       0      0 :::389                  :::*                    LISTEN      19387/slapd         
        tcp6       0      0 :::636                  :::*                    LISTEN      19387/slapd

* Por supuesto necesitamos importar estos certificados al cliente, aunque el cliente en este caso es el propio freston también realizaremos el proceso, en primero lugar copiando el certificado a la carpeta que se especifica abajo y crear un enlace simbólico, para ello haremos uso del comando `update-ca-certificates`.

        root@freston:~# cp /etc/ssl/certs/gonzalonazareno.crt /usr/local/share/ca-certificates/

        root@freston:~# update-ca-certificates 
        Updating certificates in /etc/ssl/certs...
        rehash: warning: skipping duplicate certificate in gonzalonazareno.pem
        1 added, 0 removed; done.
        Running hooks in /etc/ca-certificates/update.d...
        done.
* Vamos a comprobar su funcionamiento haciendo una busqueda anónima y especificando que use la funcionalidad ldaps y el puerto 636.

        root@freston:~# sudo ldapsearch -x -b "dc=alegv,dc=gonzalonazareno,dc=org" -H ldaps://localhost:636
        # extended LDIF
        #
        # LDAPv3
        # base <dc=alegv,dc=gonzalonazareno,dc=org> with scope subtree
        # filter: (objectclass=*)
        # requesting: ALL
        #

        # alegv.gonzalonazareno.org
        dn: dc=alegv,dc=gonzalonazareno,dc=org
        objectClass: top
        objectClass: dcObject
        objectClass: organization
        o: alegv.gonzalonazareno.org
        dc: alegv

        # admin, alegv.gonzalonazareno.org
        dn: cn=admin,dc=alegv,dc=gonzalonazareno,dc=org
        objectClass: simpleSecurityObject
        objectClass: organizationalRole
        cn: admin
        description: LDAP administrator

        # Usuarios, alegv.gonzalonazareno.org
        dn: ou=Usuarios,dc=alegv,dc=gonzalonazareno,dc=org
        objectClass: organizationalUnit
        ou:: VXN1YXJpb3Mg

        # Grupos, alegv.gonzalonazareno.org
        dn: ou=Grupos,dc=alegv,dc=gonzalonazareno,dc=org
        objectClass: organizationalUnit
        ou: Grupos

        # search result
        search: 2
        result: 0 Success

        # numResponses: 5
        # numEntries: 4

* Funciona, pero hemos tenido que especificar que use el puerto que queremos, para que ldap use ldaps por defecto debemos ir al fichero `/etc/ldap/ldap.conf` donde encotraremos la siguiente línea comentada:

        #URI    ldap://ldap.example.com ldap://ldap-master.example.com:666

* La descomentamos y la modifcamos de la siguiente forma:

        URI     ldaps://localhost

* Comprobamos que al hacer una busqueda se hace por defecto con ldaps.

        root@freston:~# ldapsearch -x -b "dc=alegv,dc=gonzalonazareno,dc=org"
        # extended LDIF
        #
        # LDAPv3
        # base <dc=alegv,dc=gonzalonazareno,dc=org> with scope subtree
        # filter: (objectclass=*)
        # requesting: ALL
        #
        
        # alegv.gonzalonazareno.org
        dn: dc=alegv,dc=gonzalonazareno,dc=org
        objectClass: top
        objectClass: dcObject
        objectClass: organization
        o: alegv.gonzalonazareno.org
        dc: alegv
        
        # admin, alegv.gonzalonazareno.org
        dn: cn=admin,dc=alegv,dc=gonzalonazareno,dc=org
        objectClass: simpleSecurityObject
        objectClass: organizationalRole
        cn: admin
        description: LDAP administrator
        
        # Usuarios, alegv.gonzalonazareno.org
        dn: ou=Usuarios,dc=alegv,dc=gonzalonazareno,dc=org
        objectClass: organizationalUnit
        ou:: VXN1YXJpb3Mg
        
        # Grupos, alegv.gonzalonazareno.org
        dn: ou=Grupos,dc=alegv,dc=gonzalonazareno,dc=org
        objectClass: organizationalUnit
        ou: Grupos
        
        # search result
        search: 2
        result: 0 Success
        
        # numResponses: 5
        # numEntries: 4
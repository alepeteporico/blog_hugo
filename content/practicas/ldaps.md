+++
title = "LDAPs"
description = ""
tags = [
    "ASO"
]
date = "2022-05-17"
menu = "main"
+++

* Para usar la configuración segura de ldap primero debemos tener los certificados correspondientes, primero creamos una clave privada con openssl.

~~~
root@apolo:~# openssl genrsa 4096 > /etc/ssl/private/apoloalexgv.key
~~~

* Y usando esa clave creamos un certificado que deberá ser firmado por la unidad certificadora del gonzalo nazareno en nuestro caso.

~~~
root@apolo:~# openssl req -new -key /etc/ssl/private/apoloalexgv.key -out /root/apoloalexgv.csr
~~~

* Con la clave, el certificado firmado y el certificado del gonzalo nazareno que descargaremos de gestiona tendremos todos los certificados necesarios, veamos donde se ubica cada uno.

~~~
root@apolo:~# ls /etc/ssl/private/
apoloalexgv.key

root@apolo:~# ls /etc/ssl/certs/ | egrep 'gonzalo|apolo'
apoloalexgv.crt
gonzalonazareno.crt
~~~

* Para una mayor seguridad vamos a crear unas acls para que unicamente en usuario `openldap` tenga acceso a la clave privada.

~~~
root@apolo:~# setfacl -m u:openldap:r-x /etc/ssl/private
root@apolo:~# setfacl -m u:openldap:r-x /etc/ssl/private/apoloalexgv.key
~~~

* Ahora necesitamos especificar el servicio de ldap que use SSL/TLS. Para ello crearemos un fichero ldif con la siguiente configuración.

~~~
dn: cn=config
changetype: modify
replace: olcTLSCACertificateFile
olcTLSCACertificateFile: /etc/ssl/certs/gonzalonazareno.crt
-
replace: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: /etc/ssl/private/apoloalexgv.key
-
replace: olcTLSCertificateFile
olcTLSCertificateFile: /etc/ssl/certs/apoloalexgv.crt
~~~

* Vamos a realizar los cambios.

~~~
root@apolo:~# ldapmodify -Y EXTERNAL -H ldapi:/// -f ldaps.ldif 
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
modifying entry "cn=config"
~~~

* `LDAPS` usa el puerto 636, para que el serivicio lo use debemos modificar el fichero `/etc/default/slapd` tal que así:

~~~
SLAPD_SERVICES="ldap:/// ldapi:/// ldaps:///"
~~~

~~~
root@apolo:~# netstat -tlnp | egrep slap
tcp        0      0 0.0.0.0:389             0.0.0.0:*               LISTEN      29945/slapd         
tcp        0      0 0.0.0.0:636             0.0.0.0:*               LISTEN      29945/slapd         
tcp6       0      0 :::389                  :::*                    LISTEN      29945/slapd         
tcp6       0      0 :::636                  :::*                    LISTEN      29945/slapd 
~~~

* Ahora debemos hacer que nuestro cliente apolo use por defecto este ldaps, para ello debemos copiar el certificado del gonzalo nazareno a la carpeta `/usr/local/share/ca-certificates/` que es donde se alojan los certificados instalados localmente.

~~~
root@apolo:~# cp /etc/ssl/certs/gonzalonazareno.crt /usr/local/share/ca-certificates/
~~~

* Una vez hecho esto actualizamos la lista de certificados locales.

~~~
root@apolo:~# update-ca-certificates
Updating certificates in /etc/ssl/certs...
rehash: warning: skipping duplicate certificate in gonzalonazareno.pem
1 added, 0 removed; done.
Running hooks in /etc/ca-certificates/update.d...
done.
~~~

* Ahora ya podemos hacer consultas ldaps, vamos a comprobarlo.

~~~
root@apolo:~# ldapsearch -x -b "dc=alexgv,dc=gonzalonazareno,dc=org" -H ldaps://localhost:636
# extended LDIF
#
# LDAPv3
# base <dc=alexgv,dc=gonzalonazareno,dc=org> with scope subtree
# filter: (objectclass=*)
# requesting: ALL
#

# alexgv.gonzalonazareno.org
dn: dc=alexgv,dc=gonzalonazareno,dc=org
objectClass: top
objectClass: dcObject
objectClass: organization
o: alexgv.gonzalonazareno.org
dc: alexgv

# Usuarios, alexgv.gonzalonazareno.org
dn: ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org
objectClass: organizationalUnit
ou:: VXN1YXJpb3Mg

# Grupos, alexgv.gonzalonazareno.org
dn: ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org
objectClass: organizationalUnit
ou: Grupos

# search result
search: 2
result: 0 Success

# numResponses: 4
# numEntries: 3
~~~

* Funciona, pero hemos tenido que especificar que use el puerto que queremos, para que ldap use ldaps por defecto debemos ir al fichero `/etc/ldap/ldap.conf` donde encotraremos la siguiente línea comentada:

~~~
#URI    ldap://ldap.example.com ldap://ldap-master.example.com:666
~~~

* La descomentamos y la modifcamos de la siguiente forma:

~~~
URI     ldaps://localhost
~~~

* Ahora si, las consultas se hacen por defecto en ldaps.

~~~
root@apolo:~# ldapsearch -x -b "dc=alexgv,dc=gonzalonazareno,dc=org"
# extended LDIF
#
# LDAPv3
# base <dc=alexgv,dc=gonzalonazareno,dc=org> with scope subtree
# filter: (objectclass=*)
# requesting: ALL
#

# alexgv.gonzalonazareno.org
dn: dc=alexgv,dc=gonzalonazareno,dc=org
objectClass: top
objectClass: dcObject
objectClass: organization
o: alexgv.gonzalonazareno.org
dc: alexgv

# Usuarios, alexgv.gonzalonazareno.org
dn: ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org
objectClass: organizationalUnit
ou:: VXN1YXJpb3Mg

# Grupos, alexgv.gonzalonazareno.org
dn: ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org
objectClass: organizationalUnit
ou: Grupos

# search result
search: 2
result: 0 Success

# numResponses: 4
# numEntries: 3
~~~
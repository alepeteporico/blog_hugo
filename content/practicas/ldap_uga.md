+++
title = "Usuarios, Grupos y ACLs en LDAP"
description = ""
tags = [
    "ASO"
]
date = "2022-05-20"
menu = "main"
+++

### Crea 10 usuarios con los nombres que prefieras en LDAP, esos usuarios deben ser objetos de los tipos posixAccount e inetOrgPerson. Estos usuarios tendrán un atributo userPassword.

~~~
dn: uid=stark,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org
objectClass: posixAccount
objectClass: inetOrgPerson
objectClass: top
cn: stark
gidNumber: 2001
homeDirectory: /home/stark
loginShell: /bin/bash
sn: stark
uid: stark
uidNumber: 2001
userPassword: {SSHA}loVCFjl442fnkpIZC05Ht+8OwLsgF0Ua

dn: uid=rogers,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org
objectClass: posixAccount
objectClass: inetOrgPerson
objectClass: top
cn: rogers
gidNumber: 2002
homeDirectory: /home/rogers
loginShell: /bin/bash
sn: rogers
uid: rogers
uidNumber: 2002
userPassword: {SSHA}gLim3ka1uQnZtFCMBoD0+NKmQ88/7f+d

dn: uid=banner,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org
objectClass: posixAccount
objectClass: inetOrgPerson
objectClass: top
cn: banner
gidNumber: 2003
homeDirectory: /home/banner
loginShell: /bin/bash
sn: banner
uid: banner
uidNumber: 2003
userPassword: {SSHA}R28hwHBG+MeisvkGM3qS7q049d8p6QO1

dn: uid=romanof,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org
objectClass: posixAccount
objectClass: inetOrgPerson
objectClass: top
cn: romanof
gidNumber: 2004
homeDirectory: /home/romanof
loginShell: /bin/bash
sn: romanof
uid: romanof
uidNumber: 2004
userPassword: {SSHA}r4NOljTbgWSfO1r4daswgbBDhlLtwMwd

dn: uid=burton,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org
objectClass: posixAccount
objectClass: inetOrgPerson
objectClass: top
cn: burton
gidNumber: 2005
homeDirectory: /home/burton
loginShell: /bin/bash
sn: burton
uid: burton
uidNumber: 2005
userPassword: {SSHA}n8aeZpDwycwusGlKWl56MuTXARrAWhyM

dn: uid=thor,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org
objectClass: posixAccount
objectClass: inetOrgPerson
objectClass: top
cn: thor
gidNumber: 2006
homeDirectory: /home/thor
loginShell: /bin/bash
sn: thor
uid: thor
uidNumber: 2006
userPassword: {SSHA}m20Ph+8uSwScFHcJ6iVpgimoiKawWuc3

dn: uid=strange,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org
objectClass: posixAccount
objectClass: inetOrgPerson
objectClass: top
cn: strange
gidNumber: 2007
homeDirectory: /home/strange
loginShell: /bin/bash
sn: strange
uid: strange
uidNumber: 2007
userPassword: {SSHA}UpziawVa6CL9Kk/g7gVzFRQ4MJWBDFKP

dn: uid=parker,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org
objectClass: posixAccount
objectClass: inetOrgPerson
objectClass: top
cn: parker
gidNumber: 2008
homeDirectory: /home/parker
loginShell: /bin/bash
sn: parker
uid: parker
uidNumber: 2008
userPassword: {SSHA}Px8NYV9wWlc/JxmUWaGaBV28KSucLIYt

dn: uid=furia,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org
objectClass: posixAccount
objectClass: inetOrgPerson
objectClass: top
cn: furia
gidNumber: 2009
homeDirectory: /home/furia
loginShell: /bin/bash
sn: furia
uid: furia
uidNumber: 2009
userPassword: {SSHA}8VRwZX4ts0fe8KBT58h3ywzpj+EEShfV

dn: uid=maximof,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org
objectClass: posixAccount
objectClass: inetOrgPerson
objectClass: top
cn: maximof
gidNumber: 2010
homeDirectory: /home/maximof
loginShell: /bin/bash
sn: maximof
uid: maximof
uidNumber: 2010
userPassword: {SSHA}t1Oa8gRUcI6kfJvVfNpNdMeMXs+05l1K
~~~

* Ejecutamos este fichero.

~~~
usuario@apolo:~$ ldapadd -x -D cn=admin,dc=alexgv,dc=gonzalonazareno,dc=org -W -f usuarios2.ldif
Enter LDAP Password: 
adding new entry "uid=stark,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org"

adding new entry "uid=rogers,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org"

adding new entry "uid=banner,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org"

adding new entry "uid=romanof,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org"

adding new entry "uid=burton,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org"

adding new entry "uid=thor,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org"

adding new entry "uid=strange,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org"

adding new entry "uid=parker,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org"

adding new entry "uid=furia,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org"

adding new entry "uid=maximof,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org"
~~~

### Crea 3 grupos en LDAP dentro de una unidad organizativa diferente que sean objetos del tipo groupOfNames. Estos grupos serán: comercial, almacen y admin.

~~~
dn: cn=comercial,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org
objectClass: top
objectClass: groupOfNames
cn: comercial
member:

dn: cn=almacen,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org
objectClass: top
objectClass: groupOfNames
cn: almacen
member:

dn: cn=admin,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org
objectClass: top
objectClass: groupOfNames
cn: admin
member:
~~~

* Añadimos estos grupos.

~~~
usuario@apolo:~$ ldapadd -x -D cn=admin,dc=alexgv,dc=gonzalonazareno,dc=org -W -f grupos.ldif
Enter LDAP Password: 
adding new entry "cn=comercial,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org"

adding new entry "cn=almacen,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org"

adding new entry "cn=admin,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org"
~~~

### Añade usuarios que pertenezcan a:

* Solo al grupo comercial.

~~~
dn: cn=comercial,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org
changetype:modify
add: member
member: uid=stark,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org

dn: cn=comercial,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org
changetype:modify
add: member
member: uid=furia,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org
~~~

* Solo al grupo almacen.

~~~
dn: cn=almacen,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org
changetype:modify
add: member
member: uid=rogers,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org

dn: cn=almacen,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org
changetype:modify
add: member
member: uid=bunner,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org
~~~

* Al grupo comercial y almacen.

~~~
dn: cn=comercial,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org
changetype:modify
add: member
member: uid=romanof,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org

dn: cn=almacen,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org
changetype:modify
add: member
member: uid=romanof,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org

dn: cn=comercial,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org
changetype:modify
add: member
member: uid=burton,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org

dn: cn=almacen,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org
changetype:modify
add: member
member: uid=burton,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org
~~~

* Al grupo admin y comercial.

~~~
dn: cn=admin,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org
changetype:modify
add: member
member: uid=thor,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org

dn: cn=comercial,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org
changetype:modify
add: member
member: uid=thor,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org

dn: cn=admin,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org
changetype:modify
add: member
member: uid=strange,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org

dn: cn=comercial,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org
changetype:modify
add: member
member: uid=strange,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org
~~~

* Solo al grupo admin.

~~~
dn: cn=admin,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org
changetype:modify
add: member
member: uid=parker,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org

dn: cn=admin,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org
changetype:modify
add: member
member: uid=maximof,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org
~~~

* El comando para modificar un registro es distinto al que usamos para añadirlos, una vez tenemos un fichero ldif con toda la información anterior ejecutamos este comando:

~~~
usuario@apolo:~$ ldapmodify -x -D cn=admin,dc=alexgv,dc=gonzalonazareno,dc=org -W -f modgrupos.ldif 
Enter LDAP Password: 
modifying entry "cn=comercial,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org"

modifying entry "cn=comercial,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org"

modifying entry "cn=almacen,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org"

modifying entry "cn=almacen,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org"

modifying entry "cn=comercial,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org"

modifying entry "cn=almacen,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org"

modifying entry "cn=comercial,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org"

modifying entry "cn=almacen,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org"

modifying entry "cn=admin,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org"

modifying entry "cn=comercial,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org"

modifying entry "cn=admin,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org"

modifying entry "cn=comercial,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org"

modifying entry "cn=admin,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org"

modifying entry "cn=admin,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org"
~~~

### Modifica OpenLDAP apropiadamente para que se pueda obtener los grupos a los que pertenece cada usuario a través del atributo "memberOf".

* Crearemos dos ficheros ldif con este fin.

~~~
dn: cn=module,cn=config
cn: module
objectClass: olcModuleList
objectclass: top
olcModuleLoad: memberof.la
olcModulePath: /usr/lib/ldap

dn: olcOverlay={0}memberof,olcDatabase={1}mdb,cn=config
objectClass: olcConfig
objectClass: olcMemberOf
objectClass: olcOverlayConfig
objectClass: top
olcOverlay: memberof
olcMemberOfDangling: ignore
olcMemberOfRefInt: TRUE
olcMemberOfGroupOC: groupOfNames
olcMemberOfMemberAD: member
olcMemberOfMemberOfAD: memberOf
~~~

~~~
dn: cn=module,cn=config
cn: module
objectclass: olcModuleList
objectclass: top
olcmoduleload: refint.la
olcmodulepath: /usr/lib/ldap

dn: olcOverlay={1}refint,olcDatabase={1}mdb,cn=config
objectClass: olcConfig
objectClass: olcOverlayConfig
objectClass: olcRefintConfig
objectClass: top
olcOverlay: {1}refint
olcRefintAttribute: memberof member manager owner
~~~

* Y añadimos la configuración.

~~~
usuario@apolo:~$ sudo ldapadd -Y EXTERNAL -H ldapi:/// -f memberof1.ldif 
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
adding new entry "cn=module,cn=config"

adding new entry "olcOverlay={0}memberof,olcDatabase={1}mdb,cn=config"

usuario@apolo:~$ sudo ldapadd -Y EXTERNAL -H ldapi:/// -f memberof2.ldif 
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
adding new entry "cn=module,cn=config"

adding new entry "olcOverlay={1}refint,olcDatabase={1}mdb,cn=config"
~~~

* Lo malo es que esta configuración estará disponible en los grupos que creemos a partir de ahora, por tanto debemos eliminar los grupos y volverlos a crear, esto no es un problema muy grave, pues teniendo los ficheros ldif, el hecho de poder volver a crearlos y añadir los usuarios es muy sencillo.

~~~
ldapdelete -x -D "cn=admin,dc=alexgv,dc=gonzalonazareno,dc=org" 'cn=comercial,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org' -W

ldapdelete -x -D "cn=admin,dc=alexgv,dc=gonzalonazareno,dc=org" 'cn=admin,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org' -W

ldapdelete -x -D "cn=admin,dc=alexgv,dc=gonzalonazareno,dc=org" 'cn=almacen,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org' -W
~~~

~~~
usuario@apolo:~$ ldapadd -x -D cn=admin,dc=alexgv,dc=gonzalonazareno,dc=org -W -f grupos.ldif
Enter LDAP Password: 
adding new entry "cn=comercial,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org"

adding new entry "cn=almacen,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org"

adding new entry "cn=admin,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org"

usuario@apolo:~$ ldapmodify -x -D cn=admin,dc=alexgv,dc=gonzalonazareno,dc=org -W -f modgrupos.ldif 
Enter LDAP Password: 
modifying entry "cn=comercial,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org"

modifying entry "cn=comercial,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org"

modifying entry "cn=almacen,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org"

modifying entry "cn=almacen,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org"

modifying entry "cn=comercial,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org"

modifying entry "cn=almacen,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org"

modifying entry "cn=comercial,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org"

modifying entry "cn=almacen,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org"

modifying entry "cn=admin,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org"

modifying entry "cn=comercial,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org"

modifying entry "cn=admin,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org"

modifying entry "cn=comercial,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org"

modifying entry "cn=admin,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org"

modifying entry "cn=admin,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org"
~~~

* Ahora, el comando que tenemos para averiguar a que grupo pertenece un usuario a partir de su uid es el siguiente:

~~~
usuario@apolo:~$ ldapsearch -LL -Y EXTERNAL -H ldapi:/// "(uid=stark)" -b dc=alexgv,dc=gonzalonazareno,dc=org memberOf
SASL/EXTERNAL authentication started
SASL username: gidNumber=1000+uidNumber=1000,cn=peercred,cn=external,cn=auth
SASL SSF: 0
version: 1

dn: uid=stark,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org
memberOf: cn=comercial,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org
~~~

~~~
usuario@apolo:~$ ldapsearch -LL -Y EXTERNAL -H ldapi:/// "(uid=thor)" -b dc=alexgv,dc=gonzalonazareno,dc=org memberOf
SASL/EXTERNAL authentication started
SASL username: gidNumber=1000+uidNumber=1000,cn=peercred,cn=external,cn=auth
SASL SSF: 0
version: 1

dn: uid=thor,ou=Usuarios,dc=alexgv,dc=gonzalonazareno,dc=org
memberOf: cn=admin,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org
memberOf: cn=comercial,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org
~~~

## Crea las ACLs necesarias para que los usuarios del grupo almacen puedan ver todos los atributos de todos los usuarios pero solo puedan modificar las suyas.

~~~
dn: olcDatabase={1}mdb,cn=config
changetype: modify
add: olcAccess
olcAccess: to dn.base="" by group="cn=almacen,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org" by self write
olcAccess: to dn.base="" by group="cn=almacen,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org" read
olcAccess: to dn.base="" by group="cn=almacen,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org" search
~~~

* Vamos a añadir esta acl al directorio.

~~~
usuario@apolo:~$ sudo ldapmodify -Y EXTERNAL -H ldapi:/// -f aclalmacen.ldif 
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
modifying entry "olcDatabase={1}mdb,cn=config"
~~~

* Vemos que se ha añadido.

~~~
usuario@apolo:~$ sudo ldapsearch -LLLQ -Y EXTERNAL -H ldapi:/// -b cn=config -s one olcAccess
dn: cn=module{0},cn=config

dn: cn=module{1},cn=config

dn: cn=module{2},cn=config

dn: cn=schema,cn=config

dn: olcDatabase={-1}frontend,cn=config
olcAccess: {0}to * by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=external
 ,cn=auth manage by * break
olcAccess: {1}to dn.exact="" by * read
olcAccess: {2}to dn.base="cn=Subschema" by * read

dn: olcDatabase={0}config,cn=config
olcAccess: {0}to * by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=external
 ,cn=auth manage by * break

dn: olcDatabase={1}mdb,cn=config
olcAccess: {0}to attrs=userPassword by self write by anonymous auth by * none
olcAccess: {1}to attrs=shadowLastChange by self write by * read
olcAccess: {2}to * by * read
olcAccess: {3}to attrs=userPassword by self =xw by dn.exact="cn=admin,dc=alexg
 v,dc=gonzalonazareno,dc=org" =xw by dn.exact="uid=mirroradmin,dc=alexgv,dc=go
 nzalonazareno,dc=org" read by anonymous auth by * none
olcAccess: {4}to * by anonymous auth by self write by dn.exact="uid=mirroradmi
 n,dc=alexgv,dc=gonzalonazareno,dc=org" read by users read by * none
olcAccess: {5}to dn.base="" by group="cn=almacen,ou=Grupos,dc=alexgv,dc=gonzal
 onazareno,dc=org" by self write
olcAccess: {6}to dn.base="" by group="cn=almacen,ou=Grupos,dc=alexgv,dc=gonzal
 onazareno,dc=org" read
olcAccess: {7}to dn.base="" by group="cn=almacen,ou=Grupos,dc=alexgv,dc=gonzal
 onazareno,dc=org" search
~~~

## Crea las ACLs necesarias para que los usuarios del grupo admin puedan ver y modificar cualquier atributo de cualquier objeto.

~~~
dn: olcDatabase={1}mdb,cn=config
changetype: modify
add: olcAccess
olcAccess: {1}to * by dn="cn=admin,dc=alexgv,dc=gonzalonazareno,dc=org" write by group.exact="cn=admin,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org" write
~~~

* La añadimos.

~~~
usuario@apolo:~$ sudo ldapmodify -Y EXTERNAL -H ldapi:/// -f acladmin.ldif 
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
modifying entry "olcDatabase={1}mdb,cn=config"
~~~

* Y nuevamente comprobamos que está en funcionamiento.

~~~
usuario@apolo:~$ sudo ldapsearch -LLLQ -Y EXTERNAL -H ldapi:/// -b cn=config -s one olcAccess
dn: cn=module{0},cn=config

dn: cn=module{1},cn=config

dn: cn=module{2},cn=config

dn: cn=schema,cn=config

dn: olcDatabase={-1}frontend,cn=config
olcAccess: {0}to * by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=external
 ,cn=auth manage by * break
olcAccess: {1}to dn.exact="" by * read
olcAccess: {2}to dn.base="cn=Subschema" by * read

dn: olcDatabase={0}config,cn=config
olcAccess: {0}to * by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=external
 ,cn=auth manage by * break

dn: olcDatabase={1}mdb,cn=config
olcAccess: {0}to attrs=userPassword by self write by anonymous auth by * none
olcAccess: {1}to * by dn="cn=admin,dc=alexgv,dc=gonzalonazareno,dc=org" write 
 by group.exact="cn=admin,ou=Grupos,dc=alexgv,dc=gonzalonazareno,dc=org" write
olcAccess: {2}to attrs=shadowLastChange by self write by * read
olcAccess: {3}to * by * read
olcAccess: {4}to attrs=userPassword by self =xw by dn.exact="cn=admin,dc=alexg
 v,dc=gonzalonazareno,dc=org" =xw by dn.exact="uid=mirroradmin,dc=alexgv,dc=go
 nzalonazareno,dc=org" read by anonymous auth by * none
olcAccess: {5}to * by anonymous auth by self write by dn.exact="uid=mirroradmi
 n,dc=alexgv,dc=gonzalonazareno,dc=org" read by users read by * none
olcAccess: {6}to dn.base="" by group="cn=almacen,ou=Grupos,dc=alexgv,dc=gonzal
 onazareno,dc=org" by self write
olcAccess: {7}to dn.base="" by group="cn=almacen,ou=Grupos,dc=alexgv,dc=gonzal
 onazareno,dc=org" read
olcAccess: {8}to dn.base="" by group="cn=almacen,ou=Grupos,dc=alexgv,dc=gonzal
 onazareno,dc=org" search
~~~
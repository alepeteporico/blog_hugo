+++
title = "Configuración inicial de LDAP"
description = ""
tags = [
    "ASO"
]
date = "2022-01-14"
menu = "main"
+++

#### LDAP es un protocolo de tipo cliente-servidor para acceder a un servicio de directorio. Un directorio es como una base de datos, pero en general contiene información más descriptiva y más basada en atributos.

#### Realizaremos esta configuración inicial en nuestro escenario en kvm, en contreto en nuestra maquina `apolo`, la cual entre otras cosas contiene por ejemplo nuestro dns

* Empezemos con la instalación del paquete de ldap.

~~~
debian@apolo:~$ sudo apt install slapd
~~~

* Durante esta instalación tendremos que introducir una contraseña para el administrador.

![contraseña](/ldap/1.png)

* Una vez instalado se habrá abierto un socket en el puerto 389 que usa por defecto LDAP y está escuchando todas las peticiones desde la `0.0.0.0`, comprobemoslo

~~~
debian@apolo:~$ sudo netstat -tlnp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name             
tcp        0      0 0.0.0.0:389             0.0.0.0:*               LISTEN      1636/slapd                 
tcp6       0      0 :::389                  :::*                    LISTEN      1636/slapd
...
...
~~~

* Usemos `ldapsearch` para ejecutar una busqueda sobre el directorio. Vamos a listar todos los objetos existentes de la estructura que tenemos.

~~~
debian@apolo:~$ sudo ldapsearch -x -b "dc=alegv,dc=gonzalonazareno,dc=org"
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

# search result
search: 2
result: 0 Success

# numResponses: 2
# numEntries: 1
~~~

* Podemos crear grupos y unidades organizativas usando un fichero con extensión `.ldif`, veamos un ejemplo de uno de ellos en el que definiremos dos objetos, uno para almacenar usuarios y otro para grupos.

~~~
debian@apolo:~$ cat prueba.ldif 
dn: ou=Usuarios,dc=alegv,dc=gonzalonazareno,dc=org
objectClass: organizationalUnit
ou: Usuarios 

dn: ou=Grupos,dc=alegv,dc=gonzalonazareno,dc=org
objectClass: organizationalUnit
ou: Grupos
~~~

* Ahora mediante el comando `ldapadd` importaremos el fichero con sus unidades organizativas.

~~~
debian@apolo:~$ ldapadd -x -D "cn=admin,dc=alegv,dc=gonzalonazareno,dc=org" -f prueba.ldif -W
Enter LDAP Password: 
adding new entry "ou=Usuarios,dc=alegv,dc=gonzalonazareno,dc=org"

adding new entry "ou=Grupos,dc=alegv,dc=gonzalonazareno,dc=org"
~~~

* Vamos a realizar una busqueda anonima simplemente para comprobar que se han añadido estas nuevas unidades organizativas.

~~~
debian@apolo:~$ sudo ldapsearch -x -b "dc=alegv,dc=gonzalonazareno,dc=org"
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

# numResponses: 4
# numEntries: 3
~~~

* Así hemos comprobado que se han creado dos nuevas unidades organizativas.
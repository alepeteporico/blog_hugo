+++
title = "Instalación y configuración de LDAP"
description = ""
tags = [
    "ASO"
]
date = "2021-05-15"
menu = "main"
+++

**LDAP es un protocolo de tipo cliente-servidor para acceder a un servicio de directorio. Un directorio es como una base de datos, pero en general contiene información más descriptiva y más basada en atributos.**

* Lo primero que debemos hacer es verificar nuestro FQDN (Fully Qualified Domain Name) que usaremos mas tarde para la configuración.

        debian@freston:~$ hostname -f
        freston.alegv.gonzalonazareno.org

* Instalaremos el paquete de LDAP

        debian@freston:~$ sudo apt install slapd

* Durante esta instalación tendremos que introducir una contraseña para el administrador.

![contraseña](/ldap/1.png)

* Una vez instalado se habrá abierto un socket en el puerto 389 que usa por defecto LDAP y está escuchando todas las peticiones desde la `0.0.0.0`, comprobemoslo

        debian@freston:~$ sudo netstat -tlnp
        Active Internet connections (only servers)
        Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
        tcp        0      0 0.0.0.0:389             0.0.0.0:*               LISTEN      13740/slapd
        ...
        ...

* Ahora instalaremos el paquete `ldap-utils` que nos permitirá interactuar de muchas formas que veremos a continuación con el servidor.

        debian@freston:~$ sudo apt install ldap-utils

* Una vez instalado usemos `ldapsearch` para ejecutar una busqueda sobre el directorio. Vamos a listar todos los objetos existentes de la estructura que tenemos.

        debian@freston:~$ sudo ldapsearch -x -b "dc=alegv,dc=gonzalonazareno,dc=org"
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

        # search result
        search: 2
        result: 0 Success

        # numResponses: 3
        # numEntries: 2

* Ahora vamos a hacer una busqueda completa, necesitaremos autentificarnos ya que se muestra información delicada como contraseñas, aunque aparecen encriptadas.

        debian@freston:~$ ldapsearch -x -D "cn=admin,dc=alegv,dc=gonzalonazareno,dc=org" -b "dc=alegv,dc=gonzalonazareno,dc=org" -W
        Enter LDAP Password: 
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
        userPassword:: e1NTSEF9R24zTkFQL1RlaVFVOW5NOW1YNTJNUXhuMHBuaGZ0Um0=

        # search result
        search: 2
        result: 0 Success

        # numResponses: 3
        # numEntries: 2

* Podemos crear grupos y unidades organizativas usando un fichero con extensión `.ldif`, veamos un ejemplo de uno de ellos en el que definiremos dos objetos, uno para almacenar usuarios y otro para grupos

        debian@freston:~$ cat prueba.ldif 
        dn: ou=Usuarios,dc=alegv,dc=gonzalonazareno,dc=org
        objectClass: organizationalUnit
        ou: Usuarios 

        dn: ou=Grupos,dc=alegv,dc=gonzalonazareno,dc=org
        objectClass: organizationalUnit
        ou: Grupos

* Ahora mediante el comando `ldapadd` importaremos el fichero con sus unidades organizativas.

        debian@freston:~$ ldapadd -x -D "cn=admin,dc=alegv,dc=gonzalonazareno,dc=org" -f prueba.ldif -W
        Enter LDAP Password: 
        adding new entry "ou=Usuarios,dc=alegv,dc=gonzalonazareno,dc=org"

        adding new entry "ou=Grupos,dc=alegv,dc=gonzalonazareno,dc=org"

* Vamos a realizar una busqueda anonima simplemente para comprobar que se han añadido estas nuevas unidades organizativas.

        debian@freston:~$ sudo ldapsearch -x -b "dc=alegv,dc=gonzalonazareno,dc=org"
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

* Podemos ver que se han creado las dos nuevas unidades organizativas tal y como especificamos el fichero.
+++
title = "LDAP en alta disponibilidad"
description = ""
tags = [
    "ASO"
]
date = "2022-05-17"
menu = "main"
+++

### Vamos a instalar un servidor LDAP en ares que va a actuar como servidor secundario o de respaldo del servidor LDAP instalado en apolo, para ello habrá que seleccionar un modo de funcionamiento y configurar la sincronización entre ambos directorios, para que los cambios que se realicen en uno de ellos se reflejen en el otro.


## Metodo usado: LDAP Syncy Replication

* Usaremos este metodo ya que podemos adecuarlo a las necesidades de nuestro escenario como queramos debido a las diferentes útilidades que tiene. vamos a enumerarlss y explicar para que sirven cada una de ellas:

* **LDAP Content Synchronization Protocol:** Consiste en hacer una copia del `DIT` que esun esquema que contiene las reglas y toda la información de nuestro servidor principal al servidor secundario, y actualizará los cambios o bien usando el `pull-based` en el que el servidor secundario hará preguntas el primario en busca de actualizaciones periodicamente. O mediante el `push-based` donde el secundario estará a la escucha continuamente puesto que el primario mandará información de las actualizaciones una vez que se hagan.

- Ventajas: Facilidad al configurarlo, pues solo es necesario hacerlo en el secundario. Y facilidad al añadir los cambios, pues se enviarán todos una vez terminados.

- Desventajas: Al enviarse todos los datos esto consume muchos recursos, mas de los necesarios. Y No se pondrán hacer cambios desde el servidor secundario, pues solo se recogerań los cambios del primario.


* **Delta-syncrepl replication:** Es practicamente lo mismo, solo que no envia todos los datos cada vez que se actualiza, solo envia los cambios. Esto lo hace creando una base de datos y cuando van a actualizarse los datos, se consulta esa base de datos y solo enviara las diferencias.

- Ventajas: Como ya se ha dicho el tema de los recursos queda solucionado.

- Desventajas: La configuración es un poco más costosa, pues se tiene que hacer en los dos servidores. Y seguimos teniendo el problema de que solo se pueden hacer cambios desde el primario.


* **N-Way Multi-Provider Replication:** Con este metodo nos olvidamos de servidor primario y secundario, todos las máquinas actuaran como servidor primario y se comunicarán entre ellas.

- Ventajas: Si algún proveedor falla, otro podrá seguir haciendo actualizaciones. No hay un punto unico de fallo. Y los proveedores podrán estar ubicados en diferentes instancias físicas.

- Desventajas: En realidad los cambios se hacen unicamente en uno de los módulos y posteriormente son propagados. Necesita un servidor sldap en modo proxy para o un balanceador de carga para la comprobación de que el proveedor está activo, sino podrían corromperse la actualización de los datos.


* **MirrorMode:** Es un híbrido entre todos. Funciona de tal manera que tiene dos servidores primarios que se replican entre ellos mismos y la interfaz enterna se encarga de redirigir las escrituras unicamente a uno de los dos, entonces uno solo funcionará si el otro falla. Una vez arreglado el problema volverán a sincronizarse y no se perderá ninguna información.

- Ventajas: Está en alta disponibilidad. Mientras uno de los dos funcione se podrán hacer escrituras. Se mantienen siempre actualizados.

- Desventajas: Se sigue necesitando el servidor sldap o un balanceador de carga. Las escrituras unicamente se pueden realizar en uno de los dos.

--------------------------------------------

## Configuración

* Vamos a hacer un Mirror Mode, para ello primero vamos a dirigirnos a apolo y crear el usuario que servirá para administrar esto. Aunque primero tenemos que introducir una contraseña para ldap.

~~~
usuario@apolo:~$ sudo slappasswd
New password: 
Re-enter new password: 
{SSHA}wEbR9rYntYbu+aUFrNAfyik+pBCtdd3
~~~

* Ahora si, el fichero ldif para crear el usuario sería tal que así:

~~~
dn: uid=mirroradmin,dc=alexgv,dc=gonzalonazareno,dc=org
objectClass: account
objectClass: simpleSecurityObject
uid: mirroradmin
description: Usuario para alta disponibilidad
userPassword: {SSHA}wEbR9rYntYbu+aUFrNAfyik+pBCtdd3
~~~

* Añadimos este fichero a nuestro directorio.

~~~
usuario@apolo:~$ sudo ldapadd -x -D "cn=admin,dc=alexgv,dc=gonzalonazareno,dc=org" -f mirroradmin.ldif -W
Enter LDAP Password: 
adding new entry "uid=mirroradmin,dc=alexgv,dc=gonzalonazareno,dc=org"
~~~

* Ahora tendremos que darle privilegios a este usuario.

~~~
dn: olcDatabase={1}mdb,cn=config
changetype: modify
add: olcAccess
olcAccess: to attrs=userPassword
  by self =xw
  by dn.exact="cn=admin,dc=alexgv,dc=gonzalonazareno,dc=org" =xw
  by dn.exact="uid=mirroradmin,dc=alexgv,dc=gonzalonazareno,dc=org" read
  by anonymous auth
  by * none
olcAccess: to *
  by anonymous auth
  by self write
  by dn.exact="uid=mirroradmin,dc=alexgv,dc=gonzalonazareno,dc=org" read
  by users read
  by * none
~~~

* Añadimos los cambios.

~~~
usuario@apolo:~$ sudo ldapmodify -Y EXTERNAL -H ldapi:/// -f privilegiosad.ldif 
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
modifying entry "olcDatabase={1}mdb,cn=config"
~~~

* Nuevamente, creamos otro fichero donde cargaremos el módulo `syncprov` el cual sincronizará los dos servidores.

~~~
dn: cn=module{0},cn=config
changetype: modify
add: olcModuleLoad
olcModuleLoad: syncprov
~~~

* Realizamos los cambios.

~~~
usuario@apolo:~$ sudo ldapmodify -Y EXTERNAL -H ldapi:/// -f syncprov.ldif
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
modifying entry "cn=module{0},cn=config"
~~~

* Ahora debemos configurarlo.

~~~
dn: olcOverlay=syncprov,olcDatabase={1}mdb,cn=config
changetype: add
objectClass: olcSyncProvConfig
olcOverlay: syncprov
olcSpCheckpoint: 3 3
~~~

* Añadimos esta configuración.

~~~
usuario@apolo:~$ sudo ldapmodify -Y EXTERNAL -H ldapi:/// -f conf_syncprov.ldif 
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
adding new entry "olcOverlay=syncprov,olcDatabase={1}mdb,cn=config"
~~~

* Los servidores tienen un número identificativo, por lo que tenemos que añadirle uno al nuestro, este será el 1.

~~~
dn: cn=config
changetype: modify
add: olcServerId
olcServerId: 1
~~~

* Ejecutamos este fichero.

~~~
usuario@apolo:~$ sudo ldapmodify -Y EXTERNAL -H ldapi:/// -f ident.ldif 
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
modifying entry "cn=config"
~~~

* El último fichero que tenemos que configurar en el servidor apolo será uno donde añadiremos algunos parametros de sincronización y como habilitarse de este servicio.

~~~
dn: olcDatabase={1}mdb,cn=config
changetype: modify
add: olcSyncrepl
olcsyncrepl: rid=000
  provider=ldaps://ares.alexgv.gonzalonazareno.org 
  type=refreshAndPersist
  retry="3 3 300 +" 
  searchbase="dc=alexgv,dc=gonzalonazareno,dc=org"
  attrs="*,+" 
  bindmethod=simple
  binddn="uid=mirroradmin,dc=alexgv,dc=gonzalonazareno,dc=org"
  credentials=admin
-
add: olcDbIndex
olcDbIndex: entryUUID eq
olcDbIndex: entryCSN eq
-
replace: olcMirrorMode
olcMirrorMode: TRUE
~~~

* Y lo ejecutamos.

~~~
usuario@apolo:~$ sudo ldapmodify -Y EXTERNAL -H ldapi:/// -f mirror.ldif 
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
modifying entry "olcDatabase={1}mdb,cn=config"
~~~

### Ares

* En ares tambień debemos crear el usuario mirror, tal y como hemos hecho en apolo, lo único que debemos tener en cuenta son las siguientes modificaciones:

* En el fichero del identificador debemos poner un identificador distinto.

~~~
dn: cn=config
changetype: modify
add: olcServerId
olcServerId: 2
~~~

* Y el fichero donde se habilita y sincroniza está apuntando a apolo.

~~~
dn: olcDatabase={1}mdb,cn=config
changetype: modify
add: olcSyncrepl
olcsyncrepl: rid=000
  provider=ldaps://apolo.alexgv.gonzalonazareno.org 
  type=refreshAndPersist
  retry="3 3 300 +" 
  searchbase="dc=alexgv,dc=gonzalonazareno,dc=org"
  attrs="*,+" 
  bindmethod=simple
  binddn="uid=mirroradmin,dc=alexgv,dc=gonzalonazareno,dc=org"
  credentials=admin
-
add: olcDbIndex
olcDbIndex: entryUUID eq
olcDbIndex: entryCSN eq
-
replace: olcMirrorMode
olcMirrorMode: TRUE
~~~

* 
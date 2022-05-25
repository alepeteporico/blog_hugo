+++
title = "Poblar un directorio LDAP desde un fichero CSV"
description = ""
tags = [
    "ASO"
]
date = "2022-05-20"
menu = "main"
+++

* Crear entre todos los alumnos de la clase que vayan a hacer esta tarea un fichero CSV que incluya información personal de cada uno incluyendo los siguientes datos:

  * Nombre

  * Apellidos

  * Dirección de correo electrónico

  * Nombre de usuario

  * Clave pública ssh

* Otro fichero con la siguiente información de los alumnos:

  * Hostname

  * IPv4

  * Clave pública de la máquina

* Añadir el esquema openssh-lpk al directorio para poder incluir claves públicas ssh en un directorio LDAP.

* Hacer un script en bash o en python que utilice el fichero como entrada y pueble el directorio LDAP con un objeto para cada alumno utilizando los ObjectClass posixAccount e inetOrgPerson.

* Configurar el sistema para que sean válidos los usuarios del LDAP.

* Configurar el servicio ssh para que permita acceder a los usuarios del LDAP utilizando las claves públicas que hay allí, en lugar de almacenarlas en .ssh/authorized_keys, que sólo permita acceder a los equipos que estén en el LDAP en lugar del fichero .ssh/known_hosts y que se cree el directorio "home" al vuelo.

--------------------

## Creación del fichero CSV.

* Tenenmos un fichero csv con los siguientes usuarios:

~~~

~~~

* Ahora necesitamos que añadir el esquema openssh-lpk. Tendremos que crear un fichero ldif en `/etc/ldap/schema/` con este contenido:

~~~
dn: cn=openssh-lpk,cn=schema,cn=config
objectClass: olcSchemaConfig
cn: openssh-lpk
olcAttributeTypes: ( 1.3.6.1.4.1.24552.500.1.1.1.13 NAME 'sshPublicKey'
  DESC 'MANDATORY: OpenSSH Public key'
  EQUALITY octetStringMatch
  SYNTAX 1.3.6.1.4.1.1466.115.121.1.40 )
olcObjectClasses: ( 1.3.6.1.4.1.24552.500.1.1.2.0 NAME 'ldapPublicKey' SUP top AUXILIARY
  DESC 'MANDATORY: OpenSSH LPK objectclass'
  MAY ( sshPublicKey $ uid )
  )
~~~

* Ejecutamos este fichero.

~~~
usuario@apolo:/etc/ldap/schema$ sudo ldapadd -Y EXTERNAL -H ldapi:/// -f openssh-lpk.lidf 
SASL/EXTERNAL authentication started
SASL username: gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth
SASL SSF: 0
adding new entry "cn=openssh-lpk,cn=schema,cn=config"
~~~

## Script:

* La forma más comoda que he encotrado para crear este script es usando python, puesto que tiene una librería sencilla de usar llamada `pyhton3-ldap`

~~~
import ldap3
from ldap3 import Connection, ALL
from getpass import getpass
from sys import exit

# VARIABLES


# Directorio donde estarán los home de los usuarios.
home_dir = '/home/'

# Valor inicial del UID que se asignan al añadir un usuarios.
uid_number = 5000

# GID de usuarios.
gid = 5000

# Shell de los usuarios.
shell = '/bin/bash'


# PROGRAMA


# Lista de cada línea del csv.
with open('usuarios.csv', 'r') as usuarios:
  usuarios = usuarios.readlines()

# Parametros para realizar la conexión.
ldap_server = 'ldaps://apolo.alexgv.gonzalonazareno.org:636'
dominio = 'dc=alexgv,dc=gonzalonazareno,dc=org'
user_admin = 'admin' 
pass = getpass('Contraseña: ')

# Intento de conexión.
conn = Connection(ldap_server, 'cn={},{}'.format(user_admin, dominio),pass)

# Comprobación de que la conexión se realiza correctamente.

if not conn.bind():
  print('No se ha podido conectar con ldap') 
  if conn.result['description'] == 'invalidCredentials':
    print('Credenciales no validas.')
  # Termina el script.
  exit(0)

# Recorre la lista de usuarios.
for user in usuarios:
  # Separa la información de cada línea y la añade a su correspondiente variable.
  user = user.split(',')
  cn = user[0]
  sn = user[1]
  mail = user[2]
  uid = user[3]
  ssh = user[4]

  # Añade el usuario.
  conn.add(
    'uid={},ou=Personas,{}'.format(uid, dominio),
    object_class = 
      [
      'inetOrgPerson',
      'posixAccount', 
      'ldapPublicKey'
      ],
    attributes =
      {
      'cn': cn,
      'sn': sn,
      'mail': mail,
      'uid': uid,
      'uidNumber': str(uid_number),
      'gidNumber': str(gid),
      'homeDirectory': '{}{}'.format(home_dir,uid),
      'loginShell': shell,
      'sshPublicKey': str(ssh)
      })

  if conn.result['description'] == 'entryAlreadyExists':
    print('El usuario {} ya existe.'.format(uid))

  # Aumentamos el valor de UID para que no de problemas al crearse dos usuarios con uid iguales.
  uid_number += 1

#Cierra la conexion.
conn.unbind()
~~~

## Configurar que los usuarios sean validos.

* Configuramos el fichero `/etc/ldap/ldap.conf` y configuramos esta línea.

~~~
BASE    dc=alexgv,dc=gonzalonazareno,dc=org
URI ldaps://127.0.0.1
~~~

* Para que nuestro sistema pueda validar los UID y GID de ldap debemos añadir al fichero `/etc/nsswitch.conf` el servicio ldap de la siguiente forma:

~~~
passwd:         files systemd ldap
group:          files systemd ldap
shadow:         files ldap
~~~

* Ahora instalamos el paquete `apt install libnss-ldap`.
+++
title = "Gestion de Usuarios BBDD"
description = ""
tags = [
    "GBD"
]
date = "2023-01-04"
menu = "main"
+++

## Parte Individual:

### MongoDB

1. Averigua si existe la posibilidad en MongoDB de limitar el acceso de un usuario a los datos de una colección determinada.

* Al crear un usuario podemos especificar la colección que queremos que pueda acceder y los permisos que le damos sobre ella, como solo lectura o lectura y escritura... Para ello entramos con el usuario administrador, entramos en la base de datos sobre la que queremos darle privilegios y creamos este usuario.

~~~
> use nobel
switched to db nobel

> db.createUser({user: "prueba1", pwd: "prueba1", roles: [{role: "read", db: "nobel"}]})
Successfully added user: {
	"user" : "prueba1",
	"roles" : [
		{
			"role" : "read",
			"db" : "nobel"
		}
	]
}
~~~

* Hemos creado el usuario anterior el cual solo tiene permiso de lectura sobre la colecciones de la base de datos "nobel", ahora entraremos con este usuario a mongo, para ello debemos especificar mínimo el usuario y la base de datos a la que nos queremos conectar, aunque en mi caso también he añadido la contraseña.

~~~
vagrant@mongoagv:~$ mongo -u prueba1 -p prueba1 --authenticationDatabase "nobel"
~~~

* vamos a comprobar que podemos visualizar los datos.

~~~
> db.premios.find().pretty()
{
	"_id" : ObjectId("63b9c93c9cd6ef460b679a17"),
	"year" : "2021",
	"category" : "Chemistry",
	"laureates" : [
		{
			"id" : "1002",
			"firstname" : "Benjamin",
			"surname" : "List",
			"motivation" : "\"for the development of asymmetric organocatalysis\"",
			"share" : "2"
		},
		{
			"id" : "1003",
			"firstname" : "David",
			"surname" : "MacMillan",
			"motivation" : "\"for the development of asymmetric organocatalysis\"",
			"share" : "2"
		}
	]
}
~~~

* Pero si intentamos insertar un registro nos avisa de que no tenemos privilegios suficientes.

~~~
> db.premios.insertOne ({
...       "year": "2023",
...       "category": "Literature",
...       "laureates": [
...          {
...             "id": "1408",
...             "firstname": "Alejandro",
...             "surname": "Prueba",
...             "motivation": "\"Prueba de fallo\"",
...             "share": "2"
...          },
... {
... "id" : "1409",
... "firstname" : "Maria",
... "surname" : "Prueba2",
... "motivation" : "\"Prueba de fallo\"",
... "share" : "2"
... }
... ]
... })
uncaught exception: WriteCommandError({
	"ok" : 0,
	"errmsg" : "not authorized on nobel to execute command { insert: \"premios\", ordered: true, lsid: { id: UUID(\"b1891384-1e6b-476c-a075-489916c31946\") }, $db: \"nobel\" }",
	"code" : 13,
	"codeName" : "Unauthorized"
~~~

* Si queremos asignar nuevos roles a un usuario sobre una base de datos nueva usamos la siguiente orden.

~~~
db.grantRolesToUser('prueba1', 
  [ { db: 'otraBBDD', role: 'readWrite' } ]
)
~~~

2. Averigua si en MongoDB existe el concepto de privilegio del sistema y muestra las diferencias más importantes con ORACLE.

* Se podría decir que si podemos asignar privilegios de sistema a nuestro usuarios en mongodb, si creamos un usuario le podemos asignar distintos roles como hicimos anteriormente para dar permisos de escritura o lectura sobre una colección, pero esta vez son roles de sistema, veremos ejemplos en el siguiente apartado que trata sobre este asunto.


* **Diferencias con oracle:**
  * Aunque tambien podemos dar solo roles especificos usando la funcion "grantRole", tenemos tres roles que agrupan una gran cantidad de ellos en funcion de para que necesitemos el usuario. Mientras que en oracle debemos asignar roles concretos como la creación de usuarios (GRANT CREATE USER) o la inserción de datos (GRANT INSERT), podemos asignarlos a la vez, sin embargo, no tenemos un rol que agrupe varios de ellos como si tenemos en mongo. Como ya hemos dicho, en el siguiente apartado se especificarán estos roles generales, para que sirven y que roles más pequeños los componen.

3. Explica los roles por defecto que incorpora MongoDB y como se asignan a los usuarios.

+ Vamos a ver tres roles que tienen que ver con la administración de la base de datos y como asignarselos a un usuario que creemos, aunque también se especificará que usar para añadir estos roles a usuarios ya creados:
  
+ **dbAdmin** Permite gestionar datos pero no usuarios.

~~~
db.createUser({user: "administrador1", pwd: "administrador1", roles: [{role: "dbAdmin", db: "admin"}]})
~~~

~~~
> db.premios.listIndexes
nobel.premios.listIndexes

> db.createUser({user: "administrador2", pwd: "administrador2", roles: [{role: "userAdmin", db: "admin"}]})
uncaught exception: Error: couldn't add user: not authorized on admin to execute command { createUser: "administrador2", pwd: "xxx", roles: [ { role: "userAdmin", db: "admin" } ], digestPassword: true, writeConcern: { w: "majority", wtimeout: 600000.0 }, lsid: { id: UUID("61ff1096-b904-479a-885d-2b33395a3326") }, $db: "admin" } :
_getErrorWithCode@src/mongo/shell/utils.js:25:13
DB.prototype.createUser@src/mongo/shell/db.js:1367:11
@(shell):1:1
~~~

* Las funciones que puede usar son:
  *  collStats 
  *  dbHash 
  *  dbStats 
  *  killCursors 
  *  listIndexes 
  *  listCollections 
  *  bypassDocumentValidation 
  *  collMod 
  *  compact 
  *  convertToCapped


+ **userAdmin** Tenemos el caso completamente opuesto, un rol que puede gestionar usuarios pero no datos.

~~~
db.createUser({user: "administrador2", pwd: "administrador2", roles: [{role: "userAdmin", db: "admin"}]})
~~~

~~~
db.createUser({user: "administrador3", pwd: "administrador3", roles: [{role: "read", db: "nobel"}]})
Successfully added user: {
	"user" : "administrador3",
	"roles" : [
		{
			"role" : "read",
			"db" : "nobel"
		}
	]
}

> db.grantRolesToUser("administrador1", [ "readWrite", {role: "read", db: "nobel"} ])
~~~

* Las funciones que puede usar son:
  *  changeCustomData 
  *  changePassword 
  *  createRole 
  *  createUser 
  *  dropRole 
  *  dropUser 
  *  grantRole 
  *  revokeRole 
  *  setAuthenticationRestriction 
  *  viewRole 
  *  viewUser

+ **dbOwner** Puede realizar cualquier función de administración en la base de datos, por lo tanto es a la vez **userAdmin** como **dbAdmin**.

* *Podemos usar tambien "dbAdminAnyDatabase" o "userAdminAnyDatabase" para que puedan realizar las acciones sobre cualquier base de datos, o como hemos hecho decir que su base de datos es "admin"*

* Hemos visto como añadirlos a usuarios que creamos nuevos, sin embargo tambiént tenemos la opción de añadir roles especificos a usuarios ya creados tambien podemos dar solo roles especificos usando la funcion "grantRole" como hemos podido ver en el ejemplo de funcionamiento del rol **userAdmin** que dejaré aquí nuevamente.

~~~
> db.grantRolesToUser("administrador1", [ "readWrite", {role: "read", db: "nobel"} ])
~~~

* También podemos crear nuevos roles, vamos a ver un ejemplo que he encontrado en la página oficial de mongo de un rol que permite eliminar cualquier colección de cualquier base de datos que especifiquemos. Y nuevamente, podríamos asignar este rol a cualquier usuario que queramos.

~~~
db.createRole(
   {
     role: "dropSystemViewsAnyDatabase", 
     privileges: [
       {
         actions: [ "dropCollection" ],
         resource: { db: "", collection: "system.views" }
       }
     ],
     roles: []
   }
)
~~~

4. Explica como puede consultarse el diccionario de datos de MongoDB para saber que roles han sido concedidos a un usuario y qué privilegios incluyen.

* Ver los roles de un usuario es una tarea bastante sencilla, solo debemos usar la funcion "getUser"

~~~
> db.getUser("administrador1")
{
	"_id" : "admin.administrador1",
	"userId" : UUID("2ec38b76-6ddf-457c-bab2-c4bb8ba34452"),
	"user" : "administrador1",
	"db" : "admin",
	"roles" : [
		{
			"role" : "read",
			"db" : "nobel"
		},
		{
			"role" : "readWrite",
			"db" : "admin"
		},
		{
			"role" : "dbAdmin",
			"db" : "admin"
		}
	],
	"mechanisms" : [
		"SCRAM-SHA-1",
		"SCRAM-SHA-256"
	]
}
~~~

* Una vez tenemos todos los roles de este usuario podemos visualizar los privilegios que incluyen ese rol, en este caso con la función "getRoles" y dentro de esta función especificando que nos muestro los privilegios como veremos a continuación.

~~~
> db.getRole ( "dbAdmin", { showPrivileges: true } )
{
	"db" : "test",
	"role" : "dbAdmin",
	"roles" : [ ],
	"privileges" : [
		{
			"resource" : {
				"db" : "test",
				"collection" : ""
			},
			"actions" : [
				"bypassDocumentValidation",
				"collMod",
				"collStats",
				"compact",
				"convertToCapped",
				"createCollection",
				"createIndex",
				"dbStats",
				"dropCollection",
				"dropDatabase",
				"dropIndex",
				"enableProfiler",
				"listCollections",
				"listIndexes",
				"planCacheIndexFilter",
				"planCacheRead",
				"planCacheWrite",
				"reIndex",
				"renameCollectionSameDB",
				"storageDetails",
				"validate"
			]
		},
		{
			"resource" : {
				"db" : "test",
				"collection" : "system.profile"
			},
			"actions" : [
				"changeStream",
				"collStats",
				"convertToCapped",
				"createCollection",
				"dbHash",
				"dbStats",
				"dropCollection",
				"find",
				"killCursors",
				"listCollections",
				"listIndexes",
				"planCacheRead"
			]
		}
	],
	"inheritedRoles" : [ ],
	"inheritedPrivileges" : [
		{
			"resource" : {
				"db" : "test",
				"collection" : ""
			},
			"actions" : [
				"bypassDocumentValidation",
				"collMod",
				"collStats",
				"compact",
				"convertToCapped",
				"createCollection",
				"createIndex",
				"dbStats",
				"dropCollection",
				"dropDatabase",
				"dropIndex",
				"enableProfiler",
				"listCollections",
				"listIndexes",
				"planCacheIndexFilter",
				"planCacheRead",
				"planCacheWrite",
				"reIndex",
				"renameCollectionSameDB",
				"storageDetails",
				"validate"
			]
		},
		{
			"resource" : {
				"db" : "test",
				"collection" : "system.profile"
			},
			"actions" : [
				"changeStream",
				"collStats",
				"convertToCapped",
				"createCollection",
				"dbHash",
				"dbStats",
				"dropCollection",
				"find",
				"killCursors",
				"listCollections",
				"listIndexes",
				"planCacheRead"
			]
		}
	],
	"isBuiltin" : true
}
~~~

* Nos muestra esta extensa lista de los privilegios que tiene el rol "dbAdmin", esto podemos hacerlo con cualquier rol.


### Oracle

1. Realiza un procedimiento llamado MostrarObjetosAccesibles que reciba un nombre de usuario y muestre todos los objetos a los que tiene acceso.

~~~
CREATE OR REPLACE PROCEDURE
~~~
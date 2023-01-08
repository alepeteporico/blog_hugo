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

* Se podría decir que si podemos asignar roles de sistema a nuestro usuarios en mongodb, si creamos un usuario le podemos asignar distintos roles como hicimos anteriormente pero de sistema, veremos algunos ejemplos a continuación.

+ Vamos a ver tres roles que tienen que ver con la administración de la base de datos:
  
  + **dbAdmin** Permite gestionar datos pero no usuarios.

~~~
db.createUser({user: "administrador1", pwd: "administrador1", roles: [{role: "dbAdmin", db: "admin"}]})
~~~

~~~
> db.premios.remove({"id": "976"});
WriteResult({ "nRemoved" : 1 })

> db.createUser({user: "administrador2", pwd: "administrador2", roles: [{role: "userAdmin", db: "admin"}]})
uncaught exception: Error: couldn't add user: not authorized on admin to execute command { createUser: "administrador2", pwd: "xxx", roles: [ { role: "userAdmin", db: "admin" } ], digestPassword: true, writeConcern: { w: "majority", wtimeout: 600000.0 }, lsid: { id: UUID("61ff1096-b904-479a-885d-2b33395a3326") }, $db: "admin" } :
_getErrorWithCode@src/mongo/shell/utils.js:25:13
DB.prototype.createUser@src/mongo/shell/db.js:1367:11
@(shell):1:1
~~~

  + Tenemos el caso completamente opuesto, un rol que puede gestionar usuarios pero no datos.



  + geg



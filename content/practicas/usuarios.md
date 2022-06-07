+++
title = "Usuarios bases de datos"
description = ""
tags = [
    "ABD"
]
date = "2022-05-17"
menu = "main"
+++

## (ORACLE, Postgres, MySQL) Crea un usuario llamado Becario y, sin usar los roles de ORACLE, dale los siguientes privilegios:

### Oracle

* Conectarse a la base de datos.

~~~
GRANT CREATE SESSION TO Becario;
~~~

* Modificar el número de errores en la introducción de la contraseña de cualquier usuario.

~~~
GRANT CREATE PROFILE TO Becario;

CREATE PROFILE Limitepasswd LIMIT
FAILED_LOGIN_ATTEMPTS 5;
~~~

* Modificar índices en cualquier esquema (este privilegio podrá pasarlo a quien quiera)

~~~

~~~
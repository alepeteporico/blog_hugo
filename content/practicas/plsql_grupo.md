+++
title = "Interconexion 2023"
description = ""
tags = [
    "GBD"
]
date = "2022-12-03"
menu = "main"
+++

* Realiza una función ComprobarPago que reciba como parámetros un código de cliente y un código de actividad y devuelva un TRUE si el cliente ha pagado la última actividad con ese código que ha realizado y un FALSE en caso contrario. Debes controlar las siguientes excepciones: Cliente inexistente, Actividad Inexistente, Actividad realizada en régimen de Todo Incluido y El cliente nunca ha realizado esa actividad.

~~~
CREATE OR REPLACE PROCEDURE ClienteInexistente (v_codcliente personas.NIF%type)
IS
    ind_existe  number:=0;
BEGIN
    SELECT count(*) into ind_existe
    FROM personas
    WHERE NIF=v_codcliente;

    IF ind_existe=0 then
        raise_application_error(-20001,'El cliente especificado no existe');
    END IF;
END;
/

CREATE OR REPLACE PROCEDURE ActividadInexistente (v_codactividad Actividades.Codigo%type)
IS
    ind_existe  number:=0;
BEGIN
    SELECT count(*) into ind_existe
    FROM personas
    WHERE NIF=v_codactividad;

    IF ind_existe=0 then
        raise_application_error(-20002,'El cliente especificado no existe');
    END IF;
END;
/

CREATE OR REPLACE PROCEDURE ActividadTodoIncluido (v_codactividad Actividades.Codigo%type)


END ActividadesInexistente;

CREATE OR REPLACE PROCEDURE ComprobarPago (v_codcliente, v_codactvidad )
IS
    comprobacion
BEGIN
    SELECT CodigoActividad
    FROM 
~~~

EXEC ClienteInexistente('06853683V');
+++
title = "practica grupal plsql"
description = ""
tags = [
    "GBD"
]
date = "2022-12-03"
menu = "main"
+++

* Realiza una función ComprobarPago que reciba como parámetros un código de cliente y un código de actividad y devuelva un TRUE si el cliente ha pagado la última actividad con ese código que ha realizado y un FALSE en caso contrario. Debes controlar las siguientes excepciones: Cliente inexistente, Actividad Inexistente, Actividad realizada en régimen de Todo Incluido y El cliente nunca ha realizado esa actividad.

~~~
CREATE OR REPLACE PROCEDURE ClienteInexistente (v_codcliente personas.NIF%type) IS
    06852683V NUMBER;
BEGIN
    SELECT COUNT(*) INTO 06852683V
    FROM personas
    WHERE NIF=v_codcliente;
    IF 06852683V=0 THEN
        RAISE_APPLICATION_ERROR(-20001,'El cliente especificado no existe');
    ELSE
        DBMS_OUTPUT.PUT_LINE('El cliente existe');
    END IF;
END;
/

CREATE OR REPLACE PROCEDURE ActividadInexistente (v_codactividad Actividades.Codigo%type)
IS
    v_actividad NUMBER;
BEGIN
    SELECT count(*) into v_actividad
    FROM actividades
    WHERE Codigo=v_codactividad;

    IF v_actividad=0 then
        raise_application_error(-20002,'La actividad especificada no existe');
    END IF;
END;
/

CREATE OR REPLACE PROCEDURE ActividadTodoIncluido (v_codactividad Actividades.Codigo%type, v_codcliente Estancias.NIFCliente%type)
IS
    v_codreg    regimenes.CodigoRegimen%type;
BEGIN
    SELECT CodigoRegimen INTO v_codreg
    FROM estancias
    WHERE NIFCliente=v_codcliente
    AND fecha_inicio
    AND WHERE Codigo = (
        SELECT CodigoEstancia
        FROM ActividadesRealizadas
        WHERE CodigoActividad=v_codactividad
    );

END;
/

CREATE OR REPLACE PROCEDURE ActividadNoRealizada (v_codcliente, v_codactividad)
IS
    v_codigoestancia NUMBER;
BEGIN
    SELECT count(*) INTO v_codigoestancia
    FROM Estancias
    WHERE NIFCliente=v_codcliente
    AND Codigo = (
        SELECT CodigoEstancia
        FROM ActividadesRealizadas
        WHERE
    )


CREATE OR REPLACE PROCEDURE ComprobarPago (v_codcliente, v_codactvidad )
IS
    comprobacion
BEGIN
    SELECT CodigoActividad
    FROM 
~~~

EXEC ClienteInexistente('54890865P');

SELECT CodigoRegimen
FROM estancias
WHERE NIFCliente='10950967T'
AND Codigo = (
    SELECT CodigoEstancia
    FROM ActividadesRealizadas
    WHERE CodigoActividad='A001'
);

    SELECT COUNT(*)
    FROM actividadesrealizadas
    WHERE codigoactividad='A001' AND codigoestancia=(SELECT codigo FROM estancias WHERE codigoregimen = 'AD');


SELECT CodigoActividad
FROM ActividadesRealizadas
WHERE Fecha=(
    SELECT MAX(Fecha)
    FROM ActividadesRealizadas
    WHERE CodigoActividad='A032'
    AND CodigoEstancia=(
        SELECT Codigo
        FROM estancias
        WHERE NIFCliente='06852683V'
        AND Fecha_Inicio=(
            SELECT MAX(Fecha_Inicio)
            FROM estancias
            WHERE NIFCliente='06852683V'
        )
    )
)
AND abonado!=0;



~~~
CREATE OR REPLACE PROCEDURE PrecioDeRegimen (v_codregimen Tarfias.CodigoRegimen%type, v_añadido OUT NUMBER)
IS
    v_PrecioBaseAD    NUMBER(6,2);
    v_PrecioBaseMP    NUMBER(6,2);
    v_PrecioBasePC    NUMBER(6,2);
    v_PrecioBaseTI    NUMBER(6,2);

BEGIN
    v_PrecioBaseAD:=30;
    v_PrecioBaseMP:=45;
    v_PrecioBasePC:=65;
    v_PrecioBaseTI:=80;

    IF v_codregimen='AD'
    THEN
        v_añadido:=v_PrecioBaseAD;
    ELSE IF v_codregimen='MP'
    THEN
        v_añadido:=v_PrecioBaseMP;
    ELSE IF v_codregimen='PC'
    THEN
        v_añadido:=v_PrecioBasePC;
    ELSE IF v_codregimen='TI'
    THEN
        v_añadido:=v_PrecioBaseTI;
    END IF;
END;
/
~~~

~~~
CREATE OR REPLACE TRIGGER PrecioDeHabitacion
DECLARE

BEGIN
    
~~~
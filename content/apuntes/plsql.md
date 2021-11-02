+++
title = "PLSQL"
description = ""
tags = [
    "Apuntes"
]
date = "2021-09-20"
menu = "main"
+++

## TRIGGERS

* Trozo de código que se ejecuta cuando sucede algo que especifiquemos.

### Triggers de datos

* Se asocian a operaciones que modifica datos de las tablas de la base de datos.

* Creación del trigger:

**Momento:** BEFORE, AFTER O INSTEAD OF
* BEFORE: Antes de la instrucción DML que queramos hacer, normalmente sirve para hacer comprobaciones y saber si realizar esa instrucción o no
* AFTER: Normalmente usado para saber si se ha realizado esa sentencia.
* INSTEAD OF: Sirve para modificar vistas que no se pueden actualizar.

**Evento:** INSERT, UPDATE O DELETE

**Nombre de tabla:** On Nombre_tabla

**Tipo de disparo:** Por sentencia, Por fila
* Por sentencia: Se ejecuta una vez, incluso cuando no haya filas afectadas. Lo usaremos cuando la acción no tenga que ver de los valores a los que afecta la operación por la que se activa.
* Por fila: Se ejecuta tantas veces como filas se vean afectadas por la sentencia. Al contrario que por sentencia, lo usaremos cuando los datos se vean afectados por la operación.

**Cuerpo de trigger:** Puede contener variables, cursores, excepciones...
~~~
DECLARE
BEGIN
EXCEPTION
END;
~~~

**Predicados condicionales:**
* IF INSERTING THEN...
* IF UPDATING [(nombre columna)] THEN...
* IF DELETING THEN...

**Uso de :old y :new:** Sirve para referirse al valor anterior o nuevo de una modificación.

**Operaciones que no podemos hacer en un trigger:**
* Operaciones DDL
* Instrucciones de control de transacciones (COMMIT, ROLLBACK, ...)
* Por fila: No puedo consultar los datos de la tabla que ha disparado el trigger (tablas mutantes).

### EJEMPLOS

* Trigger que impida insertar datos en la tabla `emp` fuera del horario normal de oficina:

~~~
CREATE OR REPLACE TRIGGER SeguridadEmp
BEFORE INSERT ON emp
BEGIN
  IF (TO_CHAR(sysdate,'DY') IN ('SAT','SUN') OR
  TO_CHAR(sysdate,'HH24') NOT BETWEEN '08' AND '15') THEN
    RAISE_APPLICATION_ERROR(-20100,'No puedes insertar registros fueras del horario de oficina');
  END IF;
END;
~~~

* Trigger que nos impida insertar a un empeado ganar mas de 5000 si no es el presidente (Resolución de problema de tablas mutantes):

~~~
CREATE OR REPLACE TRIGGER ControlSueldo
BEFORE INSERT OR UPDATE ON EMP
FOR EACH ROW

BEGIN
  IF :new.sal>5000 AND :new.job!='PRESIDENT' THEN
    RAISE_APPLICATION_ERROR(-20100, 'No puede ganar tanto si no es el presidente);
  END IF;
END;
~~~

### Diccionario de datos:

* [Pagina de referencia](https://ss64.com/)
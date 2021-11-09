+++
title = "Boletín de Triggers"
description = ""
tags = [
    "ABD"
]
date = "2021-11-09"
menu = "main"
+++

### Haz un trigger que solo permita a los vendedores tener comisiones.

~~~
CREATE OR REPLACE TRIGGER Com_vend
BEFORE INSERT OR UPDATE ON emp
BEGIN
    IF JOB!='Vendedor' THEN
      RAISE_APPLICATION_ERROR(-20100,'Los empleados que no sean vendedores no pueden tener comisiones');
    END IF;
END;
~~~

### Registrar todas las operaciones sobre la tabla EMP de SCOTT en una tabla llamada AUDIT_EMP donde se guarde usuario, fecha, tipo de operación y datos que ha modificado.

~~~
CREATE OR REPLACE TRIGGER audit_empleados
AFTER INSERT OR UPDATE OR DELETE ON emp
BEGIN
    INSERT INTO AUDIT_EMP()
~~~
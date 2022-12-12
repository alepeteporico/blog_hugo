+++
title = "Interconexion 2023"
description = ""
tags = [
    "GBD"
]
date = "2022-12-03"
menu = "main"
+++

1. Hacer un procedimiento que muestre el nombre y el salario del empleado cuyo código es 7082.

~~~
CREATE OR REPLACE PROCEDURE cod_7082
    IS
        vnombre emp.ename%TYPE;
        vsal emp.sal%TYPE;
    BEGIN
        SELECT ename, sal INTO vnombre, vsal
        FROM EMP
            WHERE EMPNO='7082';
        dbms_output.put_line('El empleado: '||vnombre||', gana: '||vsal);
END cod_7082;
~~~

~~~
SQL> exec cod_7082;
El empleado: ALEJANDRO, gana: 2050

PL/SQL procedure successfully completed.
~~~

2. Hacer un procedimiento que reciba como parámetro un código de empleado y devuelva su nombre

~~~
CREATE OR REPLACE PROCEDURE cod_nombre (cod_emp emp.empno%TYPE)
IS
    nombre_emp emp.ename%TYPE;
BEGIN
    SELECT ename INTO nombre_emp
    FROM EMP
        WHERE empno=cod_emp;
    dbms_output.put_line('El nombre de este empleado es: '||nombre_emp);
END cod_nombre;
~~~

~~~
SQL> exec cod_nombre (7900);
El nombre de este empleado es: JAMES

PL/SQL procedure successfully completed.
~~~

3. Hacer un procedimiento que devuelva los nombres de los tres empleados más antiguos

~~~
CREATE OR REPLACE PROCEDURE old_emp
IS
    cont    NUMBER = 1;
    vnombre emp%ROWTYPE;
BEGIN
    SELECT ENAME INTO vnombre
    FROM EMP
    ORDER BY TO_CHAR(HIREDATE, 'yyyy-MM-dd') ASC;

    dbms_output.put_line(vnombre);
END old_emp;

    WHILE cont < 4
        dbms_output.put_line('Empleado '||cont||': '||);
        cont=cont+1;
~~~
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
    CURSOR c_empleados IS
        SELECT ENAME
        FROM EMP
        ORDER BY TO_CHAR(HIREDATE, 'yyyy-MM-dd') ASC
        FETCH FIRST 3 ROWS ONLY;
    v_nombre emp.ename%type;
    cont NUMBER=1;
BEGIN
    FOR v_empleados IN c_empleados
    LOOP
        dbms_output.put_line('Empleado '||cont||': '||v_empleados);
        cont=cont+1;
    END LOOP;
END old_emp;
~~~

CREATE OR REPLACE PROCEDURE mostrar_antiguos
IS
  CURSOR c_antiguos IS
    SELECT ename
    FROM emp
    ORDER BY hiredate
    FETCH FIRST 3 ROWS ONLY;
  v_nombre emp.ename%TYPE;
BEGIN
    FOR v_antiguos IN c_antiguos
    LOOP
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || v_antiguos.ename);
    END LOOP;
END;
/
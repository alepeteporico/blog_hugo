+++
title = "Pequeño ejercicio plsql"
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
    cont NUMBER:=1;
BEGIN
    FOR v_empleados IN c_empleados
    LOOP
        dbms_output.put_line('Empleado '||cont||': '||v_empleados);
        cont:=cont+1;
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
BEGIN
    FOR v_antiguos IN c_antiguos
    LOOP
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || v_antiguos.ename);
    END LOOP;
END;
/




~~~
CREATE OR REPLACE FUNCTION ActividadTodoIncluidoTrue (v_codactividad actividades.codigo%type)
    RETURN
        comprobacion VARCHAR2
    CURSOR c_todoIncluido IS
        SELECT COUNT(*)
        FROM actividadesrealizadas
        WHERE codigoestancia = (SELECT codigo FROM estancias WHERE codigoregimen='TI') AND codigoactividad=v_codactividad;
    v_todoIncluido NUMBER;
BEGIN
    OPEN c_todoIncluido;
    FETCH c_todoIncluido INTO v_todoIncluido;
    IF v_todoIncluido>0 THEN
        comprobacion:='T';
    ELSE
        comprobacion:='F';
    END IF;
    CLOSE c_todoIncluido;
    RETURN comprobacion;
END;
/
~~~

~~~
CREATE OR REPLACE PROCEDURE RellenarBalance
IS
    v_codestancia actividadesrealizadas.codigoestancia%rowtype
    v_codactividad actividadesrealizadas.codigoactividad%rowtype
    v_fecha actividadesrealizadas.fecha%rowtype

    CURSOR c_actividades IS
    SELECT CodigoActividad, CodigoEstancia, Fecha INTO v_codactividad, c_codestancia, v_fecha
    FROM ActividadesRealizadas;
BEGIN
    OPEN c_actividades;
    FETCH c_actividades INTO v_codactividad, v_codestancia, v_fecha;

    WHILE c_actividades%FOUND LOOP
    UPDATE ActividadesRealizadas
    SET BalanceHotel = NVL(SELECT PrecioporPersona, ComisionHotel, CostePersonaparaHotel
                            FROM Actividades
                            WHERE Codigo=v_codactividad) * (SELECT NumPersonas
                                                FROM ActividadesRealizadas
                                                WHERE CodigoActividad = v_codactividad
                                                AND CodigoEstancia = v_codestancia
                                                AND Fecha = v_fecha);
    END LOOP;
    CLOSE c_actividades;
END;
/
~~~

~~~
CREATE OR REPLACE PROCEDURE SacarPersonasPorActividad (v_codactividad actividadesrealizadas.codigoactividad%type, v_codestancia actividadesrealizadas.codigoestancia%type, v_fecha actividadesrealizadas.fecha%type)
IS
    v_precioporpersona  actividades.PrecioPorPersona%type;
    v_comisionhotel actividades.ComisionHotel%type;
    v_costepersonaparahotel actividades.CostePersonaParaHotel%type;
    v_numpersonas   actividadesrealizadas.NumPersonas%type;
    v_balance   NUMBER(6,2);
BEGIN
    SELECT PrecioporPersona, ComisionHotel, CostePersonaParaHotel INTO v_precioporpersona, v_comisionhotel, v_costepersonaparahotel
    FROM Actividades
    WHERE Codigo=v_codactividad;

    SELECT NumPersonas INTO v_numpersonas
    FROM ActividadesRealizadas
    WHERE CodigoActividad=v_codactividad
    AND CodigoEstancia=v_codestancia
    AND Fecha=v_fecha;

    IF ActividadTodoIncluido='TRUE'
    THEN
        v_balance=v_precioporpersona + costepersonaparahotel) * v_numpersonas;
    ELSE
        v_balance=((v_precioporpersona + v_costepersonaparahotel + v_comisionhotel) * v_numpersonas) * -1;
    END IF;
    dbms_output.put_line(v_balance);
END;
/
~~~

~~~
CREATE OR REPLACE PROCEDURE CalcularNumPersonas (v_codactividad actividadesrealizadas.codigoactividad%type, v_codestancia actividadesrealizadas.codigoestancia%type, v_fecha actividadesrealizadas.fecha%type, v_numpersonas OUT actividadesrealizadas.NumPersonas%type)
IS
BEGIN
    SELECT NumPersonas INTO v_numpersonas
    FROM ActividadesRealizadas
    WHERE CodigoActividad=v_codactividad
    AND CodigoEstancia=v_codestancia
    AND Fecha=v_fecha;
END;
/
~~~

v_balance OUT actividadesrealizadas.balancehotel%type

CREATE OR REPLACE PROCEDURE CalcularPrecioBalance (v_codactividad actividadesrealizadas.codigoactividad%type, v_codestancia actividadesrealizadas.codigoestancia%type, v_fecha actividadesrealizadas.fecha%type, v_balance OUT NUMBER)
IS
    v_precioporpersona  actividades.PrecioPorPersona%type;
    v_comisionhotel actividades.ComisionHotel%type;
    v_costepersonaparahotel actividades.CostePersonaParaHotel%type;
    v_numpersonas   actividadesrealizadas.NumPersonas%type;
    v_regimen   VARCHAR2(4);
BEGIN
    SELECT PrecioporPersona, ComisionHotel, CostePersonaParaHotel INTO v_precioporpersona, v_comisionhotel, v_costepersonaparahotel
    FROM Actividades
    WHERE Codigo=v_codactividad;

    CalcularNumPersonas(v_codactividad, v_codestancia, v_fecha, v_numpersonas);
    EstanciaTodoIncluido(v_codestancia, v_regimen);

    IF v_regimen='TI'
    THEN
        v_balance:=v_precioporpersona * v_numpersonas;
    ELSE
        v_balance:=((v_precioporpersona + v_costepersonaparahotel + v_comisionhotel) * v_numpersonas) * -1;
    END IF;
    dbms_output.put_line(v_balance);
END;
/

exec calcularpreciobalance('A032', '04', '04-AUG-15');

~~~
CREATE OR REPLACE PROCEDURE EstanciaTodoIncluido (v_codestancia actividadesrealizadas.codigoestancia%type, v_codregimen OUT VARCHAR2)
AS
BEGIN
    SELECT CodigoRegimen INTO v_codregimen
    FROM Estancias
    WHERE Codigo=v_codestancia;
END;
/
~~~

EXEC ActividadTodoIncluido ('A032', to_DATE('07-08-2015','DD-MM-YYYY'));


SELECT NumPersonas
FROM ActividadesRealizadas
WHERE CodigoActividad = 'A001'
AND CodigoEstancia = '01'
AND Fecha = to_DATE('20-05-2015 17:30','DD-MM-YYYY hh24:mi');





SELECT CodigoRegimen
    FROM Estancias
    WHERE Codigo='04';


INSERT INTO actividadesrealizadas(CodigoEstancia, CodigoActividad, Fecha, NumPersonas, Abonado)
VALUES ('01','C093',to_DATE('20-05-2018 17:30','DD-MM-YYYY hh24:mi'),2,'S');
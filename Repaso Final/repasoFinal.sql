/*
1. Escribir un bloque PL/SQL que reciba una cadena y visualice el  nombre (ename) y el 
codigo de empleado (empno)  de todos los empleados cuyo apellido contenga la cadena 
especificada (variable sustitución “&”). Al finalizar visualizar el número de empleados 
mostrados. En caso no exista ningún empleado con dicha cadena generar una Excepción 
que lance el mensaje “Empleado no existe” en consola. ejemplo si ingreso la cadena ‘NE’ 
deberá mostrar en consola: (Utilizar variables tipo TYPE)
7566 - JONES
7844 - TURNER
NUMERO DE EMPLEADOS: 2
*/

CREATE OR REPLACE  PROCEDURE SP_PREGUNTA1(CAD IN EMP.ENAME%TYPE)
AS
	K INTEGER;
	V_EMPNO EMP.EMPNO%TYPE;
	V_ENAME EMP.ENAME%TYPE;
	CURSOR C IS 
	SELECT EMPNO, ENAME FROM EMP WHERE ENAME LIKE '%'||CAD||'%';
BEGIN
	K:=0;
	OPEN C;
	LOOP FETCH C INTO V_EMPNO, V_ENAME;
		EXIT WHEN C%NOTFOUND;
		DBMS_OUTPUT.PUT_LINE(V_EMPNO||' - '||V_ENAME);
		K:=K+1;
	END LOOP;
	CLOSE C;
	DBMS_OUTPUT.PUT_LINE('NUMERO DE EMPLEADOS: '||K);
END SP_PREGUNTA1;

SET SERVEROUTPUT ON;
EXECUTE SP_PREGUNTA1('AR');


/*
2. Elaborar un bloque PL/SQL que visualice en consola (buffer) el Código del departamento, 
las 3 últimas letras del nombre del departamento, y el salario promedio redondeado a 1 
decimal de los 3 primeros departamentos ordenados de mayor a menor de acuerdo al 
salario promedio obtenido. (utilizar cursores)
*/

CREATE OR REPLACE FUNCTION SAL_PROM(COD_DEP IN DEPT.DEPTNO%TYPE)
RETURN EMP.SAL%TYPE
IS
 V_SAL_PROM EMP.SAL%TYPE;
BEGIN
	SELECT AVG(SAL) INTO V_SAL_PROM 
	FROM EMP 
	WHERE DEPTNO = COD_DEP;
  IF V_SAL_PROM IS NULL THEN
    RETURN 0;
  END IF;
	RETURN V_SAL_PROM;
END SAL_PROM;

DECLARE
	V_DEPTNO DEPT.DEPTNO%TYPE;
	V_DNAME DEPT.DNAME%TYPE;
	CURSOR C IS
	SELECT DEPTNO, DNAME
	FROM DEPT ORDER BY SAL_PROM(DEPTNO);
BEGIN
	OPEN C;
	LOOP
		FETCH C INTO V_DEPTNO, V_DNAME;
		EXIT WHEN C%NOTFOUND;
		DBMS_OUTPUT.PUT_LINE(V_DEPTNO||'-'||SUBSTR(V_DNAME,LENGTH(V_DNAME)-2,3));
	END LOOP;
	CLOSE C;
END;

/*
3. Crear un Store Procedure SP_COMISION que actualice el campo COMM de la tabla EMP 
con un 10% del Salario a los Empleados cuyo Departamentos tengan de 0 a 1 empleados, 
20% del Salario a los Empleados cuyo Departamentos tengan de 2 a 3 empleados y 40% 
del Salario a los Empleados cuyo Departamentos tengan mas de 3 empleados. El 
procedure no necesita que ingrese variables. (validar el resultado con un SELECT a la 
tabla EMP)
*/

CREATE OR REPLACE PROCEDURE SP_COMISION
AS
V_DEPTNO DEPT.DEPTNO%TYPE;

CURSOR C1 IS
SELECT D.DEPTNO FROM EMP E, DEPT D
WHERE E.DEPTNO=D.DEPTNO 
GROUP BY D.DEPTNO, D.DNAME
HAVING COUNT(E.EMPNO) BETWEEN 0 AND 1;

CURSOR C2 IS
SELECT D.DEPTNO FROM EMP E, DEPT D
WHERE E.DEPTNO=D.DEPTNO 
GROUP BY D.DEPTNO, D.DNAME
HAVING COUNT(E.EMPNO) BETWEEN 2 AND 3;

CURSOR C3 IS
SELECT D.DEPTNO FROM EMP E, DEPT D
WHERE E.DEPTNO=D.DEPTNO 
GROUP BY D.DEPTNO, D.DNAME
HAVING COUNT(E.EMPNO) >3;
BEGIN

OPEN C1; 
  LOOP
    FETCH C1 INTO V_DEPTNO;
    EXIT WHEN C1%NOTFOUND;
    UPDATE EMP SET COMM=(SAL*0.10) WHERE DEPTNO=V_DEPTNO;
    COMMIT;
  END LOOP;
CLOSE C1;

OPEN C2; 
  LOOP
    FETCH C2 INTO V_DEPTNO;
    EXIT WHEN C2%NOTFOUND;
    UPDATE EMP SET COMM=(SAL*0.20) WHERE DEPTNO=V_DEPTNO;
   COMMIT;
  END LOOP;
CLOSE C2;

OPEN C3; 
  LOOP
    FETCH C3 INTO V_DEPTNO;
    EXIT WHEN C3%NOTFOUND;
    UPDATE EMP SET COMM=(SAL*0.40) WHERE DEPTNO=V_DEPTNO;
   COMMIT;
  END LOOP;
CLOSE C3;
END SP_COMISION;

EXECUTE SP_COMISION;

SELECT * FROM EMP;

/*
4. Crear una función FNC_UTILIDADES que al ingresar el código de un empleado me retorne 
el monto de sus UTILIDADES a depositar en su cuenta bancaria
Fórmula para hallar la UT= ((SALARIO * 6) + 15% SALARIO) / 3
NOTA: solo reciben utilidades aquellos empleados que hayan ingresado a la empresa 
después del 01/01/1982 en caso no cumpla se retornara 0 (ejecutar la función)
*/

CREATE OR REPLACE FUNCTION FNC_UTILIDADES(V_EMPNO IN EMP.EMPNO%TYPE)
RETURN NUMBER
IS
UT NUMBER := 0;
BEGIN
SELECT ROUND(SAL*(6.15)/3,2) INTO UT 
FROM EMP WHERE EMPNO=V_EMPNO AND HIREDATE >= '01/01/1981';
    IF UT IS NULL THEN
        RETURN 0;
        DBMS_OUTPUT.PUT_LINE('NO CORRESPONDE UT');
    ELSE
        RETURN UT;
    END IF;
END;

SET SERVEROUTPUT ON;
SELECT FNC_UTILIDADES('7654') FROM DUAL;
SELECT FNC_UTILIDADES('7369') FROM DUAL;


/*
5. Cree y ejecute el paquete PKG_CONTINUA2 que contenga el Store Procedure de la 
pregunta 3 y la Función de la pregunta 4.
Si en caso no logro realizar las preguntas 3 y 4 crear el paquete con estos 2 SP: 
a. 1 Procedimiento almacenado SP_INSDEPT – Ingresa todos los campos de la tabla 
dept. Si el departamento al ingresar ya existe enviar un mensaje en consola a través de 
una excepción “EL DEPARTAMENTO YA EXISTE”
b. 1 Procedimiento almacenado SP_DROPDEPT – Elimina un departamento a través de 
la columna DEPTNO. Si se requiere eliminar un departamento y este no existe enviar 
un mensaje en consola a través de una excepción “EL DEPARTAMENTO NO EXISTE 
O YA FUE ELIMINADO”. P
Probar el package ingresando el departamento con el procedure SP_INSDEPT:
 70-‘SISTEMAS’-‘ATE’
Probar el package borrando el departamento con el procedure SP_DROPDEPT:
*/

CREATE OR REPLACE PACKAGE PKG_CONTINUA2
IS
PROCEDURE P1;
PROCEDURE P2;
END;

CREATE OR REPLACE PACKAGE BODY PKG_CONTINUA2
IS
PROCEDURE P1
IS 
BEGIN

END P1;
PROCEDURE P2
IS 
BEGIN

END P2;
END PKG_CONTINUA2;

SET SERVEROUTPUT ON;

EXEC PKG_CONTINUA2.P1

EXEC PKG_CONTINUA2.P2
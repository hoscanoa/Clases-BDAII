/*
1. ESCRIBIR UN BLOQUE PL/SQL QUE RECIBA UNA CADENA Y VISUALICE EL  NOMBRE (ENAME) Y EL 
CODIGO DE EMPLEADO (EMPNO)  DE TODOS LOS EMPLEADOS CUYO APELLIDO CONTENGA LA CADENA 
ESPECIFICADA (VARIABLE SUSTITUCI�N �&�). AL FINALIZAR VISUALIZAR EL N�MERO DE EMPLEADOS 
MOSTRADOS. EN CASO NO EXISTA NING�N EMPLEADO CON DICHA CADENA GENERAR UNA EXCEPCI�N 
QUE LANCE EL MENSAJE �EMPLEADO NO EXISTE� EN CONSOLA. EJEMPLO SI INGRESO LA CADENA �NE� 
DEBER� MOSTRAR EN CONSOLA: (UTILIZAR VARIABLES TIPO TYPE)
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
2. ELABORAR UN BLOQUE PL/SQL QUE VISUALICE EN CONSOLA (BUFFER) EL C�DIGO DEL DEPARTAMENTO, 
LAS 3 �LTIMAS LETRAS DEL NOMBRE DEL DEPARTAMENTO, Y EL SALARIO PROMEDIO REDONDEADO A 1 
DECIMAL DE LOS 3 PRIMEROS DEPARTAMENTOS ORDENADOS DE MAYOR A MENOR DE ACUERDO AL 
SALARIO PROMEDIO OBTENIDO. (UTILIZAR CURSORES)
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
	SELECT  DEPTNO, DNAME
	FROM DEPT WHERE ROWNUM<4 ORDER BY SAL_PROM(DEPTNO);
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
3. CREAR UN STORE PROCEDURE SP_COMISION QUE ACTUALICE EL CAMPO COMM DE LA TABLA EMP 
CON UN 10% DEL SALARIO A LOS EMPLEADOS CUYO DEPARTAMENTOS TENGAN DE 0 A 1 EMPLEADOS, 
20% DEL SALARIO A LOS EMPLEADOS CUYO DEPARTAMENTOS TENGAN DE 2 A 3 EMPLEADOS Y 40% 
DEL SALARIO A LOS EMPLEADOS CUYO DEPARTAMENTOS TENGAN MAS DE 3 EMPLEADOS. EL 
PROCEDURE NO NECESITA QUE INGRESE VARIABLES. (VALIDAR EL RESULTADO CON UN SELECT A LA 
TABLA EMP)
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
4. CREAR UNA FUNCI�N FNC_UTILIDADES QUE AL INGRESAR EL C�DIGO DE UN EMPLEADO ME RETORNE 
EL MONTO DE SUS UTILIDADES A DEPOSITAR EN SU CUENTA BANCARIA
F�RMULA PARA HALLAR LA UT= ((SALARIO * 6) + 15% SALARIO) / 3
NOTA: SOLO RECIBEN UTILIDADES AQUELLOS EMPLEADOS QUE HAYAN INGRESADO A LA EMPRESA 
DESPU�S DEL 01/01/1982 EN CASO NO CUMPLA SE RETORNARA 0 (EJECUTAR LA FUNCI�N)
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
5. CREE Y EJECUTE EL PAQUETE PKG_CONTINUA2 QUE CONTENGA EL STORE PROCEDURE DE LA 
PREGUNTA 3 Y LA FUNCI�N DE LA PREGUNTA 4.
SI EN CASO NO LOGRO REALIZAR LAS PREGUNTAS 3 Y 4 CREAR EL PAQUETE CON ESTOS 2 SP: 
A. 1 PROCEDIMIENTO ALMACENADO SP_INSDEPT � INGRESA TODOS LOS CAMPOS DE LA TABLA 
DEPT. SI EL DEPARTAMENTO AL INGRESAR YA EXISTE ENVIAR UN MENSAJE EN CONSOLA A TRAV�S DE 
UNA EXCEPCI�N �EL DEPARTAMENTO YA EXISTE�
B. 1 PROCEDIMIENTO ALMACENADO SP_DROPDEPT � ELIMINA UN DEPARTAMENTO A TRAV�S DE 
LA COLUMNA DEPTNO. SI SE REQUIERE ELIMINAR UN DEPARTAMENTO Y ESTE NO EXISTE ENVIAR 
UN MENSAJE EN CONSOLA A TRAV�S DE UNA EXCEPCI�N �EL DEPARTAMENTO NO EXISTE 
O YA FUE ELIMINADO�. P
PROBAR EL PACKAGE INGRESANDO EL DEPARTAMENTO CON EL PROCEDURE SP_INSDEPT:
 70-�SISTEMAS�-�ATE�
PROBAR EL PACKAGE BORRANDO EL DEPARTAMENTO CON EL PROCEDURE SP_DROPDEPT:
*/

CREATE OR REPLACE PACKAGE PKG_CONTINUA2
AS
PROCEDURE SP_COMISION;
FUNCTION FNC_UTILIDADES(V_EMPNO IN EMP.EMPNO%TYPE) RETURN NUMBER;
END PKG_CONTINUA2;

CREATE OR REPLACE PACKAGE BODY PKG_CONTINUA2
AS
PROCEDURE SP_COMISION
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
--
FUNCTION FNC_UTILIDADES(V_EMPNO IN EMP.EMPNO%TYPE)
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
END FNC_UTILIDADES;
END PKG_CONTINUA2;

EXEC PKG_CONTINUA2.SP_COMISION;
SELECT PKG_CONTINUA2.FNC_UTILIDADES('7654') FROM DUAL;












/*********************************************************************/
/*********************************************************************/
/*********************************************************************/
/*********************************************************************/
/*********************************************************************/
/*********************************************************************/
LABORATORIO 03 � FNC, SP & PACKAGE

1.	CREE UN PROCEDIMIENTO ALMACENADO LLAMADO "SP_AUMENTA_SUELDO". DEBE INCREMENTAR EL SUELDO DE LOS EMPLEADOS CON CIERTA CANTIDAD DE A�OS EN LA EMPRESA (PAR�METRO "AYEAR" DE TIPO NUM�RICO) EN UN PORCENTAJE (PAR�METRO "APORCENTAJE" DE TIPO NUMERICO); ES DECIR, RECIBE 2 PAR�METROS. 
*EL CAMPO HIREDATE ES LA FECHA DE INGRESO DEL EMPLEADO A LA EMPRESA

CREATE OR REPLACE PROCEDURE SP_AUMENTA_SUELDO (AYEAR IN NUMBER , APORCENTAJE IN NUMBER ) IS
BEGIN
    UPDATE EMP SET SAL= SAL+ (APORCENTAJE/100)*SAL WHERE TRUNC((SYSDATE-HIREDATE)/360) = AYEAR;
    COMMIT;
END;

VALIDACI�N:
EXECUTE SP_AUMENTA_SUELDO(5,10);

BLOQUE DE EJECUCI�N:
SET SERVEROUTPUT ON
DECLARE
AYEAR NUMBER:=5;
APORCENTAJE NUMBER:=10;
BEGIN
SP_AUMENTA_SUELDO(AYEAR, APORCENTAJE);
END;


2.	CREAR UN STORE PROCEDURE QUE ACTUALICE EL CAMPO COMM DE LA TABLA EMP CON UN 10% DEL SALARIO A LOS EMPLEADOS CUYO DEPARTAMENTOS TENGAN DE 0 A 2 EMPLEADOS, 15% DEL SALARIO A LOS EMPLEADOS CUYO DEPARTAMENTOS TENGAN DE 3 A 5 EMPLEADOS Y 20% DEL SALARIO A LOS EMPLEADOS CUYO DEPARTAMENTOS TENGAN MAS DE 5 EMPLEADOS (USAR CURSORES, %TYPE  O %ROWTYPE) EL PROCEDURE NO NECESITA QUE INGRESE VARIABLES.

CREATE OR REPLACE PROCEDURE SP_ACTUALIZA_COMM
AS
V_DEPTNO DEPT.DEPTNO%TYPE;

CURSOR C1 IS
SELECT D.DEPTNO FROM EMP E, DEPT D
WHERE E.DEPTNO=D.DEPTNO 
GROUP BY D.DEPTNO, D.DNAME
HAVING COUNT(E.EMPNO) BETWEEN 0 AND 2;

CURSOR C2 IS
SELECT D.DEPTNO FROM EMP E, DEPT D
WHERE E.DEPTNO=D.DEPTNO 
GROUP BY D.DEPTNO, D.DNAME
HAVING COUNT(E.EMPNO) BETWEEN 3 AND 5;

CURSOR C3 IS
SELECT D.DEPTNO FROM EMP E, DEPT D
WHERE E.DEPTNO=D.DEPTNO 
GROUP BY D.DEPTNO, D.DNAME
HAVING COUNT(E.EMPNO) >5;

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
   UPDATE EMP SET COMM=(SAL*0.15) WHERE DEPTNO=V_DEPTNO;
   COMMIT;
  END LOOP;
CLOSE C2;

OPEN C3; 
  LOOP
    FETCH C3 INTO V_DEPTNO;
    EXIT WHEN C3%NOTFOUND;
   UPDATE EMP SET COMM=(SAL*0.20) WHERE DEPTNO=V_DEPTNO;
   COMMIT;
  END LOOP;
CLOSE C3;

END;

3.	CREAR UNA FUNCI�N QUE AL INGRESAR EL C�DIGO DE UN EMPLEADO ME RETORNE EL MONTO DE SU CTS A DEPOSITAR EN SU CUENTA BANCARIA

FORMULA PARA HALLAR LA CTS= ((SALARIO * 14 ) + 20% SALARIO ) / 6

NOTA: SOLO RECIBEN CTS AQUELLOS EMPLEADOS QUE HAYAN INGRESADO A LA EMPRESA DESPU�S DEL 01/06/1981 EN CASO NO CUMPLA SE RETORNARA 0 Y SE PINTARA EN CONSOLA UN MENSAJE QUE DIGA "NO CORRESPONDE CTS"

CREATE OR REPLACE FUNCTION FNC_CTS  (V_EMPNO IN  EMP.EMPNO%TYPE)
RETURN NUMBER
IS
CTS NUMBER := 0;
BEGIN

SELECT ROUND(((SAL*14) + (0.2*SAL)/6),2) INTO CTS FROM EMP WHERE EMPNO=V_EMPNO AND HIREDATE >= '01/06/1981';

    IF CTS IS NULL THEN
        RETURN 0;
        DBMS_OUTPUT.PUT_LINE('NO CORRESPONDE CTS');
    ELSE
        RETURN CTS;
    END IF;

END;

SCRIPT DE EJECUCION:
SET SERVEROUTPUT ON;
SELECT FNC_CTS('7654') FROM DUAL;

SELECT FNC_CTS('7369') FROM DUAL


4.	CREAR EL PACKAGE PKG_MANT_DEPT CON 3 STORES PROCEDURES:
 SP_INGRESA_DEPT � INGRESA TODOS LOS CAMPOS DE LA TABLA DEPT
*PARA EL C�DIGO DEL DEPARTAMENTO DEPTNO UTILIZAR UNA SEQUENCIA QUE EMPIECE EN 60 Y EL VALOR INCREMENTE DE 10 EN 10
 SP_ACTUALIZA_DEPT � ACTUALIZA LOS DATOS DE UN DEPARTAMENTO A TRAV�S DEL DEPTNO
 SP_ELIMINA_DEPT � ELIMINA UN DEPARTAMENTO A TRAV�S DE LA COLUMNA DEPTNO

TENER EN CUENTA QUE SE CUMPLAN LAS SIGUIENTES VALIDACIONES:
�	SI EL DEPARTAMENTO AL INGRESAR YA EXISTE ENVIAR UN MENSAJE EN CONSOLA A TRAV�S DE UNA EXCEPCI�N �EL DEPARTAMENTO YA EXISTE�
�	SI SE REQUIERE ACTUALIZAR UN DEPARTAMENTO Y ESTE NO EXISTE ENVIAR UN MENSAJE EN CONSOLA A TRAV�S DE UNA EXCEPCI�N �EL DEPARTAMENTO NO EXISTE�
�	SI SE REQUIERE ELIMINAR UN DEPARTAMENTO Y ESTE NO EXISTE ENVIAR UN MENSAJE EN CONSOLA A TRAV�S DE UNA EXCEPCI�N �EL DEPARTAMENTO NO EXISTE O YA FUE ELIMINADO�

SET SERVEROUTPUT ON;

CREATE SEQUENCE SQ_DEPT
INCREMENT BY 10
START WITH 10
MINVALUE 10
MAXVALUE 90
NOCACHE
NOCYCLE;

CREATE OR REPLACE PACKAGE "PKG_MANT_DEPT" AS 
  PROCEDURE SP_INGRESA_DEPT (V_DNAME DEPT.DNAME%TYPE,V_LOC DEPT.LOC%TYPE);
  PROCEDURE SP_ACTUALIZA_DEPT (V_DEPTNO DEPT.DEPTNO%TYPE,V_DNAME DEPT.DNAME%TYPE);
  PROCEDURE SP_ELIMINA_DEPT (V_DEPTNO DEPT.DEPTNO%TYPE);
 END PKG_MANT_DEPT;

CREATE OR REPLACE PACKAGE BODY "PKG_MANT_DEPT" AS

PROCEDURE SP_INGRESA_DEPT (V_DNAME DEPT.DNAME%TYPE,V_LOC DEPT.LOC%TYPE)
AS
BEGIN

INSERT INTO DEPT VALUES (SQ_DEPT.NEXTVAL, V_DNAME, V_LOC);
 DBMS_OUTPUT.PUT_LINE('EL DEPARTAMENTO '|| V_DNAME||' FUE INGRESADO');  
COMMIT;

END SP_INGRESA_DEPT;

PROCEDURE SP_ACTUALIZA_DEPT (V_DEPTNO DEPT.DEPTNO%TYPE,V_DNAME DEPT.DNAME%TYPE)
AS
FILA DEPT%ROWTYPE;
BEGIN 
  SELECT * INTO FILA FROM DEPDEPTNOT WHERE DEPTNO = V_DEPTNO;
  
  UPDATE DEPT SET DNAME = V_DNAME WHERE DEPTNO = V_DEPTNO;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('EL DEPARTAMENTO '||FILA.DEPTNO||' FUE ACTUALIZADO'); 
  
EXCEPTION
  WHEN NO_DATA_FOUND THEN
 DBMS_OUTPUT.PUT_LINE('EL DEPARTAMENTO NO EXISTE');  

END SP_ACTUALIZA_DEPT;

PROCEDURE SP_ELIMINA_DEPT (V_DEPTNO DEPT.DEPTNO%TYPE)
AS
V_RECODEPT DEPT%ROWTYPE;
BEGIN 
  SELECT * INTO V_RECODEPT FROM DEPT WHERE DEPTNO=V_DEPTNO;
  
  DELETE FROM DEPT WHERE DEPTNO=V_DEPTNO;
  COMMIT;
  
  DBMS_OUTPUT.PUT_LINE('EL DEPARTAMENTO'||' '||V_RECODEPT.DEPTNO||' '||'FUE ELIMINADO'); 
EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
    DBMS_OUTPUT.PUT_LINE('EL DEPARTAMENTO NO EXISTE O YA FUE ELIMINADO'); 

END SP_ELIMINA_DEPT ;

END PKG_MANT_DEPT;

VALIDACION:

EXECUTE PKG_MANT_DEPT.SP_INGRESA_DEPT('RRHH','LIMA');
--1
CREATE TABLE aud_emp(
  numemp char(4) PRIMARY KEY,
  nomemp varchar2(15),
  mng char(4),
  salario integer,
  usuario varchar2(15),
  fecha date
);

CREATE OR REPLACE TRIGGER t_1 
AFTER DELETE
ON emp 
FOR EACH ROW
DECLARE
V_USUARIO VARCHAR2(20);
V_FECHA DATE;
BEGIN
	SELECT USER INTO V_USUARIO FROM DUAL;
	SELECT SYSDATE INTO V_FECHA FROM DUAL;

	INSERT INTO aud_emp VALUES
		(:old.EMPNO, 
		:old.ENAME, 
		:old.MGR, 
		:old.SAL, 
		V_USUARIO, 
		V_FECHA);
END;


DELETE FROM emp WHERE EMPNO=7499;

ALTER SESSION SET nsl_date_format='DD/MM/YYYY H24:MI:SS';

SELECT * FROM aud_emp;

--2

--Crear un trigger sobre la tabla EMP para que no se permita que un empleado 
--sea jefe (MGR) de más de 3 empleados.
--* Inserte las tuplas necesarias para comprobar la funcionalidad del trigger

CREATE OR REPLACE TRIGGER t_2
BEFORE INSERT
ON emp
FOR EACH ROW
DECLARE
  V_CANTIDAD INTEGER;
BEGIN
  SELECT COUNT(MGR) INTO V_CANTIDAD FROM emp WHERE MGR=:new.MGR;
  IF(V_CANTIDAD=3) THEN
    raise_application_error(-20600,'NO SE PUEDE INGRESAR, EL JEFE YA TIENE UN MAXIMO DE 3 SUBORDINADOS');
  END IF;
END;

SET SERVEROUTPUT ON;
INSERT INTO emp VALUES(7480,'HERNAN','SALESMAN',7698,SYSDATE,1500,200,30);
COMMIT;


--3
--Ejecutar la sentencia para validar si la base de datos se encuentra o 
--no auditada: *De no encontrarse auditada, activar la auditoria en la 
--base de datos

SHOW PARAMETER AUDIT;

SELECT name, value from v$parameter where name like 'audit_trail';

ALTER SYSTEM SET audit_trail = "DB" SCOPE=SPFILE;
SHUTDOWN IMMEDIATE
STARTUP


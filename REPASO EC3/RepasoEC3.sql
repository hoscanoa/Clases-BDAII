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

CREATE OR REPLACE TRIGGER t_2;
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
--SYS
SHOW PARAMETER AUDIT;

SELECT name, value from v$parameter where name like 'audit_trail';

ALTER SYSTEM SET audit_trail = "DB" SCOPE=SPFILE;
SHUTDOWN IMMEDIATE
STARTUP

--4
--Activar la Auditoria de Conectividad NO EXITOSA a la base de datos
--SYS
audit session whenever not successful;

select 
username , action_name ,extended_timestamp, priv_used , returncode 
from dba_audit_trail 
where username='SCOTT';
--5
--Activar la auditoria para el usuario SCOTT de ALTERAR Y BORRAR 
--cualquier INDICE.
--SYS
audit index ON DEFAULT by access;
--SCOOT
DROP INDEX IDX_NBOLDESC
--SYS
select * 
from sys.dba_audit_trail 
where 
action_name like '%INDEX' and username='SCOTT';

/*
Nota: si no visualiza los datos siga los siguientes pasos: 
SQL> alter system set audit_trail = db,extended scope=spfile; 
System altered. 
SQL> startup force; 
ORACLE instance started.
*/

--6. Activar la auditoria de Select, delete y update para la tabla EMP del 
--usuario SCOTT por acceso
--SYS
audit select,delete,update on scott.emp by access;

/*
Verificaremos con algunas operaciones:
1ero visualizamos los datos de la tabla emp:
select * from EMP
2do insertamos un registro:
insert into emp
values(6369,'ALEX','MANAGER',7566,'12-oct-75',5000,100,20)
3ro eliminamos el registro insertado:
DELETE FROM EMP
WHERE EMPNO='6369'
Finalmente verifiquemos la auditoria:
SELECT username, extended_timestamp, owner, obj_name, action_name,transactionid
FROM dba_audit_trail
WHERE owner = 'SCOTT' and obj_name='EMP'
ORDER BY timestamp;
*/


--7. 
--Desactivar la auditoria de Select para la tabla EMP del usuario SCOTT y 
--ejecutar el SELECT correspondiente para visualizar todos los registros 
--de auditoria de la fecha actual
--SYS
NOAUDIT select on scott.emp;

select * from sys . dba_audit_trail where
obj_name='EMP'
and timestamp='19-JUN-15';


--8. Crear una política de auditoria llamada SAL_CKPT la cual audite si 
--el campo SAL de la tabla EMP es insertado con un valor MENOR o IGUAL a 0
--SYS
begin 
dbms_fga.add_policy( 
  object_schema=>'SCOTT', 
  object_name => 'SAL_CKPT', 
  policy_name => 'SAL_CKPT_AUDIT', 
  audit_condition => 'SAL <=0',
  audit_column => 'SAL', 
  statement_types => 'INSERT' 
); 
end;
/
--SCOTT
INSERT INTO emp VALUES(7481,'CARLOS','SALESMAN',7644,SYSDATE,0,200,30);

--SYS
select 
db_user, os_user, timestamp, object_schema, object_name, 
policy_name, sql_text 
from dba_fga_audit_trail;


/*
El paquete DBMS_FGA contiene los siguientes procedimientos:
? ADD_POLICY
? DROP_POLICY
? ENABLE_POLICY
? DISABLE_POLICY
Elimanción de la politica de auditoria
conn sys/cibertec as sysdba
begin dbms_fga.DROP_policy( 
object_schema=>'SCOTT', 
object_name => 'EMP_FGA', 
policy_name => 'SALARY_CHK_AUDIT' 
); 
end; /
*/
















-------------------------
-----REPASO TRIGGERS-----
-------------------------

/*
Ejercicio 1:
Crear un disparador que registre el usuario y la fecha en una tabla denominada LOG_DEPT cada
vez que se ingrese un nuevo departamento en la tabla DEPT
*para este ejercicio previamente crear la siguiente tabla:
CREATE TABLE LOG_DEPT AS
(SELECT DEPTNO, DNAME, LOC,USER AS "USER_CREA", SYSDATE AS "FECHA_CREA"
FROM DEPT WHERE 1=2);
CREATE OR REPLACE TRIGGER TR_DEPT_INST --Nombre del Trigger
AFTER INSERT ON DEPT -- Aplicado cuando realiza un insert, update o
--delete en la tabla DEPTen este caso INSERT
FOR EACH ROW --Se aplicara por cada fila insertada, tambien se
--podria aplicar una condicional usando WHEN
DECLARE --Inicio del cuerpo del Trigger PL/SQL
v_user varchar2(20);
v_fecha date;
BEGIN
SELECT USER INTO v_user FROM DUAL; --Guardamos el usuario de conexion
SELECT SYSDATE INTO v_fecha FROM DUAL;--Guardamos la fecha en que se ejecuta
INSERT INTO log_dept --Insertamos en la tabla de auditoria o log
VALUES (:new.deptno, :new.dname, :new.loc, v_user, v_fecha);
--los valos :new .* llamados identificadores de correlacion, identifica al nuevo valor
--insertado tambien existe los :old.* que identifican los valores antiguos por ejemplo
--cuando se realiza update el registro antiguo seria :old.xxxx y el nuevo :new.xxx
DBMS_OUTPUT.PUT_LINE('Insertamos el nuevo registro.');
--Esto se mostrara en consola cada vez que se registre una fila
END;
Validacion:
SET SERVEROUTPUT ON
INSERT INTO DEPT VALUES (1,'CALIDAD','ATE');
COMMIT;
SELECT * FROM LOG_DEPT;
alter session set nls_date_format='DD/MM/YYYY HH24:MI:SS';
--Permite alterar el formato de fecha para nuestra sesion
SELECT * FROM LOG_DEPT;
--Fijarse que ahora aparece la hora, minuto y segundo en que se realizo el insert
Eliminar un Trigger:
DROP TRIGGER nombre;
Desahibilita un Trigger:
ALTER TRIGGER nombre DISABLE;
Habilitar un Trigger:
ALTER TRIGGER nombre ENABLE;
Ejercicio2:
Crear un trigger que almacene el historial de modificaciones de nombres de productos.
CREATE TABLE product
( prodid number(6),
descrip char(30));
insert into product values (1,'manzana');
insert into product values (2,'naranja');
insert into product values (3,'mangos');
insert into product values (4,'ciruela');
insert into product values (5,'platano');
commit;
CREATE TABLE historial
( prodid number(6),
descrip char(30),
fecha date );
CREATE OR REPLACE TRIGGER t_product
AFTER UPDATE
ON product
FOR EACH ROW
BEGIN
INSERT INTO historial VALUES (:old.prodid, :old.descrip, sysdate);
END;
Validacion:
UPDATE product
SET descrip = 'mandarina'
WHERE prodid = 5;
SELECT * FROM HISTORIAL;
Clausula WHEN
? Válida sólo cuando se usa FOR EACH ROW.
? Se disparará sólo cuando cumpla la condición.
? Se puede usar las variables old y new dentro de la condición, pero no se usan los dos puntos (:)
Ejercicio 3:
Crear un trigger que muestre un mensaje cuando se inserta un empleado con salario mayor a
1000.
CREATE OR REPLACE TRIGGER t_emp
AFTER INSERT
ON emp
FOR EACH ROW WHEN (new.sal>1000) –Se aplica la condicional WHEN y la variable NEW van sin “:”
BEGIN
dbms_output.put_line('Salario superior');
END;
Validacion:
set serveroutput on
INSERT INTO EMP (EMPNO, ENAME, SAL) VALUES (1,'MARCOS',9000);
COMMIT;
set serveroutput on
INSERT INTO EMP (EMPNO, ENAME, SAL) VALUES (2,'PEPE',900);
COMMIT;
PREDICADORES EN TRIGGERS
Ejercicio 4:
Modificar el trigger t_product para que almacene el historial de inserciones y eliminaciones,
además del de modificaciones de productos.
--*Agregamos una columna donde se guardara que tipo de sentencia se realizo: insert, update o delete
ALTER TABLE historial
ADD sentencia varchar2(10);
CREATE OR REPLACE TRIGGER t_product
AFTER INSERT OR UPDATE OR DELETE
ON product
FOR EACH ROW
BEGIN
IF INSERTING THEN
INSERT INTO historial VALUES
(:new.prodid, :new.descrip, sysdate, 'INSERT');
ELSIF UPDATING THEN
INSERT INTO historial VALUES
(:old.prodid, :old.descrip, sysdate, 'UPDATE');
ELSIF DELETING THEN
INSERT INTO historial VALUES
(:old.prodid, :old.descrip, sysdate, 'DELETE');
END IF;
END;
Validacion:
SELECT * FROM HISTORIAL;
INSERT INTO PRODUCT VALUES (6,'pera');
COMMIT;
UPDATE PRODUCT SET DESCRIP ='granadilla' where PRODID=6;
COMMIT;
DELETE PRODUCT WHERE PRODID=6;
COMMIT;
SELECT * FROM HISTORIAL;


Crear un disparador que no me permita ingresar empleados en la tabla EMP cuya fecha de ingreso
(hiredate) sea superior al 30/05/2012:
USANDO DELETE
CREATE OR REPLACE TRIGGER TR_HIREDATE_EMP
AFTER
INSERT ON EMP
FOR EACH ROW WHEN (new.hiredate > to_date('30/05/2012','dd/mm/yyyy'))
BEGIN
DELETE EMP WHERE EMPNO=:NEW.EMPNO;
DBMS_OUTPUT.PUT_LINE(' NO SE PUEDE INGRESAR EMPLEADOS CON HIREDATE DESPUES
DEL 30/05/2012');
END;
USANDO WHEN
CREATE OR REPLACE TRIGGER TR_HIREDATE_EMP
BEFORE
INSERT ON EMP
FOR EACH ROW WHEN (new.hiredate > to_date('30/05/2012','dd/mm/yyyy'))
BEGIN
raise_application_error(-20700,:new.hiredate||' NO SE PUEDE INGRESAR EMPLEADOS CON
HIREDATE DESPUES DEL 30/05/2012');
--raise_application_error: variable de excepciones fuerza un error controlado en oracle el codigo asociado -
20700 es un codigo
--que asigna el programador y puede variar entre -20000 y -20999 y el mensaje de error puede soportar hasta
512 bytes
END;
USANDO IF
CREATE OR REPLACE TRIGGER TR_HIREDATE_EMP
BEFORE
INSERT ON EMP
FOR EACH ROW
BEGIN
IF (:new.hiredate > to_date('30/05/2012','dd/mm/yyyy') )
THEN raise_application_error(-20600,:new.hiredate||'no se puede ingresar empleados con hiredate
despues del 30/12/2012');
END IF;
END;
Validacion:
SET SERVEROUTPUT ON
INSERT INTO EMP (EMPNO, ENAME, HIREDATE) VALUES (100,'JUAN','05/04/2012');
COMMIT;
SET SERVEROUTPUT ON
INSERT INTO EMP (EMPNO, ENAME, HIREDATE) VALUES (200,'JOSE','06/06/2012');
COMMIT;
Ejercicios Propuestos:
Ejercicio 1.
Crear un trigger para impedir que se aumente el salario de un empleado en más de un 20%.
* Actualize las tuplas necesarias para comprobar que funcional el trigger
Ejercicio 2.
Crear un trigger sobre la tabla EMP para que no se permita que un empleado sea jefe (MGR) de
más de cinco empleados.
* Inserte las tuplas necesarias para comprobar que funcional el trigger
Ejercicio 3.
Crear una tabla empleados_baja con la siguiente estructura:
CREATE TABLE empleados_baja
(dni char(4) PRIMARY KEY,
nomemp varchar2(15),
mng char(4),
salario integer,
usuario varchar2(15),
fecha date );
• Crear un trigger que inserte una fila en la tabla empleados_baja cuando se borre una fila en la
tabla empleados.
• Los datos que se insertan son los correspondientes al empleado que se da de baja en la tabla
empleados, salvo en las columnas usuario y fecha se grabarán las variables del sistema USER y
SYSDATE que almacenan el usuario y fecha actual.
• El comando que dispara el trigger es AFTER DELETE.
Ejercicio 4.
Crear un trigger para impedir que un empleado y su jefe pertenezcan a departamentos distintos.
* Inserte las tuplas necesarias para comprobar que funcional el trigger
Ejercicio 5.
Crear un trigger para impedir que el salario total por departamento (suma de los salarios de los
empleados por departamento) sea superior a 10.000.
• Ayuda:
– Será necesario distinguir si se trata de una modificación o de una inserción.
– Cuando se trate de una inserción (IF INSERTING...) se comprobará que el salario del empleado a
insertar (:NEW.sal) más el salario total del departamento al que pertenece dicho empleado no es
superior a 10.0000.
– Cuando se trate de una modificación (IF UPDATING...), al salario total del departamento se le
sumará el :NEW.sal y se le restará el :OLD.sal

*/

/*
Ejercicio 1.
Crear un trigger para impedir que se aumente el salario de un empleado en más de un 20%.
* Actualize las tuplas necesarias para comprobar que funciona el trigger
CREATE OR REPLACE TRIGGER aumentoSalario
BEFORE UPDATE OF sal ON emp
FOR EACH ROW
BEGIN
IF :NEW.sal > :OLD.sal*1.20
THEN raise_application_error
(-20600,:new.Sal||'no se puede aumentar el salario más de un 20%');
END IF;
END;
Verificar trigger:
update emp
set sal=sal*1.30
where empno='7369';
*/

/*
Ejercicio 2.
Crear un trigger sobre la tabla EMP para que no se permita que un empleado sea jefe (MGR) de más de cinco empleados.
* Inserte las tuplas necesarias para comprobar que funciona el trigger
CREATE OR REPLACE TRIGGER jefes
BEFORE
INSERT ON emp
FOR EACH ROW
DECLARE
supervisa INTEGER;
BEGIN
SELECT count(*) INTO supervisa
FROM emp WHERE mgr = :new.mgr;
IF (supervisa > 4)
THEN raise_application_error
(-20600,:new.mgr||'no se puede supervisar más de 5');
END IF;
END;

SELECT * FROM EMP
WHERE MGR='7698';

INSERT INTO EMP VALUES
(7369, 'SMITH', 'CLERK', 7698,
TO_DATE('17-DEC-1980', 'DD-MON-YYYY'), 800, NULL, 20);
*/

/*
Ejercicio 3.
Crear una tabla empleados_baja con la siguiente estructura:

CREATE TABLE empleados_baja
(EMPNO NUMBER(4) NOT NULL,
ENAME VARCHAR2(10),
JOB VARCHAR2(9),
MGR NUMBER(4),
HIREDATE DATE,
SAL NUMBER(7, 2),
COMM NUMBER(7, 2),
DEPTNO NUMBER(2),
usuario varchar2(15),
fecha date );

• Crear un trigger que inserte una fila en la tabla empleados_baja cuando se borre una fila en la tabla empleados.
• Los datos que se insertan son los correspondientes al empleado que se da de baja en la tabla empleados, salvo en las columnas usuario y fecha se grabarán las variables del sistema USER y SYSDATE que almacenan el usuario y fecha actual.
• El comando que dispara el trigger es AFTER DELETE.

CREATE OR REPLACE TRIGGER bajas
AFTER DELETE ON emp
FOR EACH ROW
BEGIN
INSERT INTO empleados_baja VALUES (:old.empno,:old.ename,:old.job,:old.mgr,:old.hiredate,
:old.sal,:old.comm,:old.deptno, USER, SYSDATE);
END;
*/


/*
Ejercicio 4.
Crear un trigger para impedir que el salario total por departamento (suma de los salarios de los empleados por departamento) sea superior a 10.000.
• Ayuda:
– Será necesario distinguir si se trata de una modificación o de una inserción.
– Cuando se trate de una inserción (IF INSERTING...) se comprobará que el salario del empleado a insertar (:NEW.sal) más el salario total del departamento al que pertenece dicho empleado no es superior a 10.0000.
– Cuando se trate de una modificación (IF UPDATING...), al salario total del departamento se le sumará el :NEW.sal y se le restará el :OLD.sal.

CREATE OR REPLACE TRIGGER TGR_SALARIO_TOTAL
BEFORE INSERT OR UPDATE
ON EMP
FOR EACH ROW
DECLARE
CURSOR CUR IS
SELECT DEPTNO ,SUM(SAL)FROM EMP GROUP BY DEPTNO;
V_DEPTNO EMP.DEPTNO%TYPE;
V_SUMA EMP.SAL%TYPE;
BEGIN
OPEN CUR;
FETCH CUR INTO V_DEPTNO,V_SUMA;
WHILE CUR%FOUND LOOP
IF INSERTING THEN
IF(V_SUMA + :NEW.SAL > 10000 AND :NEW.DEPTNO = V_DEPTNO ) THEN
RAISE_APPLICATION_ERROR(-20600,:NEW.SAL||' ES SUPERIOR A 10000');
END IF;
ELSIF UPDATING THEN
IF((V_SUMA + :NEW.SAL) - :OLD.SAL > 10000 AND :NEW.DEPTNO = V_DEPTNO) THEN
RAISE_APPLICATION_ERROR(-20600,:NEW.SAL||' ES SUPERIOR A 10000');
END IF;
END IF;
FETCH CUR INTO V_DEPTNO,V_SUMA;
END LOOP;
CLOSE CUR;
END;
*/
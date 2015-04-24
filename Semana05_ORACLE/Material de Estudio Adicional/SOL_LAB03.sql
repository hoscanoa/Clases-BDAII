--1.	Realizar una consulta que liste el código del empleado, nombre, salario y nombre del departamento donde trabaja.
SELECT E.EMPNO, E.ENAME, E.SAL, D.DNAME FROM EMP E, DEPT D WHERE E.DEPTNO=D.DEPTNO;  
--2.	Instrucciones DML:
--a)	Insertar el siguiente registro en la tabla DEPT:
 INSERT INTO DEPT VALUES (60,'TECNOLOGY','NORTE');
--b)	Actualizar el campo “NORTE” por “LOS OLIVOS”
UPDATE DEPT SET LOC='LOS OLIVOS' WHERE LOC='NORTE';
--c)	Eliminar el registro del departamento TECNOLOGY agregado recientemente
DELETE DEPT WHERE DEPTNO=60;
--3.	Listar el nombre de todos los empleados cuyo salario sea mayor al salario del usuario SCOTT (usar sub-consultas)
SELECT * FROM EMP WHERE SAL > (SELECT SAL FROM EMP WHERE ENAME='SCOTT'); 
--4.	Listar el sueldo promedio de los salarios agrupados por puesto de trabajo.
SELECT JOB, AVG(SAL) FROM EMP GROUP BY JOB;
--5.	Lista todas las tablas que ha creado el usuario SCOTT durante todo el año 2011 y 2012
SELECT * FROM DBA_OBJECTS WHERE OWNER='SCOTT' AND OBJECT_TYPE='TABLE' AND CREATED BETWEEN '01/01/2011' AND '31/12/2012';

--6.	Listar las tablas del diccionario de datos cuyo nombre contenga la palabra “TABLESPACE”  y solo puedan ser leídos por usuarios con el rol DBA
--ejemplo:
--DBA_TABLESPACES	
--DBA_TABLESPACE_GROUPS	
--DBA_TABLESPACE_THRESHOLDS

SELECT * FROM DICTIONARY WHERE TABLE_NAME LIKE '%DBA%TABLESPACE%';
--7.	Calcular su edad usando MONTHS_BETWEEN
SELECT TRUNC(MONTHS_BETWEEN(SYSDATE,'11/08/1984')/12) FROM DUAL;
--8.	Obtener la fecha de hoy con el siguiente formato: Hoy es NOMBRE_DIA,DIA_MES de NOMBRE_MES de AÑO (Martes, 22 de OCTUBRE de 2012).
SELECT TO_CHAR(SYSDATE,'day,dd " de " month " de " yyyy') from dual;
--9.	Mostrar el nombre y la novena parte (con 3 decimales) redondeados;  del sueldo de los empleados cuyo sueldo es mayor a 1500
SELECT ENAME, ROUND(SAL/9,3) FROM EMP WHERE SAL>1500;
--10.	Extraer la penúltima letra del nombre de todos los empleados de la tabla EMP
SELECT ENAME, SUBSTR(ENAME,LENGTH(ENAME)-1,1) FROM EMP;

--15:55.34
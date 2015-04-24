--GUIA 1

CREATE TABLE tb_alumno(
 	codalu char(5) PRIMARY KEY NOT NULL,
 	nomalu varchar2(50) NOT NULL,
 	apealu varchar2(50) NOT NULL,
 	fecnac date,
 	sexalu char(1)
 );


CREATE INDEX IDX_SEXO ON tb_alumno(sexalu);

DROP INDEX IDX_SEXO;

CREATE INDEX IDX_SEXO ON tb_alumno(sexalu DESC);

CREATE INDEX IDX_APENOM ON tb_alumno (apealu, nomalu);


CREATE TABLE tb_boleta(
	nbol number(5),
	fbol date,
	 cliente varchar2(100),
	 monto number(5,2)
);

ALTER TABLE tb_boleta
ADD CONSTRAINT pk_tb_boleta PRIMARY KEY(nbol);


CREATE TABLE Detalle_boleta(
	nbol number(5),
	descripcion varchar(150),
	precio number(5,2)
);


ALTER TABLE Detalle_boleta
ADD CONSTRAINT fk_Tbboleta_DetalleBoleta
FOREIGN KEY(nbol) REFERENCES tb_boleta;

SELECT * FROM all_constraints
WHERE owner='SCOTT' AND TABLE_NAME='DETALLE_BOLETA';


CREATE UNIQUE INDEX idx_nboldesc
ON detalle_boleta(nbol, descripcion);

CREATE INDEX idx_descripcion 
ON detalle_boleta(descripcion);

SELECT * FROM all_indexes
WHERE TABLE_NAME='DETALLE_BOLETA'


SELECT * FROM all_indexes
WHERE owner='SCOTT';


--GUIA 2

CREATE SEQUENCE seq_nbol
INCREMENT BY 1
START WITH 100


INSERT INTO tb_boleta VALUES(seq_nbol.NextVal, sysdate, 'Mendez', 200);
INSERT INTO tb_boleta VALUES(seq_nbol.NextVal, sysdate, 'Perez', 350);


SELECT * FROM tb_boleta;


SELECT seq_nbol.CURRVAL FROM DUAL;

SELECT seq_nbol.NextVal FROM DUAL;

DROP SEQUENCE seq_nbol;

DELETE FROM tb_boleta;


CREATE SEQUENCE seq_boleta
INCREMENT BY 1
START WITH 10
MAXVALUE 15
CYCLE
NOCACHE;


INSERT INTO tb_boleta VALUES(seq_boleta.NextVal, sysdate, 'Mendez',200);
INSERT INTO tb_boleta VALUES(seq_boleta.NextVal, sysdate, 'Perez',350);
INSERT INTO tb_boleta VALUES(seq_boleta.NextVal, sysdate, 'Cardenas',200);
INSERT INTO tb_boleta VALUES(seq_boleta.NextVal, sysdate, 'Soto',350);
INSERT INTO tb_boleta VALUES(seq_boleta.NextVal, sysdate, 'Sierra',200);
INSERT INTO tb_boleta VALUES(seq_boleta.NextVal, sysdate, 'Gomez',350);
INSERT INTO tb_boleta VALUES(seq_boleta.NextVal, sysdate, 'Robles',350);



SELECT * FROM tb_boleta;

DROP SEQUENCE seq_boleta;

DELETE FROM tb_boleta;



CREATE SEQUENCE seq_descendente
INCREMENT BY -1
START WITH 100 MAXVALUE 100


INSERT INTO tb_boleta VALUES(seq_descendente.NextVal, sysdate, 'Mendez',200);
INSERT INTO tb_boleta VALUES(seq_descendente.NextVal, sysdate, 'Perez',350);
INSERT INTO tb_boleta VALUES(seq_descendente.NextVal, sysdate, 'Cardenas',200);
INSERT INTO tb_boleta VALUES(seq_descendente.NextVal, sysdate, 'Soto',350);
INSERT INTO tb_boleta VALUES(seq_descendente.NextVal, sysdate, 'Sierra',200);
INSERT INTO tb_boleta VALUES(seq_descendente.NextVal, sysdate, 'Gomez',350);
INSERT INTO tb_boleta VALUES(seq_descendente.NextVal, sysdate, 'Robles',350);


SELECT * FROM tb_boleta;



--GUIA 3

SELECT Table_name FROM All_tables WHERE Owner = 'SCOTT';

SELECT table_name, index_name FROM all_indexes
WHERE owner='SCOTT';


SELECT Sequence_name FROM all_sequences
WHERE sequence_owner='SCOTT';


SELECT owner, table_name, tablespace_name, num_rows
FROM All_tables WHERE owner='SCOTT';


SELECT * FROM Dictionary;


/*
1.	En un bloque PL/SQL, realice la búsqueda con la inicial del nombre del 
cliente y contabilice los registros encontrados. Usando excepciones definidas 
por el usuario envíe los siguientes mensajes  ‘Ningún registro encontrado’ – 
‘Una fila encontrada’ o ‘Más de una Fila encontrada’. Utilice el gestor RAISE.
*/
--SET SERVEROUTPUT ON;
DECLARE
  v_inicial VARCHAR2(1);
  v_count INTEGER;
  v_cero EXCEPTION;
  v_uno EXCEPTION;
  v_masDeUno EXCEPTION;
BEGIN 
  v_inicial:=:X;
  SELECT COUNT(*) INTO v_count FROM CLIENTE 
  WHERE NOMBRES LIKE v_inicial||'%';
  IF v_count=0 THEN
    RAISE v_cero;
  ELSIF v_count=1 THEN
    RAISE v_uno;
  ELSE
    RAISE v_masDeUno;
  END IF;
  EXCEPTION
    WHEN v_cero THEN
      dbms_output.put_line('Ningún registro encontrado');
    WHEN v_uno THEN
      dbms_output.put_line('Una fila encontrada');
    WHEN v_masDeUno THEN
      dbms_output.put_line('Más de una Fila encontrada');
END;

/*
2.	Cree un bloque PL– SQL, donde muestre la descrip_pro, Precio_pro,  
stock_act_pro y Estado.  Además deberá asignar el valor a comprar y la 
descripción del producto.
Muestre los datos del producto según el siguiente criterio:
Cuando  stock_act_pro>v_compra THEN  'Stockeado‘
Cuando stock_act_pro= v_compra THEN   'Limite‘
Cuando stock_act_pro< v_compra THEN   'Haga una Solicitud'
*/
CLEAR SCREEN
DECLARE
  V_COMPRAR INTEGER;
  V_DESCRIP_PRO PRODUCTO.DESCRIP_PRO%TYPE;
  DESCRIPCION PRODUCTO.DESCRIP_PRO%TYPE; 
  PRECIO PRODUCTO.PRECIO_PRO%TYPE;
  STOCK PRODUCTO.STOCK_ACT_PRO%TYPE;
  ESTADO VARCHAR2(20);
BEGIN
  V_COMPRAR:=:X;
  V_DESCRIP_PRO:=:Y;
  SELECT DESCRIP_PRO, PRECIO_PRO, STOCK_ACT_PRO,
  	CASE
  		WHEN STOCK_ACT_PRO>V_COMPRAR THEN
  			'Stockeado'
  		WHEN STOCK_ACT_PRO=V_COMPRAR THEN
  			'Limite'
  		WHEN STOCK_ACT_PRO<V_COMPRAR THEN
  			'Haga una Solicitud'
  	END AS ESTADO INTO DESCRIPCION, PRECIO, STOCK, ESTADO
  FROM PRODUCTO
  WHERE DESCRIP_PRO=V_DESCRIP_PRO;
  DBMS_OUTPUT.PUT_LINE(DESCRIPCION || ' ' || PRECIO || ' ' || STOCK || ' ' || ESTADO);
END;


/*
3.	Escribir un bloque PL/SQL que reciba una cadena y visualice el  nombre 
(nombres), código de cliente (cod_cli), dirección del cliente(dirección_cli) y 
nombre del distrito(DESCRIP_DIST) de todos los clientes cuyo apellido inicie con
la cadena especificada. Al finalizar visualizar el número de clientes mostrados.
Ejemplo si ingreso la cadena ‘A’ deberá mostrar en consola:
	7566 - ANIBAL
	7844 - ARTURO
	NUMERO DE EMPLEADOS: 2
Nota: Los datos son referenciales.
*/
CLEAR SCREEN
DECLARE
  V_INICIAL VARCHAR2(1);
  V_COD_CLI CLIENTE.COD_CLI%TYPE; 
  V_NOMBRES CLIENTE.NOMBRES%TYPE; 
  V_DIRECCION_CLI CLIENTE.DIRECCION_CLI%TYPE;
  V_DESCRIP_DIST DISTRITO.DESCRIP_DIST%TYPE;
  V_FILAS INTEGER;
BEGIN
  V_INICIAL:='A';
  V_FILAS:=0;
  DECLARE
  CURSOR CU IS
  SELECT 
  CLIENTE.COD_CLI, 
  CLIENTE.NOMBRES, 
  CLIENTE.DIRECCION_CLI, 
  DISTRITO.DESCRIP_DIST
  FROM 
  CLIENTE INNER JOIN DISTRITO  
  ON CLIENTE.COD_DIST=DISTRITO.COD_DIST
  WHERE CLIENTE.NOMBRES LIKE V_INICIAL||'%';
  BEGIN
    LOOP
      FETCH CU INTO V_COD_CLI, V_NOMBRES, V_DIRECCION_CLI, V_DESCRIP_DIST;
      EXIT WHEN CU%NOTFOUND;
      V_FILAS:=V_FILAS+1;
      DBMS_OUTPUT.PUT_LINE(V_COD_CLI||' - '||V_NOMBRES);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('NUMERO DE CLIENTES: '||V_FILAS);
  END;
END;


/*
4.	Elaborar un bloque PL/SQL que permita recuperar la suma(Precio x cantidad) 
de las Boletas emitidas de un determinado cliente, Deberá mostrar los siguientes
mensajes: 

Si la suma total es Cero: El cliente no ha realizado ninguna Boleta.
Si La suma es <=100 mostrar: Ha registrado  un monto considerado, continúe 
trabajando. 
Caso contrario: Ha registrado excelentes Ventas, Muy Bien!!!
*/







/*
5.	En un bloque PL/SQL, realice una inserción de registros a la tabla DISTRITO.
Usando excepciones predefinidas envíe los siguientes mensajes  ‘Ya existe un 
distrito con el código ingresado’ o ‘Error desconocido’. Utilice los gestores 
DUP_VAL_ON_INDEX   y OTHERS.
*/









/*
6.	Elaborar un bloque PL/SQL que visualice en consola (buffer) el Código del 
cliente, el nombre de cliente, la primera y última letra del nombre del cliente, 
y la cantidad de facturas emitidas por cliente ordenados de mayor a menor de 
acuerdo a la cantidad obtenida. (utilizar cursores)
*/







---------------------------------------------------
--CASO 1
---------------------------------------------------

SELECT 
    f.numfactura AS "N° Factura",
    TO_CHAR(f.fecha, 'DD "de" MONTH') AS "Fecha Emision",
    LPAD(f.rutcliente, 10, '0') AS "RUT Cliente",
    TO_CHAR(f.neto, 'L999G999') AS "Monto Neto",
    TO_CHAR(f.iva, 'L999G999') AS "Monto IVA",
    TO_CHAR(f.total, 'L999G999') AS "Total Factura",
    CASE
        WHEN f.total <= 50000 THEN 'Bajo'
        WHEN f.total BETWEEN 50001 AND 100000 THEN 'Medio'
        ELSE 'Alto'
    END AS "Categoria Monto",
    CASE 
        WHEN f.codpago = 1 THEN 'EFECTIVO'
        WHEN f.codpago = 2 THEN 'TARJETA DEBITO'
        WHEN f.codpago = 3 THEN 'TARJETA CREDITO'
        ELSE 'CHEQUE'
    END AS "Forma de Pago"
FROM factura f
WHERE EXTRACT(YEAR FROM f.fecha) = EXTRACT(YEAR FROM SYSDATE) - 1
ORDER BY f.fecha DESC, f.neto DESC;

------------------------------------------------------------------------
--CASO 2
------------------------------------------------------------------------
SELECT 
    LPAD(rutcliente, 12, '*')                          AS "RUT",
    nombre                                              AS "Cliente",
    NVL(TO_CHAR(telefono), 'Sin telefono')              AS "TELEFONO",
    NVL(TO_CHAR(codcomuna), 'Sin comuna')               AS "ID_COMUNA",
    estado                                              AS "ESTADO",
    CASE 
        WHEN (saldo / credito) < 0.5 THEN 
            'Bueno ($' || TO_CHAR(credito - saldo, '999G999G999') || ')'
        WHEN (saldo / credito) BETWEEN 0.5 AND 0.8 THEN 
            'Regular ($' || TO_CHAR(saldo, '999G999G999') || ')'
        ELSE 
            'Critico'
    END                                                 AS "Estado-Credito",
    SUBSTR(NVL(mail, 'Correo no registrado'),
           INSTR(NVL(mail, 'Correo no registrado'), '@') + 1) AS "Dominio Correo"
FROM cliente
WHERE estado = 'A'
  AND credito > 0
ORDER BY nombre;

---------------------------------------------------
-- CASO 3
---------------------------------------------------
DEFINE TIPOCAMBIO_DOLAR = 950
DEFINE UMBRAL_BAJO = 40
DEFINE UMBRAL_ALTO = 60

SELECT 
    p.codproducto                                       AS "ID",
    INITCAP(p.descripcion)                              AS "Descripcion Producto",
    NVL(TO_CHAR(p.valorcompradolar, 'FM999G999D00') || ' USD', 'Sin registro') AS "Valor Compra USD",
    CASE 
        WHEN p.valorcompradolar IS NOT NULL THEN 
             TO_CHAR(p.valorcompradolar * &TIPOCAMBIO_DOLAR, 'FM999G999') || ' PESOS'
        ELSE 'Sin registro'
    END                                                 AS "Valor Compra CLP",
    NVL(TO_CHAR(p.totalstock), 'Sin registro')          AS "Stock",
    CASE 
        WHEN p.totalstock IS NULL THEN 'Sin datos'
        WHEN p.totalstock < &UMBRAL_BAJO THEN '¡ALERTA stock muy bajo!'
        WHEN p.totalstock BETWEEN &UMBRAL_BAJO AND &UMBRAL_ALTO THEN '¡Reabastecer pronto!'
        ELSE 'OK'
    END                                                 AS "Alerta Stock",
    CASE 
        WHEN p.totalstock > 80 THEN 
             '$' || TO_CHAR(p.vunitario * 0.9, 'FM999G999')
        ELSE 'N/A'
    END                                                 AS "Descuento"
FROM producto p
WHERE UPPER(p.descripcion) LIKE '%ZAPATO%'
  AND p.procedencia = 'I'
ORDER BY p.codproducto DESC;


/*
 Script posterior al despliegue: datos de referencia que el sistema necesita
 para funcionar. Es idempotente: se puede ejecutar en cada despliegue.
*/
MERGE [dbo].[ParametroRegla] AS destino
USING (VALUES
    ('RN-01',    'Ciclo de renovación de lentes graduados',                '18', 'meses'),
    ('RN-02',    'Ciclo de consumo de lentes de contacto mensuales',        '30', 'días'),
    ('RN-03',    'Días de consumo para calcular el nivel mínimo',           '60', 'días'),
    ('RN-04',    'Días sin venta para considerar inventario sin movimiento','180','días'),
    ('UMB-RECH', 'Porcentaje máximo de rechazo antes de detener una carga', '5',  '%')
) AS origen ([codigoRegla], [descripcion], [valor], [unidad])
ON destino.[codigoRegla] = origen.[codigoRegla]
WHEN NOT MATCHED THEN
    INSERT ([codigoRegla], [descripcion], [valor], [unidad])
    VALUES (origen.[codigoRegla], origen.[descripcion], origen.[valor], origen.[unidad]);
-- Los valores existentes NO se sobrescriben: si el propietario ajustó un parámetro,
-- un despliegue no debe devolverlo a su valor inicial.

EXEC [etl].[usp_PoblarDimTiempo] @desde = '2019-01-01', @hasta = '2030-12-31';

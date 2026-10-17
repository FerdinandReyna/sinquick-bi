-- Alertas de inventario: bajo el mínimo (RN-03) y sin movimiento (RN-04).
-- Los días sin movimiento se leen de ParametroRegla; si falta el parámetro se usan 180.
CREATE VIEW [rpt].[vw_InventarioAlertas]
AS
SELECT p.[idProducto],
       p.[referencia],
       p.[descripcion],
       i.[existenciaActual],
       p.[nivelMinimo],
       i.[fechaUltimoMovimiento],
       i.[costoPromedio],
       CONVERT(BIT, CASE WHEN i.[existenciaActual] < p.[nivelMinimo] THEN 1 ELSE 0 END) AS [bajoMinimo],
       CONVERT(BIT, CASE WHEN i.[fechaUltimoMovimiento] IS NULL
                          OR DATEDIFF(DAY, i.[fechaUltimoMovimiento], CONVERT(DATE, GETDATE())) >= par.[dias]
                         THEN 1 ELSE 0 END)                                             AS [sinMovimiento],
       CONVERT(DECIMAL(12,2), i.[existenciaActual] * i.[costoPromedio])                 AS [valorEnBodega]
FROM [dbo].[Producto] p
JOIN [dbo].[Inventario] i ON i.[idProducto] = p.[idProducto]
CROSS APPLY (SELECT ISNULL((SELECT TRY_CONVERT(INT, r.[valor]) FROM [dbo].[ParametroRegla] r
                            WHERE r.[codigoRegla] = 'RN-04'), 180) AS [dias]) par
WHERE p.[activo] = 1;

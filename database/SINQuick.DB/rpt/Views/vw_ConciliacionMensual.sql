-- Total facturado por mes, para compararlo contra el reporte del punto de venta (US-16).
CREATE VIEW [rpt].[vw_ConciliacionMensual]
AS
SELECT t.[anio],
       t.[mes],
       COUNT(*)                        AS [facturas],
       CONVERT(DECIMAL(14,2), SUM(v.[total])) AS [totalFacturado]
FROM [dbo].[Venta] v
JOIN [dbo].[DimTiempo] t ON t.[idFecha] = v.[idFecha]
WHERE v.[anulada] = 0
GROUP BY t.[anio], t.[mes];

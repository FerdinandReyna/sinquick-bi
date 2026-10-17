-- Resultado de las campañas de renovación (RF-12): a quién se contactó, qué respondió
-- y cuánto vendió la campaña. Una fila por cliente incluido en cada campaña.
CREATE VIEW [rpt].[vw_CampaniasResultado]
AS
SELECT ca.[idCampania],
       ca.[nombre]            AS [campania],
       ca.[fechaGeneracion],
       dc.[idCliente],
       dc.[fechaContacto],
       ISNULL(dc.[resultado], 'SIN CONTACTO') AS [resultado],
       CONVERT(BIT, CASE WHEN dc.[resultado] = 'COMPRA' THEN 1 ELSE 0 END) AS [convirtio],
       v.[numeroFactura]      AS [facturaGenerada],
       CONVERT(DECIMAL(12,2), ISNULL(CASE WHEN v.[anulada] = 0 THEN v.[total] END, 0)) AS [ventaGenerada]
FROM [dbo].[Campania] ca
JOIN [dbo].[DetalleCampania] dc ON dc.[idCampania] = ca.[idCampania]
LEFT JOIN [dbo].[Venta] v ON v.[idVenta] = dc.[idVentaGenerada];

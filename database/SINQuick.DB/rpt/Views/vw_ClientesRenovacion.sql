-- Clientes y su ciclo de renovación (RN-01), con la condición de contacto (RN-09).
-- El ciclo se lee de ParametroRegla: cambiarlo no requiere modificar esta vista.
CREATE VIEW [rpt].[vw_ClientesRenovacion]
AS
SELECT c.[idCliente],
       c.[nombreCompleto],
       c.[telefono],
       ult.[ultimaCompra],
       m.[mesesDesdeCompra],
       par.[meses]                                                         AS [cicloMeses],
       CONVERT(BIT, CASE WHEN m.[mesesDesdeCompra] >= par.[meses] THEN 1 ELSE 0 END) AS [cicloVencido],
       CONVERT(BIT, CASE WHEN c.[telefono] IS NOT NULL
                          AND c.[consentimientoContacto] = 1
                          AND c.[fechaExclusion] IS NULL THEN 1 ELSE 0 END) AS [contactable],
       CASE WHEN c.[telefono] IS NULL             THEN 'SIN TELEFONO'
            WHEN c.[consentimientoContacto] = 0   THEN 'SIN CONSENTIMIENTO'
            WHEN c.[fechaExclusion] IS NOT NULL   THEN 'EXCLUSION SOLICITADA'
       END                                                                 AS [motivoExclusion]
FROM [dbo].[Cliente] c
JOIN (SELECT v.[idCliente], MAX(v.[fechaHora]) AS [ultimaCompra]
      FROM [dbo].[Venta] v
      WHERE v.[anulada] = 0 AND v.[idCliente] IS NOT NULL
      GROUP BY v.[idCliente]) ult ON ult.[idCliente] = c.[idCliente]
CROSS APPLY (SELECT DATEDIFF(MONTH, ult.[ultimaCompra], GETDATE())
                    - CASE WHEN DAY(GETDATE()) < DAY(ult.[ultimaCompra]) THEN 1 ELSE 0 END AS [mesesDesdeCompra]) m
CROSS APPLY (SELECT ISNULL((SELECT TRY_CONVERT(INT, r.[valor]) FROM [dbo].[ParametroRegla] r
                            WHERE r.[codigoRegla] = 'RN-01'), 18) AS [meses]) par
WHERE c.[activo] = 1;

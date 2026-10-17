-- Hecho de ventas listo para Power BI. Excluye ventas anuladas y reposiciones en
-- garantía, que no son ingreso (RN-10). Margen según RN-05 con el costo congelado.
CREATE VIEW [rpt].[vw_VentasDetalle]
AS
SELECT d.[idDetalle],
       v.[idVenta],
       v.[numeroFactura],
       v.[fechaHora],
       t.[fecha],
       t.[anio],
       t.[trimestre],
       t.[mes],
       t.[nombreMes],
       v.[idCliente],
       ISNULL(c.[nombreCompleto], 'Consumidor final')                          AS [cliente],
       u.[nombreCompleto]                                                     AS [asesor],
       p.[referencia],
       p.[descripcion]                                                        AS [producto],
       cat.[nombre]                                                           AS [categoria],
       ISNULL(pr.[nombre], 'Sin proveedor')                                   AS [proveedor],
       d.[cantidad],
       d.[precioUnitario],
       d.[descuento],
       CONVERT(DECIMAL(12,2), d.[cantidad] * d.[precioUnitario] - d.[descuento])                        AS [ingreso],
       CONVERT(DECIMAL(12,2), d.[cantidad] * d.[costoUnitario])                                         AS [costo],
       CONVERT(DECIMAL(12,2), d.[cantidad] * d.[precioUnitario] - d.[descuento] - d.[cantidad] * d.[costoUnitario]) AS [margen]
FROM [dbo].[DetalleVenta] d
JOIN [dbo].[Venta]       v   ON v.[idVenta]      = d.[idVenta]
JOIN [dbo].[DimTiempo]   t   ON t.[idFecha]      = v.[idFecha]
JOIN [dbo].[Usuario]     u   ON u.[idUsuario]    = v.[idUsuario]
JOIN [dbo].[Producto]    p   ON p.[idProducto]   = d.[idProducto]
JOIN [dbo].[Categoria]   cat ON cat.[idCategoria] = p.[idCategoria]
LEFT JOIN [dbo].[Proveedor] pr ON pr.[idProveedor] = p.[idProveedor]
LEFT JOIN [dbo].[Cliente]   c  ON c.[idCliente]    = v.[idCliente]
WHERE v.[anulada] = 0
  AND d.[esGarantia] = 0;

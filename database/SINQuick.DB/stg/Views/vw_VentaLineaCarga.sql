-- Vista sobre la que se hace el BULK INSERT: expone solo las 11 columnas del
-- archivo, de modo que no se necesita archivo de formato.
CREATE VIEW [stg].[vw_VentaLineaCarga]
AS
SELECT [numeroFactura], [fechaHora], [telefonoCliente], [nombreCliente], [usuarioAsesor],
       [referencia], [cantidad], [precioUnitario], [descuento], [anulada], [esGarantia]
FROM [stg].[VentaLinea];

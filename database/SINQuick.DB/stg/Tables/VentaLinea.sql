-- Área de aterrizaje del archivo exportado por el punto de venta.
-- Todo llega como texto: la validación decide qué es válido, no el BULK INSERT.
-- Formato supuesto de la exportación (una fila por línea de factura); se confirma
-- contra una exportación real en la historia US-10.
CREATE TABLE [stg].[VentaLinea]
(
    [idLinea]         INT IDENTITY(1,1) NOT NULL,
    [numeroFactura]   NVARCHAR(60)  NULL,
    [fechaHora]       NVARCHAR(40)  NULL,
    [telefonoCliente] NVARCHAR(40)  NULL,
    [nombreCliente]   NVARCHAR(200) NULL,
    [usuarioAsesor]   NVARCHAR(100) NULL,
    [referencia]      NVARCHAR(80)  NULL,
    [cantidad]        NVARCHAR(40)  NULL,
    [precioUnitario]  NVARCHAR(40)  NULL,
    [descuento]       NVARCHAR(40)  NULL,
    [anulada]         NVARCHAR(10)  NULL,
    [esGarantia]      NVARCHAR(10)  NULL,
    [idCarga]         INT           NULL,
    [estado]          VARCHAR(10)   NULL,  -- VALIDA, RECHAZADA u OMITIDA
    [motivo]          VARCHAR(200)  NULL,
    CONSTRAINT [PK_VentaLinea] PRIMARY KEY CLUSTERED ([idLinea])
);

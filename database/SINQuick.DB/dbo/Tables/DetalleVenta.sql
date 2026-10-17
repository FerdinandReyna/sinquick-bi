-- Tabla DetalleVenta
-- Generada desde el diccionario de datos del proyecto SIN-Quick.
CREATE TABLE [dbo].[DetalleVenta]
(
    [idDetalle] INT IDENTITY(1,1) NOT NULL,
    [idVenta] INT NOT NULL,
    [idProducto] INT NOT NULL,
    [cantidad] INT NOT NULL CONSTRAINT [CK_DetalleVenta_cantidad] CHECK ([cantidad] > 0),
    [precioUnitario] DECIMAL(10,2) NOT NULL CONSTRAINT [CK_DetalleVenta_precioUnitario] CHECK ([precioUnitario] >= 0),
    [costoUnitario] DECIMAL(10,2) NOT NULL CONSTRAINT [CK_DetalleVenta_costoUnitario] CHECK ([costoUnitario] >= 0),
    [descuento] DECIMAL(10,2) NOT NULL CONSTRAINT [DF_DetalleVenta_descuento] DEFAULT (0),
    [esGarantia] BIT NOT NULL CONSTRAINT [DF_DetalleVenta_esGarantia] DEFAULT (0),
    CONSTRAINT [PK_DetalleVenta] PRIMARY KEY CLUSTERED ([idDetalle]),
    CONSTRAINT [FK_DetalleVenta_Venta_idVenta] FOREIGN KEY ([idVenta]) REFERENCES [dbo].[Venta] ([idVenta]) ON DELETE CASCADE,
    CONSTRAINT [FK_DetalleVenta_Producto_idProducto] FOREIGN KEY ([idProducto]) REFERENCES [dbo].[Producto] ([idProducto])
);

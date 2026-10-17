-- Tabla MovimientoInventario
-- Generada desde el diccionario de datos del proyecto SIN-Quick.
CREATE TABLE [dbo].[MovimientoInventario]
(
    [idMovimiento] INT IDENTITY(1,1) NOT NULL,
    [idProducto] INT NOT NULL,
    [idFecha] INT NOT NULL,
    [tipoMovimiento] VARCHAR(20) NOT NULL CONSTRAINT [CK_MovimientoInventario_tipoMovimiento] CHECK ([tipoMovimiento] IN ('INGRESO','SALIDA','AJUSTE')),
    [cantidad] INT NOT NULL CONSTRAINT [CK_MovimientoInventario_cantidad] CHECK ([cantidad] <> 0),
    [idVenta] INT NULL,
    [idUsuario] INT NOT NULL,
    [observacion] VARCHAR(200) NULL,
    CONSTRAINT [PK_MovimientoInventario] PRIMARY KEY CLUSTERED ([idMovimiento]),
    CONSTRAINT [FK_MovimientoInventario_Producto_idProducto] FOREIGN KEY ([idProducto]) REFERENCES [dbo].[Producto] ([idProducto]),
    CONSTRAINT [FK_MovimientoInventario_DimTiempo_idFecha] FOREIGN KEY ([idFecha]) REFERENCES [dbo].[DimTiempo] ([idFecha]),
    CONSTRAINT [FK_MovimientoInventario_Venta_idVenta] FOREIGN KEY ([idVenta]) REFERENCES [dbo].[Venta] ([idVenta]),
    CONSTRAINT [FK_MovimientoInventario_Usuario_idUsuario] FOREIGN KEY ([idUsuario]) REFERENCES [dbo].[Usuario] ([idUsuario])
);

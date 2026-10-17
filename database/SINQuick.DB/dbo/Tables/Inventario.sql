-- Tabla Inventario
-- Generada desde el diccionario de datos del proyecto SIN-Quick.
CREATE TABLE [dbo].[Inventario]
(
    [idInventario] INT IDENTITY(1,1) NOT NULL,
    [idProducto] INT NOT NULL,
    [existenciaActual] INT NOT NULL CONSTRAINT [DF_Inventario_existenciaActual] DEFAULT (0) CONSTRAINT [CK_Inventario_existenciaActual] CHECK ([existenciaActual] >= 0),
    [fechaUltimoMovimiento] DATE NULL,
    [fechaUltimoConteo] DATE NULL,
    [costoPromedio] DECIMAL(10,2) NOT NULL CONSTRAINT [DF_Inventario_costoPromedio] DEFAULT (0),
    CONSTRAINT [PK_Inventario] PRIMARY KEY CLUSTERED ([idInventario]),
    CONSTRAINT [FK_Inventario_Producto_idProducto] FOREIGN KEY ([idProducto]) REFERENCES [dbo].[Producto] ([idProducto]),
    CONSTRAINT [UQ_Inventario_idProducto] UNIQUE ([idProducto])
);

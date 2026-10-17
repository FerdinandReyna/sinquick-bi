-- Tabla Producto
-- Generada desde el diccionario de datos del proyecto SIN-Quick.
CREATE TABLE [dbo].[Producto]
(
    [idProducto] INT IDENTITY(1,1) NOT NULL,
    [referencia] VARCHAR(40) NOT NULL,
    [descripcion] VARCHAR(200) NOT NULL,
    [idCategoria] INT NOT NULL,
    [idProveedor] INT NULL,
    [precioVenta] DECIMAL(10,2) NOT NULL CONSTRAINT [CK_Producto_precioVenta] CHECK ([precioVenta] >= 0),
    [costoAdquisicion] DECIMAL(10,2) NOT NULL CONSTRAINT [CK_Producto_costoAdquisicion] CHECK ([costoAdquisicion] >= 0),
    [nivelMinimo] INT NOT NULL CONSTRAINT [DF_Producto_nivelMinimo] DEFAULT (0),
    [activo] BIT NOT NULL CONSTRAINT [DF_Producto_activo] DEFAULT (1),
    CONSTRAINT [PK_Producto] PRIMARY KEY CLUSTERED ([idProducto]),
    CONSTRAINT [UQ_Producto_referencia] UNIQUE ([referencia]),
    CONSTRAINT [FK_Producto_Categoria_idCategoria] FOREIGN KEY ([idCategoria]) REFERENCES [dbo].[Categoria] ([idCategoria]),
    CONSTRAINT [FK_Producto_Proveedor_idProveedor] FOREIGN KEY ([idProveedor]) REFERENCES [dbo].[Proveedor] ([idProveedor])
);

-- Tabla Venta
-- Generada desde el diccionario de datos del proyecto SIN-Quick.
CREATE TABLE [dbo].[Venta]
(
    [idVenta] INT IDENTITY(1,1) NOT NULL,
    [numeroFactura] VARCHAR(30) NOT NULL,
    [idCliente] INT NULL,
    [idUsuario] INT NOT NULL,
    [idFecha] INT NOT NULL,
    [fechaHora] DATETIME NOT NULL,
    [total] DECIMAL(10,2) NOT NULL CONSTRAINT [CK_Venta_total] CHECK ([total] >= 0),
    [anulada] BIT NOT NULL CONSTRAINT [DF_Venta_anulada] DEFAULT (0),
    CONSTRAINT [PK_Venta] PRIMARY KEY CLUSTERED ([idVenta]),
    CONSTRAINT [UQ_Venta_numeroFactura] UNIQUE ([numeroFactura]),
    CONSTRAINT [FK_Venta_Cliente_idCliente] FOREIGN KEY ([idCliente]) REFERENCES [dbo].[Cliente] ([idCliente]),
    CONSTRAINT [FK_Venta_Usuario_idUsuario] FOREIGN KEY ([idUsuario]) REFERENCES [dbo].[Usuario] ([idUsuario]),
    CONSTRAINT [FK_Venta_DimTiempo_idFecha] FOREIGN KEY ([idFecha]) REFERENCES [dbo].[DimTiempo] ([idFecha])
);

-- Tabla DetalleCampania
-- Generada desde el diccionario de datos del proyecto SIN-Quick.
CREATE TABLE [dbo].[DetalleCampania]
(
    [idDetalleCampania] INT IDENTITY(1,1) NOT NULL,
    [idCampania] INT NOT NULL,
    [idCliente] INT NOT NULL,
    [fechaContacto] DATE NULL,
    [resultado] VARCHAR(30) NULL CONSTRAINT [CK_DetalleCampania_resultado] CHECK ([resultado] IN ('SIN CONTACTO','NO RESPONDE','RECHAZA','INTERESADO','COMPRA')),
    [idVentaGenerada] INT NULL,
    CONSTRAINT [PK_DetalleCampania] PRIMARY KEY CLUSTERED ([idDetalleCampania]),
    CONSTRAINT [FK_DetalleCampania_Campania_idCampania] FOREIGN KEY ([idCampania]) REFERENCES [dbo].[Campania] ([idCampania]) ON DELETE CASCADE,
    CONSTRAINT [FK_DetalleCampania_Cliente_idCliente] FOREIGN KEY ([idCliente]) REFERENCES [dbo].[Cliente] ([idCliente]),
    CONSTRAINT [FK_DetalleCampania_Venta_idVentaGenerada] FOREIGN KEY ([idVentaGenerada]) REFERENCES [dbo].[Venta] ([idVenta])
);

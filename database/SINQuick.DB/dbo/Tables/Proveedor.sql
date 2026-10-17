-- Tabla Proveedor
-- Generada desde el diccionario de datos del proyecto SIN-Quick.
CREATE TABLE [dbo].[Proveedor]
(
    [idProveedor] INT IDENTITY(1,1) NOT NULL,
    [nombre] VARCHAR(120) NOT NULL,
    [contacto] VARCHAR(100) NULL,
    [telefono] VARCHAR(15) NULL,
    [diasEntrega] SMALLINT NULL,
    [activo] BIT NOT NULL CONSTRAINT [DF_Proveedor_activo] DEFAULT (1),
    CONSTRAINT [PK_Proveedor] PRIMARY KEY CLUSTERED ([idProveedor])
);

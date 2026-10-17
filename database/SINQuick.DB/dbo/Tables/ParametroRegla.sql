-- Tabla ParametroRegla
-- Generada desde el diccionario de datos del proyecto SIN-Quick.
CREATE TABLE [dbo].[ParametroRegla]
(
    [idParametro] INT IDENTITY(1,1) NOT NULL,
    [codigoRegla] VARCHAR(10) NOT NULL,
    [descripcion] VARCHAR(200) NOT NULL,
    [valor] VARCHAR(50) NOT NULL,
    [unidad] VARCHAR(20) NULL,
    [idUsuarioModifica] INT NULL,
    [fechaModificacion] DATETIME NULL,
    CONSTRAINT [PK_ParametroRegla] PRIMARY KEY CLUSTERED ([idParametro]),
    CONSTRAINT [UQ_ParametroRegla_codigoRegla] UNIQUE ([codigoRegla]),
    CONSTRAINT [FK_ParametroRegla_Usuario_idUsuarioModifica] FOREIGN KEY ([idUsuarioModifica]) REFERENCES [dbo].[Usuario] ([idUsuario])
);

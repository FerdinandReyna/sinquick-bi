-- Tabla RegistroRechazado
-- Generada desde el diccionario de datos del proyecto SIN-Quick.
CREATE TABLE [dbo].[RegistroRechazado]
(
    [idRechazo] INT IDENTITY(1,1) NOT NULL,
    [idCarga] INT NOT NULL,
    [contenidoOriginal] NVARCHAR(MAX) NOT NULL,
    [motivoRechazo] VARCHAR(200) NOT NULL,
    [corregido] BIT NOT NULL CONSTRAINT [DF_RegistroRechazado_corregido] DEFAULT (0),
    [fechaCorreccion] DATETIME NULL,
    CONSTRAINT [PK_RegistroRechazado] PRIMARY KEY CLUSTERED ([idRechazo]),
    CONSTRAINT [FK_RegistroRechazado_CargaDatos_idCarga] FOREIGN KEY ([idCarga]) REFERENCES [dbo].[CargaDatos] ([idCarga])
);

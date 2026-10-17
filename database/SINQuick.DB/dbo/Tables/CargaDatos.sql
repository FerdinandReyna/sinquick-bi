-- Tabla CargaDatos
-- Generada desde el diccionario de datos del proyecto SIN-Quick.
CREATE TABLE [dbo].[CargaDatos]
(
    [idCarga] INT IDENTITY(1,1) NOT NULL,
    [fechaEjecucion] DATETIME NOT NULL CONSTRAINT [DF_CargaDatos_fechaEjecucion] DEFAULT (GETDATE()),
    [tipoCarga] VARCHAR(20) NOT NULL CONSTRAINT [CK_CargaDatos_tipoCarga] CHECK ([tipoCarga] IN ('INICIAL','INCREMENTAL')),
    [registrosProcesados] INT NOT NULL CONSTRAINT [DF_CargaDatos_registrosProcesados] DEFAULT (0),
    [registrosIncorporados] INT NOT NULL CONSTRAINT [DF_CargaDatos_registrosIncorporados] DEFAULT (0),
    [registrosRechazados] INT NOT NULL CONSTRAINT [DF_CargaDatos_registrosRechazados] DEFAULT (0),
    [resultado] VARCHAR(20) NOT NULL CONSTRAINT [CK_CargaDatos_resultado] CHECK ([resultado] IN ('EXITOSA','PARCIAL','FALLIDA')),
    [idUsuario] INT NULL,
    CONSTRAINT [PK_CargaDatos] PRIMARY KEY CLUSTERED ([idCarga]),
    CONSTRAINT [FK_CargaDatos_Usuario_idUsuario] FOREIGN KEY ([idUsuario]) REFERENCES [dbo].[Usuario] ([idUsuario])
);

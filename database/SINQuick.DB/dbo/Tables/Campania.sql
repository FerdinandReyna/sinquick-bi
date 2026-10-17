-- Tabla Campania
-- Generada desde el diccionario de datos del proyecto SIN-Quick.
CREATE TABLE [dbo].[Campania]
(
    [idCampania] INT IDENTITY(1,1) NOT NULL,
    [nombre] VARCHAR(100) NOT NULL,
    [fechaGeneracion] DATE NOT NULL,
    [criterio] VARCHAR(200) NOT NULL,
    [totalContactados] INT NOT NULL CONSTRAINT [DF_Campania_totalContactados] DEFAULT (0),
    [idUsuario] INT NOT NULL,
    CONSTRAINT [PK_Campania] PRIMARY KEY CLUSTERED ([idCampania]),
    CONSTRAINT [FK_Campania_Usuario_idUsuario] FOREIGN KEY ([idUsuario]) REFERENCES [dbo].[Usuario] ([idUsuario])
);

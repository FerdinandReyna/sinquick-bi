-- Tabla Graduacion
-- Generada desde el diccionario de datos del proyecto SIN-Quick.
CREATE TABLE [dbo].[Graduacion]
(
    [idGraduacion] INT IDENTITY(1,1) NOT NULL,
    [idCliente] INT NOT NULL,
    [fechaExamen] DATE NOT NULL,
    [esferaOD] DECIMAL(4,2) NULL,
    [cilindroOD] DECIMAL(4,2) NULL,
    [ejeOD] SMALLINT NULL CONSTRAINT [CK_Graduacion_ejeOD] CHECK ([ejeOD] BETWEEN 0 AND 180),
    [esferaOI] DECIMAL(4,2) NULL,
    [cilindroOI] DECIMAL(4,2) NULL,
    [ejeOI] SMALLINT NULL CONSTRAINT [CK_Graduacion_ejeOI] CHECK ([ejeOI] BETWEEN 0 AND 180),
    [adicion] DECIMAL(4,2) NULL,
    [profesional] VARCHAR(100) NULL,
    [vigente] BIT NOT NULL CONSTRAINT [DF_Graduacion_vigente] DEFAULT (1),
    CONSTRAINT [PK_Graduacion] PRIMARY KEY CLUSTERED ([idGraduacion]),
    CONSTRAINT [FK_Graduacion_Cliente_idCliente] FOREIGN KEY ([idCliente]) REFERENCES [dbo].[Cliente] ([idCliente])
);

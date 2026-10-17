-- Tabla Categoria
-- Generada desde el diccionario de datos del proyecto SIN-Quick.
CREATE TABLE [dbo].[Categoria]
(
    [idCategoria] INT IDENTITY(1,1) NOT NULL,
    [nombre] VARCHAR(60) NOT NULL,
    [descripcion] VARCHAR(200) NULL,
    [activo] BIT NOT NULL CONSTRAINT [DF_Categoria_activo] DEFAULT (1),
    CONSTRAINT [PK_Categoria] PRIMARY KEY CLUSTERED ([idCategoria]),
    CONSTRAINT [UQ_Categoria_nombre] UNIQUE ([nombre])
);

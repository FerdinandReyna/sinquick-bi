-- Tabla DimTiempo
-- Generada desde el diccionario de datos del proyecto SIN-Quick.
CREATE TABLE [dbo].[DimTiempo]
(
    [idFecha] INT NOT NULL,
    [fecha] DATE NOT NULL,
    [anio] SMALLINT NOT NULL,
    [trimestre] TINYINT NOT NULL CONSTRAINT [CK_DimTiempo_trimestre] CHECK ([trimestre] BETWEEN 1 AND 4),
    [mes] TINYINT NOT NULL CONSTRAINT [CK_DimTiempo_mes] CHECK ([mes] BETWEEN 1 AND 12),
    [nombreMes] VARCHAR(15) NOT NULL,
    [diaSemana] VARCHAR(12) NOT NULL,
    [esFinDeSemana] BIT NOT NULL,
    CONSTRAINT [PK_DimTiempo] PRIMARY KEY CLUSTERED ([idFecha]),
    CONSTRAINT [UQ_DimTiempo_fecha] UNIQUE ([fecha])
);

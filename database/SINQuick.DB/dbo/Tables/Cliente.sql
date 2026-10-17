-- Tabla Cliente
-- Generada desde el diccionario de datos del proyecto SIN-Quick.
CREATE TABLE [dbo].[Cliente]
(
    [idCliente] INT IDENTITY(1,1) NOT NULL,
    [nombreCompleto] VARCHAR(120) NOT NULL,
    [telefono] VARCHAR(15) NULL,
    [correo] VARCHAR(100) NULL,
    [fechaRegistro] DATE NOT NULL CONSTRAINT [DF_Cliente_fechaRegistro] DEFAULT (GETDATE()),
    [consentimientoContacto] BIT NOT NULL CONSTRAINT [DF_Cliente_consentimientoContacto] DEFAULT (0),
    [fechaConsentimiento] DATE NULL,
    [fechaExclusion] DATE NULL,
    [activo] BIT NOT NULL CONSTRAINT [DF_Cliente_activo] DEFAULT (1),
    CONSTRAINT [PK_Cliente] PRIMARY KEY CLUSTERED ([idCliente])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Cliente_telefono] ON [dbo].[Cliente] ([telefono]) WHERE [telefono] IS NOT NULL;

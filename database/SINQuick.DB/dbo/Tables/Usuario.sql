-- Tabla Usuario
-- Generada desde el diccionario de datos del proyecto SIN-Quick.
CREATE TABLE [dbo].[Usuario]
(
    [idUsuario] INT IDENTITY(1,1) NOT NULL,
    [nombreCompleto] VARCHAR(120) NOT NULL,
    [nombreUsuario] VARCHAR(50) NOT NULL,
    [hashContrasena] VARBINARY(256) NOT NULL,
    [perfil] VARCHAR(20) NOT NULL CONSTRAINT [CK_Usuario_perfil] CHECK ([perfil] IN ('U1','U2','U3')),
    [activo] BIT NOT NULL CONSTRAINT [DF_Usuario_activo] DEFAULT (1),
    [fechaAlta] DATE NOT NULL CONSTRAINT [DF_Usuario_fechaAlta] DEFAULT (GETDATE()),
    CONSTRAINT [PK_Usuario] PRIMARY KEY CLUSTERED ([idUsuario]),
    CONSTRAINT [UQ_Usuario_nombreUsuario] UNIQUE ([nombreUsuario])
);

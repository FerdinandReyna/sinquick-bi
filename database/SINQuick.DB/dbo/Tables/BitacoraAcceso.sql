-- Tabla BitacoraAcceso
-- Generada desde el diccionario de datos del proyecto SIN-Quick.
CREATE TABLE [dbo].[BitacoraAcceso]
(
    [idBitacora] BIGINT IDENTITY(1,1) NOT NULL,
    [idUsuario] INT NOT NULL,
    [fechaHora] DATETIME NOT NULL CONSTRAINT [DF_BitacoraAcceso_fechaHora] DEFAULT (GETDATE()),
    [accion] VARCHAR(40) NOT NULL CONSTRAINT [CK_BitacoraAcceso_accion] CHECK ([accion] IN ('INICIO SESION','CIERRE SESION','CONSULTA GRADUACION','ALTA USUARIO','CAMBIO PARAMETRO','RESPALDO','RESTAURACION')),
    [entidadAfectada] VARCHAR(50) NULL,
    [idRegistroAfectado] INT NULL,
    [direccionOrigen] VARCHAR(45) NULL,
    CONSTRAINT [PK_BitacoraAcceso] PRIMARY KEY CLUSTERED ([idBitacora]),
    CONSTRAINT [FK_BitacoraAcceso_Usuario_idUsuario] FOREIGN KEY ([idUsuario]) REFERENCES [dbo].[Usuario] ([idUsuario])
);

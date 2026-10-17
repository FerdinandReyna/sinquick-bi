-- Registra el inicio de una carga. Nace como FALLIDA a propósito: si el proceso
-- se interrumpe, la bitácora nunca muestra como exitosa una carga que no terminó.
CREATE PROCEDURE [etl].[usp_IniciarCarga]
    @tipoCarga VARCHAR(20) = 'INCREMENTAL',
    @idCarga   INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [dbo].[CargaDatos] ([tipoCarga], [resultado])
    VALUES (@tipoCarga, 'FALLIDA');
    SET @idCarga = CONVERT(INT, SCOPE_IDENTITY());
END;

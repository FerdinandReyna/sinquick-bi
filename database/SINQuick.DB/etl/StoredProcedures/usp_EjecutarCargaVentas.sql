-- Punto de entrada de la carga de ventas. Es lo que invoca el paquete SSIS
-- CargaVentas.dtsx (tarea Ejecutar SQL) y lo que usan las pruebas automatizadas.
CREATE PROCEDURE [etl].[usp_EjecutarCargaVentas]
    @ruta      NVARCHAR(260),
    @tipoCarga VARCHAR(20) = 'INCREMENTAL',
    @idCarga   INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC [etl].[usp_IniciarCarga] @tipoCarga = @tipoCarga, @idCarga = @idCarga OUTPUT;
    BEGIN TRY
        EXEC [etl].[usp_CargarArchivoStaging] @ruta = @ruta, @idCarga = @idCarga;
        EXEC [etl].[usp_ValidarVentas] @idCarga = @idCarga;
        EXEC [etl].[usp_CargarVentasDW] @idCarga = @idCarga;
    END TRY
    BEGIN CATCH
        UPDATE [dbo].[CargaDatos] SET [resultado] = 'FALLIDA' WHERE [idCarga] = @idCarga;
        THROW;
    END CATCH;
    SELECT [idCarga], [resultado], [registrosProcesados], [registrosIncorporados], [registrosRechazados]
    FROM [dbo].[CargaDatos] WHERE [idCarga] = @idCarga;
END;

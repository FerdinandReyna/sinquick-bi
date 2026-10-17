-- Carga el archivo CSV exportado por el punto de venta en stg.VentaLinea.
-- La cuenta que ejecuta este procedimiento necesita el permiso de servidor
-- ADMINISTER BULK OPERATIONS (rol bulkadmin) y lectura sobre la carpeta de entrada.
CREATE PROCEDURE [etl].[usp_CargarArchivoStaging]
    @ruta    NVARCHAR(260),
    @idCarga INT
AS
BEGIN
    SET NOCOUNT ON;
    -- La ruta se arma en SQL dinámico: se rechaza cualquier carácter que permita inyección
    IF @ruta IS NULL OR @ruta LIKE N'%''%' OR @ruta LIKE N'%;%' OR @ruta LIKE N'%--%'
        THROW 50010, N'Ruta de archivo no válida.', 1;

    DELETE FROM [stg].[VentaLinea];

    DECLARE @sql NVARCHAR(MAX) =
        N'BULK INSERT [stg].[vw_VentaLineaCarga] FROM N''' + @ruta + N''' ' +
        N'WITH (FORMAT = ''CSV'', FIRSTROW = 2, FIELDTERMINATOR = '','', ' +
        N'ROWTERMINATOR = ''0x0a'', CODEPAGE = ''65001'', TABLOCK);';
    EXEC sys.sp_executesql @sql;

    -- Los archivos generados en Windows terminan las líneas con CR+LF
    UPDATE [stg].[VentaLinea]
    SET [idCarga]    = @idCarga,
        [esGarantia] = REPLACE([esGarantia], NCHAR(13), N'');

    UPDATE [dbo].[CargaDatos]
    SET [registrosProcesados] = (SELECT COUNT(*) FROM [stg].[VentaLinea])
    WHERE [idCarga] = @idCarga;
END;

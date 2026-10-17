-- Valida las líneas de staging. Las inválidas se apartan en RegistroRechazado con
-- su motivo (RF-03); las facturas ya cargadas se omiten sin contarse como error.
-- Si el porcentaje de rechazo supera el umbral (parámetro UMB-RECH), la carga se detiene.
CREATE PROCEDURE [etl].[usp_ValidarVentas]
    @idCarga       INT,
    @umbralRechazo DECIMAL(5,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @umbralRechazo IS NULL
        SELECT @umbralRechazo = ISNULL(TRY_CONVERT(DECIMAL(5,2), [valor]), 5)
        FROM [dbo].[ParametroRegla] WHERE [codigoRegla] = 'UMB-RECH';
    SET @umbralRechazo = ISNULL(@umbralRechazo, 5);

    UPDATE [stg].[VentaLinea] SET [estado] = NULL, [motivo] = NULL WHERE [idCarga] = @idCarga;

    -- 1. Facturas que ya existen en el data warehouse: se omiten (carga idempotente)
    UPDATE s SET [estado] = 'OMITIDA'
    FROM [stg].[VentaLinea] s
    WHERE s.[idCarga] = @idCarga
      AND EXISTS (SELECT 1 FROM [dbo].[Venta] v WHERE v.[numeroFactura] = LTRIM(RTRIM(s.[numeroFactura])));

    -- 2. Reglas de calidad por línea (la primera que falla define el motivo)
    UPDATE s SET [estado] = 'RECHAZADA', [motivo] = x.[motivo]
    FROM [stg].[VentaLinea] s
    LEFT JOIN [dbo].[Producto]  p ON p.[referencia]    = LTRIM(RTRIM(s.[referencia])) AND p.[activo] = 1
    LEFT JOIN [dbo].[Usuario]   u ON u.[nombreUsuario] = LTRIM(RTRIM(s.[usuarioAsesor])) AND u.[activo] = 1
    LEFT JOIN [dbo].[DimTiempo] t ON t.[fecha] = TRY_CONVERT(DATE, TRY_CONVERT(DATETIME2(0), s.[fechaHora], 120))
    CROSS APPLY (SELECT CASE
        WHEN NULLIF(LTRIM(RTRIM(s.[numeroFactura])), N'') IS NULL                         THEN 'Número de factura vacío'
        WHEN TRY_CONVERT(DATETIME2(0), s.[fechaHora], 120) IS NULL                          THEN 'Fecha y hora con formato inválido'
        WHEN t.[idFecha] IS NULL                                                            THEN 'Fecha fuera del calendario'
        WHEN TRY_CONVERT(INT, s.[cantidad]) IS NULL OR TRY_CONVERT(INT, s.[cantidad]) <= 0  THEN 'Cantidad inválida'
        WHEN TRY_CONVERT(DECIMAL(10,2), s.[precioUnitario]) IS NULL
          OR TRY_CONVERT(DECIMAL(10,2), s.[precioUnitario]) < 0                             THEN 'Precio unitario inválido'
        WHEN TRY_CONVERT(DECIMAL(10,2), ISNULL(NULLIF(s.[descuento], N''), N'0')) IS NULL
          OR TRY_CONVERT(DECIMAL(10,2), ISNULL(NULLIF(s.[descuento], N''), N'0')) < 0       THEN 'Descuento inválido'
        WHEN TRY_CONVERT(DECIMAL(10,2), ISNULL(NULLIF(s.[descuento], N''), N'0'))
           > TRY_CONVERT(INT, s.[cantidad]) * TRY_CONVERT(DECIMAL(10,2), s.[precioUnitario]) THEN 'Descuento mayor que el importe de la línea'
        WHEN p.[idProducto] IS NULL                                                         THEN LEFT('Producto inexistente: ' + ISNULL(CONVERT(VARCHAR(80), s.[referencia]), '(vacío)'), 200)
        WHEN u.[idUsuario] IS NULL                                                          THEN LEFT('Asesor inexistente: ' + ISNULL(CONVERT(VARCHAR(100), s.[usuarioAsesor]), '(vacío)'), 200)
        WHEN ISNULL(s.[anulada], N'') NOT IN (N'0', N'1')
          OR ISNULL(s.[esGarantia], N'') NOT IN (N'0', N'1')                               THEN 'Indicador de anulada o garantía inválido'
        END AS [motivo]) x
    WHERE s.[idCarga] = @idCarga AND s.[estado] IS NULL AND x.[motivo] IS NOT NULL;

    -- 3. Una factura con encabezado inconsistente entre sus líneas se rechaza completa
    UPDATE s SET [estado] = 'RECHAZADA', [motivo] = 'Factura con encabezado inconsistente entre líneas'
    FROM [stg].[VentaLinea] s
    WHERE s.[idCarga] = @idCarga AND ISNULL(s.[estado], '') <> 'OMITIDA'
      AND s.[numeroFactura] IN (
          SELECT [numeroFactura] FROM [stg].[VentaLinea]
          WHERE [idCarga] = @idCarga AND ISNULL([estado], '') <> 'OMITIDA'
          GROUP BY [numeroFactura]
          HAVING COUNT(DISTINCT ISNULL([fechaHora], N'')) > 1
              OR COUNT(DISTINCT ISNULL([telefonoCliente], N'')) > 1
              OR COUNT(DISTINCT ISNULL([usuarioAsesor], N'')) > 1
              OR COUNT(DISTINCT ISNULL([anulada], N'')) > 1);

    UPDATE [stg].[VentaLinea] SET [estado] = 'VALIDA' WHERE [idCarga] = @idCarga AND [estado] IS NULL;

    INSERT INTO [dbo].[RegistroRechazado] ([idCarga], [contenidoOriginal], [motivoRechazo])
    SELECT @idCarga,
           CONCAT_WS(N',', [numeroFactura], [fechaHora], [telefonoCliente], [nombreCliente], [usuarioAsesor],
                     [referencia], [cantidad], [precioUnitario], [descuento], [anulada], [esGarantia]),
           [motivo]
    FROM [stg].[VentaLinea]
    WHERE [idCarga] = @idCarga AND [estado] = 'RECHAZADA';

    DECLARE @evaluadas INT, @rechazadas INT, @porcentaje DECIMAL(5,2);
    SELECT @evaluadas  = SUM(CASE WHEN [estado] <> 'OMITIDA' THEN 1 ELSE 0 END),
           @rechazadas = SUM(CASE WHEN [estado] = 'RECHAZADA' THEN 1 ELSE 0 END)
    FROM [stg].[VentaLinea] WHERE [idCarga] = @idCarga;

    SET @evaluadas  = ISNULL(@evaluadas, 0);
    SET @rechazadas = ISNULL(@rechazadas, 0);
    SET @porcentaje = CASE WHEN @evaluadas = 0 THEN 0 ELSE 100.0 * @rechazadas / @evaluadas END;

    UPDATE [dbo].[CargaDatos] SET [registrosRechazados] = @rechazadas WHERE [idCarga] = @idCarga;

    IF @porcentaje > @umbralRechazo
    BEGIN
        DECLARE @mensaje NVARCHAR(400) = CONCAT(N'El rechazo de ', @porcentaje, N' % supera el umbral de ',
                                                @umbralRechazo, N' %. La carga se detuvo sin modificar el data warehouse.');
        THROW 50020, @mensaje, 1;
    END;
END;

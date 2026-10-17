-- Lleva las líneas válidas de staging al modelo dimensional en una sola transacción.
-- El costo se congela al momento de la carga para que el margen histórico no cambie.
CREATE PROCEDURE [etl].[usp_CargarVentasDW]
    @idCarga INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Líneas válidas ya tipadas
        SELECT LTRIM(RTRIM(s.[numeroFactura]))                              AS numeroFactura,
               TRY_CONVERT(DATETIME2(0), s.[fechaHora], 120)                AS fechaHora,
               NULLIF(LTRIM(RTRIM(s.[telefonoCliente])), N'')               AS telefono,
               NULLIF(LTRIM(RTRIM(s.[nombreCliente])), N'')                 AS nombre,
               u.[idUsuario],
               p.[idProducto],
               p.[costoAdquisicion],
               TRY_CONVERT(INT, s.[cantidad])                               AS cantidad,
               TRY_CONVERT(DECIMAL(10,2), s.[precioUnitario])               AS precioUnitario,
               TRY_CONVERT(DECIMAL(10,2), ISNULL(NULLIF(s.[descuento], N''), N'0')) AS descuento,
               CONVERT(BIT, s.[anulada])                                    AS anulada,
               CONVERT(BIT, s.[esGarantia])                                 AS esGarantia
        INTO #lineas
        FROM [stg].[VentaLinea] s
        JOIN [dbo].[Producto] p ON p.[referencia] = LTRIM(RTRIM(s.[referencia]))
        JOIN [dbo].[Usuario]  u ON u.[nombreUsuario] = LTRIM(RTRIM(s.[usuarioAsesor]))
        WHERE s.[idCarga] = @idCarga AND s.[estado] = 'VALIDA';

        -- 1. Clientes nuevos, identificados por teléfono (RN-07). Sin teléfono = consumidor final.
        INSERT INTO [dbo].[Cliente] ([nombreCompleto], [telefono])
        SELECT CONVERT(VARCHAR(120), ISNULL(MAX(l.nombre), N'Cliente sin nombre')), CONVERT(VARCHAR(15), l.telefono)
        FROM #lineas l
        WHERE l.telefono IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM [dbo].[Cliente] c WHERE c.[telefono] = l.telefono)
        GROUP BY l.telefono;

        -- 2. Encabezados de venta (RN-08: la fecha es la de facturación)
        INSERT INTO [dbo].[Venta] ([numeroFactura], [idCliente], [idUsuario], [idFecha], [fechaHora], [total], [anulada])
        SELECT l.numeroFactura, c.[idCliente], MAX(l.idUsuario),
               CONVERT(INT, CONVERT(CHAR(8), MAX(l.fechaHora), 112)), MAX(l.fechaHora),
               SUM(l.cantidad * l.precioUnitario - l.descuento),
               CONVERT(BIT, MAX(CONVERT(INT, l.anulada)))
        FROM #lineas l
        LEFT JOIN [dbo].[Cliente] c ON c.[telefono] = l.telefono
        GROUP BY l.numeroFactura, c.[idCliente];

        -- 3. Detalle (grano del hecho). El par de lentes llega como una sola línea (RN-06).
        INSERT INTO [dbo].[DetalleVenta] ([idVenta], [idProducto], [cantidad], [precioUnitario], [costoUnitario], [descuento], [esGarantia])
        SELECT v.[idVenta], l.idProducto, l.cantidad, l.precioUnitario, l.costoAdquisicion, l.descuento, l.esGarantia
        FROM #lineas l
        JOIN [dbo].[Venta] v ON v.[numeroFactura] = l.numeroFactura;

        DECLARE @incorporadas INT = @@ROWCOUNT;

        UPDATE [dbo].[CargaDatos]
        SET [registrosIncorporados] = @incorporadas,
            [resultado] = CASE WHEN [registrosRechazados] > 0 THEN 'PARCIAL' ELSE 'EXITOSA' END
        WHERE [idCarga] = @idCarga;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        UPDATE [dbo].[CargaDatos] SET [resultado] = 'FALLIDA' WHERE [idCarga] = @idCarga;
        THROW;
    END CATCH;
END;

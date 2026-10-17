/*
 Pruebas unitarias de la validación de la carga (tSQLt).
*/
EXEC tSQLt.NewTestClass 'pruebasCarga';
GO

-- Prepara un escenario mínimo: un producto, un asesor, el calendario del día y una carga abierta.
CREATE PROCEDURE [pruebasCarga].[SetUp]
AS
BEGIN
    EXEC tSQLt.FakeTable 'stg.VentaLinea', @Identity = 1;
    EXEC tSQLt.FakeTable 'dbo.Producto';
    EXEC tSQLt.FakeTable 'dbo.Usuario';
    EXEC tSQLt.FakeTable 'dbo.DimTiempo';
    EXEC tSQLt.FakeTable 'dbo.Venta';
    EXEC tSQLt.FakeTable 'dbo.CargaDatos';
    EXEC tSQLt.FakeTable 'dbo.RegistroRechazado';
    EXEC tSQLt.FakeTable 'dbo.ParametroRegla';
    INSERT INTO dbo.Producto (idProducto, referencia, activo) VALUES (1, 'ARM-1', 1);
    INSERT INTO dbo.Usuario (idUsuario, nombreUsuario, activo) VALUES (1, 'asesor1', 1);
    INSERT INTO dbo.DimTiempo (idFecha, fecha) VALUES (20260928, '2026-09-28');
    INSERT INTO dbo.CargaDatos (idCarga, tipoCarga, resultado, registrosRechazados) VALUES (1, 'INCREMENTAL', 'FALLIDA', 0);
END;
GO

CREATE PROCEDURE [pruebasCarga].[test CP-07 una cantidad inválida se aparta con su motivo]
AS
BEGIN
    INSERT INTO stg.VentaLinea (numeroFactura, fechaHora, usuarioAsesor, referencia, cantidad, precioUnitario, descuento, anulada, esGarantia, idCarga)
    VALUES ('F-1', '2026-09-28 10:00:00', 'asesor1', 'ARM-1', '2',   '350', '0', '0', '0', 1),
           ('F-2', '2026-09-28 11:00:00', 'asesor1', 'ARM-1', 'dos', '350', '0', '0', '0', 1);

    EXEC etl.usp_ValidarVentas @idCarga = 1, @umbralRechazo = 100;

    SELECT motivoRechazo INTO #actual FROM dbo.RegistroRechazado WHERE idCarga = 1;
    CREATE TABLE #esperado (motivoRechazo VARCHAR(200));
    INSERT INTO #esperado VALUES ('Cantidad inválida');
    EXEC tSQLt.AssertEqualsTable '#esperado', '#actual';
END;
GO

CREATE PROCEDURE [pruebasCarga].[test CP-08 la carga se detiene si el rechazo supera el umbral]
AS
BEGIN
    INSERT INTO stg.VentaLinea (numeroFactura, fechaHora, usuarioAsesor, referencia, cantidad, precioUnitario, descuento, anulada, esGarantia, idCarga)
    VALUES ('F-1', '2026-09-28 10:00:00', 'asesor1', 'ARM-1',       '1', '350', '0', '0', '0', 1),
           ('F-2', '2026-09-28 11:00:00', 'asesor1', 'NO-EXISTE',   '1', '350', '0', '0', '0', 1);

    EXEC tSQLt.ExpectException @ExpectedErrorNumber = 50020;
    EXEC etl.usp_ValidarVentas @idCarga = 1, @umbralRechazo = 5;   -- 50 % de rechazo
END;
GO

CREATE PROCEDURE [pruebasCarga].[test CP-09 una factura ya cargada se omite sin contarse como rechazo]
AS
BEGIN
    INSERT INTO dbo.Venta (idVenta, numeroFactura) VALUES (1, 'F-1');
    INSERT INTO stg.VentaLinea (numeroFactura, fechaHora, usuarioAsesor, referencia, cantidad, precioUnitario, descuento, anulada, esGarantia, idCarga)
    VALUES ('F-1', '2026-09-28 10:00:00', 'asesor1', 'ARM-1', '1', '350', '0', '0', '0', 1);

    EXEC etl.usp_ValidarVentas @idCarga = 1, @umbralRechazo = 0;

    DECLARE @estado VARCHAR(10) = (SELECT estado FROM stg.VentaLinea WHERE numeroFactura = 'F-1');
    DECLARE @rechazos INT = (SELECT registrosRechazados FROM dbo.CargaDatos WHERE idCarga = 1);
    EXEC tSQLt.AssertEquals @Expected = 'OMITIDA', @Actual = @estado;
    EXEC tSQLt.AssertEquals @Expected = 0, @Actual = @rechazos;
END;
GO

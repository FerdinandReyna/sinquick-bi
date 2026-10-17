/*
 Pruebas unitarias de las reglas de negocio (tSQLt).
 Cada prueba aísla sus tablas con tSQLt.FakeTable: no depende de los datos
 de la base ni de otras pruebas, y todo se revierte al terminar.
*/
EXEC tSQLt.NewTestClass 'pruebasReglas';
GO

CREATE PROCEDURE [pruebasReglas].[test CP-01 RN-01 marca el ciclo vencido a los 18 meses]
AS
BEGIN
    EXEC tSQLt.FakeTable 'dbo.Cliente';
    EXEC tSQLt.FakeTable 'dbo.Venta';
    EXEC tSQLt.FakeTable 'dbo.ParametroRegla';
    INSERT INTO dbo.ParametroRegla (codigoRegla, valor) VALUES ('RN-01', '18');
    INSERT INTO dbo.Cliente (idCliente, nombreCompleto, telefono, consentimientoContacto, activo)
    VALUES (1, 'Compra hace 20 meses', '50255510001', 1, 1),
           (2, 'Compra hace 3 meses',  '50255510002', 1, 1);
    INSERT INTO dbo.Venta (idVenta, numeroFactura, idCliente, fechaHora, anulada)
    VALUES (1, 'F-1', 1, DATEADD(MONTH, -20, GETDATE()), 0),
           (2, 'F-2', 2, DATEADD(MONTH,  -3, GETDATE()), 0);

    SELECT idCliente, cicloVencido INTO #actual FROM rpt.vw_ClientesRenovacion;

    CREATE TABLE #esperado (idCliente INT, cicloVencido BIT);
    INSERT INTO #esperado VALUES (1, 1), (2, 0);
    EXEC tSQLt.AssertEqualsTable '#esperado', '#actual';
END;
GO

CREATE PROCEDURE [pruebasReglas].[test CP-02 RN-01 usa el parámetro configurado y no un valor fijo]
AS
BEGIN
    EXEC tSQLt.FakeTable 'dbo.Cliente';
    EXEC tSQLt.FakeTable 'dbo.Venta';
    EXEC tSQLt.FakeTable 'dbo.ParametroRegla';
    INSERT INTO dbo.ParametroRegla (codigoRegla, valor) VALUES ('RN-01', '12');
    INSERT INTO dbo.Cliente (idCliente, nombreCompleto, telefono, consentimientoContacto, activo)
    VALUES (1, 'Compra hace 14 meses', '50255510001', 1, 1);
    INSERT INTO dbo.Venta (idVenta, numeroFactura, idCliente, fechaHora, anulada)
    VALUES (1, 'F-1', 1, DATEADD(MONTH, -14, GETDATE()), 0);

    DECLARE @vencido BIT = (SELECT cicloVencido FROM rpt.vw_ClientesRenovacion WHERE idCliente = 1);
    EXEC tSQLt.AssertEquals @Expected = 1, @Actual = @vencido,
         @Message = N'Con el parámetro en 12 meses, una compra de hace 14 meses debe estar vencida';
END;
GO

CREATE PROCEDURE [pruebasReglas].[test CP-03 RN-09 solo es contactable quien tiene teléfono, consentimiento y no pidió exclusión]
AS
BEGIN
    EXEC tSQLt.FakeTable 'dbo.Cliente';
    EXEC tSQLt.FakeTable 'dbo.Venta';
    EXEC tSQLt.FakeTable 'dbo.ParametroRegla';
    INSERT INTO dbo.Cliente (idCliente, nombreCompleto, telefono, consentimientoContacto, fechaExclusion, activo)
    VALUES (1, 'Contactable',        '50255510001', 1, NULL,         1),
           (2, 'Sin consentimiento', '50255510002', 0, NULL,         1),
           (3, 'Sin teléfono',       NULL,          1, NULL,         1),
           (4, 'Pidió exclusión',    '50255510004', 1, '2026-01-10', 1);
    INSERT INTO dbo.Venta (idVenta, numeroFactura, idCliente, fechaHora, anulada)
    SELECT idCliente, CONCAT('F-', idCliente), idCliente, DATEADD(MONTH, -20, GETDATE()), 0 FROM dbo.Cliente;

    SELECT idCliente, contactable, motivoExclusion INTO #actual FROM rpt.vw_ClientesRenovacion;

    CREATE TABLE #esperado (idCliente INT, contactable BIT, motivoExclusion VARCHAR(30));
    INSERT INTO #esperado VALUES (1, 1, NULL), (2, 0, 'SIN CONSENTIMIENTO'), (3, 0, 'SIN TELEFONO'), (4, 0, 'EXCLUSION SOLICITADA');
    EXEC tSQLt.AssertEqualsTable '#esperado', '#actual';
END;
GO

CREATE PROCEDURE [pruebasReglas].[test CP-04 RN-03 detecta la existencia bajo el nivel mínimo]
AS
BEGIN
    EXEC tSQLt.FakeTable 'dbo.Producto';
    EXEC tSQLt.FakeTable 'dbo.Inventario';
    EXEC tSQLt.FakeTable 'dbo.ParametroRegla';
    INSERT INTO dbo.Producto (idProducto, referencia, descripcion, nivelMinimo, activo)
    VALUES (1, 'ARM-RB3025', 'Bajo mínimo', 5, 1), (2, 'ARM-VG1180', 'Suficiente', 4, 1);
    INSERT INTO dbo.Inventario (idInventario, idProducto, existenciaActual, costoPromedio, fechaUltimoMovimiento)
    VALUES (1, 1, 2, 240, CONVERT(DATE, GETDATE())), (2, 2, 14, 185, CONVERT(DATE, GETDATE()));

    SELECT referencia, bajoMinimo INTO #actual FROM rpt.vw_InventarioAlertas;

    CREATE TABLE #esperado (referencia VARCHAR(40), bajoMinimo BIT);
    INSERT INTO #esperado VALUES ('ARM-RB3025', 1), ('ARM-VG1180', 0);
    EXEC tSQLt.AssertEqualsTable '#esperado', '#actual';
END;
GO

CREATE PROCEDURE [pruebasReglas].[test CP-05 RN-04 marca el inventario sin movimiento y calcula su valor]
AS
BEGIN
    EXEC tSQLt.FakeTable 'dbo.Producto';
    EXEC tSQLt.FakeTable 'dbo.Inventario';
    EXEC tSQLt.FakeTable 'dbo.ParametroRegla';
    INSERT INTO dbo.ParametroRegla (codigoRegla, valor) VALUES ('RN-04', '180');
    INSERT INTO dbo.Producto (idProducto, referencia, descripcion, nivelMinimo, activo)
    VALUES (1, 'ARM-VG1180', 'Hace 200 días', 4, 1), (2, 'LC-ACV-M', 'Hace 5 días', 12, 1);
    INSERT INTO dbo.Inventario (idInventario, idProducto, existenciaActual, costoPromedio, fechaUltimoMovimiento)
    VALUES (1, 1, 14, 185, DATEADD(DAY, -200, CONVERT(DATE, GETDATE()))),
           (2, 2, 30,  95, DATEADD(DAY,   -5, CONVERT(DATE, GETDATE())));

    SELECT referencia, sinMovimiento, valorEnBodega INTO #actual FROM rpt.vw_InventarioAlertas;

    CREATE TABLE #esperado (referencia VARCHAR(40), sinMovimiento BIT, valorEnBodega DECIMAL(12,2));
    INSERT INTO #esperado VALUES ('ARM-VG1180', 1, 2590.00), ('LC-ACV-M', 0, 2850.00);
    EXEC tSQLt.AssertEqualsTable '#esperado', '#actual';
END;
GO

CREATE PROCEDURE [pruebasReglas].[test CP-06 el margen excluye ventas anuladas y reposiciones en garantía]
AS
BEGIN
    EXEC tSQLt.FakeTable 'dbo.DetalleVenta';
    EXEC tSQLt.FakeTable 'dbo.Venta';
    EXEC tSQLt.FakeTable 'dbo.DimTiempo';
    EXEC tSQLt.FakeTable 'dbo.Usuario';
    EXEC tSQLt.FakeTable 'dbo.Producto';
    EXEC tSQLt.FakeTable 'dbo.Categoria';
    EXEC tSQLt.FakeTable 'dbo.Proveedor';
    EXEC tSQLt.FakeTable 'dbo.Cliente';
    INSERT INTO dbo.DimTiempo (idFecha, fecha, anio, mes) VALUES (20260928, '2026-09-28', 2026, 9);
    INSERT INTO dbo.Usuario (idUsuario, nombreCompleto) VALUES (1, 'Asesor');
    INSERT INTO dbo.Categoria (idCategoria, nombre) VALUES (1, 'Armazones');
    INSERT INTO dbo.Producto (idProducto, referencia, descripcion, idCategoria) VALUES (1, 'ARM-1', 'Armazón', 1);
    INSERT INTO dbo.Venta (idVenta, numeroFactura, idUsuario, idFecha, anulada)
    VALUES (1, 'F-VALIDA', 1, 20260928, 0), (2, 'F-ANULADA', 1, 20260928, 1);
    INSERT INTO dbo.DetalleVenta (idDetalle, idVenta, idProducto, cantidad, precioUnitario, costoUnitario, descuento, esGarantia)
    VALUES (1, 1, 1, 2, 350, 180, 20, 0),   -- venta normal: ingreso 680, costo 360, margen 320
           (2, 1, 1, 1, 0,   180, 0,  1),   -- reposición en garantía: no es ingreso
           (3, 2, 1, 1, 350, 180, 0,  0);   -- venta anulada: no cuenta

    SELECT idDetalle, ingreso, costo, margen INTO #actual FROM rpt.vw_VentasDetalle;

    CREATE TABLE #esperado (idDetalle INT, ingreso DECIMAL(12,2), costo DECIMAL(12,2), margen DECIMAL(12,2));
    INSERT INTO #esperado VALUES (1, 680.00, 360.00, 320.00);
    EXEC tSQLt.AssertEqualsTable '#esperado', '#actual';
END;
GO

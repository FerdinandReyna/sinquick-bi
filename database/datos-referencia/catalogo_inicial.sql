/*
 Catálogo inicial de referencia: categorías, proveedores, productos y asesores.
 En producción se reemplaza por la exportación del catálogo del punto de venta
 (historia de la etapa de inventario). Es idempotente.
*/
SET NOCOUNT ON;
MERGE dbo.Categoria AS d
USING (VALUES ('Armazones'), ('Lentes de contacto'), ('Lentes graduados'), ('Lentes solares y accesorios')) AS o(nombre)
ON d.nombre = o.nombre
WHEN NOT MATCHED THEN INSERT (nombre) VALUES (o.nombre);

MERGE dbo.Proveedor AS d
USING (VALUES ('Distribuidora Óptica Xela'), ('Laboratorio Occidente')) AS o(nombre)
ON d.nombre = o.nombre
WHEN NOT MATCHED THEN INSERT (nombre) VALUES (o.nombre);

MERGE dbo.Producto AS d
USING (
    SELECT v.r, v.d, c.idCategoria, p.idProveedor, v.pv, v.ca, v.nm
    FROM (VALUES
        ('ARM-RB3025', 'Armazón metálico aviador',    'Armazones',          'Distribuidora Óptica Xela', 520, 240, 5),
        ('ARM-VG1180', 'Armazón acetato rectangular', 'Armazones',          'Distribuidora Óptica Xela', 420, 185, 4),
        ('ARM-CLS440', 'Armazón clásico pasta',       'Armazones',          'Distribuidora Óptica Xela', 380, 160, 3),
        ('LC-ACV-M',   'Lente de contacto mensual',   'Lentes de contacto', 'Distribuidora Óptica Xela', 180,  95, 12),
        ('LG-MONO',    'Par de lentes monofocales',   'Lentes graduados',   'Laboratorio Occidente',     650, 300, 0),
        ('LG-PROG',    'Par de lentes progresivos',   'Lentes graduados',   'Laboratorio Occidente',    1450, 780, 0)
    ) v(r, d, cat, prov, pv, ca, nm)
    JOIN dbo.Categoria c ON c.nombre = v.cat
    JOIN dbo.Proveedor p ON p.nombre = v.prov
) AS o(referencia, descripcion, idCategoria, idProveedor, precioVenta, costoAdquisicion, nivelMinimo)
ON d.referencia = o.referencia
WHEN NOT MATCHED THEN
    INSERT (referencia, descripcion, idCategoria, idProveedor, precioVenta, costoAdquisicion, nivelMinimo)
    VALUES (o.referencia, o.descripcion, o.idCategoria, o.idProveedor, o.precioVenta, o.costoAdquisicion, o.nivelMinimo);

INSERT INTO dbo.Inventario (idProducto, existenciaActual, costoPromedio, fechaUltimoMovimiento)
SELECT p.idProducto, 0, p.costoAdquisicion, NULL
FROM dbo.Producto p
WHERE NOT EXISTS (SELECT 1 FROM dbo.Inventario i WHERE i.idProducto = p.idProducto);

-- Los hash son marcadores: la autenticación real de los usuarios la hace Windows / Power BI
MERGE dbo.Usuario AS d
USING (VALUES ('Propietario', 'restrada', 'U1'), ('Administración', 'admin.optica', 'U2'),
              ('Asesor de ventas I', 'asesor1', 'U3'), ('Asesor de ventas II', 'asesor2', 'U3')) AS o(nombre, usuario, perfil)
ON d.nombreUsuario = o.usuario
WHEN NOT MATCHED THEN INSERT (nombreCompleto, nombreUsuario, hashContrasena, perfil) VALUES (o.nombre, o.usuario, 0x00, o.perfil);

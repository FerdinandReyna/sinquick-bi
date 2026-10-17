-- Permisos por rol. Las vistas de rpt pertenecen a dbo, por lo que rol_reportes
-- lee a través de ellas (encadenamiento de propiedad) sin acceso directo a las tablas.
GRANT EXECUTE ON SCHEMA::[etl] TO [rol_etl];
GO
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::[stg] TO [rol_etl];
GO
GRANT SELECT ON SCHEMA::[rpt] TO [rol_reportes];
GO
-- La graduación es dato sensible de salud: se niega de forma explícita
DENY SELECT ON [dbo].[Graduacion] TO [rol_reportes];
GO
GRANT SELECT ON SCHEMA::[rpt] TO [rol_administracion];
GO
GRANT SELECT ON [dbo].[RegistroRechazado] TO [rol_administracion];
GO
GRANT UPDATE ([corregido], [fechaCorreccion]) ON [dbo].[RegistroRechazado] TO [rol_administracion];
GO
GRANT SELECT ON [dbo].[CargaDatos] TO [rol_administracion];

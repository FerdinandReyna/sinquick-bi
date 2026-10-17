-- Roles de base de datos (principio de mínimo privilegio, RNF-05)
--   rol_etl            : cuenta de servicio del paquete SSIS
--   rol_reportes       : cuenta de la puerta de enlace de Power BI (solo lectura de rpt)
--   rol_administracion : plaza de administración (U2): reportes + revisión de rechazos
CREATE ROLE [rol_etl] AUTHORIZATION [dbo];
GO
CREATE ROLE [rol_reportes] AUTHORIZATION [dbo];
GO
CREATE ROLE [rol_administracion] AUTHORIZATION [dbo];

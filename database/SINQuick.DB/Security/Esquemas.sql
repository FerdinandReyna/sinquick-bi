-- Esquemas de SIN-Quick
--   dbo : modelo dimensional (dimensiones, hechos y soporte)
--   stg : área de aterrizaje de los archivos del punto de venta (datos crudos)
--   etl : procedimientos de validación y carga que invoca el paquete SSIS
--   rpt : vistas que consume Power BI (única puerta de lectura para reportes)
CREATE SCHEMA [stg] AUTHORIZATION [dbo];
GO
CREATE SCHEMA [etl] AUTHORIZATION [dbo];
GO
CREATE SCHEMA [rpt] AUTHORIZATION [dbo];

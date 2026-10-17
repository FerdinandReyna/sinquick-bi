-- Tabla de fechas para Power BI (comparativos contra el mes y el año anterior, RF-16).
CREATE VIEW [rpt].[vw_Calendario]
AS
SELECT [fecha], [anio], [trimestre], [mes], [nombreMes], [diaSemana], [esFinDeSemana]
FROM [dbo].[DimTiempo];

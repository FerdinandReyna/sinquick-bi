-- Llena DimTiempo entre dos fechas. Solo agrega las fechas que faltan (idempotente).
CREATE PROCEDURE [etl].[usp_PoblarDimTiempo]
    @desde DATE,
    @hasta DATE
AS
BEGIN
    SET NOCOUNT ON;
    SET LANGUAGE Spanish;
    WITH n AS (
        SELECT TOP (DATEDIFF(DAY, @desde, @hasta) + 1)
               ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS d
        FROM sys.all_objects a CROSS JOIN sys.all_objects b
    ), f AS (
        SELECT DATEADD(DAY, d, @desde) AS fecha FROM n
    )
    INSERT INTO [dbo].[DimTiempo] ([idFecha], [fecha], [anio], [trimestre], [mes], [nombreMes], [diaSemana], [esFinDeSemana])
    SELECT CONVERT(INT, CONVERT(CHAR(8), f.fecha, 112)),
           f.fecha,
           YEAR(f.fecha),
           DATEPART(QUARTER, f.fecha),
           MONTH(f.fecha),
           DATENAME(MONTH, f.fecha),
           DATENAME(WEEKDAY, f.fecha),
           CASE WHEN DATEDIFF(DAY, '19000101', f.fecha) % 7 IN (5, 6) THEN 1 ELSE 0 END
    FROM f
    WHERE NOT EXISTS (SELECT 1 FROM [dbo].[DimTiempo] t WHERE t.[fecha] = f.fecha);
END;

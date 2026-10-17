-- Una fila por ejecución de la carga nocturna, con su porcentaje de rechazo.
-- Sirve para la página de calidad de datos del tablero.
CREATE VIEW [rpt].[vw_CargasResumen]
AS
SELECT cd.[idCarga],
       cd.[fechaEjecucion],
       CONVERT(DATE, cd.[fechaEjecucion]) AS [fecha],
       cd.[tipoCarga],
       cd.[resultado],
       cd.[registrosProcesados],
       cd.[registrosIncorporados],
       cd.[registrosRechazados],
       CONVERT(DECIMAL(5,2), CASE WHEN cd.[registrosProcesados] = 0 THEN 0
            ELSE 100.0 * cd.[registrosRechazados] / cd.[registrosProcesados] END) AS [porcentajeRechazo]
FROM [dbo].[CargaDatos] cd;

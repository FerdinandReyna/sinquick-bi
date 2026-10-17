-- Rechazos de cada carga con su motivo, para la revisión de la administración.
CREATE VIEW [rpt].[vw_RechazosPorCarga]
AS
SELECT cd.[idCarga],
       cd.[fechaEjecucion],
       cd.[resultado],
       r.[idRechazo],
       r.[motivoRechazo],
       r.[contenidoOriginal],
       r.[corregido]
FROM [dbo].[CargaDatos] cd
JOIN [dbo].[RegistroRechazado] r ON r.[idCarga] = cd.[idCarga];

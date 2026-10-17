# Informe de Power BI — SIN-Quick

El archivo `SINQuick.pbix` se construye en **Power BI Desktop** y se guarda en esta carpeta.

## Conexión

- Origen: **SQL Server** · Servidor `localhost` · Base de datos `SINQuick` (o `SINQuick_Staging`).
- Modo: **Importar** (el volumen es pequeño y así el tablero abre rápido aunque la base esté ocupada).
- Tablas: solo las vistas del esquema `rpt`. La cuenta de la puerta de enlace pertenece a
  `rol_reportes`, que no tiene permiso sobre las tablas base ni sobre las graduaciones.

## Modelo

1. Importar `rpt.vw_VentasDetalle` (Ventas), `rpt.vw_Calendario` (Calendario),
   `rpt.vw_InventarioAlertas` (Inventario) y `rpt.vw_ClientesRenovacion` (Clientes).
2. Marcar **Calendario** como tabla de fechas (columna `fecha`).
3. Relación Calendario[fecha] 1 → * Ventas[fecha].
4. Crear las medidas de `medidas.dax`.

## Páginas del informe (Sprint 2)

| Página | Contenido |
|---|---|
| Resumen | Tarjetas: Ventas, Margen %, Ticket promedio, Variación vs mes anterior |
| Ventas y rentabilidad | Ventas y margen por categoría, proveedor y asesor; tendencia mensual |

Las páginas de inventario y clientes se incorporan en los sprints 3 y 4.

## Actualización

Refresco programado a las 06:00 en Power BI Service mediante la puerta de enlace instalada
en el equipo del local (después de la carga nocturna de las 23:00).

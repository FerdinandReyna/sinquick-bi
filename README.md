# SIN-Quick

**Sistema de Inteligencia de Negocios para Óptica Quick** — San Marcos, Guatemala.

Solución de inteligencia de negocios construida con **SQL Server**, **SSIS** (ETL de
Visual Studio) y **Power BI**, con integración y entrega continua en **Jenkins**.

## Arquitectura

```
Punto de venta ──CSV──▶ SSIS: CargaVentas.dtsx ──▶ SQL Server
                          (orquesta)               stg  → aterrizaje del archivo
                                                   etl  → validación y carga (T-SQL)
                                                   dbo  → modelo dimensional (17 tablas)
                                                   rpt  → vistas para Power BI
                                                              │
                                                              ▼
                                                   Power BI (tableros)
```

La lógica de validación y carga vive en procedimientos almacenados; el paquete SSIS
recorre los archivos, llama a la carga y los mueve según el resultado. Así toda la lógica
se prueba con tSQLt y pytest.

## Estructura

| Carpeta | Contenido |
|---|---|
| `database/SINQuick.DB` | Proyecto de base de datos (compila a DACPAC) |
| `database/datos-referencia` | Catálogo inicial de productos y asesores |
| `database/demo` | `SINQuick_Demo.sql`: base completa con datos simulados (2023–2026) para Power BI, y su generador |
| `etl` | Guía del paquete SSIS y alternativa para SQL Server Express |
| `powerbi` | Medidas DAX y guía del informe |
| `tests/tsqlt` | Pruebas unitarias de las reglas de negocio |
| `tests/pytest` | Pruebas de integración, sistema, aceptación, seguridad, rendimiento y humo |
| `ci` | Scripts de PowerShell que ejecuta el pipeline |
| `Jenkinsfile` | Pipeline: Checkout → Build → Test → Deploy Staging |
| `docs/ci` | Instalación del agente de Jenkins y guía de capturas |
| `docs/plan-pruebas` | Plan de pruebas y script que llena los resultados obtenidos |
| `docs/scrum` | Sprint Planning y evidencia Scrum del Sprint 2 |
| `docs/video` | Guion del video DEVOPS 2 |
| `docs/DEVOPS2_SIN_Quick.pdf` | Documento DEVOPS 2 |

## Pipeline

| Etapa | Qué hace | Si falla |
|---|---|---|
| Checkout | Obtiene el commit | — |
| Build | Compila el DACPAC y el `.ispac` de SSIS en paralelo | No se toca ninguna base |
| Test | Recrea `SINQuick_CI`, corre tSQLt (9 pruebas) y pytest (13 pruebas); publica JUnit y reporte HTML | No se despliega a staging |
| Deploy Staging | Solo `main` y `develop`: publica en `SINQuick_Staging`, despliega el paquete en SSISDB, lo ejecuta con un archivo de muestra y corre las pruebas de humo | La rama queda marcada en rojo |

## Ejecutar las pruebas en tu equipo

```powershell
.\ci\build-db.ps1
.\ci\publicar-db.ps1 -Base SINQuick_CI -Recrear
.\ci\pruebas-tsqlt.ps1 -Base SINQuick_CI
$env:ETL_CARPETA = 'C:\SINQuick\CI\entrada'
.\ci\pruebas-pytest.ps1 -Base SINQuick_CI
# Reporte: reportes\pytest.html
```

## Reglas de negocio configurables

Los valores viven en `dbo.ParametroRegla`; cambiarlos no requiere modificar código.

| Código | Regla | Valor inicial |
|---|---|---|
| RN-01 | Ciclo de renovación de lentes | 18 meses |
| RN-04 | Inventario sin movimiento | 180 días |
| UMB-RECH | Rechazo máximo antes de detener una carga | 5 % |

## Edición de SQL Server

SSIS y SQL Server Agent **no vienen en Express**. CI y staging usan SQL Server 2022
**Developer** (gratuito para desarrollo y pruebas). Para producción ver `etl/README.md`.

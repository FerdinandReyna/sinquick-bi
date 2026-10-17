# ETL de SIN-Quick — proyecto SSIS

El paquete se crea en **Visual Studio 2022** con la extensión
*SQL Server Integration Services Projects*. Toda la lógica de validación y carga vive en
los procedimientos del esquema `etl` de la base de datos; el paquete **orquesta**: recorre
los archivos que exporta el punto de venta, llama a la carga y mueve cada archivo según
el resultado. Así la lógica se prueba con tSQLt y pytest sin depender de SSIS.

## 1. Crear el proyecto

1. Visual Studio → *Nuevo proyecto* → **Integration Services Project**.
2. Nombre: `SINQuick.ETL` · Ubicación: la carpeta `etl\` de este repositorio.
3. El proyecto debe quedar en `etl\SINQuick.ETL\SINQuick.ETL.dtproj` (ruta que usa el pipeline).
4. Renombrar `Package.dtsx` a **`CargaVentas.dtsx`**.

## 2. Administrador de conexión del proyecto

*Connection Managers* (a nivel de proyecto) → nueva conexión **OLE DB**:

| Propiedad | Valor |
|---|---|
| Nombre | `SINQuick` |
| Proveedor | Microsoft OLE DB Driver for SQL Server |
| Servidor | `localhost` |
| Autenticación | Windows |
| Base de datos | `SINQuick_CI` (en cada entorno se reemplaza desde el catálogo SSISDB) |

## 3. Parámetro del paquete

| Nombre | Tipo | Valor por defecto | Requerido |
|---|---|---|---|
| `CarpetaBase` | String | `C:\SINQuick\Produccion` | Sí |

Dentro de `CarpetaBase` el paquete usa tres subcarpetas: `entrada`, `procesados` y `errores`.

## 4. Variables del paquete

| Nombre | Tipo | Valor |
|---|---|---|
| `RutaArchivo` | String | (vacío) |
| `Resultado` | String | (vacío) |

## 5. Flujo de control

```
[Contenedor de bucle Foreach]  ← recorre CarpetaBase\entrada\*.csv
   │
   ├─ [Ejecutar SQL] Cargar archivo
   │      EXEC etl.usp_EjecutarCargaVentas @ruta = ?, @tipoCarga = 'INCREMENTAL'
   │      Parámetro 0 → User::RutaArchivo   ·   ResultSet: fila única → User::Resultado (columna resultado)
   │
   ├─ (éxito) → [Tarea Sistema de archivos] Mover a CarpetaBase\procesados
   └─ (error) → [Tarea Sistema de archivos] Mover a CarpetaBase\errores
```

Configuración del **Foreach Loop**:

- Enumerador: *Foreach File Enumerator*.
- Carpeta: expresión `@[$Package::CarpetaBase] + "\\entrada"`.
- Archivos: `*.csv` · Recuperar nombre de archivo: *Completo*.
- Asignación de variables: índice 0 → `User::RutaArchivo`.
- Propiedad **MaximumErrorCount = 0** en el contenedor, para que un archivo con error
  no detenga el procesamiento de los demás.

Configuración de **Ejecutar SQL**:

- Conexión: `SINQuick` · Tipo: OLE DB · ResultSet: *Single row*.
- Instrucción: `EXEC etl.usp_EjecutarCargaVentas @ruta = ?, @tipoCarga = 'INCREMENTAL'`
- Asignación de parámetros: `User::RutaArchivo`, Input, NVARCHAR, nombre `0`, tamaño 260.
- Conjunto de resultados: nombre `resultado` → `User::Resultado`.

Las dos **tareas de sistema de archivos** usan *Move file*, con origen `User::RutaArchivo`
y destino dado por una expresión sobre `CarpetaBase` (`\procesados` o `\errores`).
Una precedencia es de **éxito** y la otra de **error**.

## 6. Compilar y desplegar

- En Visual Studio: *Build* genera `bin\Development\SINQuick.ETL.ispac`.
- En el pipeline: `ci\build-etl.ps1` (SSISBuild.exe) y `ci\desplegar-etl.ps1` (SSISDeploy.exe).
- Cada entorno tiene su carpeta en el catálogo: `SINQuick_Staging`, `SINQuick_Produccion`.

## 7. Nota sobre la edición de SQL Server

SSIS y SQL Server Agent **no están incluidos en SQL Server Express**. Los entornos de CI y
staging usan **SQL Server 2022 Developer** (gratuito para desarrollo y pruebas). Para
producción hay dos caminos, que el propietario debe decidir:

| Opción | Costo | Cómo se ejecuta la carga nocturna |
|---|---|---|
| SQL Server Standard | Licencia de pago | Paquete SSIS + trabajo de SQL Server Agent |
| SQL Server Express | Gratuito | `Ejecutar-CargaVentas.ps1` programado en el Programador de tareas de Windows (hace lo mismo que el paquete, llamando a los mismos procedimientos) |

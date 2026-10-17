# -*- coding: utf-8 -*-
"""Configuración de la suite pytest de SIN-Quick.

Variables de entorno:
  SQLSERVER_CONN  Cadena ODBC hacia la base de pruebas. Ejemplo:
                  DRIVER={ODBC Driver 18 for SQL Server};SERVER=localhost;
                  DATABASE=SINQuick_CI;Trusted_Connection=yes;TrustServerCertificate=yes
  ETL_CARPETA     Carpeta de entrada que el servicio de SQL Server puede leer
                  (por defecto C:\\SINQuick\\entrada)
"""
import csv
import json
import os
import platform
import sys
from datetime import datetime, timedelta
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).parent))
from catalogo_casos import CASOS  # noqa: E402

RAIZ = Path(__file__).resolve().parents[2]
REPORTES = RAIZ / "reportes"
CARPETA = Path(os.environ.get("ETL_CARPETA", r"C:\SINQuick\entrada"))
COLUMNAS = ["numeroFactura", "fechaHora", "telefonoCliente", "nombreCliente", "usuarioAsesor",
            "referencia", "cantidad", "precioUnitario", "descuento", "anulada", "esGarantia"]


# --------------------------------------------------------------------------
# Conexión
# --------------------------------------------------------------------------
@pytest.fixture(scope="session")
def conn():
    pyodbc = pytest.importorskip("pyodbc")
    cadena = os.environ.get("SQLSERVER_CONN")
    if not cadena:
        pytest.skip("Defina SQLSERVER_CONN con la cadena de conexión a la base de pruebas")
    c = pyodbc.connect(cadena, autocommit=True)
    yield c
    c.close()


def uno(conn, sql, *params):
    fila = conn.cursor().execute(sql, *params).fetchone()
    return fila[0] if fila else None


# --------------------------------------------------------------------------
# Datos de prueba
# --------------------------------------------------------------------------
LIMPIEZA = """
DELETE FROM dbo.DetalleCampania; DELETE FROM dbo.Campania;
DELETE FROM dbo.DetalleVenta; DELETE FROM dbo.MovimientoInventario; DELETE FROM dbo.Venta;
DELETE FROM dbo.Graduacion; DELETE FROM dbo.Cliente;
DELETE FROM dbo.RegistroRechazado; DELETE FROM dbo.CargaDatos;
DELETE FROM dbo.Inventario; DELETE FROM dbo.Producto; DELETE FROM dbo.Categoria; DELETE FROM dbo.Proveedor;
DELETE FROM dbo.BitacoraAcceso; UPDATE dbo.ParametroRegla SET idUsuarioModifica = NULL; DELETE FROM dbo.Usuario;
DELETE FROM stg.VentaLinea;
UPDATE dbo.ParametroRegla SET valor = '5' WHERE codigoRegla = 'UMB-RECH';
UPDATE dbo.ParametroRegla SET valor = '18' WHERE codigoRegla = 'RN-01';
"""

CATALOGO = """
INSERT INTO dbo.Categoria (nombre) VALUES ('Armazones'), ('Lentes de contacto'), ('Lentes graduados');
INSERT INTO dbo.Proveedor (nombre) VALUES ('Distribuidora Óptica Xela'), ('Laboratorio Occidente');
INSERT INTO dbo.Producto (referencia, descripcion, idCategoria, idProveedor, precioVenta, costoAdquisicion, nivelMinimo)
SELECT r, d, (SELECT idCategoria FROM dbo.Categoria WHERE nombre = c), (SELECT idProveedor FROM dbo.Proveedor WHERE nombre = p), pv, ca, nm
FROM (VALUES
  ('ARM-RB3025', 'Armazón metálico aviador',    'Armazones',          'Distribuidora Óptica Xela', 520, 240, 5),
  ('ARM-VG1180', 'Armazón acetato rectangular', 'Armazones',          'Distribuidora Óptica Xela', 420, 185, 4),
  ('LC-ACV-M',   'Lente de contacto mensual',   'Lentes de contacto', 'Distribuidora Óptica Xela', 180,  95, 12),
  ('LG-MONO',    'Par de lentes monofocales',   'Lentes graduados',   'Laboratorio Occidente',     650, 300, 0)
) v(r, d, c, p, pv, ca, nm);
INSERT INTO dbo.Usuario (nombreCompleto, nombreUsuario, hashContrasena, perfil) VALUES
  ('Propietario', 'restrada', 0x00, 'U1'),
  ('Administración', 'admin.optica', 0x00, 'U2'),
  ('Asesor de ventas I', 'asesor1', 0x00, 'U3'),
  ('Asesor de ventas II', 'asesor2', 0x00, 'U3');
"""


def preparar_base(conn):
    """Deja la base de pruebas con el catálogo mínimo y sin ventas.
    Por seguridad se niega a ejecutarse fuera de una base terminada en _CI."""
    nombre = uno(conn, "SELECT DB_NAME()")
    if not nombre.upper().endswith("_CI"):
        pytest.fail(f"Se intentó limpiar '{nombre}'. Las pruebas destructivas solo corren en bases *_CI.")
    conn.cursor().execute(LIMPIEZA)
    conn.cursor().execute(CATALOGO)
    return conn


@pytest.fixture
def base_limpia(conn):
    return preparar_base(conn)


def fecha(dias_atras=0, hora="10:30:00"):
    return (datetime.now() - timedelta(days=dias_atras)).strftime("%Y-%m-%d ") + hora


def linea(factura, cuando, referencia, cantidad=1, precio=520, telefono="50255512001", nombre="Ana Lucía Barrios",
          asesor="asesor1", descuento=0, anulada=0, garantia=0):
    return [factura, cuando, telefono, nombre, asesor, referencia, cantidad, precio, descuento, anulada, garantia]


@pytest.fixture
def archivo():
    """Escribe un CSV con el formato de exportación del punto de venta y devuelve su ruta."""
    creados = []

    def escribir(nombre, filas):
        CARPETA.mkdir(parents=True, exist_ok=True)
        ruta = CARPETA / nombre
        with open(ruta, "w", newline="", encoding="utf-8") as f:
            w = csv.writer(f, lineterminator="\r\n")   # como lo genera Windows
            w.writerow(COLUMNAS)
            w.writerows(filas)
        creados.append(ruta)
        return str(ruta)

    yield escribir
    for r in creados:
        r.unlink(missing_ok=True)


def cargar(conn, ruta, tipo="INCREMENTAL"):
    """Ejecuta la carga completa y devuelve el registro de CargaDatos como diccionario."""
    cur = conn.cursor()
    cur.execute("EXEC etl.usp_EjecutarCargaVentas @ruta = ?, @tipoCarga = ?", ruta, tipo)
    fila = cur.fetchone()
    return dict(zip([c[0] for c in cur.description], fila))


@pytest.fixture
def usuario_reportes(conn):
    """Usuario sin inicio de sesión, miembro de rol_reportes, para probar permisos."""
    cur = conn.cursor()
    cur.execute("IF USER_ID('prueba_reportes') IS NULL CREATE USER prueba_reportes WITHOUT LOGIN;"
                "ALTER ROLE rol_reportes ADD MEMBER prueba_reportes;")
    return "prueba_reportes"


# --------------------------------------------------------------------------
# Trazabilidad: ID de caso en el reporte HTML, en JUnit y en un JSON propio
# --------------------------------------------------------------------------
def pytest_configure(config):
    config.addinivalue_line("markers", "caso(id): ID del caso en el catálogo")
    config.addinivalue_line("markers", "humo: verificación mínima de un despliegue")
    try:
        from pytest_metadata.plugin import metadata_key
        md = config.stash[metadata_key]
        md.clear()
        md["Proyecto"] = "SIN-Quick — Óptica Quick"
        md["Sistema operativo"] = f"{platform.system()} {platform.release()} ({platform.machine()})"
        md["Python"] = platform.python_version()
        md["Procesador"] = platform.processor() or "no disponible"
        md["Build de Jenkins"] = os.environ.get("BUILD_NUMBER", "ejecución local")
        md["Commit"] = os.environ.get("GIT_COMMIT", "local")[:10]
        md["Base de datos"] = (os.environ.get("SQLSERVER_CONN", "").split("DATABASE=")[-1].split(";")[0]) or "no definida"
    except Exception:
        pass


def _caso(item):
    m = item.get_closest_marker("caso")
    return m.args[0] if m else ""


@pytest.fixture(autouse=True)
def _registrar_caso(request, record_property):
    if _caso(request.node):
        record_property("caso", _caso(request.node))


@pytest.fixture
def obtenido(request):
    def anotar(texto):
        request.node.obtenido = texto
    return anotar


def pytest_html_report_title(report):
    report.title = "SIN-Quick — Reporte de ejecución del plan de pruebas"


def pytest_html_results_table_header(cells):
    cells.insert(1, "<th>Caso</th>")
    cells.insert(2, "<th>Tipo</th>")


def pytest_html_results_table_row(report, cells):
    caso = getattr(report, "caso", "")
    cells.insert(1, f"<td>{caso}</td>")
    cells.insert(2, f"<td>{CASOS.get(caso, {}).get('tipo', '')}</td>")


_resultados = {}


@pytest.hookimpl(hookwrapper=True)
def pytest_runtest_makereport(item, call):
    salida = yield
    rep = salida.get_result()
    rep.caso = _caso(item)
    if not rep.caso or not (rep.when == "call" or (rep.when == "setup" and not rep.passed)):
        return
    estado = "APROBADO" if rep.passed else ("OMITIDO" if rep.skipped else "FALLIDO")
    mensaje = ""
    if rep.failed and hasattr(rep.longrepr, "reprcrash"):
        mensaje = rep.longrepr.reprcrash.message
    elif rep.skipped and isinstance(rep.longrepr, tuple):
        mensaje = rep.longrepr[2]
    _resultados[rep.caso] = {"caso": rep.caso, "estado": estado, "duracion_s": round(rep.duration, 3),
                             "obtenido": getattr(item, "obtenido", ""), "mensaje": str(mensaje)[:300]}


def pytest_sessionfinish(session, exitstatus):
    REPORTES.mkdir(exist_ok=True)
    (REPORTES / "resultados-pytest.json").write_text(
        json.dumps(sorted(_resultados.values(), key=lambda r: r["caso"]), ensure_ascii=False, indent=2), encoding="utf-8")

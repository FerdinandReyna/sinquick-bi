# -*- coding: utf-8 -*-
import pytest

from conftest import uno

pytestmark = pytest.mark.seguridad


def como_usuario(conn, usuario, sql):
    """Ejecuta una sentencia suplantando al usuario y devuelve el error, o None si no hubo."""
    import pyodbc
    cur = conn.cursor()
    cur.execute(f"EXECUTE AS USER = '{usuario}';")
    try:
        cur.execute(sql)
        try:
            cur.fetchall()
        except pyodbc.ProgrammingError:
            pass
        return None
    except pyodbc.Error as e:
        return str(e)
    finally:
        cur.execute("REVERT;")


@pytest.mark.caso("CP-18")
def test_cuenta_de_power_bi_no_lee_datos_sensibles(conn, usuario_reportes, obtenido):
    graduacion = como_usuario(conn, usuario_reportes, "SELECT TOP 1 * FROM dbo.Graduacion")
    venta = como_usuario(conn, usuario_reportes, "SELECT TOP 1 * FROM dbo.Venta")
    vista = como_usuario(conn, usuario_reportes, "SELECT TOP 1 * FROM rpt.vw_VentasDetalle")
    assert graduacion and "229" in graduacion
    assert venta and "229" in venta
    assert vista is None
    obtenido("dbo.Graduacion y dbo.Venta: permiso denegado (229). rpt.vw_VentasDetalle: consulta permitida.")


@pytest.mark.caso("CP-19")
def test_ruta_con_inyeccion_es_rechazada(base_limpia, obtenido):
    import pyodbc
    conn = base_limpia
    with pytest.raises(pyodbc.Error) as e:
        conn.cursor().execute("EXEC etl.usp_EjecutarCargaVentas @ruta = ?", "x'; DROP TABLE dbo.Venta; --")
    existe = uno(conn, "SELECT CASE WHEN OBJECT_ID('dbo.Venta') IS NULL THEN 0 ELSE 1 END")
    assert "50010" in str(e.value) or "no válida" in str(e.value)
    assert existe == 1
    obtenido("Error 50010 'Ruta de archivo no válida'; la tabla dbo.Venta sigue existiendo.")


@pytest.mark.caso("CP-20")
def test_cuenta_de_power_bi_no_ejecuta_la_carga(conn, usuario_reportes, obtenido):
    error = como_usuario(conn, usuario_reportes, r"EXEC etl.usp_EjecutarCargaVentas @ruta = N'C:\no-importa.csv'")
    assert error and "229" in error
    obtenido("EXECUTE denegado (229) para la cuenta de reportes.")

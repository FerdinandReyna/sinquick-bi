# -*- coding: utf-8 -*-
import pytest

from conftest import cargar, fecha, linea, uno

pytestmark = pytest.mark.sistema


@pytest.mark.caso("CP-13")
def test_carga_repetida_no_duplica(base_limpia, archivo, obtenido):
    conn = base_limpia
    ruta = archivo("ventas_repetidas.csv", [
        linea("F-4001", fecha(1), "ARM-RB3025"),
        linea("F-4002", fecha(1), "LC-ACV-M", precio=180),
    ])
    cargar(conn, ruta)
    antes = uno(conn, "SELECT COUNT(*) FROM dbo.Venta")
    segunda = cargar(conn, ruta)
    despues = uno(conn, "SELECT COUNT(*) FROM dbo.Venta")
    assert segunda["resultado"] == "EXITOSA"
    assert segunda["registrosIncorporados"] == 0
    assert antes == despues == 2
    obtenido(f"Segunda carga {segunda['resultado']} con 0 incorporadas; ventas antes {antes}, después {despues}.")


@pytest.mark.caso("CP-14")
def test_carga_fallida_no_deja_datos_a_medias(base_limpia, archivo, obtenido):
    import pyodbc
    conn = base_limpia
    ruta = archivo("ventas_mayoria_errores.csv", [
        linea("F-5001", fecha(1), "ARM-RB3025"),
        linea("F-5002", fecha(1), "ARM-RB3025", cantidad="dos"),
    ])
    with pytest.raises(pyodbc.Error) as e:
        cargar(conn, ruta)
    assert "50020" in str(e.value) or "umbral" in str(e.value)
    resultado = uno(conn, "SELECT TOP 1 resultado FROM dbo.CargaDatos ORDER BY idCarga DESC")
    ventas = uno(conn, "SELECT COUNT(*) FROM dbo.Venta")
    rechazos = uno(conn, "SELECT COUNT(*) FROM dbo.RegistroRechazado")
    assert resultado == "FALLIDA" and ventas == 0 and rechazos == 1
    obtenido(f"Error 50020; bitácora {resultado}; {ventas} ventas en el data warehouse; {rechazos} rechazo registrado.")

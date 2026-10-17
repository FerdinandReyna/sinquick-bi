# -*- coding: utf-8 -*-
import pytest

from conftest import cargar, fecha, linea, uno

pytestmark = pytest.mark.integracion


@pytest.mark.caso("CP-10")
def test_carga_completa_de_un_archivo_valido(base_limpia, archivo, obtenido):
    conn = base_limpia
    ruta = archivo("ventas_validas.csv", [
        linea("F-1001", fecha(1), "ARM-RB3025"),
        linea("F-1001", fecha(1), "LG-MONO", precio=650),
        linea("F-1002", fecha(1, "15:00:00"), "LC-ACV-M", cantidad=2, precio=180, telefono="50255512002", nombre="Mario Pérez López"),
        linea("F-1003", fecha(0), "ARM-VG1180", precio=420, telefono="", nombre=""),
    ])
    r = cargar(conn, ruta)
    ventas = uno(conn, "SELECT COUNT(*) FROM dbo.Venta")
    assert r["resultado"] == "EXITOSA"
    assert r["registrosProcesados"] == 4 and r["registrosIncorporados"] == 4
    assert ventas == 3
    obtenido(f"Resultado {r['resultado']}; {r['registrosProcesados']} procesadas, "
             f"{r['registrosIncorporados']} incorporadas; {ventas} ventas en dbo.Venta.")


@pytest.mark.caso("CP-11")
def test_carga_con_errores_aparta_los_rechazados(base_limpia, archivo, obtenido):
    conn = base_limpia
    conn.cursor().execute("UPDATE dbo.ParametroRegla SET valor = '50' WHERE codigoRegla = 'UMB-RECH'")
    ruta = archivo("ventas_con_un_error.csv", [
        linea("F-2001", fecha(1), "ARM-RB3025"),
        linea("F-2002", fecha(1), "LC-ACV-M", precio=180),
        linea("F-2003", fecha(1), "ARM-VG1180", precio=420),
        linea("F-2004", fecha(1), "NO-EXISTE"),
    ])
    r = cargar(conn, ruta)
    motivo = uno(conn, "SELECT motivoRechazo FROM rpt.vw_RechazosPorCarga WHERE idCarga = ?", r["idCarga"])
    assert r["resultado"] == "PARCIAL"
    assert r["registrosIncorporados"] == 3 and r["registrosRechazados"] == 1
    assert motivo == "Producto inexistente: NO-EXISTE"
    obtenido(f"Resultado {r['resultado']}; 3 incorporadas; 1 rechazada con motivo '{motivo}'.")


@pytest.mark.caso("CP-12")
def test_vistas_de_power_bi_exponen_lo_cargado(base_limpia, archivo, obtenido):
    conn = base_limpia
    filas = [
        linea("F-3001", fecha(2), "ARM-RB3025", descuento=20),
        linea("F-3001", fecha(2), "LG-MONO", precio=650),
        linea("F-3002", fecha(2), "LC-ACV-M", cantidad=3, precio=180),
        linea("F-3003", fecha(2), "ARM-VG1180", precio=420, anulada=1),          # anulada: no cuenta
        linea("F-3004", fecha(2), "ARM-RB3025", precio=0, garantia=1),           # garantía: no es ingreso
    ]
    cargar(conn, archivo("ventas_vistas.csv", filas))
    esperado = sum(f[6] * f[7] - f[8] for f in filas if f[9] == 0 and f[10] == 0)
    lineas = uno(conn, "SELECT COUNT(*) FROM rpt.vw_VentasDetalle")
    ingreso = float(uno(conn, "SELECT SUM(ingreso) FROM rpt.vw_VentasDetalle"))
    assert lineas == 3
    assert ingreso == pytest.approx(esperado)
    obtenido(f"{lineas} líneas en rpt.vw_VentasDetalle (sin anulada ni garantía); ingreso Q {ingreso:,.2f} = esperado Q {esperado:,.2f}.")

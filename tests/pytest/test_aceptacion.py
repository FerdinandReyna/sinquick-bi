# -*- coding: utf-8 -*-
import time
from datetime import datetime

import pytest

from conftest import cargar, fecha, linea, uno

pytestmark = pytest.mark.aceptacion


@pytest.mark.caso("CP-15")
def test_total_del_mes_coincide_con_el_punto_de_venta(base_limpia, archivo, obtenido):
    conn = base_limpia
    filas = [
        linea("F-6001", fecha(0, "09:00:00"), "ARM-RB3025", descuento=20),
        linea("F-6001", fecha(0, "09:00:00"), "LG-MONO", precio=650),
        linea("F-6002", fecha(0, "11:00:00"), "LC-ACV-M", cantidad=4, precio=180, telefono="50255512002", nombre="Mario Pérez López"),
        linea("F-6003", fecha(0, "12:00:00"), "ARM-VG1180", precio=420, anulada=1),
    ]
    cargar(conn, archivo("ventas_mes.csv", filas))
    total_pos = sum(f[6] * f[7] - f[8] for f in filas if f[9] == 0)
    hoy = datetime.now()
    total_dw = float(uno(conn, "SELECT totalFacturado FROM rpt.vw_ConciliacionMensual WHERE anio = ? AND mes = ?",
                         hoy.year, hoy.month))
    assert total_dw == pytest.approx(total_pos)
    obtenido(f"Total del punto de venta Q {total_pos:,.2f}; total del data warehouse Q {total_dw:,.2f}; diferencia Q {total_dw - total_pos:,.2f}.")


@pytest.mark.caso("CP-16")
def test_cliente_nuevo_por_renovar_sin_consentimiento(base_limpia, archivo, obtenido):
    conn = base_limpia
    cargar(conn, archivo("venta_antigua.csv", [
        linea("F-7001", fecha(610), "LG-MONO", precio=650, telefono="50255519999", nombre="Rosa Elena Yoc"),
    ]))
    fila = conn.cursor().execute(
        "SELECT cicloVencido, contactable, motivoExclusion FROM rpt.vw_ClientesRenovacion WHERE telefono = '50255519999'").fetchone()
    assert fila is not None
    assert (fila.cicloVencido, fila.contactable, fila.motivoExclusion) == (True, False, "SIN CONSENTIMIENTO")
    obtenido(f"cicloVencido = {int(fila.cicloVencido)}, contactable = {int(fila.contactable)}, motivo {fila.motivoExclusion}.")


@pytest.mark.caso("CP-17")
def test_carga_de_un_dia_en_el_tiempo_exigido(base_limpia, archivo, obtenido):
    conn = base_limpia
    filas = [linea(f"F-8{i:04d}", fecha(1, f"{9 + i % 9:02d}:{i % 60:02d}:00"), ["ARM-RB3025", "LC-ACV-M", "ARM-VG1180"][i % 3],
                   precio=[520, 180, 420][i % 3], telefono=f"5025551{i % 120:04d}", nombre=f"Cliente {i % 120}")
             for i in range(300)]
    ruta = archivo("ventas_dia_alto.csv", filas)
    inicio = time.perf_counter()
    r = cargar(conn, ruta)
    segundos = time.perf_counter() - inicio
    assert r["resultado"] == "EXITOSA" and r["registrosIncorporados"] == 300
    assert segundos < 600
    obtenido(f"300 líneas cargadas en {segundos:.2f} s (límite 600 s).")

# -*- coding: utf-8 -*-
import random
import time
from datetime import datetime, timedelta

import pytest

from conftest import cargar, linea, preparar_base

pytestmark = pytest.mark.rendimiento

PRODUCTOS = [("ARM-RB3025", 520), ("ARM-VG1180", 420), ("LC-ACV-M", 180), ("LG-MONO", 650)]


@pytest.fixture(scope="module")
def historico(conn, tmp_path_factory):
    """Carga una sola vez un histórico de 25,000 líneas (≈ 3 años de la óptica)."""
    import csv
    from conftest import CARPETA, COLUMNAS
    preparar_base(conn)
    rnd = random.Random(2026)
    inicio = datetime.now() - timedelta(days=3 * 365)
    filas, factura = [], 0
    while len(filas) < 25_000:
        factura += 1
        cuando = (inicio + timedelta(minutes=rnd.randint(0, 3 * 365 * 24 * 60))).strftime("%Y-%m-%d %H:%M:00")
        tel = f"5025{rnd.randint(1000000, 1000950)}"
        asesor = rnd.choice(["asesor1", "asesor2"])   # el encabezado debe ser igual en todas las líneas
        for _ in range(rnd.choice([1, 1, 2, 3])):
            ref, precio = rnd.choice(PRODUCTOS)
            filas.append(linea(f"H-{factura:06d}", cuando, ref, precio=precio, telefono=tel, nombre=f"Cliente {tel[-3:]}",
                               asesor=asesor))
    filas = filas[:25_000]
    CARPETA.mkdir(parents=True, exist_ok=True)
    ruta = CARPETA / "historico_25000.csv"
    with open(ruta, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f, lineterminator="\r\n")
        w.writerow(COLUMNAS)
        w.writerows(filas)
    t = time.perf_counter()
    r = cargar(conn, str(ruta), tipo="INICIAL")
    segundos = time.perf_counter() - t
    yield r, segundos
    ruta.unlink(missing_ok=True)


@pytest.mark.caso("CP-21")
def test_carga_inicial_del_historico(historico, obtenido):
    r, segundos = historico
    assert r["resultado"] in ("EXITOSA", "PARCIAL")
    assert r["registrosProcesados"] == 25_000
    assert segundos < 4 * 3600
    obtenido(f"25,000 líneas procesadas; {r['registrosIncorporados']} incorporadas; resultado {r['resultado']}; "
             f"duración {segundos:.1f} s (límite 14,400 s).")


@pytest.mark.caso("CP-22")
def test_consulta_del_mes_para_el_tablero(conn, historico, obtenido):
    hoy = datetime.now()
    tiempos = []
    cur = conn.cursor()
    for _ in range(10):
        t = time.perf_counter()
        cur.execute("SELECT categoria, asesor, SUM(ingreso), SUM(margen) FROM rpt.vw_VentasDetalle "
                    "WHERE anio = ? AND mes = ? GROUP BY categoria, asesor", hoy.year, hoy.month)
        cur.fetchall()
        tiempos.append(time.perf_counter() - t)
    peor = max(tiempos)
    assert peor < 2
    obtenido(f"10 consultas; peor tiempo {peor * 1000:.0f} ms; promedio {sum(tiempos) / len(tiempos) * 1000:.0f} ms (límite 2,000 ms).")

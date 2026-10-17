# -*- coding: utf-8 -*-
"""Pruebas de humo: verifican que un despliegue quedó completo.
Son de solo lectura, por lo que se pueden ejecutar contra staging."""
import pytest

from conftest import uno

pytestmark = pytest.mark.humo

OBJETOS = {
    "SCHEMA": ["stg", "etl", "rpt"],
    "V": ["rpt.vw_VentasDetalle", "rpt.vw_InventarioAlertas", "rpt.vw_ClientesRenovacion",
          "rpt.vw_ConciliacionMensual", "rpt.vw_RechazosPorCarga", "rpt.vw_Calendario"],
    "P": ["etl.usp_EjecutarCargaVentas", "etl.usp_IniciarCarga", "etl.usp_CargarArchivoStaging",
          "etl.usp_ValidarVentas", "etl.usp_CargarVentasDW", "etl.usp_PoblarDimTiempo"],
    "ROLE": ["rol_etl", "rol_reportes", "rol_administracion"],
}


@pytest.mark.caso("CP-23")
def test_despliegue_completo(conn, obtenido):
    faltan = []
    for tipo, nombres in OBJETOS.items():
        for n in nombres:
            if tipo == "SCHEMA":
                ok = uno(conn, "SELECT SCHEMA_ID(?)", n)
            elif tipo == "ROLE":
                ok = uno(conn, "SELECT DATABASE_PRINCIPAL_ID(?)", n)
            else:
                ok = uno(conn, "SELECT OBJECT_ID(?, ?)", n, tipo)
            if not ok:
                faltan.append(n)
    rn01 = uno(conn, "SELECT valor FROM dbo.ParametroRegla WHERE codigoRegla = 'RN-01'")
    desde, hasta = conn.cursor().execute("SELECT MIN(fecha), MAX(fecha) FROM dbo.DimTiempo").fetchone()
    assert not faltan, f"Objetos faltantes: {faltan}"
    assert rn01 is not None and rn01.isdigit()
    assert str(desde) == "2019-01-01" and str(hasta) == "2030-12-31"
    total = sum(len(v) for v in OBJETOS.values())
    obtenido(f"{total} objetos verificados; RN-01 = {rn01} meses; calendario {desde} a {hasta}.")

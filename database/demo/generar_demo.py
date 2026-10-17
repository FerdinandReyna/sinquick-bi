# -*- coding: utf-8 -*-
"""Genera SINQuick_Demo.sql: crea la base SINQuick completa (tablas, vistas, procedimientos)
y la llena con datos SIMULADOS de Óptica Quick para construir el tablero de Power BI.

Uso:  python generar_demo.py [salida.sql]
Los datos son ficticios. La semilla fija hace que el script salga igual cada vez.
"""
import random
import sys
from datetime import date, datetime, timedelta
from pathlib import Path

random.seed(2026)
AQUI = Path(__file__).resolve().parent
BD = AQUI.parent / "SINQuick.DB"
SALIDA = Path(sys.argv[1]) if len(sys.argv) > 1 else AQUI / "SINQuick_Demo.sql"

INICIO = date(2023, 1, 2)
FIN = date(2026, 10, 14)
ARRANQUE_SISTEMA = date(2026, 1, 5)      # día de la carga inicial del histórico

# ------------------------------------------------------------------ catálogos
CATEGORIAS = ["Armazones", "Lentes de contacto", "Lentes graduados", "Lentes solares y accesorios"]
PROVEEDORES = [  # nombre, contacto, teléfono, días de entrega
    ("Distribuidora Óptica Xela", "Marta Gómez", "77612233", 5),
    ("Laboratorio Occidente", "Luis Barrios", "77634510", 3),
    ("Importadora Visión Central", "Carlos Ajú", "22417788", 8),
    ("Contactología del Sur", "Ana Cifuentes", "24318890", 6),
    ("Accesorios Ópticos Mazate", "Pedro López", "78721144", 4),
]
# referencia, descripción, categoría, proveedor, precio 2023, costo 2023, mínimo, peso de venta, fin de ventas
PRODUCTOS = [
    ("ARM-MT1001", "Armazón metálico aviador", 0, 0, 495, 225, 5, 9, None),
    ("ARM-MT1002", "Armazón metálico redondo", 0, 0, 455, 205, 4, 6, None),
    ("ARM-MT1003", "Armazón metálico al aire", 0, 2, 610, 290, 3, 5, None),
    ("ARM-AC2001", "Armazón acetato rectangular", 0, 0, 400, 175, 5, 10, None),
    ("ARM-AC2002", "Armazón acetato cat eye", 0, 2, 430, 190, 4, 7, None),
    ("ARM-AC2003", "Armazón acetato cuadrado grueso", 0, 2, 465, 210, 3, 5, None),
    ("ARM-PS3001", "Armazón clásico pasta", 0, 0, 360, 150, 4, 8, None),
    ("ARM-PS3002", "Armazón pasta juvenil", 0, 0, 310, 125, 4, 7, None),
    ("ARM-IN4001", "Armazón infantil flexible", 0, 2, 295, 120, 4, 6, None),
    ("ARM-IN4002", "Armazón infantil con correa", 0, 2, 270, 110, 3, 4, None),
    ("ARM-TR5001", "Armazón TR90 deportivo", 0, 2, 540, 255, 3, 4, None),
    ("ARM-TI6001", "Armazón titanio ejecutivo", 0, 2, 890, 450, 2, 3, None),
    ("ARM-ED7001", "Armazón edición coleccionable dorado", 0, 2, 980, 520, 2, 1, date(2025, 3, 31)),
    ("ARM-ED7002", "Armazón madera ecológica", 0, 2, 760, 410, 2, 1, date(2025, 2, 28)),
    ("ARM-ED7003", "Armazón transparente geométrico", 0, 0, 520, 260, 2, 2, date(2025, 6, 30)),
    ("LG-MONO", "Par de lentes monofocales", 2, 1, 600, 280, 0, 14, None),
    ("LG-MONO-AR", "Par monofocales con antirreflejo", 2, 1, 780, 360, 0, 11, None),
    ("LG-BLUE", "Par monofocales filtro de luz azul", 2, 1, 850, 395, 0, 9, None),
    ("LG-FOTO", "Par monofocales fotocromáticos", 2, 1, 980, 470, 0, 6, None),
    ("LG-BIF", "Par de lentes bifocales", 2, 1, 900, 430, 0, 4, None),
    ("LG-PROG", "Par de lentes progresivos", 2, 1, 1400, 750, 0, 6, None),
    ("LG-PROG-AR", "Par progresivos con antirreflejo", 2, 1, 1750, 920, 0, 3, None),
    ("LC-MEN", "Lente de contacto mensual (caja 6)", 1, 3, 175, 92, 12, 10, None),
    ("LC-DIA", "Lente de contacto diario (caja 30)", 1, 3, 260, 145, 8, 4, None),
    ("LC-TOR", "Lente de contacto tórico mensual (caja 6)", 1, 3, 320, 180, 6, 3, None),
    ("LC-COL", "Lente de contacto de color (par)", 1, 3, 210, 98, 6, 3, None),
    ("LC-SOL", "Solución multipropósito 360 ml", 1, 3, 85, 38, 15, 8, None),
    ("SOL-POL1", "Lentes solares polarizados unisex", 3, 2, 450, 190, 4, 5, None),
    ("SOL-DEP1", "Lentes solares deportivos", 3, 2, 380, 160, 3, 4, None),
    ("SOL-MOD1", "Lentes solares moda dama", 3, 2, 340, 140, 3, 4, None),
    ("SOL-INF1", "Lentes solares infantiles", 3, 2, 160, 60, 3, 2, None),
    ("SOL-ED01", "Lentes solares espejados edición verano", 3, 2, 420, 200, 2, 1, date(2025, 4, 30)),
    ("ACC-EST1", "Estuche rígido", 3, 4, 45, 15, 20, 9, None),
    ("ACC-PAN1", "Paño de microfibra", 3, 4, 15, 4, 30, 8, None),
    ("ACC-LIM1", "Spray limpiador 60 ml", 3, 4, 40, 14, 20, 7, None),
    ("ACC-COR1", "Cordón para lentes", 3, 4, 30, 9, 15, 4, None),
    ("ACC-KIT1", "Kit de tornillos y desarmador", 3, 4, 35, 11, 10, 2, None),
]
# Productos a los que se deja de reponer en las últimas semanas: quedan bajo el mínimo
SIN_REPOSICION_FINAL = {"ARM-AC2002", "LC-TOR", "ACC-LIM1", "SOL-POL1"}

USUARIOS = [  # nombre, usuario, perfil, activo, desde, hasta
    ("Propietario", "restrada", "U1", 1, date(2022, 12, 1), None),
    ("Administración", "admin.optica", "U2", 1, date(2022, 12, 1), None),
    ("Brenda Fuentes Orozco", "asesor1", "U3", 1, date(2022, 12, 1), None),
    ("Josué Bámaca Pérez", "asesor2", "U3", 0, date(2022, 12, 1), date(2024, 11, 30)),
    ("Karla Mazariegos Velásquez", "asesor3", "U3", 1, date(2023, 3, 1), None),
    ("Diego Escobar Rodas", "asesor4", "U3", 1, date(2024, 12, 1), None),
]
OPTOMETRISTAS = ["Lic. Andrea Monzón", "Lic. Fernando Rabanales"]

NOMBRES_M = ["José", "Juan", "Carlos", "Luis", "Miguel", "Pedro", "Mario", "Jorge", "Edgar", "Byron",
             "Marvin", "Óscar", "Erick", "Kevin", "Wilson", "Hugo", "Rony", "Selvin", "Julio", "Rafael",
             "Daniel", "Alejandro", "Francisco", "Otto", "Gerson", "Henry", "Walter", "Fredy", "Esteban", "Santiago"]
NOMBRES_F = ["María", "Ana", "Rosa", "Gloria", "Marta", "Sandra", "Claudia", "Brenda", "Karla", "Ingrid",
             "Lucía", "Mónica", "Silvia", "Andrea", "Glenda", "Heidy", "Wendy", "Evelyn", "Mayra", "Dulce",
             "Fernanda", "Gabriela", "Paola", "Sofía", "Alejandra", "Carmen", "Elena", "Jennifer", "Yesenia", "Vilma"]
APELLIDOS = ["López", "García", "Pérez", "Hernández", "Gómez", "Ramírez", "Fuentes", "Orozco", "Barrios",
             "Bámaca", "Mazariegos", "Velásquez", "Escobar", "Rodas", "Cifuentes", "Monzón", "Rabanales",
             "Ajú", "Tzunún", "Chávez", "Morales", "Juárez", "Castillo", "Reyes", "Méndez", "Ochoa", "Navarro",
             "de León", "Miranda", "Coyoy", "Sic", "Pac", "Alvarado", "Fuentes", "Sandoval", "Recinos",
             "Aguilar", "Cardona", "Maldonado", "Robles", "Solís", "Toledo", "Villatoro", "Xicará", "Zacarías"]

FERIADOS = {(1, 1), (5, 1), (6, 30), (9, 15), (10, 20), (11, 1), (12, 24), (12, 25), (12, 31)}
FACTOR_MES = {1: 1.35, 2: 1.2, 3: 1.0, 4: 0.95, 5: 0.95, 6: 0.9, 7: 1.0, 8: 0.95, 9: 0.85, 10: 0.95, 11: 1.05, 12: 1.4}
FACTOR_DIA = {0: 0.9, 1: 0.85, 2: 0.9, 3: 0.95, 4: 1.1, 5: 1.5, 6: 0.0}  # domingo cerrado


def precio(base, d, tasa):
    """Precio vigente: sube cada enero."""
    return round(base * (1 + tasa) ** (d.year - 2023) / 5) * 5


def poisson(lam):
    l, k, p = pow(2.718281828, -lam), 0, 1.0
    while True:
        p *= random.random()
        if p <= l:
            return k
        k += 1


# ------------------------------------------------------------------ simulación
prods = [dict(id=i + 1, ref=p[0], desc=p[1], cat=p[2], prov=p[3], pv=p[4], ca=p[5], minimo=p[6],
              peso=p[7], fin=p[8]) for i, p in enumerate(PRODUCTOS)]
por_ref = {p["ref"]: p for p in prods}
por_cat = {c: [p for p in prods if p["cat"] == c] for c in range(4)}


def elegir(cat, d, excluir=()):
    lista = [p for p in por_cat[cat] if (p["fin"] is None or d <= p["fin"]) and p["ref"] not in excluir]
    return random.choices(lista, weights=[p["peso"] for p in lista])[0]


clientes = []          # dicts
telefonos = set()
ventas, detalles, graduaciones = [], [], []
ultima_compra = {}     # idCliente -> fecha
agenda = {}            # fecha -> [(idCliente, tipo, idDetalleCampania o None)]
campanias, det_campania = [], []
ultima_campania_cliente = {}


def nuevo_cliente(d):
    fem = random.random() < 0.55
    nombre = f"{random.choice(NOMBRES_F if fem else NOMBRES_M)} {random.choice(APELLIDOS)} {random.choice(APELLIDOS)}"
    tel = None
    if random.random() > 0.12:
        while True:
            tel = "502" + random.choice("345") + "".join(random.choice("0123456789") for _ in range(7))
            if tel not in telefonos:
                telefonos.add(tel)
                break
    consiente = 1 if (tel and random.random() < 0.72) else 0
    exclusion = None
    if consiente and random.random() < 0.04:
        exclusion = d + timedelta(days=random.randint(60, 900))
        if exclusion >= FIN:
            exclusion = None
    correo = None
    if random.random() < 0.35:
        base = nombre.split()[0].lower() + "." + nombre.split()[1].lower()
        for a, b in zip("áéíóúñ", "aeioun"):
            base = base.replace(a, b)
        correo = f"{base}{random.randint(1, 99)}@{random.choice(['gmail.com', 'hotmail.com', 'yahoo.com'])}"
    c = dict(id=len(clientes) + 1, nombre=nombre, tel=tel, correo=correo, registro=d, consiente=consiente,
             fcons=d if consiente else None, exclusion=exclusion)
    clientes.append(c)
    return c


def asesor_del_dia(d):
    activos = [i + 1 for i, u in enumerate(USUARIOS) if u[2] == "U3" and u[4] <= d and (u[5] is None or d <= u[5])]
    if random.random() < 0.05:
        return random.choice([1, 2])
    return random.choice(activos)


def armar_ticket(tipo, d):
    """Devuelve líneas [(producto, cantidad)] según el tipo de compra."""
    lineas = []
    if tipo == "graduado":
        if random.random() < 0.85:
            lineas.append((elegir(0, d), 1))
        lente = elegir(2, d)
        lineas.append((lente, 1))
        if random.random() < 0.30:
            lineas.append((elegir(3, d, excluir=[p["ref"] for p in por_cat[3] if p["ref"].startswith("SOL")]), 1))
    elif tipo == "contacto":
        lc = elegir(1, d, excluir=["LC-SOL"])
        lineas.append((lc, random.choice([1, 1, 2, 2, 3])))
        if random.random() < 0.5:
            lineas.append((por_ref["LC-SOL"], random.choice([1, 1, 2])))
    elif tipo == "solares":
        sol = [p for p in por_cat[3] if p["ref"].startswith("SOL")]
        p = random.choices([x for x in sol if x["fin"] is None or d <= x["fin"]],
                           weights=[x["peso"] for x in sol if x["fin"] is None or d <= x["fin"]])[0]
        lineas.append((p, 1))
        if random.random() < 0.3:
            lineas.append((por_ref["ACC-EST1"], 1))
    else:  # accesorios
        acc = [p for p in por_cat[3] if p["ref"].startswith("ACC")] + [por_ref["LC-SOL"]]
        for p in random.sample(acc, random.choice([1, 1, 2])):
            lineas.append((p, random.choice([1, 1, 1, 2])))
    return lineas


def registrar_venta(d, cliente, tipo, id_det_camp=None):
    idv = len(ventas) + 1
    hora = datetime(d.year, d.month, d.day, random.randint(9, 18), random.choice(range(0, 60, 1)), random.randint(0, 59))
    asesor = asesor_del_dia(d)
    anulada = 1 if random.random() < 0.012 else 0
    promo = d.month == 12 or (d.month == 1 and d.day <= 31 and tipo == "graduado")
    total = 0
    for prod, cant in armar_ticket(tipo, d):
        pu = precio(prod["pv"], d, 0.05)
        cu = round(prod["ca"] * (1.04 ** (d.year - 2023)), 2)
        desc = 0
        if random.random() < (0.25 if promo else 0.08):
            desc = round(cant * pu * random.choice([0.05, 0.10, 0.15]), 2)
        detalles.append(dict(id=len(detalles) + 1, venta=idv, prod=prod["id"], cant=cant, pu=pu, cu=cu, desc=desc, gar=0, fecha=d))
        total += cant * pu - desc
    # Reposición en garantía (no es ingreso): 0.6 % de las ventas con cliente
    if cliente and random.random() < 0.006:
        prod = elegir(0, d)
        detalles.append(dict(id=len(detalles) + 1, venta=idv, prod=prod["id"], cant=1, pu=0, cu=round(prod["ca"] * (1.04 ** (d.year - 2023)), 2),
                             desc=0, gar=1, fecha=d))
    ventas.append(dict(id=idv, fac=f"FQ-{idv:06d}", cli=cliente["id"] if cliente else None, usr=asesor, d=d, hora=hora,
                       total=round(total, 2), anulada=anulada))
    if id_det_camp:
        det_campania[id_det_camp - 1]["venta"] = idv
    if cliente and not anulada:
        ultima_compra[cliente["id"]] = d
        if tipo == "graduado":
            g = graduacion(cliente, d)
            graduaciones.append(g)
            if random.random() < 0.3:   # algunos vuelven solos a renovar
                agendar(d + timedelta(days=random.randint(420, 1000)), cliente["id"], "graduado")
        elif tipo == "contacto" and random.random() < 0.5:
            agendar(d + timedelta(days=random.randint(28, 100)), cliente["id"], "contacto")
    return idv


def graduacion(c, d):
    q = lambda a, b: round(random.randint(int(a * 4), int(b * 4)) / 4, 2)
    esf = q(-6, 4)
    adicion = q(0.75, 2.5) if random.random() < 0.3 else None
    return dict(cli=c["id"], fecha=d, esfOD=esf, cilOD=q(-2, 0), ejeOD=random.randrange(0, 181, 5),
                esfOI=round(esf + q(-0.5, 0.5), 2), cilOI=q(-2, 0), ejeOI=random.randrange(0, 181, 5),
                adicion=adicion, prof=random.choice(OPTOMETRISTAS))


def agendar(d, idc, tipo, det=None):
    if d <= FIN:
        agenda.setdefault(d, []).append((idc, tipo, det))


def contactable(c, d):
    return c["tel"] and c["consiente"] and (c["exclusion"] is None or c["exclusion"] > d)


def meses_entre(a, b):
    return (b.year - a.year) * 12 + b.month - a.month - (1 if b.day < a.day else 0)


def correr_campania(d):
    elegibles = [c for c in clientes if c["id"] in ultima_compra and meses_entre(ultima_compra[c["id"]], d) >= 18
                 and contactable(c, d) and (d - ultima_campania_cliente.get(c["id"], date(2000, 1, 1))).days > 170]
    if not elegibles:
        return
    idc = len(campanias) + 1
    nombres = {1: "enero", 2: "febrero", 3: "marzo", 4: "abril", 5: "mayo", 6: "junio", 7: "julio",
               8: "agosto", 9: "septiembre", 10: "octubre", 11: "noviembre", 12: "diciembre"}
    camp = dict(id=idc, nombre=f"Renovación de lentes {nombres[d.month]} {d.year}", fecha=d, contactados=0)
    campanias.append(camp)
    for c in elegibles:
        r = random.choices(["SIN CONTACTO", "NO RESPONDE", "RECHAZA", "INTERESADO", "COMPRA"], weights=[14, 30, 24, 22, 10])[0]
        det = dict(id=len(det_campania) + 1, camp=idc, cli=c["id"],
                   fcont=None if r == "SIN CONTACTO" else d + timedelta(days=random.randint(0, 6)), res=r, venta=None)
        det_campania.append(det)
        ultima_campania_cliente[c["id"]] = d
        if r != "SIN CONTACTO":
            camp["contactados"] += 1
        if r == "COMPRA":
            agendar(det["fcont"] + timedelta(days=random.randint(1, 35)), c["id"], "graduado", det["id"])


FECHAS_CAMPANIA = {date(a, m, 5) for a in (2024, 2025, 2026) for m in (2, 5, 8, 11)} - {date(2026, 11, 5)}
d = INICIO
while d <= FIN:
    # Las campañas se generan aunque sea domingo (las prepara administración)
    if d in FECHAS_CAMPANIA:
        correr_campania(d)
    abierto = d.weekday() != 6 and (d.month, d.day) not in FERIADOS
    pendientes = agenda.pop(d, [])
    if not abierto:
        for p in pendientes:          # se corre al siguiente día
            agendar(d + timedelta(days=1), *p)
    else:
        for idc, tipo, det in pendientes:
            registrar_venta(d, clientes[idc - 1], tipo, det)
        # Las recompras agendadas son parte del mismo flujo de clientes: restan a las visitas nuevas
        lam = 6.0 * FACTOR_MES[d.month] * FACTOR_DIA[d.weekday()] * (1.04 ** ((d - INICIO).days / 365))
        lam = max(lam - 0.8 * len(pendientes), 0.5 if FACTOR_DIA[d.weekday()] else 0)
        for _ in range(poisson(lam)):
            tipo = random.choices(["graduado", "contacto", "solares", "accesorios"], weights=[45, 15, 17, 23])[0]
            if tipo in ("solares", "accesorios") and random.random() < 0.55:
                cliente = None                                   # consumidor final
            elif clientes and random.random() < 0.12:
                cliente = random.choice(clientes)                # cliente que vuelve sin agenda
            else:
                cliente = nuevo_cliente(d)
            registrar_venta(d, cliente, tipo)
    d += timedelta(days=1)

# Solo la graduación más reciente de cada cliente queda vigente
ultima_grad = {}
for i, g in enumerate(graduaciones):
    ultima_grad[g["cli"]] = i
for i, g in enumerate(graduaciones):
    g["vigente"] = 1 if ultima_grad[g["cli"]] == i else 0
# Una campaña sin compra concretada (cliente agendado tras el corte) queda como INTERESADO
for det in det_campania:
    if det["res"] == "COMPRA" and det["venta"] is None:
        det["res"] = "INTERESADO"

# ------------------------------------------------------------------ inventario
salidas = {}  # (fecha, idProducto) -> cantidad
for x in detalles:
    v = ventas[x["venta"] - 1]
    if v["anulada"] == 0 and prods[x["prod"] - 1]["cat"] != 2:   # los lentes graduados se piden al laboratorio
        salidas[(x["fecha"], x["prod"])] = salidas.get((x["fecha"], x["prod"]), 0) + x["cant"]

movs = []
stock, ult_mov, conteo = {}, {}, {}
pedidos = {}  # fecha de llegada -> [(idProducto, cantidad)]
for p in prods:
    if p["cat"] == 2:
        continue
    ini = max(p["minimo"] * 3, 4)
    stock[p["id"]] = ini
    movs.append((p["id"], INICIO, "INGRESO", ini, 2, "Inventario inicial"))
    ult_mov[p["id"]] = INICIO

d = INICIO
en_camino = set()
while d <= FIN:
    for idp, cant in pedidos.pop(d, []):
        stock[idp] += cant
        movs.append((idp, d, "INGRESO", cant, 2, f"Compra a {PROVEEDORES[prods[idp - 1]['prov']][0]}"))
        ult_mov[idp] = d
        en_camino.discard(idp)
    for p in prods:
        if p["cat"] == 2:
            continue
        q = salidas.get((d, p["id"]), 0)
        if q:
            if stock[p["id"]] < q:  # compra urgente para no vender sin existencia
                urg = q - stock[p["id"]] + p["minimo"]
                stock[p["id"]] += urg
                movs.append((p["id"], d, "INGRESO", urg, 2, "Compra urgente"))
            stock[p["id"]] -= q
            movs.append((p["id"], d, "SALIDA", -q, 2, "Ventas del día"))
            ult_mov[p["id"]] = d
        # Reposición: al bajar del mínimo se pide al proveedor
        corte = p["ref"] in SIN_REPOSICION_FINAL and d >= FIN - timedelta(days=50)
        descontinuado = p["fin"] is not None and d > p["fin"] - timedelta(days=60)
        if stock[p["id"]] < max(p["minimo"], 1) and p["id"] not in en_camino and not corte and not descontinuado:
            llegada = d + timedelta(days=PROVEEDORES[p["prov"]][3])
            pedidos.setdefault(llegada, []).append((p["id"], max(p["minimo"] * 3, 6)))
            en_camino.add(p["id"])
    # Conteo físico el último sábado de cada mes: a veces aparece un ajuste
    if d.weekday() == 5 and (d + timedelta(days=7)).month != d.month:
        for p in prods:
            if p["cat"] == 2:
                continue
            conteo[p["id"]] = d
            if random.random() < 0.06 and stock[p["id"]] > 0:
                stock[p["id"]] -= 1
                movs.append((p["id"], d, "AJUSTE", -1, 2, random.choice(["Producto dañado", "Faltante en conteo físico"])))
    d += timedelta(days=1)

# ------------------------------------------------------------------ cargas nocturnas y rechazos
cargas, rechazos = [], []
lineas_por_dia = {}
for x in detalles:
    lineas_por_dia[x["fecha"]] = lineas_por_dia.get(x["fecha"], 0) + 1
ase_users = [u[1] for u in USUARIOS]


def linea_mala(d):
    tel = random.choice([c["tel"] for c in clientes[-300:] if c["tel"]])
    base = [f"FQ-{random.randint(1, len(ventas)):06d}", d.strftime("%Y-%m-%d") + " 11:20:00", tel, "Cliente", "asesor1",
            "ARM-AC2001", "1", "400", "0", "0", "0"]
    tipo = random.choices(range(7), weights=[10, 25, 10, 25, 15, 10, 5])[0]
    motivos = ["Número de factura vacío", "Fecha y hora con formato inválido", "Cantidad inválida",
               "Producto inexistente: ", "Asesor inexistente: ", "Descuento mayor que el importe de la línea",
               "Precio unitario inválido"]
    if tipo == 0:
        base[0] = ""
    elif tipo == 1:
        base[1] = d.strftime("%d/%m/%Y") + " 11:20"
    elif tipo == 2:
        base[6] = "0"
    elif tipo == 3:
        base[5] = random.choice(["ARM-XX999", "LC-MEN6", "SOL-POL", "ACC-EST"])
    elif tipo == 4:
        base[4] = random.choice(["asesor5", "bfuentes", "caja1"])
    elif tipo == 5:
        base[8] = "450"
    else:
        base[7] = "-400"
    m = motivos[tipo] + (base[5] if tipo == 3 else base[4] if tipo == 4 else "")
    return ",".join(base), m


def nueva_carga(fecha_hora, tipo, proc, inc, rech, resultado):
    cargas.append(dict(id=len(cargas) + 1, fh=fecha_hora, tipo=tipo, proc=proc, inc=inc, rech=rech, res=resultado, usr=2))
    return len(cargas)


hist = sum(n for f, n in lineas_por_dia.items() if f < ARRANQUE_SISTEMA)
nrech = int(hist * 0.006)
idc = nueva_carga(datetime.combine(ARRANQUE_SISTEMA, datetime.min.time()) + timedelta(hours=20, minutes=12), "INICIAL",
                  hist + nrech, hist, nrech, "PARCIAL")
for _ in range(nrech):
    dd = INICIO + timedelta(days=random.randint(0, (ARRANQUE_SISTEMA - INICIO).days - 1))
    txt, m = linea_mala(dd)
    rechazos.append(dict(carga=idc, txt=txt, motivo=m, corr=1, fcorr=datetime.combine(ARRANQUE_SISTEMA + timedelta(days=random.randint(1, 20)), datetime.min.time()) + timedelta(hours=10)))

fallidas = {date(2026, 3, 18), date(2026, 7, 9)}
d = ARRANQUE_SISTEMA
while d <= FIN:
    n = lineas_por_dia.get(d, 0)
    if n:
        fh = datetime.combine(d, datetime.min.time()) + timedelta(hours=23, minutes=random.randint(0, 4), seconds=random.randint(0, 59))
        if d in fallidas:
            r = max(int(n * 0.12), 3)
            idc = nueva_carga(fh, "INCREMENTAL", n + r, 0, r, "FALLIDA")
            for _ in range(r):
                txt, m = linea_mala(d)
                rechazos.append(dict(carga=idc, txt=txt, motivo=m, corr=1, fcorr=fh + timedelta(minutes=40)))
            nueva_carga(fh + timedelta(minutes=55), "INCREMENTAL", n, n, 0, "EXITOSA")
        else:
            r = random.choices([0, 1, 2, 3], weights=[70, 18, 8, 4])[0] if random.random() < 0.35 else 0
            idc = nueva_carga(fh, "INCREMENTAL", n + r, n, r, "PARCIAL" if r else "EXITOSA")
            for _ in range(r):
                txt, m = linea_mala(d)
                corr = 1 if d < FIN - timedelta(days=10) and random.random() < 0.8 else 0
                rechazos.append(dict(carga=idc, txt=txt, motivo=m, corr=corr,
                                     fcorr=fh + timedelta(hours=random.randint(9, 40)) if corr else None))
    d += timedelta(days=1)

# ------------------------------------------------------------------ bitácora
bitacora = []
d = ARRANQUE_SISTEMA
while d <= FIN:
    if d.weekday() != 6:
        for idu in (1, 2):
            if idu == 2 or random.random() < 0.7:
                t = datetime.combine(d, datetime.min.time()) + timedelta(hours=random.randint(8, 10), minutes=random.randint(0, 59))
                ip = "192.168.1.10" if idu == 1 else "192.168.1.11"
                bitacora.append((idu, t, "INICIO SESION", None, None, ip))
                if idu == 2 and random.random() < 0.15:
                    gid = random.randint(1, len(graduaciones))
                    bitacora.append((idu, t + timedelta(minutes=random.randint(5, 90)), "CONSULTA GRADUACION", "Graduacion", gid, ip))
                bitacora.append((idu, t + timedelta(hours=random.randint(2, 8)), "CIERRE SESION", None, None, ip))
    if d.weekday() == 4:
        bitacora.append((2, datetime.combine(d, datetime.min.time()) + timedelta(hours=18, minutes=30), "RESPALDO", None, None, "192.168.1.11"))
    d += timedelta(days=1)
bitacora.append((1, datetime(2026, 1, 5, 9, 0), "ALTA USUARIO", "Usuario", 6, "192.168.1.10"))
bitacora.append((1, datetime(2026, 2, 16, 9, 40), "CAMBIO PARAMETRO", "ParametroRegla", 1, "192.168.1.10"))
bitacora.sort(key=lambda b: b[1])


# ------------------------------------------------------------------ escritura del script
def s(v):
    if v is None:
        return "NULL"
    if isinstance(v, bool):
        return "1" if v else "0"
    if isinstance(v, (int, float)):
        return repr(v) if isinstance(v, float) else str(v)
    if isinstance(v, datetime):
        return "'" + v.strftime("%Y-%m-%dT%H:%M:%S") + "'"
    if isinstance(v, date):
        return "'" + v.strftime("%Y-%m-%d") + "'"
    return "N'" + str(v).replace("'", "''") + "'"


def bloque(out, tabla, columnas, filas, identidad=True):
    if not filas:
        return
    out.append(f"PRINT 'Cargando {tabla} ({len(filas)} filas)';")
    if identidad:
        out.append(f"SET IDENTITY_INSERT [dbo].[{tabla}] ON;")
    cols = ", ".join(f"[{c}]" for c in columnas)
    for i in range(0, len(filas), 1000):
        out.append(f"INSERT INTO [dbo].[{tabla}] ({cols}) VALUES")
        out.append(",\n".join("(" + ", ".join(s(v) for v in f) + ")" for f in filas[i:i + 1000]) + ";")
    if identidad:
        out.append(f"SET IDENTITY_INSERT [dbo].[{tabla}] OFF;")
    out.append("GO")


def leer(rel):
    return (BD / rel).read_text(encoding="utf-8").strip() + "\nGO"


ORDEN_TABLAS = ["Usuario", "Categoria", "Proveedor", "Producto", "Cliente", "DimTiempo", "Inventario", "Graduacion",
                "Venta", "DetalleVenta", "MovimientoInventario", "Campania", "DetalleCampania", "CargaDatos",
                "RegistroRechazado", "ParametroRegla", "BitacoraAcceso"]

out = [f"""/*
================================================================================
 SIN-Quick — base de datos de demostración
 Sistema de Inteligencia de Negocios para Óptica Quick (San Marcos, Guatemala)

 Crea la base [SINQuick] con todo el modelo del proyecto (17 tablas, esquemas
 stg/etl/rpt, procedimientos y vistas) y la llena con datos SIMULADOS del
 {INICIO:%d/%m/%Y} al {FIN:%d/%m/%Y}. Ningún dato corresponde a personas reales.

 Cómo usarlo:
   1. Abrir en SQL Server Management Studio, conectado a tu instancia.
   2. Ejecutar todo (F5). Tarda uno o dos minutos.
   Por consola (más rápido):  sqlcmd -S localhost -E -f 65001 -i SINQuick_Demo.sql

 Si la base SINQuick ya existe, el script no hace nada. Para volver a crearla,
 elimínala primero (clic derecho > Delete) y ejecuta de nuevo.
================================================================================
*/
SET NOCOUNT ON;
USE [master];
GO
IF DB_ID(N'SINQuick') IS NOT NULL
BEGIN
    PRINT 'La base SINQuick ya existe. Elimínala primero si quieres recrearla. No se hizo ningún cambio.';
    SET NOEXEC ON;
END
GO
CREATE DATABASE [SINQuick] COLLATE Modern_Spanish_CI_AS;
GO
ALTER DATABASE [SINQuick] SET RECOVERY SIMPLE;
GO
USE [SINQuick];
GO
SET NOCOUNT ON;
GO
PRINT 'Creando esquemas, roles y tablas...';
GO"""]
out += [leer("Security/Esquemas.sql"), leer("Security/Roles.sql")]
out += [leer(f"dbo/Tables/{t}.sql") for t in ORDEN_TABLAS]
out += [leer("stg/Tables/VentaLinea.sql"), leer("stg/Views/vw_VentaLineaCarga.sql")]
for f in sorted((BD / "etl/StoredProcedures").glob("*.sql")):
    out.append(leer(f"etl/StoredProcedures/{f.name}"))
for f in sorted((BD / "rpt/Views").glob("*.sql")):
    out.append(leer(f"rpt/Views/{f.name}"))
out.append(leer("Security/Permisos.sql"))
out.append("PRINT 'Llenando el calendario...';\nEXEC [etl].[usp_PoblarDimTiempo] @desde = '2019-01-01', @hasta = '2030-12-31';\nGO")

bloque(out, "Usuario", ["idUsuario", "nombreCompleto", "nombreUsuario", "hashContrasena", "perfil", "activo", "fechaAlta"],
       [(i + 1, u[0], u[1], "0x00", u[2], u[3], u[4]) for i, u in enumerate(USUARIOS)])
out[-3] = out[-3].replace("N'0x00'", "0x00")
bloque(out, "Categoria", ["idCategoria", "nombre", "descripcion", "activo"],
       [(i + 1, c, None, 1) for i, c in enumerate(CATEGORIAS)])
bloque(out, "Proveedor", ["idProveedor", "nombre", "contacto", "telefono", "diasEntrega", "activo"],
       [(i + 1, p[0], p[1], p[2], p[3], 1) for i, p in enumerate(PROVEEDORES)])
bloque(out, "Producto", ["idProducto", "referencia", "descripcion", "idCategoria", "idProveedor", "precioVenta",
                         "costoAdquisicion", "nivelMinimo", "activo"],
       [(p["id"], p["ref"], p["desc"], p["cat"] + 1, p["prov"] + 1, precio(p["pv"], FIN, 0.05),
         round(p["ca"] * 1.04 ** (FIN.year - 2023), 2), p["minimo"], 0 if p["fin"] and stock.get(p["id"], 0) == 0 else 1)
        for p in prods])
bloque(out, "Cliente", ["idCliente", "nombreCompleto", "telefono", "correo", "fechaRegistro", "consentimientoContacto",
                        "fechaConsentimiento", "fechaExclusion", "activo"],
       [(c["id"], c["nombre"], c["tel"], c["correo"], c["registro"], c["consiente"], c["fcons"], c["exclusion"], 1) for c in clientes])
bloque(out, "Inventario", ["idInventario", "idProducto", "existenciaActual", "fechaUltimoMovimiento", "fechaUltimoConteo", "costoPromedio"],
       [(p["id"], p["id"], stock.get(p["id"], 0), ult_mov.get(p["id"]), conteo.get(p["id"]),
         round(p["ca"] * 1.04 ** (FIN.year - 2023), 2)) for p in prods])
bloque(out, "Graduacion", ["idGraduacion", "idCliente", "fechaExamen", "esferaOD", "cilindroOD", "ejeOD", "esferaOI",
                           "cilindroOI", "ejeOI", "adicion", "profesional", "vigente"],
       [(i + 1, g["cli"], g["fecha"], g["esfOD"], g["cilOD"], g["ejeOD"], g["esfOI"], g["cilOI"], g["ejeOI"], g["adicion"],
         g["prof"], g["vigente"]) for i, g in enumerate(graduaciones)])
bloque(out, "Venta", ["idVenta", "numeroFactura", "idCliente", "idUsuario", "idFecha", "fechaHora", "total", "anulada"],
       [(v["id"], v["fac"], v["cli"], v["usr"], int(v["d"].strftime("%Y%m%d")), v["hora"], v["total"], v["anulada"]) for v in ventas])
bloque(out, "DetalleVenta", ["idDetalle", "idVenta", "idProducto", "cantidad", "precioUnitario", "costoUnitario", "descuento", "esGarantia"],
       [(x["id"], x["venta"], x["prod"], x["cant"], x["pu"], x["cu"], x["desc"], x["gar"]) for x in detalles])
bloque(out, "MovimientoInventario", ["idMovimiento", "idProducto", "idFecha", "tipoMovimiento", "cantidad", "idVenta", "idUsuario", "observacion"],
       [(i + 1, m[0], int(m[1].strftime("%Y%m%d")), m[2], m[3], None, m[4], m[5]) for i, m in enumerate(movs)])
bloque(out, "Campania", ["idCampania", "nombre", "fechaGeneracion", "criterio", "totalContactados", "idUsuario"],
       [(c["id"], c["nombre"], c["fecha"], "Ciclo de renovación vencido (RN-01) y cliente contactable (RN-09)", c["contactados"], 2)
        for c in campanias])
bloque(out, "DetalleCampania", ["idDetalleCampania", "idCampania", "idCliente", "fechaContacto", "resultado", "idVentaGenerada"],
       [(x["id"], x["camp"], x["cli"], x["fcont"], x["res"], x["venta"]) for x in det_campania])
bloque(out, "CargaDatos", ["idCarga", "fechaEjecucion", "tipoCarga", "registrosProcesados", "registrosIncorporados",
                           "registrosRechazados", "resultado", "idUsuario"],
       [(c["id"], c["fh"], c["tipo"], c["proc"], c["inc"], c["rech"], c["res"], c["usr"]) for c in cargas])
bloque(out, "RegistroRechazado", ["idRechazo", "idCarga", "contenidoOriginal", "motivoRechazo", "corregido", "fechaCorreccion"],
       [(i + 1, r["carga"], r["txt"], r["motivo"], r["corr"], r["fcorr"]) for i, r in enumerate(rechazos)])
bloque(out, "ParametroRegla", ["idParametro", "codigoRegla", "descripcion", "valor", "unidad", "idUsuarioModifica", "fechaModificacion"], [
    (1, "RN-01", "Ciclo de renovación de lentes graduados", "18", "meses", 1, datetime(2026, 2, 16, 9, 40)),
    (2, "RN-02", "Ciclo de consumo de lentes de contacto mensuales", "30", "días", None, None),
    (3, "RN-03", "Días de consumo para calcular el nivel mínimo", "60", "días", None, None),
    (4, "RN-04", "Días sin venta para considerar inventario sin movimiento", "180", "días", None, None),
    (5, "UMB-RECH", "Porcentaje máximo de rechazo antes de detener una carga", "5", "%", None, None)])
bloque(out, "BitacoraAcceso", ["idBitacora", "idUsuario", "fechaHora", "accion", "entidadAfectada", "idRegistroAfectado", "direccionOrigen"],
       [(i + 1,) + b for i, b in enumerate(bitacora)])

anuladas = sum(v["anulada"] for v in ventas)
out.append(f"""PRINT '';
PRINT 'Listo. Base SINQuick creada con datos simulados:';
PRINT '  {len(clientes)} clientes, {len(ventas)} facturas ({anuladas} anuladas), {len(detalles)} líneas de venta';
PRINT '  {len(prods)} productos, {len(movs)} movimientos de inventario, {len(campanias)} campañas, {len(cargas)} cargas';
PRINT 'Para Power BI: Obtener datos > SQL Server > servidor: tu instancia, base: SINQuick, modo Importar,';
PRINT 'y elegir las vistas del esquema rpt.';
GO
SET NOEXEC OFF;
GO""")

SALIDA.write_text("\n".join(out) + "\n", encoding="utf-8-sig")
print(f"{SALIDA}  {SALIDA.stat().st_size / 1e6:.1f} MB")
print(f"clientes={len(clientes)} ventas={len(ventas)} anuladas={anuladas} detalles={len(detalles)} graduaciones={len(graduaciones)}")
print(f"movimientos={len(movs)} campañas={len(campanias)} detCamp={len(det_campania)} cargas={len(cargas)} rechazos={len(rechazos)} bitacora={len(bitacora)}")

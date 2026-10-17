# Cómo obtener las capturas de ejecuciones exitosas y fallidas

El enunciado pide capturas de corridas **exitosas y fallidas**. Una corrida fallida no se
simula: se provoca un error real en el código y se deja que el pipeline lo detecte.

## Ejecución exitosa

1. En Jenkins, abrir el pipeline y la rama `develop` → **Build Now**.
2. Esperar a que las cuatro etapas queden en verde.
3. Capturar:
   - **Stage View** con Checkout, Build, Test y Deploy Staging en verde.
   - **Test Result**: las pruebas tSQLt y pytest aprobadas.
   - **Reporte de pruebas (pytest)**: el reporte HTML con la columna *Caso*.
   - **Console Output**: el final, con `Finished: SUCCESS`.

## Ejecución fallida (error real detectado por las pruebas)

1. Crear una rama: `git checkout -b feature/error-rn09`.
2. En `database/SINQuick.DB/rpt/Views/vw_ClientesRenovacion.sql` quitar la condición
   `AND c.[consentimientoContacto] = 1` del cálculo de `contactable`.
   (Es el error más grave posible: contactar a clientes que no dieron permiso.)
3. `git commit -am "prueba: quitar consentimiento (error intencional)"` y `git push`.
4. Jenkins ejecuta la rama: la prueba **CP-03** de tSQLt falla, la etapa **Test** queda en
   rojo y **Deploy Staging no se ejecuta**.
5. Capturar:
   - **Stage View** con Test en rojo y Deploy Staging sin ejecutar.
   - **Test Result** mostrando CP-03 fallida y el mensaje de la aserción.
   - **Console Output** con `Finished: FAILURE`.
6. Revertir: `git revert HEAD` y `git push`. El pipeline vuelve a verde.

## Segunda falla opcional (etapa Build)

Introducir un error de sintaxis en cualquier vista (por ejemplo `SELEC`). El DACPAC no
compila y el pipeline se detiene en **Build**, antes de tocar cualquier base de datos.

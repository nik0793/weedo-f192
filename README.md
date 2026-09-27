# Weedo F192: perfil de Cura, manual y firmware

Todo lo necesario para volver a imprimir con la **Weedo F192** (la impresora 3D de doble boquilla, cama de 280 × 200 mm, que llegó a muchas escuelas técnicas de Argentina a través de Novatech). El software original de Weedo (Cura WEEDO y ReplicatorG WEEDO) ya no se puede descargar: acá está el reemplazo, probado en máquinas reales.

| Carpeta | Qué hay |
|---|---|
| [`manual/`](manual/) | **Guía en PDF** ([guia-weedo-f192.pdf](manual/guia-weedo-f192.pdf)): hojas 1–2 para pegar al lado de la máquina (con QR a esta página) y, desde la hoja 3, la instalación y configuración de Cura paso a paso con capturas. |
| [`cura/`](cura/) | Perfil de la F192 para UltiMaker Cura 5 y el complemento que genera los archivos `.x3g`, con instalador. |
| [`pruebas/`](pruebas/) | Archivos listos para comprobar la máquina sin instalar nada. |
| [`eeprom/`](eeprom/) | Verificar y restaurar la configuración interna de la impresora. |
| [`firmware/`](firmware/) | Firmware original de la F192 y cómo respaldarlo o grabarlo (solo para rescates). |
| [`herramientas/`](herramientas/) | Ver el estado de la impresora, imprimir por cable USB y cancelar. |
| [`docs/NOTAS-TECNICAS.md`](docs/NOTAS-TECNICAS.md) | Cómo funciona por dentro y qué descubrimos para que ande. |

Para descargar todo: botón verde **Code** → **Download ZIP**; después, clic derecho en el ZIP → **Extraer todo** → **Extraer**. No ejecutes nada desde adentro del ZIP sin extraer.

---

## Lo esencial (leer antes de empezar)

1. **La F192 solo imprime archivos `.x3g` desde la tarjeta SD.** No entiende G-code; Pronterface, OctoPrint o un Cura común no sirven solos.
2. **Los `.x3g` tienen que salir de este perfil de Cura.** El firmware de Weedo exige una marca especial al principio del archivo; los `.x3g` hechos con otros programas hacen que la impresora **vuelva al menú principal** al elegirlos.
3. **Tarjeta SD común de 2 GB o menos, formateada en FAT** (FAT16). Con una de 32 GB no la pudo leer.
4. **No conectes ReplicatorG ni MakerBot Desktop a la impresora.** Al conectarse cambian la configuración interna (por ejemplo, los pasos del eje Z) y las piezas salen mal. Si ya pasó, se arregla con [`eeprom/restaurar-eeprom.bat`](eeprom/).
5. **No grabes el firmware "F192C" que aparece en internet.** Es otro firmware (Marlin) para otra variante; no lo probamos en la F192 y cambia la forma de trabajar.

---

## 1. Instalar Cura y el perfil (una sola vez)

1. Descargá e instalá **UltiMaker Cura 5** desde [ultimaker.com/software/ultimaker-cura](https://ultimaker.com/software/ultimaker-cura/). Probado con Cura 5.12 en Windows 11.
2. Abrí Cura una vez y cerralo cuando llegues a *Agregar impresora* (así crea su carpeta de configuración). Cura recién instalado arranca **en inglés**: *Agree*, *Skip*, *Add printer*.
3. Ejecutá **`cura/instalar-cura.bat`** con Cura cerrado. Copia el perfil de la F192, sus dos boquillas y el complemento X3GWriter modificado.
4. Abrí Cura y agregá la impresora: en el asistente, o en **Preferencias → Configurar Cura... → Impresoras → Añadir nuevo** → **Impresoras no UltiMaker** (*Non UltiMaker printer*) → **Agregar una impresora fuera de red** (*Add a non-networked printer*) → buscá `weedo` → **WEEDO F192** → **Agregar** (*Add*). Cura trae otras Weedo de fábrica (F150S, F152S, TINA2…): no sirven para la F192.
5. Si Cura quedó en inglés: *Preferences → Configure Cura... → General → Language\** → **Español**, y volvé a abrirlo.
6. **No instales ni actualices X3GWriter desde el Marketplace**: se perderían las modificaciones para la F192. El botón **Actualizar firmware** de Cura no sirve para esta máquina: Cura no trae firmware para la F192 ni puede comunicarse con ella por USB. Para rescates, ver [`firmware/`](firmware/).
7. **No cambies Ajustes de la máquina** (tamaño de cama ni inicio de impresión). Cura guarda esos cambios dentro de la impresora agregada y volver a ejecutar el instalador no los deshace. Si alguien los cambió, agregá otra **WEEDO F192** (queda con otro nombre, por ejemplo *WEEDO F192 #2*) y después eliminá la vieja en **Preferencias → Configurar Cura... → Impresoras** → elegila → menú **☰** → **Eliminar** (Cura no deja eliminar la única impresora; por eso primero se agrega la nueva).

La guía en PDF ([`manual/guia-weedo-f192.pdf`](manual/guia-weedo-f192.pdf), desde la hoja 3) muestra cada pantalla.

¿Sin Windows o sin permiso para ejecutar el `.bat`? Con Cura cerrado (y después de haberlo abierto una vez), copiá a mano dentro de la carpeta de tu versión de Cura (por ejemplo `5.12`):

- Windows: `%APPDATA%\cura\<versión>\`
- macOS: `~/Library/Application Support/cura/<versión>/`
- Linux: `~/.local/share/cura/<versión>/` (no `~/.config/cura/`, que solo guarda las preferencias)

Qué copiar: `cura/definitions/*` → `definitions/`, `cura/extruders/*` → `extruders/`, y el contenido de `cura/plugins/X3GWriter/` → `plugins/X3GWriter/X3GWriter/` (crear las carpetas que falten). Con Cura abierto, **Ayuda → Mostrar carpeta de configuración** abre esa carpeta. Probado solo en Windows.

## 2. Elegir la boquilla

| En Cura | En la máquina | Motor |
|---|---|---|
| Extrusor 1 | Boquilla **derecha** (T0) | A |
| Extrusor 2 | Boquilla **izquierda** (T1) | B |

- **Una boquilla por impresión: deshabilitá la que no usás.** Para imprimir con la derecha: **Ajustes → Extrusor izquierdo (T1) → Deshabilitar extrusor**. Para la izquierda: **Ajustes → Extrusor derecho (T0) → Deshabilitar extrusor**. La deshabilitada se ve gris en la barra de arriba, y Cura recuerda el ajuste para la próxima vez.
- Si la pieza había quedado asignada a la boquilla que deshabilitaste, se ve rayada y Cura avisa *No se puede segmentar*: clic derecho sobre la pieza → *Imprimir modelo seleccionado con* → la habilitada (o Ctrl+1 / Ctrl+2).
- **No dejes las dos habilitadas.** Aunque la pieza esté asignada a la izquierda, la balsa sale con la derecha y la impresión pasa a usar las dos boquillas. Si Cura avisa *Extrusor(es) no usado(s)*, tocá *Desactivar extrusor(es) no usado(s)*.
- El perfil calienta y purga solo la boquilla que se usa, y deja la otra apagada.
- Con la **boquilla izquierda** el firmware corre el cabezal 35 mm a la derecha para que la pieza caiga en el mismo lugar. Por eso **no pongas piezas en los últimos 4 cm del borde derecho de la cama** (mirando la impresora de frente; en Cura, el borde derecho de la placa). Cura no marca esa franja.
- **Doble color (las dos a la vez):** todavía no está calibrado. Por ahora, una boquilla por impresión.

## 3. Preparar la pieza

Valores de partida para filamento de 1,75 mm:

| Ajuste | PLA | ABS |
|---|---|---|
| Temperatura de boquilla | 200 °C | 230 °C |
| Temperatura de cama | 60 °C | 100 °C |
| Altura de capa | 0,2 mm (perfil *Draft*, el que viene elegido) | 0,2 mm |
| Paredes | 0,8 mm (2 líneas) | 0,8 mm |
| Relleno | 15–20 % | 15–20 % |
| Velocidad de impresión | 40–50 mm/s | 40 mm/s |
| Primera capa | 20–25 mm/s | 20 mm/s |
| Adherencia | Borde (brim) | Balsa (raft) o borde, puerta cerrada |
| Retracción | 1–1,5 mm a 25 mm/s | 1–1,5 mm a 25 mm/s |
| Ventilador de capa | 100 % desde la capa 2 | Apagado |

**Con PLA el perfil ya trae estos valores.** Con ABS: **Ajustes → Extrusor… → Material → Genérico → ABS**; después, en **Mostrar personalización**, pestaña de esa boquilla: *Material* → Temperatura de impresión 230 y Temperatura de la placa de impresión 100; *Refrigeración* → desmarcar *Activar refrigeración de impresión*; si la pieza se despega, *Adherencia de la placa de impresión* → *Tipo adherencia de la placa de impresión* → *Balsa*.

Después de cortar (*Segmentación*): **Guardar en disco**. El *Tipo* ya viene en **X3G File (\*.x3g)**; si no, elegilo. Usá un **nombre corto, sin espacios ni acentos** (por ejemplo `LLAVERO1.x3g`). Si la tarjeta SD ya está puesta en la PC, el botón dice **Guardar en unidad extraíble** y graba directo en la raíz de la tarjeta, sin ventana, con el nombre que se ve abajo a la izquierda junto al lápiz (por ejemplo `WF_cubo_20mm`): cambiá ese nombre antes, o elegí **Guardar en disco** con la flechita del botón.

## 4. Tarjeta SD

- Tarjeta SD común de **2 GB o menos** (sirven las micro SD con adaptador).
- Formato **FAT** (en Windows: clic derecho sobre la tarjeta → Formatear → Sistema de archivos *FAT*, no FAT32 ni exFAT). Formatear borra todo lo que tenga la tarjeta.
- Copiá los `.x3g` **en la raíz**, no dentro de carpetas.

## 5. Imprimir

1. Filamento **cargado** en la boquilla elegida y **pasando por el sensor de filamento**: si el sensor no lo detecta, la impresora se pausa sola al principio. Para cargarlo, en la pantalla: **Ajustes** (el botón con la llave) → **Cambiar filamento** y la opción de cargar en la boquilla derecha o izquierda; la boquilla se calienta y el motor lo empuja (nombres según el manual de Weedo).
2. Tarjeta en la ranura → **Imprimir** → tocá el archivo en la lista (la pantalla se titula *Tarjeta SD*).
3. Qué vas a ver al arrancar: home de X e Y (esquina), el cabezal va **al centro**, la cama sube hasta el sensor, baja y vuelve a subir despacio; el cabezal va adelante, calienta cama y boquilla, hace una línea de purga al frente y empieza la pieza.
4. Para frenar: **Cancelar** en la pantalla.

El home de Z se hace con el cabezal en el centro porque **el sensor de Z va montado en el carro**: en la esquina queda fuera de la cama y la cama subiría sin frenar. El perfil ya lo hace así; si usás otro inicio de impresión, respetalo.

## 6. Nivelar la cama

En la pantalla: **Ajustes** (el botón con la llave) → **Nivelar plato de impresión**, y seguí las indicaciones. En cada punto, girá la perilla de la cama hasta que suene el aviso (así lo indica el manual de Weedo) o hasta que una hoja de papel pase entre la boquilla y la cama con un leve roce. Repetí la vuelta completa dos veces.

## 7. Problemas frecuentes

| Síntoma | Causa | Qué hacer |
|---|---|---|
| Al elegir el archivo vuelve al menú principal | El `.x3g` no tiene la marca que exige el firmware de Weedo, o la configuración interna fue cambiada (típico después de conectar ReplicatorG) | Generarlo con este perfil de Cura (el complemento la agrega). Si también pasa con `pruebas/MOVIM.X3G`, ejecutar `eeprom/verificar-eeprom.bat` y, si hay diferencias, `eeprom/restaurar-eeprom.bat`; después apagar y prender. Los archivos chiquitos (menos de 512 bytes) sin la marca andan igual y confunden. |
| La lista de la tarjeta está vacía o no la lee | Tarjeta grande o formato FAT32/exFAT | Tarjeta de 2 GB o menos en FAT; archivos en la raíz. |
| Al hacer home la cama sube sin frenar y el motor fuerza | El sensor de Z no detecta: cabezal fuera de la cama, o cable/conector del sensor | **Apagar la impresora enseguida**: el home de Z insiste hasta 20 s y la cama puede golpear la boquilla. Después: usar el inicio de este perfil (home de Z en el centro), revisar el cable del sensor y que esté en el conector Z-MIN de la placa. |
| Al nivelar, la cama baja cuando debería subir, o el motor Z vibra | Un cable del motor Z cortado o flojo (nos pasó) | Revisar con multímetro las dos bobinas del motor Z en el conector de la placa. |
| Se pausa sola al principio | El sensor de filamento no detecta filamento | Pasar el filamento por el sensor; revisar su cable. Si el sensor está roto, la detección se puede desactivar en **Configuracion → Función avanzada** (según el manual de Weedo). |
| Imprime con la boquilla equivocada | Boquillas habilitadas en Cura | Deshabilitar la que no se usa (sección 2). |
| Piezas con la mitad de altura o aplastadas; extrusión rara | Configuración interna cambiada (típico después de conectar ReplicatorG) | Con la impresora encendida y conectada por USB (Cura y ReplicatorG cerrados): `eeprom/verificar-eeprom.bat`; si alguna zona dice DISTINTO, `eeprom/restaurar-eeprom.bat`, escribir `SI` y apagar y prender. |
| Pronterface u OctoPrint no conectan | La F192 usa un protocolo binario (s3g), no G-code | Usar la SD, o `herramientas/imprimir-por-usb.bat` (sección 10). |

## 8. Configuración interna (EEPROM)

La impresora guarda su configuración (pasos por mm, corriente de motores, home, velocidades) en una memoria interna. En [`eeprom/`](eeprom/):

- **`verificar-eeprom.bat`**: lee la configuración por USB, guarda un respaldo y la compara con la de fábrica. No cambia nada.
- **`restaurar-eeprom.bat`**: reescribe solo las partes que difieren de fábrica y verifica releyendo. Antes muestra el puerto y el nombre de la máquina y pide escribir `SI`. No toca contadores de horas ni la calibración fina entre boquillas.

Necesitás la impresora encendida, conectada por USB, y Cura/ReplicatorG cerrados. **Conectá solo esa impresora**: si responde más de una, los scripts se detienen y piden el puerto (`restaurar-eeprom.bat -Port COM5`). El chip USB de la placa es un CH340 o un Prolific PL2303 según la unidad; Windows 10/11 suele instalar el driver solo.

## 9. Firmware (solo para rescates)

La mayoría de las escuelas **no necesita tocar el firmware**. Solo si la máquina perdió el firmware o le grabaron otro. Ver [`firmware/LEEME.md`](firmware/LEEME.md): primero se hace un respaldo del firmware actual y después se graba el original con avrdude, usando el botón de reset de la impresora.

## 10. Imprimir por cable USB (opcional)

`herramientas/imprimir-por-usb.bat` manda un `.x3g` por el cable, sin tarjeta: arrastrá el archivo sobre el `.bat` (o abrilo y arrastrá el archivo a la ventana). La PC tiene que quedar encendida y conectada durante toda la impresión. Sirve para pruebas; para imprimir de verdad es más seguro usar la SD. Con Cura y ReplicatorG cerrados.

- Si el envío se corta por un error o con Ctrl+C, el script intenta cancelar el trabajo. Si se cerró la ventana o se desconectó el cable, la impresora sigue caliente: cancelala desde la pantalla o con `herramientas/cancelar-impresion.bat`.
- `herramientas/estado-impresora.bat` muestra el estado de la impresora (trabajo, archivo, posición).
- Desde una consola: `powershell -ExecutionPolicy Bypass -File herramientas\imprimir-por-usb.ps1 -Archivo pruebas\MOVIM.X3G` (con `-Port COM5` si hace falta indicar el puerto).

---

## Créditos y licencias

Armado en 2026 por nik0793 y colaboradores a partir de máquinas reales de escuelas técnicas, desensamblando el firmware de fábrica y reconstruyendo la documentación perdida de Weedo. Detalle de licencias de cada parte en [LICENCIAS.md](LICENCIAS.md). Correcciones y aportes: abrir un *issue* en este repositorio.

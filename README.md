# Weedo F192: perfil de Cura, manual y firmware

Todo lo necesario para volver a imprimir con la **Weedo F192** (la impresora 3D de doble boquilla, cama de 280 × 200 mm, que llegó a muchas escuelas técnicas de Argentina a través de Novatech). El software original de Weedo (Cura WEEDO y ReplicatorG WEEDO) ya no se puede descargar: acá está el reemplazo, probado en máquinas reales.

| Carpeta | Qué hay |
|---|---|
| [`manual/`](manual/) | Guía rápida en PDF para imprimir y dejar al lado de la máquina (con QR a esta página). |
| [`cura/`](cura/) | Perfil de la F192 para UltiMaker Cura 5 y el complemento que genera los archivos `.x3g`, con instalador. |
| [`pruebas/`](pruebas/) | Archivos listos para comprobar la máquina sin instalar nada. |
| [`eeprom/`](eeprom/) | Verificar y restaurar la configuración interna de la impresora. |
| [`firmware/`](firmware/) | Firmware original de la F192 y cómo respaldarlo o grabarlo (solo para rescates). |
| [`herramientas/`](herramientas/) | Ver el estado de la impresora e imprimir por cable USB. |
| [`docs/NOTAS-TECNICAS.md`](docs/NOTAS-TECNICAS.md) | Cómo funciona por dentro y qué descubrimos para que ande. |

Para descargar todo: botón verde **Code** → **Download ZIP**, y descomprimir.

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
2. Abrí Cura una vez y cerralo (así crea su carpeta de configuración).
3. Ejecutá **`cura/instalar-cura.bat`**. Copia el perfil de la F192, sus dos boquillas y el complemento X3GWriter modificado.
4. Abrí Cura y agregá la impresora: **Preferencias → Configurar Cura → Impresoras → Agregar** → impresora sin conexión en red → **WEEDO → WEEDO F192**.
5. **No instales ni actualices X3GWriter desde el Marketplace**: se perderían las modificaciones para la F192.

¿Sin Windows o sin permiso para ejecutar el `.bat`? Copiá a mano, dentro de `%APPDATA%\cura\<versión>\`:
`cura/definitions/*` → `definitions`, `cura/extruders/*` → `extruders`, y el contenido de `cura/plugins/X3GWriter/` → `plugins\X3GWriter\X3GWriter\`.

## 2. Elegir la boquilla

| En Cura | En la máquina | Motor |
|---|---|---|
| Extrusor 1 | Boquilla **derecha** (T0) | A |
| Extrusor 2 | Boquilla **izquierda** (T1) | B |

- **Habilitar o deshabilitar una boquilla:** menú **Ajustes → Extrusor derecho (T0)** o **Extrusor izquierdo (T1)** → *Habilitar / Deshabilitar extrusor*. Si una boquilla no anda bien, deshabilitala y Cura manda todo a la otra.
- **Elegir con qué boquilla va una pieza:** clic derecho sobre la pieza → *Imprimir modelo seleccionado con* (o Ctrl+1 / Ctrl+2).
- El perfil calienta y purga solo la boquilla que se usa, y deja la otra apagada.
- Con la **boquilla izquierda** el firmware corre el cabezal 35 mm para que la pieza caiga en el mismo lugar. Por eso **no pongas piezas en los últimos 4 cm del lado donde la máquina hace home en X**.
- **Doble color (las dos a la vez):** todavía no está calibrado. Por ahora, una boquilla por impresión.

## 3. Preparar la pieza

Valores de partida para filamento de 1,75 mm:

| Ajuste | PLA | ABS |
|---|---|---|
| Temperatura de boquilla | 200 °C | 230 °C |
| Temperatura de cama | 60 °C | 100 °C |
| Altura de capa | 0,2 mm | 0,2 mm |
| Paredes | 0,8 mm (2 líneas) | 0,8 mm |
| Relleno | 15–20 % | 15–20 % |
| Velocidad de impresión | 40–50 mm/s | 40 mm/s |
| Primera capa | 20–25 mm/s | 20 mm/s |
| Adherencia | Borde (brim) | Balsa (raft) o borde, puerta cerrada |
| Retracción | 1–1,5 mm a 25 mm/s | 1–1,5 mm a 25 mm/s |
| Ventilador de capa | 100 % desde la capa 2 | Apagado |

Después de cortar (*Segmentación*): **Guardar en disco** → en *Tipo de archivo* elegí **X3G**. Usá un **nombre corto, sin espacios ni acentos** (por ejemplo `LLAVERO1.x3g`).

## 4. Tarjeta SD

- Tarjeta SD común de **2 GB o menos** (sirven las micro SD con adaptador).
- Formato **FAT** (en Windows: clic derecho sobre la tarjeta → Formatear → Sistema de archivos *FAT*).
- Copiá los `.x3g` **en la raíz**, no dentro de carpetas.

## 5. Imprimir

1. Filamento cargado y **pasando por el sensor de filamento**: si el sensor no lo detecta, la impresora se pausa sola al principio.
2. Tarjeta en la ranura → **Imprimir** → **Tarjeta SD** → tocá el archivo.
3. Qué vas a ver al arrancar: home de X e Y (esquina), el cabezal va **al centro**, la cama sube hasta el sensor, baja y vuelve a subir despacio; el cabezal va adelante, calienta cama y boquilla, hace una línea de purga al frente y empieza la pieza.
4. Para frenar: **Cancelar** en la pantalla.

El home de Z se hace con el cabezal en el centro porque **el sensor de Z va montado en el carro**: en la esquina queda fuera de la cama y la cama subiría sin frenar. El perfil ya lo hace así; si usás otro inicio de impresión, respetalo.

## 6. Nivelar la cama

Desde la pantalla, con la opción de nivelación de plataforma: en cada punto, ajustá las tuercas de la cama hasta que una hoja de papel pase entre la boquilla y la cama con un leve roce. Repetí la vuelta completa dos veces.

## 7. Problemas frecuentes

| Síntoma | Causa | Qué hacer |
|---|---|---|
| Al elegir el archivo vuelve al menú principal | El `.x3g` no tiene la marca que exige el firmware de Weedo | Generarlo con este perfil de Cura (el complemento la agrega). Los archivos chiquitos (menos de 512 bytes) andan igual y confunden. |
| La lista de la tarjeta está vacía o no la lee | Tarjeta grande o formato FAT32/exFAT | Tarjeta de 2 GB o menos en FAT; archivos en la raíz. |
| Al hacer home la cama sube sin frenar y el motor fuerza | El sensor de Z no detecta: cabezal fuera de la cama, o cable/conector del sensor | Usar el inicio de este perfil (home de Z en el centro). Revisar el cable del sensor y que esté en el conector Z-MIN de la placa. |
| Al nivelar, la cama baja cuando debería subir, o el motor Z vibra | Un cable del motor Z cortado o flojo (nos pasó) | Revisar con multímetro las dos bobinas del motor Z en el conector de la placa. |
| Se pausa sola al principio | El sensor de filamento no detecta filamento | Pasar el filamento por el sensor; revisar su cable. |
| Imprime con la boquilla equivocada | Extrusor asignado en Cura | Ver la sección 2. |
| Piezas con la mitad de altura o aplastadas; extrusión rara | Configuración interna cambiada (típico después de conectar ReplicatorG) | Ejecutar `eeprom/verificar-eeprom.bat` y, si hay diferencias, `eeprom/restaurar-eeprom.bat`. |
| Pronterface u OctoPrint no conectan | La F192 usa un protocolo binario (s3g), no G-code | Usar la SD, o `herramientas/imprimir-por-usb.ps1`. |

## 8. Configuración interna (EEPROM)

La impresora guarda su configuración (pasos por mm, corriente de motores, home, velocidades) en una memoria interna. En [`eeprom/`](eeprom/):

- **`verificar-eeprom.bat`**: lee la configuración por USB, guarda un respaldo y la compara con la de fábrica. No cambia nada.
- **`restaurar-eeprom.bat`**: reescribe solo las partes que difieren de fábrica y verifica releyendo. No toca contadores de horas ni la calibración fina entre boquillas.

Necesitás la impresora encendida, conectada por USB, y Cura/ReplicatorG cerrados. El chip USB de la placa es un CH340 o un Prolific PL2303 según la unidad; Windows 10/11 suele instalar el driver solo.

## 9. Firmware (solo para rescates)

La mayoría de las escuelas **no necesita tocar el firmware**. Solo si la máquina perdió el firmware o le grabaron otro. Ver [`firmware/LEEME.md`](firmware/LEEME.md): primero se hace un respaldo del firmware actual y después se graba el original con avrdude, usando el botón de reset de la impresora.

## 10. Imprimir por cable USB (opcional)

`herramientas/imprimir-por-usb.ps1` manda un `.x3g` por el cable, sin tarjeta. La PC tiene que quedar encendida y conectada durante toda la impresión. Sirve para pruebas; para imprimir de verdad es más seguro usar la SD.

---

## Créditos y licencias

Armado en 2026 a partir de máquinas reales de escuelas técnicas, desensamblando el firmware de fábrica y reconstruyendo la documentación perdida de Weedo. Detalle de licencias de cada parte en [LICENCIAS.md](LICENCIAS.md). Correcciones y aportes: abrir un *issue* en este repositorio.

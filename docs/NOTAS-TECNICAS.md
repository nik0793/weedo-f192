# Notas técnicas de la Weedo F192

Lo que sabemos de la máquina por dentro y cómo lo averiguamos. Todo lo que dice "verificado" se comprobó en dos máquinas reales (septiembre 2026); lo demás está marcado.

## Hardware

- Placa clon de la **MakerBot Mightyboard** con microcontrolador **ATmega1280**, bootloader tipo Arduino (stk500v1, 57600 baudios) y chip USB-serie CH340 o Prolific PL2303 según la unidad.
- Dos extrusores (A = derecho, B = izquierdo), cama calefaccionada de 280 × 200 mm, altura 200 mm, origen de coordenadas en el centro de la cama.
- **Sensor de Z montado en el carro** (no en la cama): el home de Z tiene que hacerse con el cabezal sobre la cama; en la esquina de home de X/Y el sensor queda afuera y la cama sube sin frenar.
- Sensor de filamento y pantalla táctil a color (display DGUS por puerto serie).

## Firmware

- **Sailfish 7.6 modificado por Weedo** (el nombre interno del proyecto es "Wiiboox One"): responde s3g versión 706, variante 0x80. Imprime archivos `.x3g` (formato binario de MakerBot) y habla el protocolo binario s3g por USB a 115200 baudios. Por eso Pronterface y OctoPrint no sirven.
- El firmware original ya no se descarga de ningún lado; el de este repositorio se leyó de una máquina de fábrica (ver `firmware/`).
- El firmware "F192C V2.1.0" que todavía circula es **Marlin 1.1** compilado para otra variante: no es el de esta máquina.

## Por qué los archivos `.x3g` "vuelven al menú" (verificado)

Síntoma: al elegir un `.x3g` en la pantalla, la máquina vuelve al menú principal sin moverse ni mostrar error. Los archivos de menos de 512 bytes sí imprimen.

Causa, leída en el desensamblado del firmware de fábrica:

1. Mientras imprime desde la SD, la función `runCommandSlice` de Weedo agrega un control que Sailfish no tiene: al llegar a la segunda orden, si una marca interna (RAM 0x07AE) está en cero, apaga calefactores y motores, vacía el buffer y cancela el trabajo, en silencio (dirección 0x051AC del flash).
2. Esa marca solo la pone el comando x3g **157 (Stream Version)** cuando su primer byte de datos es igual al byte **0x0211 de la EEPROM, que de fábrica vale 5** (manejador en 0x04FEE). Un 157 con otro valor cancela en el acto.
3. **GPX, el conversor que usan todos los complementos de Cura, nunca escribe el comando 157.** El Cura WEEDO original sí lo escribía.
4. Los archivos de 512 bytes o menos se salvan por casualidad: entran enteros en el buffer de comandos (que mide 512 bytes), la lectura de la SD termina antes de ejecutar la primera orden y el control ya no corre.

Solución: anteponer a cada `.x3g` estos 21 bytes (comando 157, versión 5, tipo de máquina Replicator 0xD314):

```
9D 05 00 00 00 00 00 00 14 D3 00 00 00 00 00 00 00 00 00 00 00
```

El complemento X3GWriter de `cura/plugins/` ya lo hace. Dato curioso: una vez que se imprimió un archivo con la marca correcta, la marca queda puesta hasta apagar la máquina, y en ese mismo encendido también imprimen archivos sin ella.

Otro detalle del mismo código: desde la orden 200 de cada trabajo el firmware revisa el sensor de filamento y, si no detecta filamento, pausa la impresión.

## Configuración interna (EEPROM)

Mapa de Sailfish 7.6 más una zona propia de Weedo. Valores de fábrica, idénticos en las dos máquinas revisadas:

| Dirección | Contenido | Fábrica |
|---|---|---|
| 0x0002 | Inversión de ejes | 0x17 |
| 0x0004 | Inversión de finales de carrera | 0x9F |
| 0x0006 | Corriente de motores X Y Z A B (digipot) | 118 / 118 / 80 / 118 / 118 |
| 0x000C | Dirección de home | 0x1B (X e Y al máximo, Z al mínimo) |
| 0x000E | Posición de home X Y (pasos) | 15062 / 10120 (160 mm / 107,5 mm) |
| 0x0022 | Nombre | `WEEDO F192` |
| 0x0162 | Desviación entre boquillas X Y Z (pasos) | calibración de cada máquina (pocos pasos) |
| 0x018C | Largo de ejes (mm) | 244 / 215 / 190 |
| 0x01A4 | Pasos por mm × 1.000.000 | 94,139704 / 94,139704 / **800** / 93,275202 / 93,275202 |
| 0x01F4 | Velocidades máximas (mm/min) | 18000 / 18000 / 1170 / 1600 / 1600 |
| 0x0210 | Weedo: sensor de filamento habilitado (0 = sí) | 0 |
| 0x0211 | Weedo: versión de `.x3g` exigida | **5** |
| 0x0F93 | Sistema de offsets entre boquillas | 1 (nuevo) |

**ReplicatorG 0040 pisa la EEPROM al conectarse** con el perfil "The Replicator Dual": escribe pasos por mm de Z = 400, extrusores = 96,275201 y 20 bytes desde 0x0210 (donde cree que están los largos de ejes), incluido el 0x0211. Resultado: capas a la mitad de altura y todos los `.x3g` rechazados. Se arregla con `eeprom/restaurar-eeprom.bat`.

**Nunca escribir la EEPROM con avrdude.** El bootloader de esta placa duplica la dirección al leer la EEPROM: el volcado sale intercalado (solo los bloques pares de 8 bytes, y la mitad alta es espejo). Leerla y escribirla siempre por s3g (comandos 12 y 13), como hacen los scripts de `eeprom/`.

## Dos boquillas (verificado en el desensamblado, 0x0DDAC)

Al cambiar a la boquilla izquierda (comando 134, herramienta 1) el firmware suma al X de cada movimiento `35,0 mm × pasos/mm − desviación guardada en 0x0162`, y al Y `− desviación de 0x0166`. Weedo cambió la constante de 33 mm (MakerBot) a **35 mm**. Así la pieza cae en el mismo lugar con cualquiera de las dos boquillas, pero con la izquierda el carro necesita 35 mm más hacia el lado del home de X. GPX no aplica desplazamientos propios, por eso en Cura el *nozzle offset* va en 0.

## Tarjeta SD

- Funciona siempre con **SD común de 2 GB en FAT16** (verificado).
- Con una de **32 GB en FAT32** respondió "sistema de archivos no reconocido" (código 4, verificado por USB). El firmware sí tiene compilado el soporte SDHC y FAT32, así que otras tarjetas grandes podrían andar: **no probado**.
- Por USB el firmware no lista ni arranca archivos de la SD (responde "archivo no encontrado"): esa función del protocolo quedó sin conectar en la versión de Weedo.

## Inicio de impresión que usa el perfil

```
G162 X Y F2500        ; home X e Y (esquina)
G92 X160 Y107.5       ; posición de home de fábrica
G1 X0 Y0 F3000        ; cabezal al centro (el sensor de Z está en el carro)
G161 Z F1100          ; home Z: la cama sube hasta el sensor
G92 Z-5
G1 Z0 F1100
G161 Z F100           ; home Z lento
M132 Z A B            ; solo Z A B: X e Y ya quedaron definidos
T{initial_extruder_nr}; boquilla elegida en Cura
... calentar, línea de purga al frente, imprimir
```

Error que hay que evitar: `M132 X Y Z A B` después de mover el cabezal al centro le dice al firmware que está en la esquina de home, y el siguiente movimiento termina contra el extremo opuesto.

## Cómo se averiguó

- Lectura del firmware y la EEPROM de una máquina de fábrica con avrdude (flash) y por s3g (EEPROM).
- Desensamblado del firmware con un desensamblador AVR propio y comparación con el código fuente de Sailfish 7.6 (commit de enero de 2014).
- Archivos de prueba de tamaño creciente en la máquina real: los de 512 bytes o menos imprimían, cualquiera más grande volvía al menú, hasta encontrar el control del comando 157.
- Documentación archivada de Weedo en el Wayback Machine (weedo.ltd y la wiki weedotina2.com).

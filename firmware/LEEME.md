# Firmware de la Weedo F192

**Solo para rescates.** Si la impresora arranca y muestra su menú, no hace falta tocar el firmware. Para problemas de impresión, primero revisá la configuración con `../eeprom/verificar-eeprom.bat`.

## Archivos

| Archivo | Para qué |
|---|---|
| `F192_FIRMWARE.hex` | Firmware original de fábrica (Sailfish 7.6 de Weedo), sin el bootloader. Es el que se graba por USB. |
| `F192_COMPLETO_CON_BOOTLOADER.hex` | Imagen completa de la memoria, bootloader incluido. Solo para grabar con un programador ISP (USBasp o similar) si el bootloader también se perdió. |
| `respaldar-firmware.bat` | Lee el firmware actual de la impresora y lo guarda. Solo lee. |
| `grabar-firmware.bat` | Graba `F192_FIRMWARE.hex` en la impresora. |

Los dos `.hex` se leyeron de una máquina de fábrica y se comprobó que son idénticos byte a byte al volcado original.

## Qué hace falta

1. **avrdude** para Windows: [github.com/avrdudes/avrdude/releases](https://github.com/avrdudes/avrdude/releases), archivo `avrdude-v8.x-windows-x64.zip`. Descomprimilo en una carpeta `avrdude` dentro de esta carpeta (tiene que quedar `firmware\avrdude\avrdude.exe`).
2. Cable USB y el driver del chip USB de la placa (CH340 o Prolific PL2303).
3. Un destornillador para apretar el botón **RESET** del lateral derecho de la impresora.

## Procedimiento

1. Cerrá Cura, ReplicatorG y cualquier programa que use el puerto de la impresora.
2. Ejecutá **`respaldar-firmware.bat`**. Te pide el puerto COM. Cuando lo indique: mantené apretado el RESET, apretá una tecla y **soltá el reset enseguida** (1 o 2 segundos). Si dice "not in sync" o "timeout", repetí: es cuestión de tiempo entre la tecla y soltar el botón. Guarda `respaldo_flash_<fecha>.hex`.
3. Ejecutá **`grabar-firmware.bat`** con el mismo movimiento del RESET. avrdude verifica lo grabado al terminar.
4. Apagá y prendé la impresora, y revisá la configuración con `../eeprom/verificar-eeprom.bat`.

**Estado:** la lectura del firmware por este método está probada en dos máquinas. **La grabación no se probó todavía** en una máquina real; el bootloader queda intacto, así que si falla se puede reintentar.

## Advertencias

- **La EEPROM nunca se graba con avrdude**: el bootloader de esta placa la lee y escribe mal. La configuración se maneja con los scripts de `../eeprom/`.
- No grabes el firmware "F192C V2.1.0" que circula por internet: es Marlin, para otra variante.

# Licencias

Este repositorio junta piezas de distinto origen; cada una conserva su licencia.

| Parte | Origen | Licencia |
|---|---|---|
| Manual, guía rápida y notas (`README.md`, `manual/`, `docs/`, `LEEME.md`) | Este proyecto | [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/deed.es) |
| Scripts propios (`cura/instalar-cura.*`, `eeprom/`, `firmware/*.bat`, `herramientas/`) y perfil de Cura (`cura/definitions`, `cura/extruders`) | Este proyecto | GPL-3.0 (ver `LICENSE`) |
| Complemento `cura/plugins/X3GWriter/` | [X3GWriter](https://github.com/Ghostkeeper/X3GWriter) de Ghostkeeper, modificado para la F192 (cambios en `CAMBIOS-WEEDO.md`) | AGPL-3.0 (ver su `LICENSE`) |
| Binarios `gpx`, `gpx.exe`, `gpx_macos` dentro del complemento | [GPX](https://github.com/markwal/GPX) de Mark Walker y colaboradores, tal como vienen en X3GWriter 1.1.13 | GPL-2.0 |
| Firmware `firmware/*.hex` | Sailfish ([jetty840/Sailfish-MightyBoardFirmware](https://github.com/jetty840/Sailfish-MightyBoardFirmware)), derivado del firmware de MakerBot, modificado por Weedo / Wiiboox; bootloader tipo ATmegaBOOT | GPL-3.0 (Sailfish). Ver nota. |
| EEPROM de referencia `eeprom/EEPROM_F192_FABRICA.bin` | Leída de una máquina de fábrica; se borraron los nombres de archivos impresos | Datos de configuración |

**Nota sobre el firmware.** Es una copia exacta del que traían las máquinas, leída con avrdude. Sailfish es software libre bajo GPL-3.0, pero Weedo nunca publicó el código fuente de sus modificaciones y su sitio ya no existe, así que acá solo podemos ofrecer el binario y el enlace al código de Sailfish. Se publica para que las escuelas puedan reparar sus máquinas. Si sos titular de derechos y tenés una objeción, abrí un *issue* y lo resolvemos.

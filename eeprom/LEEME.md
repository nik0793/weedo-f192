# Configuración interna (EEPROM) de la Weedo F192

La impresora guarda en una memoria interna los pasos por mm de cada eje, la corriente de los motores, la posición de home, las velocidades máximas y un dato propio de Weedo que decide qué archivos `.x3g` acepta. Si alguien la conectó a ReplicatorG o a MakerBot Desktop, esos programas la modifican sin avisar.

| Archivo | Para qué |
|---|---|
| `verificar-eeprom.bat` | Lee la configuración por USB, guarda un respaldo en `respaldos/` y la compara con la de fábrica. **No cambia nada.** |
| `restaurar-eeprom.bat` | Igual que el anterior y además reescribe solo las zonas que difieren, verificando cada una. |
| `eeprom-f192.ps1` | El script que usan los dos `.bat` (opciones: `-Restaurar`, `-SoloRespaldo`, `-Port COM5`). |
| `EEPROM_F192_FABRICA.bin` | Configuración de fábrica de referencia (4096 bytes), leída de una máquina sin tocar. |

## Uso

1. Impresora encendida y conectada por USB. Cura y ReplicatorG cerrados.
2. Doble clic en `verificar-eeprom.bat`. Encuentra la impresora sola en los puertos COM.
3. Si aparece alguna zona **DISTINTO**, ejecutá `restaurar-eeprom.bat`.
4. Apagá y prendé la impresora.

Qué zonas compara: sentido de ejes, finales de carrera, corriente de motores, home, nombre, cantidad de extrusores, aceleración, largo de ejes, pasos por mm, velocidades máximas, la zona Weedo (sensor de filamento y versión de `.x3g` = 5) y el sistema de offsets entre boquillas. No toca los contadores de horas y filamento, la calibración fina entre boquillas ni los perfiles de precalentado.

Probado sin conexión contra las lecturas de dos máquinas: detecta justo las zonas que cambió ReplicatorG (pasos por mm y zona Weedo) y ninguna en la máquina sana. La lectura y escritura por USB que usa son las mismas con las que se reparó una de las máquinas.

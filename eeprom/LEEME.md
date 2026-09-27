# Configuración interna (EEPROM) de la Weedo F192

La impresora guarda en una memoria interna los pasos por mm de cada eje, la corriente de los motores, la posición de home, las velocidades máximas y un dato propio de Weedo que decide qué archivos `.x3g` acepta. Si alguien la conectó a ReplicatorG o a MakerBot Desktop, esos programas la modifican sin avisar.

| Archivo | Para qué |
|---|---|
| `verificar-eeprom.bat` | Lee la configuración por USB, guarda un respaldo en `respaldos/` y la compara con la de fábrica. **No cambia nada.** |
| `restaurar-eeprom.bat` | Igual que el anterior y además reescribe solo las zonas que difieren, verificando cada una. Antes de escribir muestra el puerto y el nombre de la máquina y pide escribir `SI`. |
| `eeprom-f192.ps1` | El script que usan los dos `.bat`. Opciones: `-Restaurar`, `-SoloRespaldo`, `-Port COM5` (puerto fijo) y `-Desde archivo.bin` (usar otro archivo como referencia, por ejemplo un respaldo). |
| `EEPROM_F192_FABRICA.bin` | Configuración de fábrica de referencia (4096 bytes), leída por USB de una máquina que nadie había modificado. Único cambio respecto de la lectura: se pusieron en cero los bytes 0x022E–0x0266, donde la impresora guarda el nombre del último archivo impreso (el script no compara ni escribe esa zona). |

## Uso

1. Impresora encendida y conectada por USB. Cura y ReplicatorG cerrados. **Conectá solo esta impresora a la PC**: si responde más de una, el script se detiene y pide indicar el puerto (`restaurar-eeprom.bat -Port COM5`).
2. Doble clic en `verificar-eeprom.bat`. Encuentra la impresora sola en los puertos COM.
3. Si aparece alguna zona **DISTINTO**, ejecutá `restaurar-eeprom.bat` y escribí `SI` cuando lo pida. Si solo difieren los *datos para reanudar*, el script lo aclara: la configuración está bien y no hace falta restaurar.
4. Apagá y prendé la impresora.

Para deshacer una restauración, volvé a grabar el respaldo que se guardó antes de escribir:

```
powershell -ExecutionPolicy Bypass -File eeprom-f192.ps1 -Restaurar -Desde respaldos\EEPROM_<fecha>.bin
```

Qué zonas compara: sentido de ejes, finales de carrera, corriente de motores, home, nombre, cantidad de extrusores, aceleración, largo de ejes, pasos por mm, velocidades máximas, la zona Weedo (sensor de filamento y versión de `.x3g` = 5; y los datos para reanudar una impresión cortada, 0x0212–0x0223, donde ReplicatorG también escribe) y el sistema de offsets entre boquillas. No toca los contadores de horas y filamento, la calibración fina entre boquillas ni los perfiles de precalentado.

Probado sin conexión contra las lecturas reales de dos máquinas: en la máquina sana no marca nada; en la que había modificado ReplicatorG marca los pasos por mm y las dos zonas Weedo (los 20 bytes desde 0x0210); en esa misma máquina, después de repararla, solo marca un byte de los datos para reanudar y avisa que no hace falta restaurar. La lectura y escritura por USB que usa son las mismas con las que se reparó una de las máquinas. **El script completo todavía no se ejecutó contra una impresora.**

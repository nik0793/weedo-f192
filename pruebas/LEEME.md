# Archivos de prueba

Listos para copiar a la raíz de la tarjeta SD (2 GB o menos, formato FAT) e imprimir desde la pantalla.

| Archivo | Qué hace | Calienta |
|---|---|---|
| `MOVIM.X3G` | Home de X e Y, cabezal al centro, home de Z, baja la cama 20 mm, va adelante a la izquierda, vuelve al centro y baja la cama. Sirve para comprobar el home sin gastar filamento. | No |
| `DADO_D.X3G` | Cubo de 20 mm (`cubo_20mm.stl`) con la **boquilla derecha**. PLA, boquilla 200 °C, cama 60 °C, perfil Draft 0,2 mm con borde; Cura estima 22 minutos. | Sí |
| `DADO_I.X3G` | El mismo cubo con la **boquilla izquierda**. | Sí |
| `cubo_20mm.stl` | El cubo, para practicar en Cura (es el que aparece en las capturas de la guía). | — |

`MOVIM.X3G` se probó en la máquina: terminó en el centro, con el home de Z correcto.

Los dos dados se generaron con **Guardar en disco** en Cura 5.12, con el perfil y el complemento de este repositorio, deshabilitando la otra boquilla. Se revisaron decodificándolos: marca de versión 5 al principio, home con la boquilla derecha, cambio a la izquierda recién después del home (solo en `DADO_I`), purga de 13 mm al frente y extrusión igual a la que calcula Cura. **Todavía no se imprimieron en la máquina.**

Si `MOVIM.X3G` también vuelve al menú principal al elegirlo, la configuración interna de la impresora fue cambiada (típico después de conectar ReplicatorG): ver [`../eeprom/LEEME.md`](../eeprom/LEEME.md).

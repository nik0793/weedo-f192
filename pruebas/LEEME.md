# Archivos de prueba

Listos para copiar a la raíz de la tarjeta SD (2 GB o menos, formato FAT) e imprimir desde la pantalla. Generados con el perfil de este repositorio.

| Archivo | Qué hace | Calienta |
|---|---|---|
| `MOVIM.X3G` | Home de X e Y, cabezal al centro, home de Z, baja la cama 20 mm, va adelante a la izquierda, vuelve al centro y baja la cama. Sirve para comprobar el home sin gastar filamento. | No |
| `DADO_D.X3G` | Dado de calibración de 20 mm con la **boquilla derecha**. PLA, boquilla 200 °C, cama 60 °C, unos 25 minutos. | Sí |
| `DADO_I.X3G` | El mismo dado con la **boquilla izquierda**. | Sí |

`MOVIM.X3G` se probó en la máquina (terminó en el centro, con el home de Z correcto). Los dados usan ese mismo inicio y el contenido que genera Cura con este perfil.

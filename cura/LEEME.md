# Perfil de Cura para la Weedo F192

Ejecutar `instalar-cura.bat` con Cura cerrado (después de haberlo abierto una vez). Instala:

- `definitions/weedo_f192.def.json`: la impresora (280 × 200 × 200 mm, origen al centro, pasos por mm de fábrica, inicio con home de Z en el centro).
- `extruders/`: boquilla derecha (T0, extrusor 1) e izquierda (T1, extrusor 2).
- `plugins/X3GWriter/`: complemento que guarda en formato X3G, modificado para el firmware de Weedo (ver `CAMBIOS-WEEDO.md`).

No actualizar X3GWriter desde el Marketplace de Cura: la versión original no sirve para la F192.

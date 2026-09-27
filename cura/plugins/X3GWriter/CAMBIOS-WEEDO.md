# Cambios respecto de X3GWriter 1.1.13

Complemento original: [Ghostkeeper/X3GWriter](https://github.com/Ghostkeeper/X3GWriter) v1.1.13 (AGPL-3.0). Cambios para la Weedo F192, septiembre 2026:

1. `write(..., **kwargs)`: Cura 5.12 pasa argumentos nuevos (`mime_type`) y la versión original fallaba al guardar.
2. `machine_type = r1d` en la configuración de GPX: base Replicator 1 Dual; los pasos por mm y velocidades reales de la F192 se escriben después y la sobreescriben.
3. **Cabecera de 21 bytes (comando x3g 157, versión 5)** al principio de cada archivo: sin ella el firmware de Weedo cancela en silencio cualquier archivo de más de 512 bytes (ver `docs/NOTAS-TECNICAS.md`).
4. La boquilla que no se usa queda con temperatura 0: sin esto GPX la calentaba a la temperatura de espera (175 °C) al cambiar de herramienta.
5. **Orden de los cambios de herramienta**: el home se hace siempre con T0 y el cambio a la boquilla elegida va justo después de recuperar el home (comando 144). Si el cambio a T1 queda antes del home, el firmware anula el desplazamiento de 35 mm de la boquilla izquierda y la pieza sale corrida. Solo se revisa el principio del archivo (hasta el home); el resto se copia tal cual.
6. **`recalculate_5d = 0`**: GPX usa la extrusión que calcula Cura. El original le pedía a GPX que la recalculara (distancia × boquilla × altura de capa): la primera capa salía calculada con la altura por defecto de GPX (0,34 mm) y no con la de Cura (con capa inicial de 0,2 mm, cerca de 70 % más de material), aparecían retracciones sueltas en medio de los tramos y los ajustes de flujo y ancho de línea de Cura no tenían efecto. Comprobado decodificando los archivos de `pruebas/`: purga de 13,0 mm y sección de extrusión de 0,3 × 0,4 mm en la primera capa y 0,2 × 0,4 mm en las siguientes, igual que Cura.

## Diferencias exactas

```diff
@@ -27,7 +27,7 @@
 	\param mode The output mode to use. This is ignored, since it has no
 	meaning. X3G is always a binary file.
 	"""
-	def write(self, stream, nodes, mode = MeshWriter.OutputMode.TextMode):
+	def write(self, stream, nodes, mode = MeshWriter.OutputMode.TextMode, **kwargs):
 		# Write the g-code to a temporary file.
 		temp_gcode = None
 		try:
@@ -83,7 +83,7 @@
 						os.remove(temp_gcode.name)
 					return False
 				# Read from the temporary X3G file and put it in the stream.
-				stream.write(open(temp_x3g.name, "rb").read())
+				stream.write(WEEDO_X3G_HEADER + weedo_fix_tool_changes(open(temp_x3g.name, "rb").read()))  # WEEDO F192: el firmware exige un comando 157 (stream version) con version high = 5 en los 2 primeros comandos
 
 			except EnvironmentError as e:
 				if temp_x3g:
@@ -216,10 +216,11 @@
 		parser = configparser.ConfigParser()
 
 		parser.add_section("printer")  # Slicer data.
+		parser["printer"]["machine_type"] = "r1d"  # WEEDO F192: base Replicator 1 Dual (cabecera x3g 157 y tipo de bot); los pasos/mm reales se sobreescriben abajo.
 		parser["printer"]["ditto_printing"] = "0"  # Whether to duplicate the extrusion with all extruders. Cura doesn't support this.
 		parser["printer"]["build_progress"] = "1"  # Let GPX calculate the percent done counter shown on the printer's display.
 		parser["printer"]["packing_density"] = "1.0"  # TODO: 1.0 is the default but I don't know what this means. It's not documented.
-		parser["printer"]["recalculate_5d"] = "1"  # Whether to re-compute the extrusion widths. Please do! We assume that GPX knows better what to do with the feedrate than Cura.
+		parser["printer"]["recalculate_5d"] = "0"  # WEEDO F192: GPX usa la E que calcula Cura. Con "1" la recalcula como distancia x boquilla x altura de capa (la primera capa con 0,34 mm por defecto: sobreextruida) e ignora el flujo y los anchos de Cura.
 		parser["printer"]["nominal_filament_diameter"] = str(extruder_stacks[0].getProperty("material_diameter", "value"))  # Use the first extruder since it was used for actual slicing, not just matching materials.
 		parser["printer"]["gcode_flavor"] = "makerbot" if global_stack.getProperty("machine_gcode_flavor", "value") == "Makerbot" else "reprap"  # Default to RepRap for all other types.
 		parser["printer"]["build_platform_temperature"] = str(global_stack.getProperty("material_bed_temperature", "value"))  # Is different for layer 0 though!
@@ -272,6 +273,17 @@
 			parser["left"]["actual_filament_diameter"] = str(extruder_stacks[1].getProperty("material_diameter", "value"))
 			parser["left"]["packing_density"] = "1.0"
 
+		# WEEDO F192: la boquilla que no se usa queda apagada. Sin esto GPX la pone en "standby" (175 C) al cambiar de herramienta.
+		try:
+			used = set(int(stack.getMetaDataEntry("position")) for stack in application.getExtruderManager().getUsedExtruderStacks())
+		except Exception:
+			used = None
+		if used:
+			for index, section in ((0, "right"), (1, "left")):
+				if parser.has_section(section) and index not in used:
+					parser[section]["active_temperature"] = "0"
+					parser[section]["standby_temperature"] = "0"
+
 		parser.add_section("machine")
 		parser["machine"]["nominal_filament_diameter"] = str(extruder_stacks[0].getProperty("material_diameter", "value"))  # Seems to be the same as the printer category.
 		parser["machine"]["packing_density"] = "1.0"  # Seems to be the same as the printer category.
@@ -281,3 +293,53 @@
 		#parser["machine"]["steps_per_mm"] = ?  # I think the steps_per_mm per axis will override this.
 
 		parser.write(cfg_stream)
+
+
+# --- WEEDO F192: comando 157 Stream Version de 21 bytes. El firmware Weedo (Sailfish 7.6 fork) cancela en silencio
+# cualquier archivo SD de mas de 512 bytes que no traiga un 157 cuyo primer byte de payload sea igual a EEPROM[0x0211] (5 de fabrica).
+# GPX 2.6 nunca lo escribe. Descubierto desensamblando el firmware (septiembre 2026). ---
+WEEDO_X3G_HEADER = bytes([157, 5, 0, 0, 0, 0, 0, 0, 0x14, 0xD3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
+
+
+# --- WEEDO F192: orden de los cambios de herramienta respecto del home. Cura emite "T1" antes del inicio de impresion
+# y GPX lo traduce a un cambio de herramienta (comando 134) antes del home. Con T1 activo, el firmware interpreta la
+# posicion fijada en el home (G92) en el sistema de la boquilla izquierda y se pierde su desplazamiento de 35 mm:
+# la pieza saldria corrida. Se sacan los 134 anteriores al primer "recuperar home" (144), se fuerza T0 antes del home
+# y se vuelve a la herramienta elegida justo despues del 144. ---
+_WEEDO_X3G_LEN = {131: 7, 132: 7, 133: 4, 134: 1, 135: 5, 137: 1, 139: 24, 140: 20, 141: 5, 142: 25, 143: 1, 144: 1, 145: 2, 146: 5, 147: 5, 148: 4, 150: 2, 151: 1, 152: 1, 154: 1, 155: 31, 156: 1, 157: 20, 158: 4}
+
+def _weedo_x3g_commands(data):
+	commands = []
+	i = 0
+	while i < len(data):
+		code = data[i]
+		if code in _WEEDO_X3G_LEN:
+			length = 1 + _WEEDO_X3G_LEN[code]
+		elif code == 136:
+			length = 4 + data[i + 3]
+		elif code in (149, 153):
+			length = data.index(bytes([0]), i + 5) - i + 1
+		else:
+			break  # orden desconocida (GPX escribe consultas sueltas por un M105): de aca en adelante el archivo queda igual
+		commands.append(data[i:i + length])
+		i += length
+	return commands, i
+
+def weedo_fix_tool_changes(data):
+	commands, end = _weedo_x3g_commands(data)
+	recall = next((k for k, c in enumerate(commands) if c[0] == 144), None)
+	home = next((k for k, c in enumerate(commands) if c[0] in (131, 132)), None)
+	if recall is None or home is None or home > recall:
+		return data
+	early_tools = [c[1] for c in commands[:recall] if c[0] == 134]
+	late_change = any(c[0] == 134 for c in commands[recall + 1:recall + 3])
+	out = []
+	for k, c in enumerate(commands):
+		if k < recall and c[0] == 134:
+			continue
+		if k == home:
+			out.append(bytes([134, 0]))  # home siempre con la boquilla derecha (T0)
+		out.append(c)
+		if k == recall and early_tools and early_tools[-1] != 0 and not late_change:
+			out.append(bytes([134, early_tools[-1]]))  # recien ahora la boquilla elegida
+	return bytes().join(out) + data[end:]
```

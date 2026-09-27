# Cambios respecto de X3GWriter 1.1.13

Complemento original: [Ghostkeeper/X3GWriter](https://github.com/Ghostkeeper/X3GWriter) v1.1.13 (AGPL-3.0). Cambios para la Weedo F192, septiembre 2026:

1. `write(..., **kwargs)`: Cura 5.12 pasa argumentos nuevos (`mime_type`) y la versión original fallaba al guardar.
2. `machine_type = r1d` en la configuración de GPX: base Replicator 1 Dual; los pasos por mm y velocidades reales de la F192 se escriben después y la sobreescriben.
3. **Cabecera de 21 bytes (comando x3g 157, versión 5)** al principio de cada archivo: sin ella el firmware de Weedo cancela en silencio cualquier archivo de más de 512 bytes (ver `docs/NOTAS-TECNICAS.md`).
4. La boquilla que no se usa queda con temperatura 0: sin esto GPX la calentaba a la temperatura de espera (175 °C) al cambiar de herramienta.

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
+				stream.write(WEEDO_X3G_HEADER + open(temp_x3g.name, "rb").read())  # WEEDO F192: el firmware exige un comando 157 (stream version) con version high = 5 en los 2 primeros comandos
 
 			except EnvironmentError as e:
 				if temp_x3g:
@@ -216,6 +216,7 @@
 		parser = configparser.ConfigParser()
 
 		parser.add_section("printer")  # Slicer data.
+		parser["printer"]["machine_type"] = "r1d"  # WEEDO F192: base Replicator 1 Dual (cabecera x3g 157 y tipo de bot); los pasos/mm reales se sobreescriben abajo.
 		parser["printer"]["ditto_printing"] = "0"  # Whether to duplicate the extrusion with all extruders. Cura doesn't support this.
 		parser["printer"]["build_progress"] = "1"  # Let GPX calculate the percent done counter shown on the printer's display.
 		parser["printer"]["packing_density"] = "1.0"  # TODO: 1.0 is the default but I don't know what this means. It's not documented.
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
@@ -281,3 +293,9 @@
 		#parser["machine"]["steps_per_mm"] = ?  # I think the steps_per_mm per axis will override this.
 
 		parser.write(cfg_stream)
+
+
+# --- WEEDO F192: comando 157 Stream Version de 21 bytes. El firmware Weedo (Sailfish 7.6 fork) cancela en silencio
+# cualquier archivo SD de mas de 512 bytes que no traiga un 157 cuyo primer byte de payload sea igual a EEPROM[0x0211] (5 de fabrica).
+# GPX 2.6 nunca lo escribe. Descubierto desensamblando el firmware (septiembre 2026). ---
+WEEDO_X3G_HEADER = bytes([157, 5, 0, 0, 0, 0, 0, 0, 0x14, 0xD3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
```

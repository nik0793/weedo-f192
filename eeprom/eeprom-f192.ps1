# Verifica (y si se pide, restaura) la configuracion interna (EEPROM) de una Weedo F192 comparandola con la de fabrica.
# Se comunica por USB con el protocolo propio de la impresora (s3g). No usa avrdude: por el bootloader, avrdude corrompe la EEPROM.
#
#   Solo verificar (no escribe nada):   powershell -ExecutionPolicy Bypass -File eeprom-f192.ps1
#   Restaurar lo que difiere:           powershell -ExecutionPolicy Bypass -File eeprom-f192.ps1 -Restaurar
#   Solo hacer una copia de respaldo:   powershell -ExecutionPolicy Bypass -File eeprom-f192.ps1 -SoloRespaldo
#   Puerto fijo (opcional):             ... -Port COM5
#
# Antes de escribir guarda un respaldo completo en la carpeta "respaldos" (EEPROM_<fecha>.bin).
# No toca: contadores de horas y filamento, calibracion fina entre boquillas, perfiles de precalentado.
param([string]$Port = "", [switch]$Restaurar, [switch]$SoloRespaldo)
$ErrorActionPreference = "Stop"
. "$PSScriptRoot\..\herramientas\s3g-comun.ps1"

$refPath = Join-Path $PSScriptRoot "EEPROM_F192_FABRICA.bin"
$ref = [System.IO.File]::ReadAllBytes($refPath)
if ($ref.Length -ne 4096) { throw "La EEPROM de referencia debe medir 4096 bytes." }

# Zonas de configuracion que se comparan (mapa de Sailfish 7.6 + zona propia de Weedo)
$zonas = @(
  @{ Off = 0x0002; Len = 32; Nombre = "sentido de ejes, finales de carrera, corriente de motores, direccion y posicion de home" },
  @{ Off = 0x0022; Len = 16; Nombre = "nombre de la maquina" },
  @{ Off = 0x0042; Len = 1;  Nombre = "cantidad de extrusores" },
  @{ Off = 0x016E; Len = 28; Nombre = "aceleracion" },
  @{ Off = 0x018C; Len = 20; Nombre = "largo de los ejes" },
  @{ Off = 0x01A4; Len = 20; Nombre = "pasos por mm (X Y Z y extrusores)" },
  @{ Off = 0x01D8; Len = 28; Nombre = "aceleracion (2)" },
  @{ Off = 0x01F4; Len = 20; Nombre = "velocidades maximas" },
  @{ Off = 0x0210; Len = 4;  Nombre = "zona Weedo: sensor de filamento y version de archivo x3g (debe ser 5)" },
  @{ Off = 0x0F93; Len = 1;  Nombre = "sistema de desplazamiento entre boquillas" }
)

$sp = Open-Impresora $Port
try {
  $actual = Read-Eeprom $sp 0 4096
  $dirResp = Join-Path $PSScriptRoot "respaldos"
  if (-not (Test-Path $dirResp)) { New-Item -ItemType Directory -Path $dirResp | Out-Null }
  $respaldo = Join-Path $dirResp ("EEPROM_{0}.bin" -f (Get-Date -Format "yyyyMMdd_HHmmss"))
  [System.IO.File]::WriteAllBytes($respaldo, $actual)
  Write-Host ("Respaldo de la EEPROM actual: {0}" -f $respaldo)
  if ($SoloRespaldo) { return }

  # Resumen legible de lo mas importante
  $pasos = 0..4 | ForEach-Object { [BitConverter]::ToUInt32($actual, 0x01A4 + 4 * $_) / 1e6 }
  Write-Host ("Pasos por mm X Y Z A B: {0}" -f (($pasos | ForEach-Object { "{0:0.######}" -f $_ }) -join " / "))
  Write-Host ("Corriente de motores X Y Z A B: {0}" -f (($actual[6..10]) -join " / "))
  Write-Host ("Version de archivo x3g esperada (0x0211): {0}" -f $actual[0x0211])

  $difieren = @()
  foreach ($z in $zonas) {
    $a = $actual[$z.Off..($z.Off + $z.Len - 1)]
    $b = $ref[$z.Off..($z.Off + $z.Len - 1)]
    $igual = $true
    for ($i = 0; $i -lt $z.Len; $i++) { if ($a[$i] -ne $b[$i]) { $igual = $false; break } }
    if ($igual) {
      Write-Host ("  OK       {0}" -f $z.Nombre)
    } else {
      Write-Host ("  DISTINTO {0}" -f $z.Nombre) -ForegroundColor Yellow
      Write-Host ("           actual  : {0}" -f (ConvertTo-HexText $a))
      Write-Host ("           fabrica : {0}" -f (ConvertTo-HexText $b))
      $difieren += $z
    }
  }

  if ($difieren.Count -eq 0) { Write-Host "La configuracion coincide con la de fabrica."; return }
  if (-not $Restaurar) {
    Write-Host ("{0} zona(s) distinta(s). Para restaurarlas, ejecutar restaurar-eeprom.bat (o este script con -Restaurar)." -f $difieren.Count)
    return
  }

  foreach ($z in $difieren) {
    $datos = [byte[]]$ref[$z.Off..($z.Off + $z.Len - 1)]
    Write-Eeprom $sp $z.Off $datos
    $releido = Read-Eeprom $sp $z.Off $z.Len
    $ok = $true
    for ($i = 0; $i -lt $z.Len; $i++) { if ($releido[$i] -ne $datos[$i]) { $ok = $false; break } }
    if ($ok) { Write-Host ("  RESTAURADO {0}" -f $z.Nombre) -ForegroundColor Green }
    else { Write-Host ("  NO VERIFICO {0}" -f $z.Nombre) -ForegroundColor Red }
  }
  Write-Host "Listo. Apagar y prender la impresora para que tome los valores."
} finally {
  $sp.Close()
}

# Muestra el estado de la Weedo F192 por USB (firmware, trabajo en curso, posicion) o cancela el trabajo.
#   powershell -ExecutionPolicy Bypass -File estado-impresora.ps1            (estado)
#   powershell -ExecutionPolicy Bypass -File estado-impresora.ps1 -Cancelar  (cancela el trabajo y apaga calefactores)
param([string]$Port = "", [switch]$Cancelar)
$ErrorActionPreference = "Stop"
. "$PSScriptRoot\s3g-comun.ps1"
$estados = @{ 0 = "sin trabajo"; 1 = "imprimiendo"; 2 = "termino bien"; 3 = "en pausa"; 4 = "cancelado"; 5 = "cancelando" }
$sp = Open-Impresora $Port
try {
  if ($Cancelar) { $r = Send-S3g $sp ([byte[]](7)); Write-Host ("Cancelar: {0}" -f $(if ($r[0] -eq 0x81) { "OK" } else { "codigo 0x{0:X2}" -f $r[0] })) ; Start-Sleep -Milliseconds 500 }
  $r = Send-S3g $sp ([byte[]](24))
  Write-Host ("Trabajo: {0}, {1} h {2} min, {3} ordenes ejecutadas" -f $estados[[int]$r[1]], $r[2], $r[3], [BitConverter]::ToUInt32($r, 4))
  $n = Send-S3g $sp ([byte[]](20)); $nombre = ""; if ($n.Length -gt 1) { $nombre = [System.Text.Encoding]::ASCII.GetString($n, 1, $n.Length - 1).TrimEnd([char]0) }
  if ($nombre) { Write-Host ("Archivo: {0}" -f $nombre) }
  $p = Send-S3g $sp ([byte[]](21))
  $x = [BitConverter]::ToInt32($p, 1); $y = [BitConverter]::ToInt32($p, 5); $z = [BitConverter]::ToInt32($p, 9)
  Write-Host ("Posicion segun el firmware: X {0:n2} mm, Y {1:n2} mm, Z {2:n2} mm" -f ($x / 94.139704), ($y / 94.139704), ($z / 800))
} finally { $sp.Close() }

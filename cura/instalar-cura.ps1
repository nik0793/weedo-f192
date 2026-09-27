# Instala el perfil WEEDO F192 y el plugin X3GWriter modificado en UltiMaker Cura 5.x (Windows).
# Requisito: haber abierto Cura al menos una vez (para que exista la carpeta de configuracion) y tenerlo CERRADO.
#   powershell -ExecutionPolicy Bypass -File instalar-cura.ps1
#   (opcional) -Destino "C:\Users\...\AppData\Roaming\cura\5.12"  para elegir la carpeta a mano
param([string]$Destino = "")
$ErrorActionPreference = "Stop"
$origen = $PSScriptRoot

if (-not $Destino) {
  $base = Join-Path $env:APPDATA "cura"
  if (-not (Test-Path $base)) { throw "No existe $base. Instala UltiMaker Cura 5, abrilo una vez, cerralo y volve a ejecutar esto." }
  $versiones = Get-ChildItem $base -Directory | Where-Object { $_.Name -match '^\d+\.\d+$' } |
    Sort-Object { [version]$_.Name } -Descending
  if (-not $versiones) { throw "No encontre ninguna carpeta de version de Cura dentro de $base." }
  $Destino = $versiones[0].FullName
}
Write-Host ("Carpeta de Cura: {0}" -f $Destino)

$cura = Get-Process | Where-Object { $_.ProcessName -match 'cura' } | Select-Object -First 1
if ($cura) { throw "Cura esta abierto ($($cura.ProcessName)). Cerralo y volve a ejecutar." }

$dDef = Join-Path $Destino "definitions"
$dExt = Join-Path $Destino "extruders"
$dPlg = Join-Path $Destino "plugins\X3GWriter\X3GWriter"
foreach ($d in @($dDef, $dExt, $dPlg)) { if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null } }

Copy-Item (Join-Path $origen "definitions\weedo_f192.def.json") $dDef -Force
Copy-Item (Join-Path $origen "extruders\weedo_f192_extruder_0.def.json") $dExt -Force
Copy-Item (Join-Path $origen "extruders\weedo_f192_extruder_1.def.json") $dExt -Force
Copy-Item (Join-Path $origen "plugins\X3GWriter\*") $dPlg -Recurse -Force

Write-Host "Instalado:"
Write-Host ("  {0}" -f (Join-Path $dDef "weedo_f192.def.json"))
Write-Host ("  {0} (2 extrusores)" -f $dExt)
Write-Host ("  {0}" -f $dPlg)
Write-Host "Abri Cura y agrega la impresora: Preferencias > Configurar Cura > Impresoras > Agregar > Agregar una impresora sin conexion en red > WEEDO > WEEDO F192."
Write-Host "Importante: no actualices ni reinstales X3GWriter desde el Marketplace (se perderian los cambios para la F192)."

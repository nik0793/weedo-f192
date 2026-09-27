# Imprime un archivo .x3g mandandolo por el cable USB (como hacia ReplicatorG), sin usar la tarjeta SD.
# La PC tiene que quedar encendida y conectada durante TODA la impresion: si se corta el cable o se apaga la PC, la impresion queda a medias.
#   powershell -ExecutionPolicy Bypass -File imprimir-por-usb.ps1 -Archivo ..\pruebas\MOVIM.X3G
param([Parameter(Mandatory = $true)][string]$Archivo, [string]$Port = "")
$ErrorActionPreference = "Stop"
. "$PSScriptRoot\s3g-comun.ps1"

$largos = @{ 131 = 7; 132 = 7; 133 = 4; 134 = 1; 135 = 5; 137 = 1; 139 = 24; 140 = 20; 141 = 5; 142 = 25; 143 = 1; 144 = 1; 145 = 2; 146 = 5; 147 = 5; 148 = 4; 150 = 2; 151 = 1; 152 = 1; 154 = 1; 155 = 31; 156 = 1; 157 = 20; 158 = 4 }
$data = [System.IO.File]::ReadAllBytes((Resolve-Path $Archivo))
$ordenes = New-Object System.Collections.Generic.List[byte[]]
$i = 0
while ($i -lt $data.Length) {
  $c = [int]$data[$i]
  if ($largos.ContainsKey($c)) { $L = 1 + $largos[$c] }
  elseif ($c -eq 136) { $L = 4 + [int]$data[$i + 3] }
  elseif ($c -eq 149 -or $c -eq 153) { $j = $i + 5; while ($data[$j] -ne 0) { $j++ }; $L = $j - $i + 1 }
  else { throw ("El archivo no parece un .x3g valido (orden desconocida {0} en el byte {1})." -f $c, $i) }
  $ordenes.Add($data[$i..($i + $L - 1)]); $i += $L
}
Write-Host ("{0}: {1} ordenes" -f $Archivo, $ordenes.Count)

$sp = Open-Impresora $Port
$sp.ReadTimeout = 5000
$enviadas = 0; $inicio = Get-Date
try {
  foreach ($o in $ordenes) {
    if ($o[0] -eq 157) { continue }   # la cabecera 157 solo la exige la lectura desde SD
    while ($true) {
      $r = Send-S3g $sp $o
      if ($r[0] -eq 0x81) { break }
      if ($r[0] -eq 0x80 -or $r[0] -eq 0x82) { Start-Sleep -Milliseconds 60; continue }   # buffer lleno: esperar
      if ($r[0] -eq 0x89) { throw "La impresora cancelo el trabajo." }
      throw ("Respuesta inesperada 0x{0:X2} a la orden {1}" -f $r[0], $o[0])
    }
    $enviadas++
    if (($enviadas % 1000) -eq 0) { Write-Host ("  {0}/{1} ordenes ({2:n0} min)" -f $enviadas, $ordenes.Count, ((Get-Date) - $inicio).TotalMinutes) }
  }
  Write-Host ("LISTO: {0} ordenes enviadas. La impresora termina de ejecutar las ultimas que tiene en memoria." -f $enviadas)
} finally { $sp.Close() }

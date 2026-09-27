# Funciones comunes para hablar con la Weedo F192 por USB (protocolo s3g de MakerBot/Sailfish, 115200 baudios).
# Lo usan los demas scripts con:  . "$PSScriptRoot\..\herramientas\s3g-comun.ps1"

function Get-Crc8([byte[]]$data) {
  # CRC8 iButton/Dallas (polinomio 0x8C reflejado), el que usa s3g
  $crc = 0
  foreach ($b in $data) {
    $inb = [int]$b
    for ($i = 0; $i -lt 8; $i++) {
      $mix = ($crc -bxor $inb) -band 1
      $crc = $crc -shr 1
      if ($mix) { $crc = $crc -bxor 0x8C }
      $inb = $inb -shr 1
    }
  }
  return [byte]$crc
}

function Send-S3g($sp, [byte[]]$payload) {
  # Manda un paquete s3g y devuelve la respuesta (byte 0 = codigo: 0x81 OK, 0x80/0x82 buffer lleno, 0x89 trabajo cancelado)
  $pkt = New-Object System.Collections.Generic.List[byte]
  $pkt.Add(0xD5); $pkt.Add([byte]$payload.Length)
  foreach ($b in $payload) { $pkt.Add($b) }
  $pkt.Add((Get-Crc8 $payload))
  $sp.DiscardInBuffer()
  $sp.Write($pkt.ToArray(), 0, $pkt.Count)
  $h = $sp.ReadByte(); $t = 0
  while ($h -ne 0xD5 -and $t -lt 64) { $h = $sp.ReadByte(); $t++ }
  if ($h -ne 0xD5) { throw "La impresora no respondio (sin cabecera 0xD5)." }
  $len = $sp.ReadByte()
  $resp = New-Object byte[] $len
  $got = 0
  while ($got -lt $len) { $got += $sp.Read($resp, $got, $len - $got) }
  $crc = $sp.ReadByte()
  if ($crc -ne (Get-Crc8 $resp)) { throw "Respuesta con CRC incorrecto." }
  return $resp
}

function Open-Impresora([string]$Port = "") {
  # Abre el puerto de la impresora. Si no se indica, prueba todos los puertos COM y se queda con el que responde como Sailfish.
  $candidatos = @()
  if ($Port) { $candidatos = @($Port) } else { $candidatos = [System.IO.Ports.SerialPort]::GetPortNames() | Sort-Object -Unique }
  foreach ($p in $candidatos) {
    $sp = New-Object System.IO.Ports.SerialPort $p, 115200, "None", 8, "One"
    $sp.ReadTimeout = 3000; $sp.WriteTimeout = 3000; $sp.DtrEnable = $false; $sp.RtsEnable = $false
    try {
      $sp.Open(); Start-Sleep -Milliseconds 2000; $sp.DiscardInBuffer()
      $v = Send-S3g $sp ([byte[]](0, 100, 0))
      if ($v[0] -eq 0x81) {
        $ver = $v[1] + 256 * $v[2]
        Write-Host ("Impresora encontrada en {0} (firmware s3g {1})" -f $p, $ver)
        return $sp
      }
      $sp.Close()
    } catch {
      try { $sp.Close() } catch {}
    }
  }
  throw "No encontre la impresora. Revisa que este encendida, conectada por USB, con el driver instalado, y que ReplicatorG/Cura no tengan el puerto abierto."
}

function Read-Eeprom($sp, [int]$off, [int]$len) {
  # Comando s3g 12 (READ_EEPROM), de a 16 bytes
  $buf = New-Object byte[] $len
  $done = 0
  while ($done -lt $len) {
    $n = [Math]::Min(16, $len - $done)
    $o = $off + $done
    $r = Send-S3g $sp ([byte[]](12, [byte]($o -band 0xFF), [byte](($o -shr 8) -band 0xFF), [byte]$n))
    if ($r[0] -ne 0x81) { throw ("Error leyendo EEPROM en 0x{0:X4} (codigo 0x{1:X2})" -f $o, $r[0]) }
    [Array]::Copy($r, 1, $buf, $done, $n)
    $done += $n
  }
  return $buf
}

function Write-Eeprom($sp, [int]$off, [byte[]]$data) {
  # Comando s3g 13 (WRITE_EEPROM), de a 16 bytes
  $done = 0
  while ($done -lt $data.Length) {
    $n = [Math]::Min(16, $data.Length - $done)
    $o = $off + $done
    $payload = New-Object System.Collections.Generic.List[byte]
    $payload.Add(13); $payload.Add([byte]($o -band 0xFF)); $payload.Add([byte](($o -shr 8) -band 0xFF)); $payload.Add([byte]$n)
    for ($i = 0; $i -lt $n; $i++) { $payload.Add($data[$done + $i]) }
    $r = Send-S3g $sp $payload.ToArray()
    if ($r[0] -ne 0x81) { throw ("Error escribiendo EEPROM en 0x{0:X4} (codigo 0x{1:X2})" -f $o, $r[0]) }
    $done += $n
  }
}

function ConvertTo-HexText([byte[]]$b) { return (($b | ForEach-Object { "{0:X2}" -f $_ }) -join " ") }

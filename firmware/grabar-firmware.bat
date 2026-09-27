@echo off
setlocal
title Grabar firmware original en la Weedo F192
set AQUI=%~dp0
set HEX=%AQUI%F192_FIRMWARE.hex
set AVR=
if exist "%AQUI%avrdude\avrdude.exe" set AVR=%AQUI%avrdude\avrdude.exe
if "%AVR%"=="" for %%X in (avrdude.exe) do if not "%%~$PATH:X"=="" set AVR=%%~$PATH:X
if "%AVR%"=="" (
  echo No encuentro avrdude.exe. Bajalo de https://github.com/avrdudes/avrdude/releases
  echo ^(archivo avrdude-v8.x-windows-x64.zip^) y descomprimilo en la carpeta "avrdude" junto a este archivo.
  pause
  exit /b 1
)
echo ====================================================================
echo  ATENCION: esto REEMPLAZA el firmware de la impresora.
echo  Usalo solo si la maquina perdio el firmware o quedo con uno equivocado.
echo  Antes: ejecuta respaldar-firmware.bat y guarda el respaldo.
echo  Este procedimiento NO fue probado todavia en una maquina real.
echo  NO graba la EEPROM (la configuracion se revisa con ..\eeprom\verificar-eeprom.bat).
echo ====================================================================
set /p SEGURO=Escribi SI para continuar: 
if /i not "%SEGURO%"=="SI" exit /b 1
echo Puertos serie presentes:
powershell -NoProfile -Command "[System.IO.Ports.SerialPort]::GetPortNames() -join ', '"
set /p PORT=Puerto COM de la impresora (ej. COM5): 
echo.
echo  Mantene apretado el RESET, apreta una tecla y SOLTA el reset enseguida.
pause
"%AVR%" -c stk500v1 -P %PORT% -b 57600 -p m1280 -D -U flash:w:"%HEX%":i
if errorlevel 1 (
  echo FALLO. El bootloader queda intacto: se puede reintentar con el mismo procedimiento.
) else (
  echo LISTO. avrdude verifico lo grabado. Apagar y prender la impresora.
)
pause

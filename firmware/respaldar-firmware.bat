@echo off
setlocal
title Respaldo del firmware de la Weedo F192 (solo lectura)
set AQUI=%~dp0
set AVR=
if exist "%AQUI%avrdude\avrdude.exe" set AVR=%AQUI%avrdude\avrdude.exe
if "%AVR%"=="" for %%X in (avrdude.exe) do if not "%%~$PATH:X"=="" set AVR=%%~$PATH:X
if "%AVR%"=="" (
  echo No encuentro avrdude.exe. Bajalo de https://github.com/avrdudes/avrdude/releases
  echo ^(archivo avrdude-v8.x-windows-x64.zip^) y descomprimilo en la carpeta "avrdude" junto a este archivo.
  pause
  exit /b 1
)
echo Puertos serie presentes:
powershell -NoProfile -Command "[System.IO.Ports.SerialPort]::GetPortNames() -join ', '"
set /p PORT=Puerto COM de la impresora (ej. COM5): 
for /f %%d in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmm"') do set FECHA=%%d
set SALIDA=%AQUI%respaldo_flash_%FECHA%.hex
echo.
echo  1. Cerra Cura, ReplicatorG y cualquier programa que use el puerto.
echo  2. Impresora encendida y conectada por USB.
echo  3. Mantene apretado el boton RESET (lateral derecho, con un destornillador).
echo  4. Con el reset apretado apreta una tecla aca y SOLTA el reset enseguida (1 o 2 segundos).
echo     Esto SOLO LEE el firmware; no cambia nada en la impresora.
pause
"%AVR%" -c stk500v1 -P %PORT% -b 57600 -p m1280 -U flash:r:"%SALIDA%":i
if errorlevel 1 (
  echo FALLO. Si dice "not in sync" o "timeout", repetir: reset apretado, tecla, soltar.
) else (
  echo LISTO: %SALIDA%
)
pause

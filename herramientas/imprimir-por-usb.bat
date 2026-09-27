@echo off
title Imprimir por USB - Weedo F192
rem Arrastrar el archivo .x3g sobre este .bat, o abrirlo y arrastrar el archivo a la ventana.
set "ARCH=%~1"
if not defined ARCH set /p "ARCH=Arrastra aca el archivo .x3g y apreta Enter: "
if not defined ARCH goto :sinarchivo
set ARCH=%ARCH:"=%
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0imprimir-por-usb.ps1" -Archivo "%ARCH%" %2 %3
pause
exit /b
:sinarchivo
echo No se indico ningun archivo.
pause

@echo off
title Cancelar impresion - Weedo F192
rem Cancela el trabajo en curso por USB y apaga los calefactores.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0estado-impresora.ps1" -Cancelar %*
pause

@echo off
title Restaurar configuracion (EEPROM) Weedo F192
echo Esto compara la configuracion de la impresora con la de fabrica y reescribe solo lo que difiere.
echo Antes guarda un respaldo en la carpeta "respaldos".
pause
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0eeprom-f192.ps1" -Restaurar %*
pause

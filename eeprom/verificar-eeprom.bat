@echo off
title Verificar configuracion (EEPROM) Weedo F192
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0eeprom-f192.ps1" %*
pause

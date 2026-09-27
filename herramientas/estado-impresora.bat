@echo off
title Estado de la Weedo F192
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0estado-impresora.ps1" %*
pause

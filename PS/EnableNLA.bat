@echo off
powershell -ver 3 -Command "Start-Process powershell.exe -Verb Runas -ArgumentList '-ExecutionPolicy RemoteSigned', '-NoExit', '-File C:\PortalPms\Support\EnableNLA.ps1', '-Action "%1"'"

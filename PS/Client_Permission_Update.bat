@echo OFF
@cd /d "%~dp0"

powershell -ver 2 -Command "Start-Process powershell.exe -Verb Runas -ArgumentList '-ExecutionPolicy RemoteSigned', '-NoExit', '-File .\Client_Permissions_Update.ps1'"
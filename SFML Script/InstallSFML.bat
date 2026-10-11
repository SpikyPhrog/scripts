@ECHO OFF

set ScriptPath=%~dp0
Powershell.exe -executionpolicy remotesigned -file "%ScriptPath%\InstallSFML.ps1"

pause
@ECHO OFF

echo Change Monitors
echo.

choice /c 12 /n /m "Choose between 1 or 2 Monitors"
set Input=%errorlevel%

if %Input% equ 1 goto 1
if %Input% equ 2 goto 2

:1
echo Internal
DisplaySwitch.exe /internal
exit

:2
echo Extend
DisplaySwitch.exe /extend
exit
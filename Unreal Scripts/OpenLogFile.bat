SETLOCAL
@ECHO OFF
set ScriptPath=%~dp0
set ProjectExtension=*.exe
set ProjectString=%ScriptPath%%ProjectExtension%

FOR /f "delims=" %%a IN ('findstr /i /m "string" %ProjectString%') DO (
 set ProjectName=%%~na
)
set LogPath=%ScriptPath%%ProjectName%\Saved\Logs\%ProjectName%.log

START "" notepad.exe %LogPath%

ENDLOCAL
@echo off
title Teleprompter
cd /d "%~dp0"

set "PORT=8777"
set "URL=http://127.0.0.1:%PORT%/teleprompter.html"

if not exist teleprompter.html (
  echo.
  echo   teleprompter.html is not next to this script.
  echo   If you are running this from inside the zip, extract the whole
  echo   folder first, then run start-teleprompter.bat from the extracted copy.
  echo.
  pause
  exit /b
)

rem --- pick something to serve the folder with.
rem --- Each candidate is actually RUN, not just looked up: Windows ships a
rem --- fake "python.exe" (Microsoft Store stub) that passes a PATH check
rem --- but cannot run anything.
set "SRV="
python -V >nul 2>&1 && set "SRV=python -m http.server %PORT% --bind 127.0.0.1"
if not defined SRV py -3 -V >nul 2>&1 && set "SRV=py -3 -m http.server %PORT% --bind 127.0.0.1"
if not defined SRV node -v >nul 2>&1 && set "SRV=node server.js %PORT%"
if not defined SRV goto noserver

rem --- prefer Chrome, then Edge, then the default browser --------------------
set "BROWSER="
if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" set "BROWSER=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
if not defined BROWSER if exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" set "BROWSER=%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
if not defined BROWSER if exist "%LocalAppData%\Google\Chrome\Application\chrome.exe" set "BROWSER=%LocalAppData%\Google\Chrome\Application\chrome.exe"
if not defined BROWSER if exist "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe" set "BROWSER=%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"
if not defined BROWSER if exist "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe" set "BROWSER=%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"

echo.
echo   Starting the teleprompter server...
start "TeleprompterServer" /min cmd /c %SRV%

rem --- only open the browser once the server actually answers (max ~10s)
set /a TRIES=0
:waitloop
curl.exe -s -o nul --max-time 1 "%URL%" 2>nul && goto up
set /a TRIES+=1
if %TRIES% geq 10 goto down
timeout /t 1 /nobreak >nul
goto waitloop

:up
echo   Server is up at %URL%
if not defined TP_NOBROWSER (
  if defined BROWSER (
    start "" "%BROWSER%" "%URL%"
  ) else (
    start "" "%URL%"
  )
)
echo.
echo   The page is open in your browser.
echo   Allow the microphone when it asks - that is how it follows your reading.
echo.
echo   Press any key here to stop the server.
pause >nul
taskkill /fi "WINDOWTITLE eq TeleprompterServer*" /t /f >nul 2>&1
exit /b

:down
taskkill /fi "WINDOWTITLE eq TeleprompterServer*" /t /f >nul 2>&1
echo.
echo   The server did not start. Running it here so you can see the error:
echo.
echo     %SRV%
echo.
%SRV%
echo.
echo   Common causes: the port is in use, or Python/Node is broken.
echo   Fix: install Python from python.org (tick "Add python.exe to PATH")
echo   or Node from nodejs.org, then run this again.
echo.
pause
exit /b

:noserver
echo.
echo   Neither Python nor Node.js is installed, so the page cannot be served.
echo   (Note: Windows sometimes has a fake "python" that only opens the
echo   Microsoft Store - that one does not count.)
echo.
echo   Install ONE of these, then run this file again:
echo     Python  https://www.python.org/downloads/   (tick "Add python.exe to PATH")
echo     Node    https://nodejs.org/
echo.
pause

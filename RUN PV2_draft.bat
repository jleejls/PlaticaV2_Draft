@echo off
setlocal

REM ============================================================
REM  Run Platica V2 Local
REM  This BAT file does NOT call Chrome.
REM  Put this file in the main Platica V2 folder,
REM  right beside index.html.
REM ============================================================

cd /d "%~dp0"

if not exist "%~dp0index.html" (
    echo.
    echo ERROR: index.html was not found in this folder:
    echo %~dp0
    echo.
    echo Put this BAT file in the main Platica V2 folder,
    echo right beside index.html, then run it again.
    echo.
    pause
    exit /b
)

REM Open the Platica V2 start page without naming Chrome.
REM Windows will use the normal default handler for .html files.
start "" "%~dp0index.html"

REM Close this black command window.
exit

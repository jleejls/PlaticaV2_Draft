@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ================================================================
REM  remove_all_png_from_program.bat
REM  Purpose: Remove every .png file from this program folder tree.
REM
REM  HOW TO USE:
REM  1. Put this BAT file in the TOP folder of the program.
REM     Example: PlaticaV2_Draft\
REM  2. Double-click it, or right-click and Run.
REM  3. It will search this folder and every subfolder.
REM  4. It will delete files ending in .png or .PNG.
REM
REM  This does NOT convert files. It only removes PNG files.
REM  This does NOT touch JPG, JPEG, M4A, MP3, HTML, CSS, or JS files.
REM ================================================================

set "ROOT=%~dp0"
set "LOG=%ROOT%png_removal_log.txt"

cd /d "%ROOT%"

echo =============================================================== > "%LOG%"
echo PNG removal started: %date% %time% >> "%LOG%"
echo Root folder: %ROOT% >> "%LOG%"
echo =============================================================== >> "%LOG%"
echo. >> "%LOG%"

echo.
echo This will remove EVERY PNG file under:
echo %ROOT%
echo.
echo A log will be written here:
echo %LOG%
echo.

set /p ANSWER=Type YES to remove all PNG files: 
if /I not "%ANSWER%"=="YES" (
  echo.
  echo Cancelled. No files were removed.
  echo Cancelled by user: %date% %time% >> "%LOG%"
  pause
  exit /b 0
)

echo.
echo Searching for PNG files...
echo.

set /a COUNT=0

for /r "%ROOT%" %%F in (*.png) do (
  set /a COUNT+=1
  echo Deleting: %%F
  echo Deleting: %%F >> "%LOG%"
  del /f /q "%%F" >> "%LOG%" 2>&1
)

echo. >> "%LOG%"
echo =============================================================== >> "%LOG%"
echo PNG removal finished: %date% %time% >> "%LOG%"
echo Files attempted: %COUNT% >> "%LOG%"
echo =============================================================== >> "%LOG%"

echo.
echo Done. PNG files attempted for removal: %COUNT%
echo See log:
echo %LOG%
echo.
pause
endlocal

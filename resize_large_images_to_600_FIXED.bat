@echo off
setlocal EnableExtensions

REM ============================================================
REM resize_large_images_to_600_FIXED.bat
REM
REM Put this BAT file in the ROOT folder of the program/project.
REM It uses the BAT file's own folder as the root, even if Windows
REM starts the command window somewhere else.
REM
REM It searches downward through all subfolders.
REM It resizes JPG, JPEG, PNG, BMP, and GIF images IN PLACE.
REM It makes NO backup.
REM ============================================================

pushd "%~dp0"

echo.
echo Root folder being processed:
echo %CD%
echo.
echo This will overwrite large images in place.
echo No backup will be created.
echo.

set "PSFILE=%TEMP%\resize_large_images_to_600_%RANDOM%%RANDOM%.ps1"

> "%PSFILE%" echo Add-Type -AssemblyName System.Drawing
>> "%PSFILE%" echo $root = (Get-Location).Path
>> "%PSFILE%" echo $validExtensions = @('.jpg', '.jpeg', '.png', '.bmp', '.gif')
>> "%PSFILE%" echo $files = Get-ChildItem -LiteralPath $root -Recurse -File ^| Where-Object { $validExtensions -contains $_.Extension.ToLower() }
>> "%PSFILE%" echo $total = 0
>> "%PSFILE%" echo $resized = 0
>> "%PSFILE%" echo $skipped = 0
>> "%PSFILE%" echo $errors = 0
>> "%PSFILE%" echo foreach ($file in $files) {
>> "%PSFILE%" echo     $total++
>> "%PSFILE%" echo     $img = $null
>> "%PSFILE%" echo     $ms = $null
>> "%PSFILE%" echo     $bitmap = $null
>> "%PSFILE%" echo     $graphics = $null
>> "%PSFILE%" echo     try {
>> "%PSFILE%" echo         $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
>> "%PSFILE%" echo         $ms = New-Object System.IO.MemoryStream @(,$bytes)
>> "%PSFILE%" echo         $img = [System.Drawing.Image]::FromStream($ms)
>> "%PSFILE%" echo         $w = $img.Width
>> "%PSFILE%" echo         $h = $img.Height
>> "%PSFILE%" echo         if ($w -ge 1024) {
>> "%PSFILE%" echo             $newW = 600
>> "%PSFILE%" echo             $newH = [int][Math]::Round($h * ($newW / $w))
>> "%PSFILE%" echo         } elseif ($h -ge 1024) {
>> "%PSFILE%" echo             $newH = 600
>> "%PSFILE%" echo             $newW = [int][Math]::Round($w * ($newH / $h))
>> "%PSFILE%" echo         } else {
>> "%PSFILE%" echo             $skipped++
>> "%PSFILE%" echo             Write-Host ("SKIP  {0}  {1}x{2}" -f $file.FullName, $w, $h)
>> "%PSFILE%" echo             continue
>> "%PSFILE%" echo         }
>> "%PSFILE%" echo         $bitmap = New-Object System.Drawing.Bitmap $newW, $newH, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
>> "%PSFILE%" echo         $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
>> "%PSFILE%" echo         $graphics.Clear([System.Drawing.Color]::Transparent)
>> "%PSFILE%" echo         $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
>> "%PSFILE%" echo         $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
>> "%PSFILE%" echo         $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
>> "%PSFILE%" echo         $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
>> "%PSFILE%" echo         $graphics.DrawImage($img, 0, 0, $newW, $newH)
>> "%PSFILE%" echo         $graphics.Dispose()
>> "%PSFILE%" echo         $graphics = $null
>> "%PSFILE%" echo         $img.Dispose()
>> "%PSFILE%" echo         $img = $null
>> "%PSFILE%" echo         $ms.Dispose()
>> "%PSFILE%" echo         $ms = $null
>> "%PSFILE%" echo         $ext = $file.Extension.ToLower()
>> "%PSFILE%" echo         $tmp = $file.FullName + ".tmp" + $file.Extension
>> "%PSFILE%" echo         if ($ext -eq '.png') {
>> "%PSFILE%" echo             $bitmap.Save($tmp, [System.Drawing.Imaging.ImageFormat]::Png)
>> "%PSFILE%" echo         } elseif ($ext -eq '.bmp') {
>> "%PSFILE%" echo             $bitmap.Save($tmp, [System.Drawing.Imaging.ImageFormat]::Bmp)
>> "%PSFILE%" echo         } elseif ($ext -eq '.gif') {
>> "%PSFILE%" echo             $bitmap.Save($tmp, [System.Drawing.Imaging.ImageFormat]::Gif)
>> "%PSFILE%" echo         } else {
>> "%PSFILE%" echo             $bitmap.Save($tmp, [System.Drawing.Imaging.ImageFormat]::Jpeg)
>> "%PSFILE%" echo         }
>> "%PSFILE%" echo         $bitmap.Dispose()
>> "%PSFILE%" echo         $bitmap = $null
>> "%PSFILE%" echo         Move-Item -LiteralPath $tmp -Destination $file.FullName -Force
>> "%PSFILE%" echo         $resized++
>> "%PSFILE%" echo         Write-Host ("DONE  {0}  {1}x{2}  --^>  {3}x{4}" -f $file.FullName, $w, $h, $newW, $newH)
>> "%PSFILE%" echo     } catch {
>> "%PSFILE%" echo         $errors++
>> "%PSFILE%" echo         Write-Host ("ERROR {0}  {1}" -f $file.FullName, $_.Exception.Message)
>> "%PSFILE%" echo     } finally {
>> "%PSFILE%" echo         if ($graphics -ne $null) { $graphics.Dispose() }
>> "%PSFILE%" echo         if ($bitmap -ne $null) { $bitmap.Dispose() }
>> "%PSFILE%" echo         if ($img -ne $null) { $img.Dispose() }
>> "%PSFILE%" echo         if ($ms -ne $null) { $ms.Dispose() }
>> "%PSFILE%" echo     }
>> "%PSFILE%" echo }
>> "%PSFILE%" echo Write-Host ""
>> "%PSFILE%" echo Write-Host ("Images checked: " + $total)
>> "%PSFILE%" echo Write-Host ("Images resized: " + $resized)
>> "%PSFILE%" echo Write-Host ("Images skipped:  " + $skipped)
>> "%PSFILE%" echo Write-Host ("Errors:          " + $errors)

powershell -NoProfile -ExecutionPolicy Bypass -File "%PSFILE%"

del "%PSFILE%" >nul 2>nul

echo.
echo Finished. Look above for DONE, SKIP, or ERROR lines.
echo.
pause

popd
endlocal

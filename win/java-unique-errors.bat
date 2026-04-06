@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
  echo arg 1 must be an existing file
  exit /b 1
)
if not exist "%~1" (
  echo arg 1 must be an existing file
  exit /b 1
)

set "fname=%~nx1"
for /f "delims=" %%t in ('powershell -NoProfile -Command "(Get-Date).ToString('yyyyMMdd_HHmmss')"') do set "NOW=%%t"
set "result=%NOW%_%fname%.unique.err"

powershell -NoProfile -Command "Get-Content -Path '%~1' | Where-Object { $_ -match 'ERROR' } | ForEach-Object { ($_ -replace '^\S+\s+\S+\s+\S+\s+','').Trim() } | Sort-Object -Unique | Set-Content -Path '%cd%\\%result' -Encoding utf8"

exit /b 0
endlocalnfor %%p in ("%cd%\%result%") do echo %%~fp
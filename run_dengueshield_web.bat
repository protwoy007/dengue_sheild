@echo off
setlocal EnableExtensions
title DengueShield BD - Setup and Run (Web)
cd /d "%~dp0"

echo ==========================================
echo   DengueShield BD - first-time setup + run
echo ==========================================
echo.

if not exist "pubspec.yaml" goto :wrongfolder

rem ---------- 1. Git ----------
where git >nul 2>nul
if not errorlevel 1 goto :gitok
echo [1/5] Git not found. Trying to install it with winget...
where winget >nul 2>nul
if errorlevel 1 goto :gitmanual
winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements
echo.
echo Git was installed. CLOSE this window and run this file again.
pause
exit /b 0
:gitmanual
echo Please install Git from https://git-scm.com/download/win then run this file again.
pause
exit /b 1
:gitok
echo [1/5] Git ........ OK

rem ---------- 2. Flutter ----------
where flutter >nul 2>nul
if not errorlevel 1 goto :flutterok
if exist "%USERPROFILE%\flutter\bin\flutter.bat" goto :flutterlocal
echo [2/5] Flutter not found. Downloading the Flutter SDK, this can take several minutes...
git clone https://github.com/flutter/flutter.git -b stable "%USERPROFILE%\flutter"
if errorlevel 1 goto :flutterfail
:flutterlocal
set "PATH=%USERPROFILE%\flutter\bin;%PATH%"
rem Save Flutter to your user PATH for future terminals
powershell -NoProfile -Command "$p=[Environment]::GetEnvironmentVariable('Path','User'); $f=$env:USERPROFILE+'\flutter\bin'; if(-not $p){$p=''}; if($p -notlike ('*'+$f+'*')){[Environment]::SetEnvironmentVariable('Path',($p.TrimEnd(';')+';'+$f),'User')}"
:flutterok
echo [2/5] Flutter .... OK

rem ---------- 3. Web support ----------
echo [3/5] Enabling Flutter web support (first run downloads tools, please wait)...
call flutter config --enable-web >nul
call flutter precache --web
if errorlevel 1 goto :fail
if exist "web\index.html" goto :webok
echo       Adding web platform files to the project...
call flutter create --platforms=web .
if errorlevel 1 goto :fail
:webok
echo [3/5] Web ........ OK

rem ---------- 4. Packages ----------
echo [4/5] Installing project packages...
call flutter pub get
if errorlevel 1 goto :fail
echo [4/5] Packages ... OK

rem ---------- 5. Run ----------
echo [5/5] Starting the app in Chrome. Press q in this window to stop it.
echo.
call flutter run -d chrome
if not errorlevel 1 goto :done
echo.
echo Chrome failed. Trying Microsoft Edge...
call flutter run -d edge
goto :done

:wrongfolder
echo This file must be placed in the project folder, next to pubspec.yaml.
pause
exit /b 1

:flutterfail
echo Could not download Flutter. Check your internet connection and try again.
pause
exit /b 1

:fail
echo.
echo Setup stopped because of an error shown above.
echo Tip: run  flutter doctor -v  to see what is missing.
pause
exit /b 1

:done
echo.
echo Finished.
pause
endlocal

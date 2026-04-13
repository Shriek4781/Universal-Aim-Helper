@echo off
setlocal enabledelayedexpansion
title Universal Recoil Helper v3.0 (No Admin)
color 0a

:: ---------------------------
:: Initialize variables
:: ---------------------------
set base200=12
set base400=7
set base600=6
set base800=6
set base1000=5
set base1200=5
set base1400=4
set base1600=4

:: Clean backup filename (always safe, no spaces)
set hh=%time:~0,2%
if "%hh:~0,1%"==" " set hh=0%hh:~1%
set backupfile=mouse_backup_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%hh%%time:~3,2%.reg

:: Load default profile if exists
if exist "profiles_default.cfg" (
    set /p loadedvalues=<"profiles_default.cfg"
    for /f "tokens=1-8" %%a in ("!loadedvalues!") do (
        set base200=%%a
        set base400=%%b
        set base600=%%c
        set base800=%%d
        set base1000=%%e
        set base1200=%%f
        set base1400=%%g
        set base1600=%%h
    )
)

:MENU
cls
echo =====================================================
echo           UNIVERSAL RECOIL HELPER v3.0
echo =====================================================
echo 1. Select DPI ^& Configure Sensitivity
echo 2. Change Base Values
echo 3. Save/Load/Delete Profiles
echo 4. Tutorial (How it works)
echo 5. Backup Current Settings
echo 6. Restore Windows Defaults
echo 7. View Current Settings
echo 0. Exit
echo =====================================================

choice /c 01234567 /n /m "Enter option (0-7): "

if %errorlevel%==1 goto EXIT
if %errorlevel%==2 goto DPISELECT
if %errorlevel%==3 goto BASECHANGE
if %errorlevel%==4 goto PROFILES
if %errorlevel%==5 goto TUTORIAL
if %errorlevel%==6 goto BACKUP
if %errorlevel%==7 goto RESET
if %errorlevel%==8 goto VIEWSETTINGS
goto MENU

:EXIT
exit

:TUTORIAL
cls
echo =====================================================
echo                     TUTORIAL
echo =====================================================
echo 1. DPI = your hardware mouse DPI.
echo 2. Base Sensitivity = starting point (per DPI).
echo 3. Focus Mode:
echo    - Vertical = steadier pull-down.
echo    - Horizontal = better strafing.
echo    - Balanced = middle ground.
echo 4. Recoil Profile:
echo    - Shake Reduction = slows vertical recoil.
echo    - Burst = tighter bursts, faster tracking.
echo    - Drive-by = balanced.
echo 5. Y Multiplier = scales vertical only (50%%-200%%).
echo NOTE: X multiplier is locked at 100 to prevent drift.
echo.
pause
goto MENU

:BACKUP
cls
echo =====================================================
echo              BACKUP CURRENT SETTINGS
echo =====================================================
echo Creating backup file: %backupfile%
REG EXPORT "HKCU\Control Panel\Mouse" "%backupfile%" >nul 2>&1
if exist "%backupfile%" (
    echo ✓ Backup created successfully!
    echo Location: %cd%\%backupfile%
) else (
    echo ✗ Backup failed!
)
pause
goto MENU

:VIEWSETTINGS
cls
echo =====================================================
echo              CURRENT MOUSE SETTINGS
echo =====================================================
set found=0
for /f "tokens=1,2,*" %%a in ('REG QUERY "HKCU\Control Panel\Mouse" 2^>nul') do (
    if "%%a"=="MouseSensitivity" (echo Sensitivity: %%c & set found=1)
    if "%%a"=="MouseSpeed" echo MouseSpeed: %%c
    if "%%a"=="MouseThreshold1" echo Threshold1: %%c
    if "%%a"=="MouseThreshold2" echo Threshold2: %%c
)
if !found! equ 0 echo No registry settings found.
pause
goto MENU

:BASECHANGE
cls
echo =====================================================
echo            CHANGE BASE SENSITIVITY VALUES
echo =====================================================
echo Current:
echo 200:%base200% 400:%base400% 600:%base600% 800:%base800%
echo 1000:%base1000% 1200:%base1200% 1400:%base1400% 1600:%base1600%
echo -----------------------------------------------------
echo Enter new values (1-20) or leave blank:
set /p "in200=200 DPI: "
set /p "in400=400 DPI: "
set /p "in600=600 DPI: "
set /p "in800=800 DPI: "
set /p "in1000=1000 DPI: "
set /p "in1200=1200 DPI: "
set /p "in1400=1400 DPI: "
set /p "in1600=1600 DPI: "

call :ValidateAndSet in200 base200
call :ValidateAndSet in400 base400
call :ValidateAndSet in600 base600
call :ValidateAndSet in800 base800
call :ValidateAndSet in1000 base1000
call :ValidateAndSet in1200 base1200
call :ValidateAndSet in1400 base1400
call :ValidateAndSet in1600 base1600

echo ✓ Updated.
echo Save as default profile?
choice /c YN /n /m "(Y/N): "
if %errorlevel%==1 (
    echo %base200% %base400% %base600% %base800% %base1000% %base1200% %base1400% %base1600% >"profiles_default.cfg"
    echo ✓ Default saved.
)
pause
goto MENU

:ValidateAndSet
setlocal
set val=!%1!
if not "!val!"=="" (
    echo !val!|findstr /r "^[0-9][0-9]*$" >nul
    if !errorlevel! equ 0 if !val! geq 1 if !val! leq 20 (
        endlocal & set %2=!val! & goto :eof
    )
)
endlocal
goto :eof

:DPISELECT
cls
echo =====================================================
echo Step 1: Choose DPI
echo =====================================================
echo 1. 200 (%base200%)  2. 400 (%base400%)  3. 600 (%base600%)  4. 800 (%base800%)
echo 5. 1000 (%base1000%) 6. 1200 (%base1200%) 7. 1400 (%base1400%) 8. 1600 (%base1600%)
echo 0. Back
echo =====================================================
choice /c 012345678 /n /m "Enter option: "
if %errorlevel%==1 goto MENU
set dpi=200
if %errorlevel%==3 set dpi=400
if %errorlevel%==4 set dpi=600
if %errorlevel%==5 set dpi=800
if %errorlevel%==6 set dpi=1000
if %errorlevel%==7 set dpi=1200
if %errorlevel%==8 set dpi=1400
if %errorlevel%==9 set dpi=1600
goto FOCUS

:FOCUS
cls
echo =====================================================
echo Step 2: Focus Mode (DPI %dpi%)
echo =====================================================
echo 1. Vertical  2. Horizontal  3. Balanced
choice /c 123 /n /m "Choose mode: "
set mode=VERTICAL
if %errorlevel%==2 set mode=HORIZONTAL
if %errorlevel%==3 set mode=BALANCED
goto PROFILE

:PROFILE
cls
echo =====================================================
echo Step 3: Recoil Profile (DPI %dpi% / %mode%)
echo =====================================================
echo 1. Shake Reduction  2. Burst Fire  3. Drive-by
choice /c 123 /n /m "Choose profile: "
set profile=SHAKE
if %errorlevel%==2 set profile=BURST
if %errorlevel%==3 set profile=DRIVEBY
goto YINPUT

:YINPUT
cls
echo =====================================================
echo Step 4: Y Multiplier (DPI %dpi%)
echo =====================================================
set /p "y=Enter vertical multiplier (50-200, default 100): "
if "!y!"=="" set y=100
echo !y!|findstr /r "^[0-9][0-9]*$" >nul || set y=100
if !y! lss 50 set y=50
if !y! gtr 200 set y=200
set x=100
call :ApplyDPI %dpi% %mode% %profile% %x% %y%
goto MENU

:ApplyDPI
setlocal
set dpi=%1
set mode=%2
set profile=%3
set x=%4
set y=%5

:: pick base
set base=10
if "%dpi%"=="200" set base=%base200%
if "%dpi%"=="400" set base=%base400%
if "%dpi%"=="600" set base=%base600%
if "%dpi%"=="800" set base=%base800%
if "%dpi%"=="1000" set base=%base1000%
if "%dpi%"=="1200" set base=%base1200%
if "%dpi%"=="1400" set base=%base1400%
if "%dpi%"=="1600" set base=%base1600%

set temp=%base%

:: focus adjust
if "%mode%"=="VERTICAL" set /a temp-=1
if "%mode%"=="HORIZONTAL" set /a temp+=1

:: profile adjust
if "%profile%"=="SHAKE" set /a temp-=1
if "%profile%"=="BURST" set /a temp+=1

:: scale with Y multiplier
set /a temp=temp*%y%/100

if %temp% lss 1 set temp=1
if %temp% gtr 20 set temp=20

cls
echo =====================================================
echo Applying Mouse Settings
echo =====================================================
echo DPI: %dpi%
echo Mode: %mode%
echo Profile: %profile%
echo Base: %base% -> %temp%
echo X Multiplier: %x%%% (locked)
echo Y Multiplier: %y%%%
echo.

REG ADD "HKCU\Control Panel\Mouse" /v MouseSensitivity /t REG_SZ /d %temp% /f >nul
REG ADD "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 0 /f >nul
REG ADD "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d 0 /f >nul
REG ADD "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d 0 /f >nul
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters >nul

echo ✓ Applied.
pause
endlocal
goto :eof

:RESET
cls
echo Resetting to Windows defaults...
REG ADD "HKCU\Control Panel\Mouse" /v MouseSensitivity /t REG_SZ /d 10 /f >nul
REG ADD "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 1 /f >nul
REG ADD "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d 6 /f >nul
REG ADD "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d 10 /f >nul
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters >nul
echo ✓ Defaults restored.
pause
goto MENU

:PROFILES
cls
echo =====================================================
echo              PROFILE MANAGEMENT
echo =====================================================
echo 1. Save Profile  2. Load Profile  3. Delete Profile  4. Set Default  0. Back
choice /c 01234 /n /m "Enter option: "
if %errorlevel%==1 goto MENU
if %errorlevel%==2 goto SAVEPROFILE
if %errorlevel%==3 goto LOADPROFILE
if %errorlevel%==4 goto DELETEPROFILE
if %errorlevel%==5 goto SETDEFAULT
goto PROFILES

:SAVEPROFILE
set /p "profilename=Enter profile name: "
if "!profilename!"=="" goto PROFILES
call :CleanName "!profilename!" clean
echo %base200% %base400% %base600% %base800% %base1000% %base1200% %base1400% %base1600% >"profiles_!clean!.cfg"
echo ✓ Saved.
pause
goto PROFILES

:LOADPROFILE
cls
echo Profiles:
dir /b profiles_*.cfg 2>nul || (echo None & pause & goto PROFILES)
set /p "profilename=Enter name: "
if "!profilename!"=="" goto PROFILES
call :CleanName "!profilename!" clean
if not exist "profiles_!clean!.cfg" (echo Not found & pause & goto PROFILES)
set /p loaded=<"profiles_!clean!.cfg"
for /f "tokens=1-8" %%a in ("!loaded!") do (
    set base200=%%a&set base400=%%b&set base600=%%c&set base800=%%d&set base1000=%%e&set base1200=%%f&set base1400=%%g&set base1600=%%h
)
echo ✓ Loaded.
pause
goto PROFILES

:DELETEPROFILE
cls
echo Profiles:
dir /b profiles_*.cfg 2>nul || (echo None & pause & goto PROFILES)
set /p "profilename=Enter name to delete: "
if "!profilename!"=="" goto PROFILES
call :CleanName "!profilename!" clean
if exist "profiles_!clean!.cfg" (del "profiles_!clean!.cfg" & echo ✓ Deleted) else echo Not found
pause
goto PROFILES

:SETDEFAULT
echo %base200% %base400% %base600% %base800% %base1000% %base1200% %base1400% %base1600% >"profiles_default.cfg"
echo ✓ Default saved.
pause
goto PROFILES

:CleanName
setlocal enabledelayedexpansion
set "name=%~1"
for %%C in (\ / : * ? " < > | .) do set "name=!name:%%C=!"
set "name=!name: =_!"
endlocal & set %2=%name%
goto :eof

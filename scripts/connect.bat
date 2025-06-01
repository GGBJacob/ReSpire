@echo off
echo Restarting ADB in TCP/IP mode...
adb tcpip 5555
timeout /t 2 /nobreak >nul

echo.
echo Getting device IP address...
for /f "tokens=9" %%A in ('adb shell ip route ^| findstr /R /C:"src"') do set IP=%%A

echo.
echo Connecting to device at %IP%:5555...
adb connect %IP%:5555

echo.
echo Connecting finished. Press any button to continue...
pause >nul
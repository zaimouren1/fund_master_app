@echo off
chcp 65001 >nul
title J.A.R.V.I.S. Auto Build APK
echo ========================================
echo    J.A.R.V.I.S. APK 自动构建系统
echo ========================================
echo.

; 1. 关闭 Android Studio
echo [1/5] 关闭 Android Studio...
taskkill /F /IM studio64.exe >nul 2>&1
timeout /t 2 /nobreak >nul
echo      完成

; 2. 接受 SDK licenses
echo [2/5] 接受 SDK licenses...
set JAVA_HOME=C:\Program Files\java\jdk-17
echo y | C:\Users\Administrator\AppData\Local\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat --licenses >nul 2>&1
echo      完成

; 3. 启动 Android Studio
echo [3/5] 启动 Android Studio...
start "" "C:\Program Files\Android\Android Studio\bin\studio64.exe"
timeout /t 15 /nobreak >nul
echo      完成

; 4. 打开项目
echo [4/5] 打开 Flutter Android 项目...
powershell -Command "$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys('%%o'); Start-Sleep -Seconds 2; $wshell.SendKeys('C:\Users\Administrator\.openclaw\workspace\fund_master_app\android'); $wshell.SendKeys('{Enter}'); Start-Sleep -Seconds 2"
timeout /t 15 /nobreak >nul
echo      完成

; 5. 开始构建
echo [5/5] 启动 APK 构建...
powershell -Command "$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys('%%b'); Start-Sleep -Seconds 2; $wshell.SendKeys('a'); Start-Sleep -Seconds 2"
echo.
echo ========================================
echo    构建已启动！
echo    请在 Android Studio 中查看进度
echo ========================================
echo.
echo APK 输出位置:
echo    build\app\outputs\flutter-apk\app-release.apk
echo.
pause

@echo off
cd /d "C:\Users\Administrator\.openclaw\workspace\fund_master_app"

:: 直接使用 Flutter 的 gradle 调用（绕过 wrapper）
set FLUTTER_ROOT=C:\Flutter\flutter
set ANDROID_HOME=C:\Users\Administrator\AppData\Local\Android\sdk

:: 清理
echo Cleaning...
%FLUTTER_ROOT%\bin\flutter.bat clean

:: 构建（使用 --no-shrink 避免某些 Gradle 步骤）
echo Building APK...
%FLUTTER_ROOT%\bin\flutter.bat build apk --release --no-shrink

pause
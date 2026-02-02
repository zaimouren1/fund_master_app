@echo off
chcp 65001 >nul
echo ========================================
echo 基金大师 Pro - 构建 APK
echo ========================================
echo.

REM 设置环境变量
set JAVA_HOME=C:\Program Files\Java\jdk-17\jdk-17.0.10+7
set ANDROID_HOME=C:\Users\Administrator\AppData\Local\Android\Sdk
set PATH=%JAVA_HOME%\bin;C:\AndroidSDK\cmdline-tools\latest\bin;%PATH%

REM 检查 SDK
if not exist "%ANDROID_HOME%\platforms" (
    echo 正在安装 Android SDK...
    sdkmanager --sdk_root=%ANDROID_HOME% "platforms;android-34" "build-tools;34.0.0" "platform-tools"
)

echo.
echo 开始构建 APK...
cd /d C:\Users\Administrator\.openclaw\workspace\fund_master_app
flutter build apk --release

echo.
echo 构建完成！
pause

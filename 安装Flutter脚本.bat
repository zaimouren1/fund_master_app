@echo off
chcp 65001 >nul
echo ============================================
echo     基金大师 Pro - Flutter 环境安装脚本
echo ============================================
echo.

REM 检查是否已安装 Flutter
flutter --version >nul 2>&1
if %errorlevel% equ 0 (
    echo Flutter 已安装!
    flutter --version
    echo.
    pause
    exit /b
)

echo 步骤 1/4: 下载 Flutter SDK...
echo.

REM 创建安装目录
set "FLUTTER_DIR=C:\Flutter"
if not exist "%FLUTTER_DIR%" mkdir "%FLUTTER_DIR%"

REM 使用 PowerShell 下载（更可靠）
echo 正在下载 Flutter SDK (约 1GB)...
powershell -Command "& {Param($url='https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.19.0-stable.zip', $out='%FLUTTER_DIR%\flutter.zip'); $ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri $url -OutFile $out; echo '下载完成: '$out; Write-Host '文件大小: ' -NoNewline; (Get-Item $out).Length / 1MB | Write-Host 'MB' -NoNewline; Write-Host ''}"

if not exist "%FLUTTER_DIR%\flutter.zip" (
    echo 下载失败，请手动下载:
    echo https://flutter.dev/docs/get-started/install/windows
    pause
    exit /b
)

echo.
echo 步骤 2/4: 解压 Flutter...
tar -xf "%FLUTTER_DIR%\flutter.zip" -C "%FLUTTER_DIR%"
if errorlevel 1 (
    echo 解压失败，请手动解压到 %FLUTTER_DIR%
    pause
    exit /b
)

echo.
echo 步骤 3/4: 设置环境变量...
setx PATH "%FLUTTER_DIR%\flutter\bin;%PATH%" /M
echo 环境变量已设置

echo.
echo 步骤 4/4: 验证安装...
echo.
echo 请打开新的 CMD 窗口，运行以下命令：
echo.
echo    flutter doctor
echo.
echo 然后接受许可证：
echo    flutter doctor --android-licenses
echo.
echo 安装 Android Studio:
echo    https://developer.android.com/studio
echo.
echo 运行项目:
echo    cd C:\Users\Administrator\.openclaw\workspace\fund_master_app
echo    flutter pub get
echo    flutter run
echo.

pause

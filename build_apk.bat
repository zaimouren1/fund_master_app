@echo off
chcp 65001 >nul
echo ========================================
echo 基金大师 Pro - APK 构建脚本
echo ========================================
echo.

REM 设置环境变量
set JAVA_HOME=C:\Program Files\Java\jdk-17\jdk-17.0.10+7
set ANDROID_HOME=C:\Users\Administrator\AppData\Local\Android\Sdk
set ANDROID_SDK_ROOT=C:\Users\Administrator\AppData\Local\Android\Sdk
set GRADLE_HOME=C:\Gradle\gradle-8.4
set PATH=%JAVA_HOME%\bin;%GRADLE_HOME%\bin;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\tools;%PATH%

echo 环境变量设置完成
echo JAVA_HOME: %JAVA_HOME%
echo ANDROID_HOME: %ANDROID_HOME%
echo GRADLE_HOME: %GRADLE_HOME%
echo.

REM 检查必要工具
echo 检查必要工具...
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误：Flutter 未找到！
    pause
    exit /b 1
)

adb version >nul 2>&1
if %errorlevel% neq 0 (
    echo 警告：ADB 未找到，但可以继续构建
)

echo.

REM 尝试构建
echo 开始构建 APK...
cd /d C:\Users\Administrator\.openclaw\workspace\fund_master_app

echo.
echo 构建 Release 版本...
flutter build apk --release --verbose
set BUILD_RESULT=%errorlevel%

if %BUILD_RESULT% equ 0 (
    echo.
    echo ========================================
    echo 构建成功！
    echo ========================================
    echo 查找生成的 APK 文件：
    for /r build\app\outputs\flutter-apk %%f in (*.apk) do (
        if exist "%%f" (
            echo APK 文件: %%f
            echo 文件大小: %%~zf 字节
        )
    )
    echo.
    echo 基金大师 Pro APK 已生成！
) else (
    echo.
    echo ========================================
    echo 构建失败！错误代码: %BUILD_RESULT%
    echo ========================================
    echo 可能的原因：
    echo 1. SSL 证书问题（Gradle 下载失败）
    echo 2. 缺少必要的构建工具
    echo 3. 磁盘空间不足
    echo.
    echo 解决方案：
    echo 1. 使用 Android Studio 手动构建
    echo 2. 检查网络连接
    echo 3. 确保已安装所有 Android SDK 组件
)

echo.
pause
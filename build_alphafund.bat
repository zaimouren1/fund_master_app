@echo off
echo Setting up environment for AlphaFund build...

:: 设置 JAVA_HOME（使用短路径避免空格和特殊字符）
set JAVA_HOME=C:\PROGRA~1\Java\JDK-17~1.0.10+7
echo JAVA_HOME=%JAVA_HOME%

:: 验证 Java
if exist "%JAVA_HOME%\bin\java.exe" (
    echo Java found at %JAVA_HOME%
) else (
    echo ERROR: Java not found at %JAVA_HOME%
    pause
    exit /b 1
)

:: 设置 PATH
set PATH=%JAVA_HOME%\bin;%PATH%

:: 切换到项目目录
cd /d "C:\Users\Administrator\.openclaw\workspace\fund_master_app\android"

:: 执行构建
echo Starting Gradle build...
"C:\Users\Administrator\.gradle\wrapper\dists\gradle-8.5-all\gradle-8.5\bin\gradle.bat" assembleRelease -PflutterRoot="C:\Flutter\flutter"

echo Build completed.
pause
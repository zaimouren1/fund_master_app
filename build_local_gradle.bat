@echo off
cd /d "C:\Users\Administrator\.openclaw\workspace\fund_master_app\android"
echo Building with local Gradle...
set JAVA_HOME=C:\PROGRA~1\Java\JDK-17~1.0.10+7
"C:\Users\Administrator\.gradle\wrapper\dists\gradle-8.5-all\gradle-8.5\bin\gradle.bat" assembleRelease -PflutterRoot=C:\Flutter\flutter --no-daemon
pause
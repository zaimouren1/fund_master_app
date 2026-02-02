@echo off
cd /d "C:\Users\Administrator\.openclaw\workspace\fund_master_app"
echo Starting AlphaFund APK build...
C:\Flutter\flutter\bin\flutter.bat build apk --release
pause
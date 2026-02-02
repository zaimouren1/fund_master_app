@echo off
chcp 65001 >nul
echo J.A.R.V.I.S. 自动化构建开始: %time%

; 步骤 1: 关闭 Android Studio (如果正在运行)
taskkill /F /IM studio64.exe 2>nul
timeout /t 3 /nobreak >nul

; 步骤 2: 接受 SDK licenses
echo 正在接受 SDK licenses...
set JAVA_HOME=C:\Program Files\java\jdk-17
echo y | C:\Users\Administrator\AppData\Local\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat --licenses

; 步骤 3: 启动 Android Studio
echo 正在启动 Android Studio...
start "" "C:\Program Files\Android\Android Studio\bin\studio64.exe"

; 等待启动
timeout /t 15 /nobreak >nul

; 步骤 4: 发送 Ctrl+O 打开项目
echo 正在打开项目...
powershell -Command "$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys('^o'); Start-Sleep -Seconds 3; $wshell.SendKeys('C:\Users\Administrator\.openclaw\workspace\fund_master_app\android'); $wshell.SendKeys('{Enter}')"

; 等待项目加载
timeout /t 20 /nobreak >nul

; 步骤 5: 发送 Alt+B 打开 Build 菜单，然后按 A
echo 正在启动构建...
powershell -Command "$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys('%b'); Start-Sleep -Seconds 2; $wshell.SendKeys('a')"

echo 构建已启动，请查看 Android Studio 窗口
pause

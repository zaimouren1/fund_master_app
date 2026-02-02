@echo off
chcp 65001 >nul
echo ========================================
echo    J.A.R.V.I.S. APK 构建自动化
echo ========================================
echo.
echo 请确保:
echo 1. Android Studio 已关闭
echo 2. 屏幕分辨率 1920x1080 或更高
echo.
echo 开始构建? (按任意键继续...)
pause >nul

echo.
echo 正在启动 Android Studio 构建...
"C:\Program Files\AutoHotkey\AutoHotkeyU64.exe" "C:\Users\Administrator\.openclaw\workspace\fund_master_app\build_apk_v2.ahk"

echo.
echo 构建完成，请检查日志: C:\Users\Administrator\.openclaw\workspace\fund_master_app\build_log.txt
pause

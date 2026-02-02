; J.A.R.V.I.S. Android Studio APK 构建自动化脚本
; 用途：自动打开 Android Studio 并构建 APK

#SingleInstance Force
SetTitleMatchMode, 2

; 配置变量
AndroidStudioPath := "C:\Program Files\Android\Android Studio\bin\studio64.exe"
ProjectPath := "C:\Users\Administrator\.openclaw\workspace\fund_master_app\android"
BuildMenuX := 200  ; Build 菜单位置 (根据屏幕调整)
BuildMenuY := 100
BuildApkX := 800   ; Build APK 按钮位置
BuildApkY := 600

; 检查 Android Studio 是否已运行
IfWinExist, Android Studio
{
    MsgBox, Android Studio 已在运行中，请先关闭后重试
    ExitApp
}

; 步骤 1: 打开 Android Studio
Run, "%AndroidStudioPath%",, Min

; 等待 Android Studio 启动
WinWait, Android Studio,, 30
Sleep, 5000  ; 额外等待加载

; 步骤 2: 点击菜单按钮 (可能需要调整坐标)
; Click, 100, 50  ; 菜单按钮位置

; 步骤 3: 打开项目
Send ^o  ; Ctrl+O 打开
Sleep, 3000

; 输入项目路径
Send, %ProjectPath%
Sleep, 1000
Send, {Enter}
Sleep, 15000  ; 等待项目加载和索引

; 步骤 4: 打开 Build 菜单
Send !b  ; Alt+B 打开 Build 菜单
Sleep, 3000

; 步骤 5: 点击 Build APK
Click, %BuildApkX%, %BuildApkY%
Sleep, 3000

; 步骤 6: 检查构建状态
WinWait, Build Output,, 60

; 等待构建完成
Loop
{
    Sleep, 10000  ; 每 10 秒检查一次
    
    ; 检查是否有错误对话框
    IfWinExist, Error
    {
        MsgBox, 构建失败：发现错误
        ExitApp
    }
    
    ; 检查是否构建成功 (根据输出或通知)
    ; 这里可以添加更复杂的检查逻辑
    
    ; 超时检查 (30 分钟)
    If (A_TickCount > 1800000)
    {
        MsgBox, 构建超时
        ExitApp
    }
}

ExitApp

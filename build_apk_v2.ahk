; J.A.R.V.I.S. Android Studio APK 构建自动化脚本 v2
; 使用键盘快捷键，减少对鼠标位置的依赖

#SingleInstance Force
SetTitleMatchMode, 2

; 配置
ProjectPath := "C:\Users\Administrator\.openclaw\workspace\fund_master_app\android"
BuildLogPath := "C:\Users\Administrator\.openclaw\workspace\fund_master_app\build_log.txt"

; 打开日志文件
FileAppend, J.A.R.V.I.S. Build Automation Started: %A_Now%`n, %BuildLogPath%

; 步骤 1: 检查 Android Studio 是否已运行
IfWinExist, ahk_exe studio64.exe
{
    FileAppend, Android Studio already running, checking status...`n, %BuildLogPath%
}
Else
{
    FileAppend, Opening Android Studio...`n, %BuildLogPath%
    Run, "C:\Program Files\Android\Android Studio\bin\studio64.exe",, Min
    
    ; 等待启动
    WinWait, ahk_exe studio64.exe,, 60
    Sleep, 10000  ; 等待初始加载
}

; 步骤 2: 打开项目
FileAppend, Opening project...`n, %BuildLogPath%
Send ^o  ; 打开对话框
Sleep, 3000
Send, %ProjectPath%
Sleep, 1000
Send, {Enter}
Sleep, 15000  ; 等待项目加载

; 步骤 3: 构建 APK (使用 Build 菜单)
FileAppend, Starting APK build...`n, %BuildLogPath%
Send !b  ; Alt+B
Sleep, 1000

; 发送 'a' 选择 Build APK (通常 Build 菜单中 Build APK 是第一个选项，快捷键是 A)
Send, a
Sleep, 1000

; 步骤 4: 等待构建完成
FileAppend, Waiting for build to complete...`n, %BuildLogPath%

BuildTimeout := 1800000  ; 30 分钟超时
StartTime := A_TickCount

Loop
{
    Sleep, 30000  ; 每 30 秒检查一次
    
    ; 检查构建输出窗口
    IfWinExist, Build Output
    {
        WinGetText, BuildOutputText, Build Output
        
        ; 检查是否包含 "BUILD SUCCESSFUL"
        IfInString, BuildOutputText, BUILD SUCCESSFUL
        {
            FileAppend, BUILD SUCCESSFUL!`n, %BuildLogPath%
            MsgBox, 4,, 构建成功！是否关闭 Android Studio?
            IfMsgBox, Yes
            {
                Send !{F4}
            }
            ExitApp
        }
        
        ; 检查是否包含 "BUILD FAILED"
        IfInString, BuildOutputText, BUILD FAILED
        {
            FileAppend, BUILD FAILED!`n, %BuildLogPath%
            MsgBox, 构建失败，请检查 Build Output 窗口
            ExitApp
        }
    }
    
    ; 检查错误弹窗
    IfWinExist, Error
    {
        FileAppend, Error dialog detected!`n, %BuildLogPath%
        MsgBox, 构建过程中出现错误
        ExitApp
    }
    
    ; 检查超时
    If ((A_TickCount - StartTime) > BuildTimeout)
    {
        FileAppend, Build timeout!`n, %BuildLogPath%
        MsgBox, 构建超时 (30 分钟)
        ExitApp
    }
    
    ; 进度报告
    ElapsedMinutes := Round((A_TickCount - StartTime) / 60000, 1)
    FileAppend, Still building... (%ElapsedMinutes% min)`n, %BuildLogPath%
}

ExitApp

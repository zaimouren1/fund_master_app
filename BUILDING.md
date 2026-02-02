# 基金大师 Pro - 构建说明

## 问题说明
当前 Flutter 项目在命令行构建时遇到 SSL 证书问题，导致 Gradle 无法下载。

## 解决方案

### 方法 1：使用 Android Studio（推荐）
1. 打开 Android Studio
2. 选择 "Open an existing project"
3. 导航到：`C:\Users\Administrator\.openclaw\workspace\fund_master_app\android`
4. 等待项目同步完成
5. 选择 Build -> Build Bundle(s) / APK(s) -> Build APK(s)
6. 构建完成后，在底部通知栏点击 "locate" 查找 APK

### 方法 2：命令行修复 SSL
1. 下载并安装最新版 Android Studio/Gradle
2. 或配置正确的 SSL 证书

### 方法 3：使用预配置的构建脚本
运行此脚本将尝试修复环境并构建：
```
C:\Users\Administrator\.openclaw\workspace\fund_master_app\构建APK.bat
```

## 项目信息
- 项目名称：基金大师 Pro
- 位置：C:\Users\Administrator\.openclaw\workspace\fund_master_app
- 用途：实时基金估值与分析软件

## 注意事项
- 构建过程可能需要 5-10 分钟
- 确保有足够的磁盘空间
- 构建成功后 APK 位于 build/app/outputs/flutter-apk/

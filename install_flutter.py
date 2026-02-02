import os
import time

print("="*50)
print("Flutter 自动安装脚本")
print("="*50)

flutter_zip = "C:\\flutter.zip"
flutter_dir = "C:\\Flutter"

# 检查是否已安装
if os.system("flutter --version") == 0:
    print("\nFlutter 已安装!")
    os.system("flutter --version")
else:
    print("\n开始下载 Flutter SDK...")
    
    import urllib.request
    url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.19.0-stable.zip"
    
    print(f"URL: {url}")
    print(f"目标: {flutter_zip}")
    
    try:
        print("\n下载中... (这可能需要几分钟)")
        urllib.request.urlretrieve(url, flutter_zip)
        print(f"\n下载完成!")
        
        if os.path.exists(flutter_zip):
            size = os.path.getsize(flutter_zip) / (1024*1024)
            print(f"文件大小: {size:.1f} MB")
    except Exception as e:
        print(f"下载失败: {e}")
        
print("\n" + "="*50)

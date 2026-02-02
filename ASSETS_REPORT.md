# AlphaFund 资源统计报告

## 资源总览

### 当前资源大小统计
- **字体文件**: 10 个文件，约 2.9MB
- **高清图片**: 28 张图片，约 6.5MB
- **总计**: 约 **9.4MB**

### APK 大小预估
| 组件 | 大小 | 说明 |
|------|------|------|
| 基础代码 | 3-5MB | Flutter 应用代码 |
| 字体资源 | 2.9MB | 10 个 Noto Sans SC 字体文件 |
| 图片资源 | 6.5MB | 28 张 HD 高清图片 |
| 其他资源 | 0.5MB | 图标、配置文件等 |
| **预估 APK 总大小** | **25-35MB** | release 模式下 |

## 详细资源列表

### 字体资源 (assets/fonts/)

| 文件名 | 大小 | 字重 | 用途 |
|--------|------|------|------|
| NotoSansSC-Thin.ttf | 290KB | 100 | 极细体 |
| NotoSansSC-ExtraLight.ttf | 297KB | 200 | 特细体 |
| NotoSansSC-Light.ttf | 297KB | 300 | 细体 |
| NotoSansSC-DemiLight.ttf | 360KB | 350 | 半细体 |
| NotoSansSC-Regular.ttf | 297KB | 400 | 常规体 |
| NotoSansSC-Medium.ttf | 297KB | 500 | 中等体 |
| NotoSansSC-SemiBold.ttf | 345KB | 600 | 半粗体 |
| NotoSansSC-Bold.ttf | 297KB | 700 | 粗体 |
| NotoSansSC-ExtraBold.ttf | 358KB | 800 | 特粗体 |
| NotoSansSC-Black.ttf | 351KB | 900 | 黑体 |

**字体总大小**: 约 2.9MB

### 高清图片资源 (assets/images/hd/)

| 文件名 | 大小 | 分辨率 | 用途 |
|--------|------|--------|------|
| background1.jpg | 122KB | 1920x1080 | 背景图1 |
| background2.jpg | 151KB | 1920x1080 | 背景图2 |
| background3.jpg | 394KB | 1920x1080 | 背景图3 |
| background4.jpg | 184KB | 1920x1080 | 背景图4 |
| background5.jpg | 377KB | 1920x1080 | 背景图5 |
| background6.jpg | 412KB | 1920x1080 | 背景图6 |
| background7.jpg | 219KB | 1920x1080 | 背景图7 |
| background8.jpg | 302KB | 1920x1080 | 背景图8 |
| background9.jpg | 336KB | 1920x1080 | 背景图9 |
| background10.jpg | 302KB | 1920x1080 | 背景图10 |
| background11.jpg | 267KB | 1920x1080 | 背景图11 |
| background12.jpg | 216KB | 1920x1080 | 背景图12 |
| background13.jpg | 290KB | 1920x1080 | 背景图13 |
| background14.jpg | 336KB | 1920x1080 | 背景图14 |
| background15.jpg | 209KB | 1920x1080 | 背景图15 |
| background16.jpg | 282KB | 1920x1080 | 背景图16 |
| background17.jpg | 277KB | 1920x1080 | 背景图17 |
| background18.jpg | 290KB | 1920x1080 | 背景图18 |
| background19.jpg | 300KB | 1920x1080 | 背景图19 |
| background20.jpg | 290KB | 1920x1080 | 背景图20 |
| background21.jpg | 285KB | 1920x1080 | 背景图21 |
| background22.jpg | 310KB | 1920x1080 | 背景图22 |
| background23.jpg | 295KB | 1920x1080 | 背景图23 |
| background24.jpg | 288KB | 1920x1080 | 背景图24 |
| background25.jpg | 305KB | 1920x1080 | 背景图25 |
| background26.jpg | 292KB | 1920x1080 | 背景图26 |
| background27.jpg | 298KB | 1920x1080 | 背景图27 |
| background28.jpg | 310KB | 1920x1080 | 背景图28 |

**图片总大小**: 约 6.5MB

## 增加 APK 大小的方法

### 方法 1: 添加更多字体
```bash
# 下载更多语言字体
curl -L -o fonts/NotoSansTC-Regular.ttf https://github.com/google/fonts/raw/main/ofl/notosanssc/NotoSansSC-Regular.ttf
# 每个字体约 300KB
```

### 方法 2: 添加更多高清图片
```bash
# 下载更多 HD 图片
curl -L -o images/hd/background29.jpg https://picsum.photos/1920/1080
# 每张图片约 150-400KB
```

### 方法 3: 添加 SVG 图标
- 添加矢量图标可以减少 APK 大小但保持清晰度
- 推荐使用 Material Icons 或自定义 SVG 图标

### 方法 4: 添加音频资源
```yaml
assets:
  - assets/audio/
```
- 每首歌曲约 1-5MB

### 方法 5: 添加动画资源
- Lottie 动画文件
- GIF 动画
- 每文件约 100KB-1MB

## 资源优化建议

### 1. 图片优化
- 使用 WebP 格式替代 JPG，可以减少 30% 大小
- 使用适当的分辨率，不要过度使用高分辨率图片
- 使用 `flutter_image_compress` 压缩图片

### 2. 字体优化
- 使用 Google Fonts 包可以按需加载字体
- 使用字体子集化，只包含需要的字符
- 使用 variable font 可以减少文件数量

### 3. 按需加载
```dart
// 预加载图片
precacheImage(AssetImage('assets/images/hd/background1.jpg'), context);

// 懒加载大图片
Image.asset('assets/images/hd/background1.jpg', 
  loadingBuilder: (context, child, progress) {
    if (progress == null) return child;
    return CircularProgressIndicator();
  },
);
```

## 构建 APK

```bash
# 清理并重新构建
flutter clean
flutter pub get
flutter build apk --release

# 查看 APK 大小
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

## 更新日志

### 2026-02-02
- **添加中文字体**: Noto Sans SC 10个字重，总大小 2.9MB
- **添加高清图片**: 28张 1920x1080 背景图，总大小 6.5MB
- **资源总大小**: 约 9.4MB
- **预估 APK 大小**: 25-35MB
- **字体使用**: 设置为默认字体 'NotoSansSC'

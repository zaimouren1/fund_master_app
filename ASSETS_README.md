# AlphaFund 资源文件说明

## 字体资源 (assets/fonts/)

### Noto Sans SC 中文字体
- **NotoSansSC-Thin.ttf** (100 weight) - 极细体
- **NotoSansSC-ExtraLight.ttf** (200 weight) - 特细体
- **NotoSansSC-Light.ttf** (300 weight) - 细体
- **NotoSansSC-DemiLight.ttf** (350 weight) - 半细体
- **NotoSansSC-Regular.ttf** (400 weight) - 常规体
- **NotoSansSC-Medium.ttf** (500 weight) - 中等体
- **NotoSansSC-SemiBold.ttf** (600 weight) - 半粗体
- **NotoSansSC-Bold.ttf** (700 weight) - 粗体
- **NotoSansSC-ExtraBold.ttf** (800 weight) - 特粗体
- **NotoSansSC-Black.ttf** (900 weight) - 黑体

### 使用方法
在 `pubspec.yaml` 中已配置：
```yaml
flutter:
  fonts:
    - family: NotoSansSC
      fonts:
        - asset: assets/fonts/NotoSansSC-Regular.ttf
          weight: 400
        - asset: assets/fonts/NotoSansSC-Bold.ttf
          weight: 700
```

在代码中使用：
```dart
Text(
  '中文文本',
  style: TextStyle(
    fontFamily: 'NotoSansSC',
    fontWeight: FontWeight.w500,
  ),
)
```

## 图片资源 (assets/images/)

### HD 高清背景图 (assets/images/hd/)
- background1.jpg - 1920x1080
- background2.jpg - 1920x1080
- background3.jpg - 1920x1080
- background4.jpg - 1920x1080
- background5.jpg - 1920x1080
- ...更多高清背景图

### 使用方法
```dart
// 使用背景图片
Container(
  decoration: BoxDecoration(
    image: DecorationImage(
      image: AssetImage('assets/images/hd/background1.jpg'),
      fit: BoxFit.cover,
    ),
  ),
)

// 使用图片图标
Image.asset('assets/images/icons/icon.png')
```

## APK 大小说明

### 当前资源大小
- **字体文件**: 约 3MB (10个字体文件)
- **图片资源**: 约 4-6MB (18张HD高清图片)
- **总计**: 约 7-10MB

### APK 大小预计
- 基础代码: 约 3-5MB
- 资源文件: 约 7-10MB
- **预计总大小**: 约 **25-35MB**

### 增加 APK 大小的方法
1. **添加更多字体变体** - 每个字体约 300KB
2. **添加更多高清图片** - 每张HD图片约 150-400KB
3. **添加音频/视频资源** - 占用空间大
4. **添加动画资源** - Lottie动画、gif等
5. **添加数据文件** - JSON数据、配置文件等

## 资源管理最佳实践

1. **图片优化**: 使用 WebP 格式替代 JPG 可以减少 30% 大小
2. **按需加载**: 大图片使用 `precacheImage` 预加载
3. **字体子集化**: 只包含需要的字符可以大幅减少字体大小
4. **资源压缩**: 使用压缩工具优化资源文件

## 更新日志

### 2026-02-02
- 添加 Noto Sans SC 中文字体 (10个字重)
- 添加 18张 HD 高清背景图
- 总资源大小: 约 7MB

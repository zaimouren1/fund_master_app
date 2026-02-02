# AlphaFund 工业级改造计划

## 📋 当前代码问题诊断

### 🔴 严重问题
| 问题 | 影响 | 严重程度 |
|------|------|----------|
| Provider 状态管理 | 无法应对复杂业务逻辑 | 🔴 P0 |
| 无 WebSocket 实时推送 | 无法实现真正的实时行情 | 🔴 P0 |
| 无 K线图表系统 | 用户体验严重不足 | 🔴 P0 |
| 无用户认证系统 | 无法实现云端同步 | 🔴 P0 |
| 无错误边界处理 | 崩溃风险高 | 🔴 P0 |
| 无单元测试 | 无法保证代码质量 | 🔴 P0 |

### 🟡 中等问题
- 无统一的架构模式
- 无日志系统
- 无性能监控
- UI 不够专业

---

## 🎯 工业级改造目标

### 架构升级
```
当前: Provider + GetX (简单)
目标: Bloc Pattern + Clean Architecture (工业级)
```

### 依赖升级
```yaml
# 新增依赖
dependencies:
  # 状态管理升级
  bloc: ^8.1.0
  flutter_bloc: ^8.1.0
  hydrated_bloc: ^9.0.0  # 持久化

  # WebSocket 实时推送
  web_socket_channel: ^3.0.0
  rxdart: ^0.28.0

  # K线图表
  flutter_chen_kchart: ^1.0.0  # 可商用

  # 数据库升级
  drift: ^2.22.0
  sqlite3_flutter_libs: ^0.5.0

  # 认证
  dio: ^5.7.0
  shared_preferences: ^2.5.0
  flutter_secure_storage: ^9.0.0

  # UI 增强
  flutter_animate: ^4.5.0
  shimmer: ^3.0.0
  cached_network_image: ^3.3.0

  # 日志与监控
  logger: ^2.0.0
```

---

## 📅 分阶段改造计划

### Phase 1: 架构基础设施 (8h)

#### 1.1 目录结构重构
```
lib/
├── core/                    # 核心层
│   ├── constants/           # 常量定义
│   ├── errors/              # 异常定义
│   ├── usecases/            # 用例层
│   └── utils/               # 工具类
├── features/                # 功能模块
│   ├── home/                # 首页功能
│   │   ├── data/            # 数据层
│   │   ├── domain/          # 领域层
│   │   └── presentation/    # 表现层
│   ├── market/              # 行情功能
│   ├── portfolio/           # 持仓功能
│   ├── estimator/           # 估值功能
│   ├── recommend/           # 推荐功能
│   └── auth/                # 认证功能
└── shared/                  # 共享组件
    ├── widgets/             # 通用组件
    ├── theme/               # 主题
    └── extensions/          # 扩展方法
```

#### 1.2 错误处理框架
```dart
// core/errors/failures.dart
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure();
}

class CacheFailure extends Failure {
  const CacheFailure();
}
```

#### 1.3 统一 API 客户端
```dart
// core/network/api_client.dart
class ApiClient with Loggable {
  final Dio _dio;
  final Connectivity connectivity;
  
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? params}) async {
    if (!await connectivity.checkConnection()) {
      throw NetworkFailure();
    }
    
    try {
      final response = await _dio.get(endpoint, queryParameters: params);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  T _handleResponse<T>(Response response) {
    if (response.statusCode == 200) {
      return response.data;
    }
    throw ServerFailure('服务器错误: ${response.statusCode}');
  }
}
```

### Phase 2: 实时行情系统 (6h)

#### 2.1 WebSocket 管理器
```dart
// features/market/data/datasource/websocket_manager.dart
class MarketWebSocketManager with Loggable {
  WebSocketChannel? _channel;
  final _reconnectPolicy = ExponentialBackoff(
    initialDelay: const Duration(seconds: 1),
    maxDelay: const Duration(seconds: 16),
    maxAttempts: 10,
  );
  
  final _priceController = StreamController<QuoteUpdate>.broadcast();
  Stream<QuoteUpdate> get priceStream => _priceController.stream;
  
  void connect(String url) {
    _channel = WebSocketChannel.connect(Uri.parse(url));
    
    _channel!.stream.listen(
      _handleMessage,
      onError: _handleError,
      onDone: _handleDisconnect,
    );
    
    _startHeartbeat();
  }
  
  void _handleMessage(dynamic message) {
    final data = json.decode(message);
    switch (data['type']) {
      case 'quote':
        _priceController.add(QuoteUpdate.fromJson(data));
        break;
      case 'heartbeat':
        _lastHeartbeat = DateTime.now();
    }
  }
}
```

### Phase 3: K线图表系统 (8h)

#### 3.1 K线组件封装
```dart
// features/market/presentation/widgets/kline_chart.dart
class KLineChart extends StatelessWidget {
  final String fundCode;
  final List<KLineData> data;
  final List<MainIndicator> mainIndicators;
  
  @override
  Widget build(BuildContext context) {
    return KChartWidget(
      data: data,
      mainIndicators: mainIndicators,
      chartController: ChartController(
        enableGpuRendering: true,
        maxDataPoints: 100000,
        updateThrottleMs: 16,
      ),
      style: ChartStyle(
        upColor: const Color(0xFF26A69A),
        downColor: const Color(0xFFEF5350),
      ),
    );
  }
}
```

### Phase 4: AI投顾系统 (6h)

#### 4.1 智能推荐引擎
```dart
// features/recommend/domain/usecase/get_recommendation.dart
class GetRecommendationUseCase with Loggable {
  final FundRepository _fundRepository;
  final AIAdvisor _aiAdvisor;
  
  Future<InvestmentRecommendation> execute({
    required RiskProfile riskProfile,
    required InvestmentGoal goal,
  }) async {
    // 获取基金池
    final funds = await _fundRepository.queryFunds(
      category: goal.category,
      minRating: riskProfile.minRating,
    );
    
    // 构建用户上下文
    final context = await _buildUserContext(riskProfile, goal);
    
    // AI 分析
    return _aiAdvisor.getRecommendation(context, funds);
  }
}
```

### Phase 5: 用户认证系统 (6h)

#### 5.1 认证模块
```dart
// features/auth/data/repository/auth_repository.dart
class AuthRepository with Loggable {
  final ApiClient _apiClient;
  final SecureStorage _storage;
  
  Future<User> login(LoginParams params) async {
    try {
      final response = await _apiClient.post('/auth/login', data: params.toJson());
      final token = response['token'];
      
      await _storage.write('token', token);
      return User.fromJson(response['user']);
    } catch (e) {
      throw AuthFailure('登录失败: $e');
    }
  }
}
```

### Phase 6: UI/UX 工业级改造 (8h)

#### 6.1 主题系统
```dart
// shared/theme/app_theme.dart
class AppTheme with Loggable {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1E40AF),
        primary: const Color(0xFF1E40AF),
        secondary: const Color(0xFF06B6D4),
      ),
      typography: Typography.material2021(),
      // ... 更多配置
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF06B6D4),
        brightness: Brightness.dark,
      ),
    );
  }
}
```

#### 6.2 通用组件
```dart
// shared/widgets/loading_overlay.dart
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
```

### Phase 7: 测试与质量保证 (4h)

#### 7.1 测试覆盖
```dart
// test/fund_provider_test.dart
void main() {
  group('FundProvider', () {
    test('should fetch fund nav successfully', () async {
      // Arrange
      final provider = FundProvider();
      
      // Act
      await provider.fetchFundNav('161725');
      
      // Assert
      expect(provider.hotFunds.isNotEmpty, true);
    });
    
    test('should handle network error', () async {
      // Arrange
      final provider = FundProvider();
      
      // Act & Assert
      expectLater(
        provider.fetchFundNav('invalid_code'),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });
}
```

---

## 📊 改造清单

### 必须完成 (P0)
- [ ] 1. 目录结构重构 (Clean Architecture)
- [ ] 2. 错误处理框架
- [ ] 3. 统一 API 客户端
- [ ] 4. WebSocket 实时行情
- [ ] 5. K线图表集成
- [ ] 6. 用户登录系统
- [ ] 7. 错误边界组件

### 推荐完成 (P1)
- [ ] 8. 单元测试覆盖
- [ ] 9. 日志系统
- [ ] 10. 性能监控
- [ ] 11. 深色模式完善
- [ ] 12. 动画效果

### 后续扩展 (P2)
- [ ] 13. 推送通知
- [ ] 14. 风控预警
- [ ] 15. iOS 版本

---

## 🚀 启动改造

### 第一步：创建目录结构
```bash
mkdir -p lib/core/{constants,errors,usecases,utils}
mkdir -p lib/features/{home,market,portfolio,estimator,recommend,auth}/{data/{datasource,repository},domain/{model,repository,usecase},presentation/{bloc,page,widget}}
mkdir -p lib/shared/{widgets,theme,extensions}
```

### 第二步：更新 pubspec.yaml
添加新的依赖包

### 第三步：迁移代码
逐步将现有代码迁移到新架构

---

## 📈 验收标准

### 功能验收
- [ ] WebSocket 延迟 < 200ms
- [ ] K线图支持 60fps 滚动
- [ ] 登录/注册功能正常
- [ ] 持仓数据云端同步

### 质量验收
- [ ] 崩溃率 < 0.1%
- [ ] 单元测试覆盖率 > 60%
- [ ] 冷启动 < 3秒
- [ ] 内存占用 < 150MB

---

*文档版本：v1.0*
*创建时间：2026-02-02 17:50*
*作者：J.A.R.V.I.S.*

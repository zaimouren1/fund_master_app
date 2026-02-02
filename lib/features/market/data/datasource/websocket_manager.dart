import 'dart:async';
import 'dart:convert';
import 'package:rxdart/rxdart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../core/logger/app_logger.dart';

/// 行情 WebSocket 管理器
/// 
/// 特性：
/// - 自动重连（指数退避）
/// - 心跳检测
/// - 增量数据推送
/// - 订阅管理
class MarketWebSocketManager with AppLogger {
  WebSocketChannel? _channel;
  final String _url;
  final Duration _heartbeatInterval;
  final int _maxReconnectAttempts;
  
  final _priceController = BehaviorSubject<QuoteUpdate>();
  final _connectionController = BehaviorSubject<ConnectionState>();
  
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempt = 0;
  DateTime? _lastHeartbeat;
  bool _isDisposed = false;
  
  // 订阅的基金代码
  final Set<String> _subscribedFunds = {};
  
  /// 价格更新流
  Stream<QuoteUpdate> get priceStream => _priceController.stream;
  
  /// 连接状态流
  Stream<ConnectionState> get connectionState => _connectionController.stream;
  
  /// 当前连接状态
  ConnectionState get currentState => _connectionController.value;
  
  MarketWebSocketManager({
    required this._url,
    Duration heartbeatInterval = const Duration(seconds: 30),
    int maxReconnectAttempts = 10,
  })  : _heartbeatInterval = heartbeatInterval,
        _maxReconnectAttempts = maxReconnectAttempts {
    _connectionController.add(ConnectionState.disconnected);
  }
  
  /// 连接 WebSocket
  void connect() {
    if (_isDisposed) return;
    
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_url));
      _connectionController.add(ConnectionState.connecting);
      
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
      );
      
      logInfo('WebSocket connected to $_url');
    } catch (e, stack) {
      logError('Failed to connect WebSocket', e, stack);
      _scheduleReconnect();
    }
  }
  
  /// 断开连接
  void disconnect() {
    _isDisposed = true;
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _connectionController.add(ConnectionState.disconnected);
    logInfo('WebSocket disconnected');
  }
  
  /// 订阅基金行情
  void subscribe(String fundCode) {
    if (_subscribedFunds.add(fundCode)) {
      _sendMessage({
        'type': 'subscribe',
        'fundCode': fundCode,
      });
    }
  }
  
  /// 取消订阅
  void unsubscribe(String fundCode) {
    if (_subscribedFunds.remove(fundCode)) {
      _sendMessage({
        'type': 'unsubscribe',
        'fundCode': fundCode,
      });
    }
  }
  
  /// 批量订阅
  void subscribeAll(Iterable<String> fundCodes) {
    for (final code in fundCodes) {
      subscribe(code);
    }
  }
  
  void _handleMessage(dynamic message) {
    try {
      final data = json.decode(message);
      
      // 更新心跳时间
      if (data['type'] == 'heartbeat') {
        _lastHeartbeat = DateTime.now();
        _connectionController.add(ConnectionState.connected);
        return;
      }
      
      // 处理价格更新
      if (data['type'] == 'quote') {
        final update = QuoteUpdate.fromJson(data['data']);
        _priceController.add(update);
      }
    } catch (e, stack) {
      logError('Error parsing WebSocket message', e, stack);
    }
  }
  
  void _handleError(dynamic error) {
    logError('WebSocket error', error);
    _connectionController.add(ConnectionState.error);
    _scheduleReconnect();
  }
  
  void _handleDisconnect() {
    logInfo('WebSocket disconnected');
    if (!_isDisposed) {
      _connectionController.add(ConnectionState.disconnected);
      _scheduleReconnect();
    }
  }
  
  void _scheduleReconnect() {
    if (_isDisposed) return;
    if (_reconnectAttempt >= _maxReconnectAttempts) {
      logError('Max reconnect attempts reached');
      return;
    }
    
    final delay = _getReconnectDelay();
    _reconnectAttempt++;
    
    logInfo('Scheduling reconnect in ${delay.inSeconds}s (attempt $_reconnectAttempt)');
    _reconnectTimer = Timer(delay, connect);
  }
  
  Duration _getReconnectDelay() {
    // 指数退避: 1s, 2s, 4s, 8s, 16s, 30s
    final baseDelay = Duration(seconds: pow(2, _reconnectAttempt - 1).toInt().clamp(1, 30));
    return baseDelay;
  }
  
  void _sendMessage(dynamic message) {
    if (_channel != null) {
      _channel!.sink.add(json.encode(message));
    }
  }
  
  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      if (_lastHeartbeat != null) {
        final elapsed = DateTime.now().difference(_lastHeartbeat!);
        if (elapsed > _heartbeatInterval * 2) {
          logWarning('Heartbeat timeout, reconnecting...');
          _channel?.sink.close();
          return;
        }
      }
      _sendMessage({'type': 'ping'});
    });
  }
  
  void dispose() {
    disconnect();
    _priceController.close();
    _connectionController.close();
  }
}

/// 行情更新数据模型
class QuoteUpdate {
  final String fundCode;
  final double estimatedNav;
  final double changePercent;
  final double confidence;
  final int volume;
  final DateTime timestamp;
  
  const QuoteUpdate({
    required this.fundCode,
    required this.estimatedNav,
    required this.changePercent,
    required this.confidence,
    required this.volume,
    required this.timestamp,
  });
  
  factory QuoteUpdate.fromJson(Map<String, dynamic> json) {
    return QuoteUpdate(
      fundCode: json['fundCode'] ?? '',
      estimatedNav: (json['estimatedNav'] ?? 0).toDouble(),
      changePercent: (json['changePercent'] ?? 0).toDouble(),
      confidence: (json['confidence'] ?? 0).toDouble(),
      volume: json['volume'] ?? 0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
  
  /// 是否上涨
  bool get isUp => changePercent >= 0;
  
  /// 涨跌幅颜色
  Color get color => isUp ? const Color(0xFF26A69A) : const Color(0xFFEF5350);
}

/// 连接状态
enum ConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

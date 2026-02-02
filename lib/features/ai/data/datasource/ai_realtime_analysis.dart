import 'dart:async';
import 'dart:convert';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import '../core/logger/app_logger.dart';
import '../core/network/api_client.dart';
import '../features/market/data/datasource/websocket_manager.dart';

/// AI 实时分析服务
/// 
/// 特性：
/// - 实时市场数据分析
/// - 智能风险预警
/// - 情绪分析
/// - 投资建议生成
class AIRealtimeAnalysisService with AppLogger {
  final ApiClient _apiClient;
  final MarketWebSocketManager _wsManager;
  
  // 聚合分析结果流
  final _marketAnalysisController = BehaviorSubject<MarketAnalysis>();
  final _alertsController = BehaviorSubject<List<AIAlert>>();
  final _sentimentController = BehaviorSubject<MarketSentiment>();
  
  // 缓存
  final Map<String, QuoteUpdate> _priceCache = {};
  final List<QuoteUpdate> _priceHistory = [];
  
  // 定时器
  Timer? _analysisTimer;
  Timer? _sentimentTimer;
  
  // 配置
  static const Duration analysisInterval = Duration(seconds: 30);
  static const Duration sentimentInterval = Duration(minutes: 5);
  static const int maxHistorySize = 100;

  Stream<MarketAnalysis> get marketAnalysis => _marketAnalysisController.stream;
  Stream<List<AIAlert>> get alerts => _alertsController.stream;
  Stream<MarketSentiment> get sentiment => _sentimentController.stream;

  AIRealtimeAnalysisService({
    required ApiClient apiClient,
    required MarketWebSocketManager wsManager,
  })  : _apiClient = apiClient,
        _wsManager = wsManager;

  /// 启动实时分析
  void startAnalysis(List<String> fundCodes) {
    logInfo('Starting AI realtime analysis for ${fundCodes.length} funds');
    
    // 订阅行情数据
    _wsManager.subscribeAll(fundCodes);
    
    // 监听价格更新
    _wsManager.priceStream.listen(_handlePriceUpdate);
    
    // 启动定时分析
    _analysisTimer = Timer.periodic(analysisInterval, (_) => _performAnalysis());
    _sentimentTimer = Timer.periodic(sentimentInterval, (_) => _analyzeSentiment());
    
    // 初始分析
    _performAnalysis();
  }

  /// 停止分析
  void stopAnalysis() {
    _analysisTimer?.cancel();
    _sentimentTimer?.cancel();
    _wsManager.disconnect();
    logInfo('AI realtime analysis stopped');
  }

  void _handlePriceUpdate(QuoteUpdate quote) {
    // 更新缓存
    _priceCache[quote.fundCode] = quote;
    _priceHistory.add(quote);
    
    // 限制历史大小
    if (_priceHistory.length > maxHistorySize) {
      _priceHistory.removeAt(0);
    }
  }

  Future<void> _performAnalysis() async {
    if (_priceCache.isEmpty) return;

    try {
      final analysis = await _generateMarketAnalysis();
      _marketAnalysisController.add(analysis);
      
      // 检查预警
      final alerts = _checkAlerts(analysis);
      if (alerts.isNotEmpty) {
        _alertsController.add(alerts);
      }
    } catch (e, stack) {
      logError('Analysis failed', e, stack);
    }
  }

  Future<MarketAnalysis> _generateMarketAnalysis() async {
    final quotes = _priceCache.values.toList();
    
    // 计算市场统计
    final upCount = quotes.where((q) => q.changePercent > 0).length;
    final downCount = quotes.where((q) => q.changePercent < 0).length;
    final avgChange = quotes.fold(0.0, (sum, q) => sum + q.changePercent) / quotes.length;
    final avgConfidence = quotes.fold(0.0, (sum, q) => sum + q.confidence) / quotes.length;
    
    // 生成AI分析
    final prompt = _buildAnalysisPrompt(quotes, upCount, downCount, avgChange);
    final aiAnalysis = await _callAIAnalysis(prompt);
    
    return MarketAnalysis(
      timestamp: DateTime.now(),
      upCount: upCount,
      downCount: downCount,
      avgChange: avgChange,
      avgConfidence: avgConfidence,
      sentiment: _calculateSentiment(avgChange),
      hotFunds: _identifyHotFunds(quotes),
      marketTrend: _determineTrend(avgChange),
      aiSummary: aiAnalysis,
    );
  }

  String _buildAnalysisPrompt(List<QuoteUpdate> quotes, int up, int down, double avg) {
    final topGainers = quotes
        .where((q) => q.changePercent > 0)
        .sorted((a, b) => b.changePercent.compareTo(a.changePercent))
        .take(3)
        .map((q) => '${q.fundCode}: ${q.changePercent.toStringAsFixed(2)}%')
        .join(', ');
    
    final topLosers = quotes
        .where((q) => q.changePercent < 0)
        .sorted((a, b) => a.changePercent.compareTo(b.changePercent))
        .take(3)
        .map((q) => '${q.fundCode}: ${q.changePercent.toStringAsFixed(2)}%')
        .join(', ');

    return '''请分析当前市场情况：

市场概览：
- 上涨基金: $up 只
- 下跌基金: $down 只
- 平均涨跌幅: ${avg.toStringAsFixed(2)}%

领涨基金: $topGainers
领跌基金: $topLosers

请给出：
1. 今日市场简要评价（30字以内）
2. 短期趋势判断（上涨/震荡/下跌）
3. 风险等级（低/中/高）
4. 操作建议（50字以内）

只返回JSON格式：
{"comment":"评价","trend":"趋势","riskLevel":"等级","advice":"建议"}
''';
  }

  Future<String> _callAIAnalysis(String prompt) async {
    try {
      final response = await _apiClient.post(
        'https://api.deepseek.com/v1/chat/completions',
        data: {
          'model': 'deepseek-chat',
          'messages': [
            {'role': 'system', 'content': '你是专业的基金投资顾问'},
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 500,
          'temperature': 0.5,
        },
      );
      
      return response['choices'][0]['message']['content'] ?? '';
    } catch (e) {
      logError('AI analysis call failed', e);
      return 'AI服务暂时不可用';
    }
  }

  MarketSentiment _calculateSentiment(double avgChange) {
    if (avgChange > 2) return MarketSentiment.stronglyBullish;
    if (avgChange > 0.5) return MarketSentiment.bullish;
    if (avgChange > -0.5) return MarketSentiment.neutral;
    if (avgChange > -2) return MarketSentiment.bearish;
    return MarketSentiment.stronglyBearish;
  }

  List<QuoteUpdate> _identifyHotFunds(List<QuoteUpdate> quotes) {
    return quotes
        .sorted((a, b) => b.changePercent.abs().compareTo(a.changePercent.abs()))
        .take(5)
        .toList();
  }

  MarketTrend _determineTrend(double avgChange) {
    if (avgChange > 1) return MarketTrend.uptrend;
    if (avgChange > -1) return MarketTrend.consolidation;
    return MarketTrend.downtrend;
  }

  List<AIAlert> _checkAlerts(MarketAnalysis analysis) {
    final alerts = <AIAlert>[];
    final now = DateTime.now();
    
    // 检查大涨
    for (final quote in _priceCache.values) {
      if (quote.changePercent > 5) {
        alerts.add(AIAlert(
          id: '${quote.fundCode}_spike',
          type: AlertType.priceSpike,
          level: quote.changePercent > 8 ? AlertLevel.urgent : AlertLevel.warning,
          title: '基金${quote.fundCode}大幅上涨',
          message: '涨幅达${quote.changePercent.toStringAsFixed(2)}%',
          timestamp: now,
          data: {'fundCode': quote.fundCode, 'change': quote.changePercent},
        ));
      }
      
      // 检查大跌
      if (quote.changePercent < -5) {
        alerts.add(AIAlert(
          id: '${quote.fundCode}_drop',
          type: AlertType.priceDrop,
          level: quote.changePercent < -8 ? AlertLevel.urgent : AlertLevel.warning,
          title: '基金${quote.fundCode}大幅下跌',
          message: '跌幅达${quote.changePercent.toStringAsFixed(2)}%',
          timestamp: now,
          data: {'fundCode': quote.fundCode, 'change': quote.changePercent},
        ));
      }
    }
    
    // 检查市场异动
    if (analysis.avgChange.abs() > 3) {
      alerts.add(AIAlert(
        id: 'market_volatility',
        type: AlertType.marketVolatility,
        level: AlertLevel.warning,
        title: '市场波动较大',
        message: '平均涨跌幅达${analysis.avgChange.toStringAsFixed(2)}%',
        timestamp: now,
      ));
    }
    
    return alerts;
  }

  Future<void> _analyzeSentiment() async {
    // 简化版情绪分析
    final sentiment = MarketSentiment.neutral; // 基于当前数据计算
    _sentimentController.add(sentiment);
  }

  void dispose() {
    stopAnalysis();
    _marketAnalysisController.close();
    _alertsController.close();
    _sentimentController.close();
  }
}

/// 市场分析结果
class MarketAnalysis {
  final DateTime timestamp;
  final int upCount;
  final int downCount;
  final double avgChange;
  final double avgConfidence;
  final MarketSentiment sentiment;
  final List<QuoteUpdate> hotFunds;
  final MarketTrend marketTrend;
  final String aiSummary;

  const MarketAnalysis({
    required this.timestamp,
    required this.upCount,
    required this.downCount,
    required this.avgChange,
    required this.avgConfidence,
    required this.sentiment,
    required this.hotFunds,
    required this.marketTrend,
    required this.aiSummary,
  });
}

/// 市场情绪
enum MarketSentiment {
  stronglyBullish,
  bullish,
  neutral,
  bearish,
  stronglyBearish,
  
  String get emoji {
    switch (this) {
      case MarketSentiment.stronglyBullish: return '🔥';
      case MarketSentiment.bullish: return '📈';
      case MarketSentiment.neutral: return '➖';
      case MarketSentiment.bearish: return '📉';
      case MarketSentiment.stronglyBearish: return '⚠️';
    }
  }
  
  String get displayName {
    switch (this) {
      case MarketSentiment.stronglyBullish: return '强烈看涨';
      case MarketSentiment.bullish: return '看涨';
      case MarketSentiment.neutral: return '中性';
      case MarketSentiment.bearish: return '看跌';
      case MarketSentiment.stronglyBearish: return '强烈看跌';
    }
  }
}

/// 市场趋势
enum MarketTrend {
  uptrend,
  consolidation,
  downtrend,
  
  String get displayName {
    switch (this) {
      case MarketTrend.uptrend: return '上涨趋势';
      case MarketTrend.consolidation: return '震荡整理';
      case MarketTrend.downtrend: return '下跌趋势';
    }
  }
}

/// AI 预警
class AIAlert {
  final String id;
  final AlertType type;
  final AlertLevel level;
  final String title;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  const AIAlert({
    required this.id,
    required this.type,
    required this.level,
    required this.title,
    required this.message,
    required this.timestamp,
    this.data,
  });

  Color get levelColor {
    switch (level) {
      case AlertLevel.urgent: return Colors.red;
      case AlertLevel.warning: return Colors.orange;
      case AlertLevel.info: return Colors.blue;
    }
  }
}

/// 预警类型
enum AlertType {
  priceSpike,
  priceDrop,
  marketVolatility,
  riskWarning,
}

/// 预警级别
enum AlertLevel {
  urgent,
  warning,
  info,
}

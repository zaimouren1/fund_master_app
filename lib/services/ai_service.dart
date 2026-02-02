import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/logger.dart';

/// DeepSeek AI配置
class DeepSeekConfig {
  static const String apiKey = 'sk-96ae91ab330848c98adb150381c3ac66';
  static const String baseUrl = 'https://api.deepseek.com/v1';
  static const String model = 'deepseek-chat';
}

/// AI分析结果
class AIAnalysisResult {
  final String summary;
  final double riskScore;
  final double performanceScore;
  final List<String> strengths;
  final List<String> weaknesses;
  final String? action;
  final String? actionPlan;
  final List<AIRecommendation> recommendations;
  final List<String> riskWarnings;

  AIAnalysisResult({
    required this.summary,
    required this.riskScore,
    required this.performanceScore,
    required this.strengths,
    required this.weaknesses,
    this.action,
    this.actionPlan,
    this.recommendations = const [],
    this.riskWarnings = const [],
  });
}

/// AI推荐
class AIRecommendation {
  final String code;
  final String name;
  final String action;
  final String reason;
  final double confidence;

  AIRecommendation({
    required this.code,
    required this.name,
    required this.action,
    required this.reason,
    required this.confidence,
  });
}

/// DeepSeek AI服务
class AIService {
  static final AIService _instance = AIService._();
  factory AIService() => _instance;
  AIService._();

  final String _apiKey = DeepSeekConfig.apiKey;
  final String _baseUrl = DeepSeekConfig.baseUrl;
  final String _model = DeepSeekConfig.model;

  /// 聊天完成
  Future<String> chat(String message, {String systemPrompt = 'You are a helpful assistant.'}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': message},
          ],
          'stream': false,
          'max_tokens': 2000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'];
      } else {
        Logger.e('AI API请求失败: ${response.statusCode}', tag: LogTags.ai);
        return 'AI服务暂时不可用，请稍后重试。';
      }
    } catch (e) {
      Logger.e('AI请求异常', tag: LogTags.ai, error: e);
      return 'AI服务暂时不可用，请检查网络连接。';
    }
  }

  /// 分析持仓
  Future<AIAnalysisResult> analyzePortfolio(List<dynamic> holdings) async {
    final holdingsJson = json.encode(holdings);
    
    const systemPrompt = '''你是一位专业的基金投资顾问，擅长分析基金持仓并给出专业建议。''';

    final userPrompt = '''请分析以下基金持仓数据：

$holdingsJson

请从以下维度提供分析：
1. 整体配置评价（50字以内）
2. 风险评估（0-100分）
3. 表现评分（0-100分）
4. 建议操作（买入/卖出/持有/加仓/减仓）
5. 具体基金推荐或替换建议（如果有）
6. 风险提示

请用JSON格式回复，包含以下字段：
- summary: 整体评价
- riskScore: 风险评分(0-100)
- performanceScore: 表现评分(0-100)
- action: 建议操作
- actionPlan: 行动方案简述
- strengths: [优势列表]
- weaknesses: [劣势列表]
- recommendations: [{code, name, action, reason, confidence}]
- riskWarnings: [风险提示列表]

只返回JSON，不要有其他文字。''';

    try {
      final response = await chat(userPrompt, systemPrompt: systemPrompt);
      
      // 解析JSON响应
      return _parseAnalysisResult(response);
    } catch (e) {
      Logger.e('持仓分析失败', tag: LogTags.ai, error: e);
      return AIAnalysisResult(
        summary: 'AI分析暂时不可用，请稍后重试',
        riskScore: 50,
        performanceScore: 50,
        strengths: [],
        weaknesses: [],
        riskWarnings: [],
      );
    }
  }

  /// 诊断单只基金
  Future<String> diagnoseFund(String code, String name, double nav, double dayChange) async {
    final userPrompt = '''请分析基金 $name ($code)：

- 当前净值: $nav
- 日涨跌: ${dayChange >= 0 ? '+' : ''}${dayChange.toStringAsFixed(2)}%

请从以下方面提供简要分析：
1. 当前估值是否合理
2. 今日表现解读
3. 短期操作建议（20字以内）

简洁回复，50字以内。''';

    return chat(userPrompt);
  }

  /// 生成市场简评
  Future<String> generateMarketCommentary() async {
    const userPrompt = '''请用50字以内简要评价今日A股市场表现，包括：
- 今日大盘走势
- 主要影响因素
- 投资者应注意什么

简洁专业，不要太乐观或悲观。''';

    return chat(userPrompt);
  }

  /// 解析分析结果
  AIAnalysisResult _parseAnalysisResult(String response) {
    try {
      // 尝试清理响应文本（去除markdown标记）
      final cleanResponse = response
          .replaceAll(RegExp(r'```json'), '')
          .replaceAll(RegExp(r'```'), '')
          .trim();

      final json = jsonDecode(cleanResponse);
      
      return AIAnalysisResult(
        summary: json['summary'] ?? '',
        riskScore: (json['riskScore'] ?? 50).toDouble(),
        performanceScore: (json['performanceScore'] ?? 50).toDouble(),
        strengths: List<String>.from(json['strengths'] ?? []),
        weaknesses: List<String>.from(json['weaknesses'] ?? []),
        action: json['action'],
        actionPlan: json['actionPlan'],
        recommendations: (json['recommendations'] as List?)
            ?.map((r) => AIRecommendation(
                  code: r['code'] ?? '',
                  name: r['name'] ?? '',
                  action: r['action'] ?? '',
                  reason: r['reason'] ?? '',
                  confidence: (r['confidence'] ?? 0.5).toDouble(),
                ))
            .toList() ?? [],
        riskWarnings: List<String>.from(json['riskWarnings'] ?? []),
      );
    } catch (e) {
      Logger.e('解析AI响应失败', tag: LogTags.ai, error: e);
      return AIAnalysisResult(
        summary: 'AI分析暂时不可用',
        riskScore: 50,
        performanceScore: 50,
        strengths: [],
        weaknesses: [],
        riskWarnings: [],
      );
    }
  }
}

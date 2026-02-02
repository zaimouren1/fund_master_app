import 'dart:async';
import 'dart:convert';
import 'package:rxdart/rxdart.dart';
import '../core/network/api_client.dart';
import '../core/logger/app_logger.dart';

/// AI 智能投顾服务
/// 
/// 特性：
/// - 自然语言对话
/// - 上下文理解
/// - 投资建议生成
/// - 风险提示
class AIInvestmentAdvisor with AppLogger {
  final ApiClient _apiClient;
  
  final _messagesController = BehaviorSubject<List<ChatMessage>>();
  final _isTypingController = BehaviorSubject<bool>();
  
  // 对话历史
  final List<ChatMessage> _messageHistory = [];
  
  // 用户画像（缓存）
  UserProfile? _userProfile;
  
  Stream<List<ChatMessage>> get messages => _messagesController.stream;
  Stream<bool> get isTyping => _isTypingController.stream;

  AIInvestmentAdvisor({required ApiClient apiClient}) : _apiClient = apiClient;

  /// 发送消息
  Future<String> sendMessage(String content) async {
    if (content.trim().isEmpty) return '请输入有效内容';

    // 添加用户消息
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.user,
      content: content.trim(),
      timestamp: DateTime.now(),
    );
    _addMessage(userMessage);

    try {
      _isTypingController.add(true);
      
      // 生成回复
      final response = await _generateResponse(userMessage);
      
      // 添加AI回复
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: MessageRole.assistant,
        content: response,
        timestamp: DateTime.now(),
      );
      _addMessage(aiMessage);
      
      return response;
    } catch (e, stack) {
      logError('Failed to generate response', e, stack);
      final errorMessage = '抱歉，我遇到了一些问题。请稍后再试。';
      _addMessage(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: MessageRole.assistant,
        content: errorMessage,
        timestamp: DateTime.now(),
      ));
      return errorMessage;
    } finally {
      _isTypingController.add(false);
    }
  }

  Future<String> _generateResponse(ChatMessage message) async {
    // 构建上下文
    final context = _buildContext();
    final messages = [...context, {'role': 'user', 'content': message.content}];

    try {
      final response = await _apiClient.post(
        'https://api.deepseek.com/v1/chat/completions',
        data: {
          'model': 'deepseek-chat',
          'messages': messages,
          'max_tokens': 1500,
          'temperature': 0.7,
        },
      );
      
      return response['choices'][0]['message']['content'] ?? '抱歉，我没有理解您的问题。';
    } catch (e) {
      logError('API call failed', e);
      rethrow;
    }
  }

  List<Map<String, String>> _buildContext() {
    final context = <Map<String, String>>[];
    
    // 系统提示
    context.add({
      'role': 'system',
      'content': _getSystemPrompt(),
    });
    
    // 添加历史消息（最多最近10条）
    final recentMessages = _messageHistory.take(10);
    for (final msg in recentMessages) {
      context.add({
        'role': msg.role.value,
        'content': msg.content,
      });
    }
    
    return context;
  }

  String _getSystemPrompt() {
    return '''你是AlphaFund的AI投资顾问，一位拥有15年经验的CFA特许金融分析师。

你的职责：
1. 提供专业的基金投资建议
2. 用通俗易懂的语言解释复杂的金融概念
3. 根据用户风险偏好给出个性化建议
4. 提醒投资风险，但不制造恐慌

注意事项：
- 实时估值为模拟推算，仅供参考
- 不承诺收益，不保证准确
- 建议用户分散投资，长期持有
- 遇到无法回答的问题，诚实说明

当前用户画像：${_userProfile?.toJson() ?? '未知'}''';
  }

  void _addMessage(ChatMessage message) {
    _messageHistory.add(message);
    if (_messageHistory.length > 50) {
      _messageHistory.removeAt(0);
    }
    _messagesController.add(List.unmodifiable(_messageHistory));
  }

  /// 设置用户画像
  void setUserProfile(UserProfile profile) {
    _userProfile = profile;
  }

  /// 清空对话
  void clearConversation() {
    _messageHistory.clear();
    _messagesController.add([]);
  }

  /// 快速提问
  Future<String> quickAsk(String question) async {
    // 预设的快捷问题快速回答
    final quickAnswers = {
      '今天市场怎么样': '今日市场整体${_getMarketStatus()}，建议关注成交量变化。',
      '推荐基金': '请告诉我您的风险偏好和投资期限，我会为您推荐合适的基金。',
      '什么是ETF': 'ETF(交易型开放式指数基金)是一种在交易所上市的基金，兼具股票和基金的特点。',
      '如何分散投资': '建议配置不同行业、不同地区的基金，通常3-5只即可。',
    };

    for (final entry in quickAnswers.entries) {
      if (question.contains(entry.key)) {
        return entry.value;
      }
    }

    return sendMessage(question);
  }

  String _getMarketStatus() {
    // 简化的市场状态判断
    return '表现平稳';
  }

  void dispose() {
    _messagesController.close();
    _isTypingController.close();
  }
}

/// 聊天消息
class ChatMessage {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;
}

/// 消息角色
enum MessageRole {
  system,
  user,
  assistant;

  String get value {
    switch (this) {
      case MessageRole.system: return 'system';
      case MessageRole.user: return 'user';
      case MessageRole.assistant: return 'assistant';
    }
  }
}

/// 用户画像
class UserProfile {
  final RiskLevel riskLevel;
  final InvestmentGoal goal;
  final double? investAmount;
  final int? investmentPeriod; // 月

  const UserProfile({
    required this.riskLevel,
    required this.goal,
    this.investAmount,
    this.investmentPeriod,
  });

  String toJson() {
    return '风险偏好: ${riskLevel.displayName}, 投资目标: ${goal.displayName}';
  }
}

/// 风险等级
enum RiskLevel {
  conservative,
  moderate,
  aggressive;

  String get displayName {
    switch (this) {
      case RiskLevel.conservative: return '保守型';
      case RiskLevel.moderate: return '稳健型';
      case RiskLevel.aggressive: return '进取型';
    }
  }
}

/// 投资目标
enum InvestmentGoal {
  preserveCapital,
  steadyGrowth,
  aggressiveGrowth,
  income;

  String get displayName {
    switch (this) {
      case InvestmentGoal.preserveCapital: return '保本为主';
      case InvestmentGoal.steadyGrowth: return '稳健增长';
      case InvestmentGoal.aggressiveGrowth: return '积极增值';
      case InvestmentGoal.income: return '获取收益';
    }
  }
}

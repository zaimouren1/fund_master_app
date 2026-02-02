class FundModel {
  final String code;
  final String name;
  final double nav;
  final double dayChange;
  final double? weekChange;
  final double? monthChange;
  final double? yearChange;
  final double? sharpeRatio;
  final double? maxDrawdown;
  final int? recommendLevel;
  final double? confidence;
  final String? updateTime;

  FundModel({
    required this.code,
    required this.name,
    required this.nav,
    required this.dayChange,
    this.weekChange,
    this.monthChange,
    this.yearChange,
    this.sharpeRatio,
    this.maxDrawdown,
    this.recommendLevel,
    this.confidence,
    this.updateTime,
  });

  factory FundModel.fromJson(Map<String, dynamic> json) {
    return FundModel(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      nav: (json['nav'] ?? 0).toDouble(),
      dayChange: (json['dayChange'] ?? 0).toDouble(),
      weekChange: json['weekChange']?.toDouble(),
      monthChange: json['monthChange']?.toDouble(),
      yearChange: json['yearChange']?.toDouble(),
      sharpeRatio: json['sharpeRatio']?.toDouble(),
      maxDrawdown: json['maxDrawdown']?.toDouble(),
      recommendLevel: json['recommendLevel'],
      confidence: json['confidence']?.toDouble(),
      updateTime: json['updateTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'nav': nav,
      'dayChange': dayChange,
      'weekChange': weekChange,
      'monthChange': monthChange,
      'yearChange': yearChange,
      'sharpeRatio': sharpeRatio,
      'maxDrawdown': maxDrawdown,
      'recommendLevel': recommendLevel,
      'confidence': confidence,
      'updateTime': updateTime,
    };
  }
}

class HoldingModel {
  final String code;
  final String name;
  final double amount;
  final double cost;
  final double? currentNav;
  final double? profit;
  final double? profitPercent;
  final String? addDate;
  final String? notes;

  HoldingModel({
    required this.code,
    required this.name,
    required this.amount,
    required this.cost,
    this.currentNav,
    this.profit,
    this.profitPercent,
    this.addDate,
    this.notes,
  });

  factory HoldingModel.fromJson(Map<String, dynamic> json) {
    return HoldingModel(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      cost: (json['cost'] ?? 0).toDouble(),
      currentNav: json['currentNav']?.toDouble(),
      profit: json['profit']?.toDouble(),
      profitPercent: json['profitPercent']?.toDouble(),
      addDate: json['addDate'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'amount': amount,
      'cost': cost,
      'currentNav': currentNav,
      'profit': profit,
      'profitPercent': profitPercent,
      'addDate': addDate,
      'notes': notes,
    };
  }
}

class SuggestionModel {
  final String code;
  final String name;
  final String action; // 买入/卖出/持有/加仓/减仓
  final String reason;
  final double confidence;
  final double currentNav;
  final double? targetPrice;
  final double? stopLoss;

  SuggestionModel({
    required this.code,
    required this.name,
    required this.action,
    required this.reason,
    required this.confidence,
    required this.currentNav,
    this.targetPrice,
    this.stopLoss,
  });

  factory SuggestionModel.fromJson(Map<String, dynamic> json) {
    return SuggestionModel(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      action: json['action'] ?? '',
      reason: json['reason'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
      currentNav: (json['currentNav'] ?? 0).toDouble(),
      targetPrice: json['targetPrice']?.toDouble(),
      stopLoss: json['stopLoss']?.toDouble(),
    );
  }
}

/// 板块类型
enum SectorType {
  industry,
  concept,
  capitalFlow,
  
  String get displayName {
    switch (this) {
      case SectorType.industry: return '行业';
      case SectorType.concept: return '概念';
      case SectorType.capitalFlow: return '资金流向';
    }
  }
}

/// 板块模型
class SectorModel {
  final String id;
  final String name;
  final SectorType type;
  final int fundCount;
  final double volume;
  final double mainInflow;
  final double changePercent;
  final FundModel leadFund;
  
  const SectorModel({
    required this.id,
    required this.name,
    required this.type,
    required this.fundCount,
    required this.volume,
    required this.mainInflow,
    required this.changePercent,
    required this.leadFund,
  });
  
  factory SectorModel.fromJson(Map<String, dynamic> json) {
    return SectorModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: _parseSectorType(json['type']),
      fundCount: json['fundCount'] ?? 0,
      volume: (json['volume'] ?? 0).toDouble(),
      mainInflow: (json['mainInflow'] ?? 0).toDouble(),
      changePercent: (json['changePercent'] ?? 0).toDouble(),
      leadFund: FundModel.fromJson(json['leadFund'] ?? {}),
    );
  }
  
  static SectorType _parseSectorType(dynamic type) {
    if (type == null) return SectorType.industry;
    final typeStr = type.toString().toLowerCase();
    if (typeStr == 'industry') return SectorType.industry;
    if (typeStr == 'concept') return SectorType.concept;
    if (typeStr == 'capitalflow' || typeStr == 'capital_flow') return SectorType.capitalFlow;
    return SectorType.industry;
  }
}

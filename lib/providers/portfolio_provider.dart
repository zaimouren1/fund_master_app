import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/fund_models.dart';
import 'fund_provider.dart';

class PortfolioProvider with ChangeNotifier {
  List<HoldingModel> _holdings = [];
  double _totalProfit = 0;
  double _todayChange = 0;
  List<SuggestionModel> _suggestions = [];

  List<HoldingModel> get holdings => _holdings;
  double get totalProfit => _totalProfit;
  double get todayChange => _todayChange;
  List<SuggestionModel> get suggestions => _suggestions;

  PortfolioProvider() {
    _loadPortfolio();
  }

  Future<void> _loadPortfolio() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> holdingStrs = prefs.getStringList('holdings') ?? [];
    
    _holdings = holdingStrs.map((str) {
      return HoldingModel.fromJson(json.decode(str));
    }).toList();
    
    notifyListeners();
  }

  Future<void> _savePortfolio() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> holdingStrs = _holdings.map((h) {
      return json.encode(h.toJson());
    }).toList();
    
    await prefs.setStringList('holdings', holdingStrs);
  }

  void addHolding(HoldingModel holding) {
    // 检查是否已存在
    final existing = _holdings.indexWhere((h) => h.code == holding.code);
    if (existing >= 0) {
      _holdings[existing] = holding;
    } else {
      _holdings.add(holding);
    }
    _savePortfolio();
    notifyListeners();
  }

  void removeHolding(String code) {
    _holdings.removeWhere((h) => h.code == code);
    _savePortfolio();
    notifyListeners();
  }

  void updateCost(String code, double newCost) {
    final index = _holdings.indexWhere((h) => h.code == code);
    if (index >= 0) {
      final old = _holdings[index];
      _holdings[index] = HoldingModel(
        code: old.code,
        name: old.name,
        amount: old.amount,
        cost: newCost,
        currentNav: old.currentNav,
        addDate: old.addDate,
        notes: old.notes,
      );
      _savePortfolio();
      notifyListeners();
    }
  }

  Future<void> refreshEstimates(FundProvider fundProvider) async {
    _totalProfit = 0;
    _todayChange = 0;
    
    for (final holding in _holdings) {
      final fund = await fundProvider.fetchFundNav(holding.code);
      if (fund != null) {
        final profit = (fund.nav - holding.cost) * holding.amount;
        final profitPercent = (fund.nav - holding.cost) / holding.cost * 100;
        
        // 更新持仓信息
        final index = _holdings.indexOf(holding);
        _holdings[index] = HoldingModel(
          code: holding.code,
          name: holding.name,
          amount: holding.amount,
          cost: holding.cost,
          currentNav: fund.nav,
          profit: profit,
          profitPercent: profitPercent,
          addDate: holding.addDate,
          notes: holding.notes,
        );
        
        _totalProfit += profit;
        _todayChange += fund.dayChange * holding.amount * fund.nav;
      }
    }
    
    // 生成操作建议
    _generateSuggestions();
    _savePortfolio();
    notifyListeners();
  }

  void _generateSuggestions() {
    _suggestions = [];
    
    for (final holding in _holdings) {
      if (holding.currentNav == null) continue;
      
      final returnPercent = (holding.currentNav! - holding.cost) / holding.cost * 100;
      
      String action;
      String reason;
      double confidence;
      
      // 简单策略逻辑
      if (returnPercent > 30) {
        action = '减仓';
        reason = '已盈利${returnPercent.toStringAsFixed(1)}%，建议锁利';
        confidence = 0.75;
      } else if (returnPercent > 15) {
        if (holding.profitPercent != null && holding.profitPercent! > 0) {
          action = '持有';
          reason = '基金表现良好，继续持有';
          confidence = 0.70;
        } else {
          action = '持有';
          reason = '温和上涨，持有观察';
          confidence = 0.65;
        }
      } else if (returnPercent > 5) {
        action = '持有';
        reason = '小幅盈利，持有待涨';
        confidence = 0.60;
      } else if (returnPercent > -5) {
        action = '持有';
        reason = '接近成本，持有观察';
        confidence = 0.65;
      } else if (returnPercent > -15) {
        action = '加仓';
        reason = '可逢低加仓摊薄成本';
        confidence = 0.55;
      } else {
        action = '止损';
        reason = '亏损较大，控制风险';
        confidence = 0.60;
      }
      
      _suggestions.add(SuggestionModel(
        code: holding.code,
        name: holding.name,
        action: action,
        reason: reason,
        confidence: confidence,
        currentNav: holding.currentNav!,
      ));
    }
  }
}

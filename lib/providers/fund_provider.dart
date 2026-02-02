import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import '../models/fund_models.dart';

class FundProvider with ChangeNotifier {
  List<FundModel> _hotFunds = [];
  Map<String, List<FundModel>> _sectorFunds = {};
  bool _isLoading = false;
  String _error = '';

  List<FundModel> get hotFunds => _hotFunds;
  Map<String, List<FundModel>> get sectorFunds => _sectorFunds;
  bool get isLoading => _isLoading;
  String get error => _error;

  // 热门基金列表
  final List<String> _hotFundCodes = [
    '161725', // 招商中证白酒
    '005827', // 易方达蓝筹精选
    '020274', // 富国化工
    '110022', // 易方达消费
    '001594', // 天弘中证银行
    '005196', // 易方达国防军工
    '006663', // 鹏华养老2035
    '512010', // 医药ETF
  ];

  Future<FundModel?> fetchFundNav(String code) async {
    try {
      // 天天基金估值API
      final url = 'http://fundgz.1234567.com.cn/js/$code.js';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        // 天天基金API返回GBK编码，需要特殊处理
        String jsonStr;
        try {
          // 尝试UTF-8解码
          jsonStr = utf8.decode(response.bodyBytes);
        } catch (e) {
          // UTF-8失败则使用latin1（GBK兼容）
          jsonStr = latin1.decode(response.bodyBytes);
        }
        
        final start = jsonStr.indexOf('(') + 1;
        final end = jsonStr.lastIndexOf(')');
        if (start > 0 && end > start) {
          final jsonData = jsonStr.substring(start, end);
          final data = json.decode(jsonData);
          
          return FundModel(
            code: code,
            name: data['name'] ?? '未知基金',
            nav: double.tryParse(data['gz'] ?? '0') ?? 0,
            dayChange: double.tryParse(data['gsz'] ?? '0') ?? 0,
            updateTime: data['gztime'] ?? '',
          );
        }
      }
    } catch (e) {
      print('获取基金$code估值失败: $e');
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> fetchFundHistory(String code, {int days = 90}) async {
    try {
      // 东方财富历史净值API
      final url = 'http://api.fund.eastmoney.com/f10/lszh';
      final params = {
        'fundCode': code,
        'pageIndex': '1',
        'pageSize': days.toString(),
        'type': 'ALL',
        'rt': DateTime.now().millisecondsSinceEpoch.toString(),
      };
      
      final response = await http.get(Uri.parse('$url?${Uri(queryParameters: params).query}'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['Data'] != null && data['Data']['LSZHList'] != null) {
          final List<dynamic> list = data['Data']['LSZHList'];
          return list.map((item) {
            return {
              'date': item['FSRQ'],
              'nav': double.tryParse(item['NAV'] ?? '0') ?? 0,
              'accNav': double.tryParse(item['ACCNAV'] ?? '0') ?? 0,
              'change': double.tryParse(item['DWSS'] ?? '0') ?? 0,
            };
          }).toList();
        }
      }
    } catch (e) {
      print('获取基金$code历史失败: $e');
    }
    return [];
  }

  Future<Map<String, double>> analyzeFund(String code) async {
    // 获取历史数据计算分析指标
    final history = await fetchFundHistory(code);
    
    if (history.isEmpty) return {};
    
    // 计算收益率
    final weekReturn = _calcPeriodReturn(history, 7);
    final monthReturn = _calcPeriodReturn(history, 30);
    final yearReturn = _calcPeriodReturn(history, 365);
    
    // 计算夏普比率
    final sharpe = _calcSharpeRatio(history);
    
    // 计算最大回撤
    final maxDrawdown = _calcMaxDrawdown(history);
    
    return {
      'weekReturn': weekReturn,
      'monthReturn': monthReturn,
      'yearReturn': yearReturn,
      'sharpeRatio': sharpe,
      'maxDrawdown': maxDrawdown,
    };
  }

  double _calcPeriodReturn(List<Map<String, dynamic>> history, int days) {
    if (history.length < days) return 0;
    final endNav = history[0]['nav'] as double;
    final startNav = history[days-1]['nav'] as double;
    if (startNav == 0) return 0;
    return (endNav - startNav) / startNav * 100;
  }

  double _calcSharpeRatio(List<Map<String, dynamic>> history, {double riskFree = 0.03}) {
    if (history.length < 30) return 0;
    
    List<double> returns = [];
    for (int i = 1; i < history.length && i <= 180; i++) {
      final prev = history[i]['nav'] as double;
      final curr = history[i-1]['nav'] as double;
      if (prev > 0) {
        returns.add((curr - prev) / prev);
      }
    }
    
    if (returns.length < 10) return 0;
    
    final avgReturn = returns.reduce((a, b) => a + b) / returns.length * 252;
    final variance = returns.map((r) => pow(r - avgReturn / 252, 2)).reduce((a, b) => a + b) / returns.length;
    final std = sqrt(variance) * sqrt(252);
    
    if (std == 0) return 0;
    return (avgReturn - riskFree) / std;
  }

  double _calcMaxDrawdown(List<Map<String, dynamic>> history) {
    if (history.length < 10) return 0;
    
    double maxNav = 0;
    double maxDD = 0;
    
    for (final item in history) {
      final nav = item['nav'] as double;
      if (nav > maxNav) {
        maxNav = nav;
      } else {
        final dd = (maxNav - nav) / maxNav * 100;
        if (dd > maxDD) maxDD = dd;
      }
    }
    
    return maxDD;
  }

  Future<void> refreshAll() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _hotFunds.clear();
      // 获取热门基金估值
      for (final code in _hotFundCodes) {
        final fund = await fetchFundNav(code);
        if (fund != null) {
          _hotFunds.add(fund);
        }
      }
      
      // 按评分排序
      _hotFunds.sort((a, b) => b.dayChange.compareTo(a.dayChange));
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

import 'package:flutter/foundation.dart';
import '../services/market_service.dart';
import '../models/fund_models.dart';

/// 行情状态管理
class MarketProvider with ChangeNotifier {
  final MarketService _service = MarketService();
  
  // 状态
  List<SectorModel> _sectors = [];
  bool _isLoading = false;
  String _error = '';
  
  // Getter
  List<SectorModel> get sectors => _sectors;
  bool get isLoading => _isLoading;
  String get error => _error;
  
  /// 加载板块数据
  Future<void> loadSectors() async {
    if (_sectors.isNotEmpty) return;
    
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    try {
      _sectors = await _service.fetchAllSectors();
    } catch (e) {
      _error = '加载板块数据失败: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// 下拉刷新
  Future<void> refresh() async {
    _sectors.clear();
    await loadSectors();
  }
}

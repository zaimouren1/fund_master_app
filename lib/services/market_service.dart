import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'logger.dart';
import '../models/fund_models.dart';

/// 板块详情
class SectorDetail {
  final String id;
  final String name;
  final String? description;
  final double changePercent;
  final double changeAmount;
  final double? turnoverRate;
  final double? capitalFlow;
  final List<FundModel> funds;
  final List<String> relatedNews;

  SectorDetail({
    required this.id,
    required this.name,
    this.description,
    required this.changePercent,
    required this.changeAmount,
    this.turnoverRate,
    this.capitalFlow,
    required this.funds,
    this.relatedNews = const [],
  });
}

/// 行情服务
class MarketService {
  static final MarketService _instance = MarketService._();
  factory MarketService() => _instance;
  MarketService._();

  // 模拟板块数据（实际应从API获取）
  final List<FundModels.SectorModel> _industrySectors = [
    FundModels.SectorModel(id: '1', name: '食品饮料', type: FundModels.SectorType.industry, fundCount: 156, volume: 12500000000, mainInflow: 850000000, changePercent: 2.35, leadFund: FundModel(code: '161725', name: '招商中证白酒', nav: 1.25, dayChange: 3.21)),
    FundModels.SectorModel(id: '2', name: '医药生物', type: FundModels.SectorType.industry, fundCount: 203, volume: 9800000000, mainInflow: 620000000, changePercent: 1.87, leadFund: FundModel(code: '512010', name: '医药ETF', nav: 0.85, dayChange: 2.45)),
    FundModels.SectorModel(id: '3', name: '电子', type: FundModels.SectorType.industry, fundCount: 189, volume: 15600000000, mainInflow: -320000000, changePercent: -0.85, leadFund: FundModel(code: '512480', name: '芯片ETF', nav: 0.65, dayChange: -1.23)),
    FundModels.SectorModel(id: '4', name: '新能源', type: FundModels.SectorType.industry, fundCount: 167, volume: 22000000000, mainInflow: 1250000000, changePercent: 3.12, leadFund: FundModel(code: '516160', name: '新能源车ETF', nav: 1.85, dayChange: 4.56)),
    FundModels.SectorModel(id: '5', name: '银行', type: FundModels.SectorType.industry, fundCount: 98, volume: 5800000000, mainInflow: 120000000, changePercent: 0.45, leadFund: FundModel(code: '001594', name: '天弘中证银行', nav: 1.12, dayChange: 0.89)),
    FundModels.SectorModel(id: '6', name: '非银金融', type: FundModels.SectorType.industry, fundCount: 87, volume: 7200000000, mainInflow: 450000000, changePercent: 1.23, leadFund: FundModel(code: '512800', name: '券商ETF', nav: 0.95, dayChange: 2.15)),
    FundModels.SectorModel(id: '7', name: '房地产', type: FundModels.SectorType.industry, fundCount: 76, volume: 3500000000, mainInflow: -380000000, changePercent: -1.25, leadFund: FundModel(code: '512200', name: '房地产ETF', nav: 0.75, dayChange: -1.87)),
    FundModels.SectorModel(id: '8', name: '军工', type: FundModels.SectorType.industry, fundCount: 112, volume: 6800000000, mainInflow: 720000000, changePercent: 2.01, leadFund: FundModel(code: '005196', name: '易方达国防军工', nav: 1.45, dayChange: 2.78)),
  ];

  final List<FundModels.SectorModel> _conceptSectors = [
    FundModels.SectorModel(id: 'c1', name: '新能源车', type: FundModels.SectorType.concept, fundCount: 89, volume: 18500000000, mainInflow: 1850000000, changePercent: 4.25, leadFund: FundModel(code: '159806', name: '新能源车ETF', nav: 2.15, dayChange: 5.32)),
    FundModels.SectorModel(id: 'c2', name: '半导体', type: FundModels.SectorType.concept, fundCount: 76, volume: 12500000000, mainInflow: -580000000, changePercent: -1.52, leadFund: FundModel(code: '512480', name: '芯片ETF', nav: 0.65, dayChange: -2.15)),
    FundModels.SectorModel(id: 'c3', name: '白酒', type: FundModels.SectorType.concept, fundCount: 45, volume: 9500000000, mainInflow: 950000000, changePercent: 2.85, leadFund: FundModel(code: '161725', name: '招商中证白酒', nav: 1.25, dayChange: 3.21)),
    FundModels.SectorModel(id: 'c4', name: '人工智能', type: FundModels.SectorType.concept, fundCount: 134, volume: 16800000000, mainInflow: 520000000, changePercent: 1.68, leadFund: FundModel(code: '512710', name: '人工智能ETF', nav: 1.35, dayChange: 2.35)),
    FundModels.SectorModel(id: 'c5', name: 'CXO', type: FundModels.SectorType.concept, fundCount: 32, volume: 4200000000, mainInflow: 1250000000, changePercent: 3.45, leadFund: FundModel(code: '011855', name: '易方达医药创新', nav: 0.95, dayChange: 4.12)),
  ];

  /// 获取所有板块
  Future<List<FundModels.SectorModel>> fetchAllSectors() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return [..._industrySectors, ..._conceptSectors];
    } catch (e) {
      Logger.e('获取板块数据失败', tag: LogTags.data, error: e);
      return [];
    }
  }

  /// 获取行业板块
  Future<List<FundModels.SectorModel>> fetchIndustrySectors() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _industrySectors;
  }

  /// 获取概念板块
  Future<List<FundModels.SectorModel>> fetchConceptSectors() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _conceptSectors;
  }

  /// 获取板块详情
  Future<SectorDetail> fetchSectorDetail(String sectorId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final sector = [..._industrySectors, ..._conceptSectors].firstWhere(
      (s) => s.id == sectorId,
      orElse: () => FundModels.SectorModel(id: '', name: '未知', type: FundModels.SectorType.industry, fundCount: 0, volume: 0, mainInflow: 0, changePercent: 0, leadFund: FundModel(code: '', name: '', nav: 0, dayChange: 0)),
    );
    
    final funds = await _fetchSectorFunds(sector.name);
    
    return SectorDetail(
      id: sector.id,
      name: sector.name,
      changePercent: sector.changePercent,
      changeAmount: sector.mainInflow,
      turnoverRate: 3.5,
      capitalFlow: 15.8,
      funds: funds,
      relatedNews: ['${sector.name}板块今日表现活跃'],
    );
  }

  /// 获取板块内基金列表
  Future<List<FundModel>> _fetchSectorFunds(String sectorName) async {
    final fundCodes = ['161725', '005827', '020274', '110022', '001594', '005196', '512010', '516160'];
    final List<FundModel> funds = [];
    for (final code in fundCodes) {
      funds.add(FundModel(
        code: code,
        name: '基金$code',
        nav: 1.0 + (code.hashCode % 100) / 1000,
        dayChange: (code.hashCode % 200 - 100) / 100,
        updateTime: DateTime.now().toString().substring(0, 16),
      ));
    }
    return funds;
  }

  /// 搜索板块
  Future<List<FundModels.SectorModel>> searchSectors(String keyword) async {
    final allSectors = [..._industrySectors, ..._conceptSectors];
    return allSectors.where((s) => s.name.contains(keyword)).toList();
  }

  /// 获取涨跌幅排行榜
  Future<List<FundModels.SectorModel>> getSectorRanking({bool ascending = false}) async {
    final allSectors = [..._industrySectors, ..._conceptSectors];
    allSectors.sort((a, b) => ascending ? a.changePercent.compareTo(b.changePercent) : b.changePercent.compareTo(a.changePercent));
    return allSectors;
  }
}

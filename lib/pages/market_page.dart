import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/market_provider.dart';
import '../../models/fund_models.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    Future.microtask(() => Provider.of<MarketProvider>(context, listen: false).loadSectors());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTabBar(),
        Expanded(child: _buildTabView()),
      ],
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      indicator: BoxDecoration(
        color: const Color(0xFF1E40AF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      labelColor: const Color(0xFF1E40AF),
      unselectedLabelColor: Colors.grey[600],
      padding: const EdgeInsets.symmetric(horizontal: 16),
      tabs: const [
        Tab(text: '全部'),
        Tab(text: '行业'),
        Tab(text: '概念'),
        Tab(text: '资金流向'),
      ],
    );
  }

  Widget _buildTabView() {
    return Consumer<MarketProvider>(
      builder: (context, provider, child) {
        final sectors = provider.sectors;
        if (provider.isLoading && sectors.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (sectors.isEmpty) {
          return const Center(child: Text('暂无板块数据'));
        }
        return _buildSectorList(sectors);
      },
    );
  }

  Widget _buildSectorList(List<FundModels.SectorModel> sectors) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sectors.length,
      itemBuilder: (context, index) {
        final sector = sectors[index];
        return _SectorCard(sector: sector);
      },
    );
  }
}

class _SectorCard extends StatelessWidget {
  final FundModels.SectorModel sector;

  const _SectorCard({required this.sector});

  @override
  Widget build(BuildContext context) {
    final changeColor = sector.changePercent >= 0 ? Colors.green : Colors.red;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _navigateToDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getTypeColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      sector.type.displayName,
                      style: TextStyle(color: _getTypeColor(), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      sector.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: changeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${sector.changePercent >= 0 ? '+' : ''}${sector.changePercent.toStringAsFixed(2)}%',
                      style: TextStyle(color: changeColor, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStat(Icons.folder, '${sector.fundCount}只基金'),
                  const SizedBox(width: 24),
                  _buildStat(Icons.show_chart, '成交额 ${_formatVolume(sector.volume)}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(value, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      ],
    );
  }

  String _formatVolume(double volume) {
    if (volume >= 100000000) return '${(volume / 100000000).toStringAsFixed(1)}亿';
    if (volume >= 10000) return '${(volume / 10000).toStringAsFixed(1)}万';
    return volume.toStringAsFixed(0);
  }

  Color _getTypeColor() {
    switch (sector.type) {
      case FundModels.SectorType.industry: return const Color(0xFF3B82F6);
      case FundModels.SectorType.concept: return const Color(0xFF8B5CF6);
      case FundModels.SectorType.capitalFlow: return const Color(0xFF10B981);
    }
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SectorDetailPage(sector: sector)),
    );
  }
}

class SectorDetailPage extends StatelessWidget {
  final FundModels.SectorModel sector;

  const SectorDetailPage({super.key, required this.sector});

  @override
  Widget build(BuildContext context) {
    final changeColor = sector.changePercent >= 0 ? Colors.green : Colors.red;
    
    return Scaffold(
      appBar: AppBar(title: Text(sector.name), centerTitle: true),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF1E40AF).withOpacity(0.8), const Color(0xFF06B6D4).withOpacity(0.8)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(sector.type.displayName, style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                    const Spacer(),
                    Text(DateFormat('HH:mm').format(DateTime.now()), style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${sector.changePercent >= 0 ? '+' : ''}${sector.changePercent.toStringAsFixed(2)}%',
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat('基金数量', '${sector.fundCount}只'),
                    _buildStat('成交额', _formatVolume(sector.volume)),
                    _buildStat('主力净流入', _formatVolume(sector.mainInflow)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 10,
              itemBuilder: (context, index) {
                final change = (index % 2 == 0 ? 1 : -1) * (index * 0.5);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF1E40AF).withOpacity(0.1),
                      child: Text('${index + 1}', style: const TextStyle(color: Color(0xFF1E40AF), fontWeight: FontWeight.bold)),
                    ),
                    title: Text('基金代码 00${index + 1}'),
                    subtitle: Text('近一年涨幅 +${(index * 2.5).toStringAsFixed(2)}%'),
                    trailing: Text(
                      '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%',
                      style: TextStyle(color: change >= 0 ? Colors.green : Colors.red, fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
      ],
    );
  }

  String _formatVolume(double volume) {
    if (volume >= 100000000) return '${(volume / 100000000).toStringAsFixed(1)}亿';
    if (volume >= 10000) return '${(volume / 10000).toStringAsFixed(1)}万';
    return volume.toStringAsFixed(0);
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/market_provider.dart';
import '../services/market_service.dart';
import '../models/fund_models.dart';

/// 板块详情页面
class SectorDetailPage extends StatefulWidget {
  final SectorModel sector;
  
  const SectorDetailPage({super.key, required this.sector});
  
  @override
  State<SectorDetailPage> createState() => _SectorDetailPageState();
}

class _SectorDetailPageState extends State<SectorDetailPage> {
  late Future<SectorDetail> _detailFuture;
  
  @override
  void initState() {
    super.initState();
    _detailFuture = MarketService().fetchSectorDetail(widget.sector.id);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sector.name),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.star_border),
            onPressed: () {
              // 添加自选
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已添加到自选板块')),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<SectorDetail>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('加载失败: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _detailFuture = MarketService().fetchSectorDetail(widget.sector.id);
                      });
                    },
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }
          
          final detail = snapshot.data!;
          return _buildContent(detail);
        },
      ),
    );
  }
  
  Widget _buildContent(SectorDetail detail) {
    final changeColor = detail.changePercent >= 0 ? Colors.red : Colors.green;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 板块概览卡片
          _buildOverviewCard(detail, changeColor),
          
          // 统计指标
          _buildStatisticsRow(detail),
          
          // 板块内基金列表
          _buildFundList(detail.funds),
          
          // 相关资讯
          if (detail.relatedNews.isNotEmpty)
            _buildNewsSection(detail.relatedNews),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  Widget _buildOverviewCard(SectorDetail detail, Color changeColor) {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${detail.changePercent >= 0 ? '+' : ''}${detail.changePercent.toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: changeColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '板块涨跌',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${detail.changePercent >= 0 ? '+' : ''}${detail.changeAmount.toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontSize: 16,
                    color: changeColor,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  width: 1,
                  height: 20,
                  color: Colors.grey.shade300,
                ),
                Text(
                  '共${detail.funds.length}只基金',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatisticsRow(SectorDetail detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              '换手率',
              '${detail.turnoverRate?.toStringAsFixed(2) ?? '--'}%',
              Icons.swap_horiz,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              '资金流向',
              '${detail.capitalFlow != null ? '${detail.capitalFlow! > 0 ? '+' : ''}${detail.capitalFlow!.toStringAsFixed(1)}亿' : '--'}',
              Icons.trending_up,
              color: (detail.capitalFlow ?? 0) >= 0 ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String label, String value, IconData icon, {Color? color}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color ?? Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFundList(List<FundModel> funds) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '板块内基金',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '共${funds.length}只',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
        ...funds.map((fund) => _buildFundItem(fund)).toList(),
      ],
    );
  }
  
  Widget _buildFundItem(FundModel fund) {
    final changeColor = fund.dayChange >= 0 ? Colors.red : Colors.green;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: () => _showFundDetail(fund),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fund.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      fund.code,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    fund.nav.toStringAsFixed(4),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${fund.dayChange >= 0 ? '+' : ''}${fund.dayChange.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: changeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.add_circle_outline,
                color: Colors.blue.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNewsSection(List<String> news) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '相关资讯',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        ...news.map((item) => ListTile(
          leading: const Icon(Icons.article, color: Colors.blue),
          title: Text(item, maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: () {},
        )),
      ],
    );
  }
  
  void _showFundDetail(FundModel fund) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fund.code, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(fund.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('估算净值', fund.nav.toStringAsFixed(4)),
                _buildStat('日涨跌', '${fund.dayChange >= 0 ? '+' : ''}${fund.dayChange.toStringAsFixed(2)}%'),
                _buildStat('更新时间', fund.updateTime ?? '--'),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // 添加到持仓
                },
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                child: const Text('添加自选'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/fund_models.dart';
import '../providers/fund_provider.dart';

class RecommendPage extends StatelessWidget {
  const RecommendPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // 标签选择
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey.shade100,
            child: const TabBar(
              tabs: [
                Tab(text: '热门推荐'),
                Tab(text: '行业推荐'),
              ],
            ),
          ),
          
          // 内容区域
          Expanded(
            child: TabBarView(
              children: [
                _buildHotRecommend(context),
                _buildSectorRecommend(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotRecommend(BuildContext context) {
    return Consumer<FundProvider>(
      builder: (context, fundProvider, child) {
        final funds = fundProvider.hotFunds;
        
        if (funds.isEmpty) {
          return Center(
            child: ElevatedButton(
              onPressed: () => fundProvider.refreshAll(),
              child: const Text('加载热门基金'),
            ),
          );
        }
        
        return ListView(
          padding: const EdgeInsets.all(16),
          children: funds.map((fund) => _buildRecommendCard(fund, context)).toList(),
        );
      },
    );
  }

  Widget _buildSectorRecommend(BuildContext context) {
    // 模拟行业数据
    final sectors = [
      {'name': '消费', 'funds': ['161725', '110022']},
      {'name': '科技', 'funds': ['001594', '005731']},
      {'name': '医药', 'funds': ['512010', '512030']},
      {'name': '新能源', 'funds': ['516160', '159823']},
      {'name': '化工', 'funds': ['020274', '005196']},
    ];
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: sectors.map((sector) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            title: Text(
              sector['name'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            children: (sector['funds'] as List<String>).map((code) {
              return ListTile(
                title: Text(code),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecommendCard(FundModel fund, BuildContext context) {
    final changeColor = fund.dayChange >= 0 ? Colors.red : Colors.green;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showFundDetail(fund, context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.blue.shade600],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '推荐',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fund.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        Icons.star,
                        size: 16,
                        color: index < 4 ? Colors.amber : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem('当前净值', fund.nav.toStringAsFixed(4)),
                  _buildStatItem('日涨跌', '${fund.dayChange >= 0 ? '+' : ''}${fund.dayChange.toStringAsFixed(2)}%', 
                    color: changeColor),
                  _buildStatItem('周涨幅', '${fund.weekChange != null ? (fund.weekChange! >= 0 ? '+' : '') + fund.weekChange!.toStringAsFixed(2) : '--'}%'),
                  _buildStatItem('月涨幅', '${fund.monthChange != null ? (fund.monthChange! >= 0 ? '+' : '') + fund.monthChange!.toStringAsFixed(2) : '--'}%'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showFundDetail(FundModel fund, BuildContext context) {
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
                    Text(fund.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(fund.code, style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow('估算净值', fund.nav.toStringAsFixed(4)),
            _buildDetailRow('日涨跌', '${fund.dayChange >= 0 ? '+' : ''}${fund.dayChange.toStringAsFixed(2)}%'),
            _buildDetailRow('周涨幅', '${fund.weekChange?.toStringAsFixed(2) ?? '--'}%'),
            _buildDetailRow('月涨幅', '${fund.monthChange?.toStringAsFixed(2) ?? '--'}%'),
            _buildDetailRow('年涨幅', '${fund.yearChange?.toStringAsFixed(2) ?? '--'}%'),
            _buildDetailRow('夏普比率', fund.sharpeRatio?.toStringAsFixed(2) ?? '--'),
            _buildDetailRow('最大回撤', '${fund.maxDrawdown?.toStringAsFixed(2) ?? '--'}%'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // 添加到持仓
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('添加到持仓'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

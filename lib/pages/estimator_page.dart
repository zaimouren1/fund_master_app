import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/fund_models.dart';
import '../providers/fund_provider.dart';

class EstimatorPage extends StatefulWidget {
  const EstimatorPage({super.key});

  @override
  State<EstimatorPage> createState() => _EstimatorPageState();
}

class _EstimatorPageState extends State<EstimatorPage> {
  final TextEditingController _codeController = TextEditingController();
  final List<String> _quickCodes = [
    '020274', // 富国化工
    '161725', // 招商白酒
    '110022', // 易方达消费
    '005827', // 易方达蓝筹
    '001594', // 天弘银行
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 查询区域
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade100,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    labelText: '输入基金代码',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: (_) => _queryFund(context),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => _queryFund(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('查询'),
              ),
            ],
          ),
        ),
        
        // 快捷查询
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: _quickCodes.map((code) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  label: Text(code),
                  onPressed: () {
                    _codeController.text = code;
                    _queryFund(context);
                  },
                ),
              );
            }).toList(),
          ),
        ),
        
        // 结果展示
        Expanded(
          child: Consumer<FundProvider>(
            builder: (context, fundProvider, child) {
              if (fundProvider.hotFunds.isEmpty && !fundProvider.isLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search, size: 60, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        '输入基金代码查询估值',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => fundProvider.refreshAll(),
                        child: const Text('刷新数据'),
                      ),
                    ],
                  ),
                );
              }
              
              if (fundProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              
              return ListView(
                padding: const EdgeInsets.all(16),
                children: fundProvider.hotFunds.map((fund) {
                  return _buildFundCard(fund);
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFundCard(FundModel fund) {
    final color = fund.dayChange >= 0 ? Colors.red : Colors.green;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fund.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        fund.code,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${fund.dayChange >= 0 ? '+' : ''}${fund.dayChange.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetric('估算净值', fund.nav.toStringAsFixed(4)),
                _buildMetric('更新时间', fund.updateTime ?? '--'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _queryFund(BuildContext context) {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;
    
    // 添加到热门基金列表进行查询
    Provider.of<FundProvider>(context, listen: false).fetchFundNav(code);
  }
}

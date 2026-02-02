import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/fund_models.dart';
import '../providers/portfolio_provider.dart';
import '../providers/fund_provider.dart';

class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PortfolioProvider>(
      builder: (context, portfolio, child) {
        if (portfolio.holdings.isEmpty) {
          return _buildEmptyState(context);
        }
        
        return RefreshIndicator(
          onRefresh: () async {
            await portfolio.refreshEstimates(
              Provider.of<FundProvider>(context, listen: false),
            );
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSummaryCard(portfolio),
              const SizedBox(height: 16),
              ...portfolio.holdings.map((holding) => _buildHoldingCard(holding, context)).toList(),
              const SizedBox(height: 16),
              _buildSuggestionsSection(portfolio.suggestions),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_balance_wallet,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无持仓',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _showAddHoldingDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('添加持仓'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(PortfolioProvider portfolio) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              portfolio.totalProfit >= 0 
                ? Colors.green.shade400 
                : Colors.red.shade400,
              portfolio.totalProfit >= 0 
                ? Colors.green.shade600 
                : Colors.red.shade600,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Text(
              '总资产',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              '¥${(portfolio.holdings.fold(0.0, (sum, h) => sum + (h.currentNav ?? h.cost) * h.amount)).toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('盈亏', '¥${portfolio.totalProfit.toStringAsFixed(2)}'),
                _buildSummaryItem('持仓数', '${portfolio.holdings.length}只'),
                _buildSummaryItem('今日涨跌', '${portfolio.todayChange.toStringAsFixed(2)}%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    final isProfit = value.contains('-') || value.startsWith('¥-');
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildHoldingCard(HoldingModel holding, BuildContext context) {
    final profit = holding.profit ?? (holding.currentNav ?? holding.cost - holding.cost) * holding.amount;
    final profitPercent = holding.profitPercent ?? ((holding.currentNav ?? holding.cost) - holding.cost) / holding.cost * 100;
    
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
                        holding.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        holding.code,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: profitPercent >= 0 ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${profitPercent >= 0 ? '+' : ''}${profitPercent.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: profitPercent >= 0 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem('份额', holding.amount.toString()),
                _buildInfoItem('成本价', holding.cost.toStringAsFixed(4)),
                _buildInfoItem('当前净值', (holding.currentNav ?? holding.cost).toStringAsFixed(4)),
                _buildInfoItem('盈亏', '¥${profit.toStringAsFixed(2)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionsSection(List<SuggestionModel> suggestions) {
    if (suggestions.isEmpty) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  '操作建议',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...suggestions.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getActionColor(s.action).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      s.action,
                      style: TextStyle(
                        color: _getActionColor(s.action),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                        Text(
                          s.reason,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Color _getActionColor(String action) {
    switch (action) {
      case '买入':
      case '加仓':
        return Colors.green;
      case '卖出':
      case '减仓':
      case '止损':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  void _showAddHoldingDialog(BuildContext context) {
    final codeController = TextEditingController();
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final costController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加持仓'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeController,
              decoration: const InputDecoration(labelText: '基金代码'),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '基金名称'),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: '持有份额'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: costController,
              decoration: const InputDecoration(labelText: '成本价'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (codeController.text.isNotEmpty && amountController.text.isNotEmpty) {
                Provider.of<PortfolioProvider>(context, listen: false).addHolding(
                  HoldingModel(
                    code: codeController.text,
                    name: nameController.text.isNotEmpty ? nameController.text : codeController.text,
                    amount: double.parse(amountController.text),
                    cost: double.parse(costController.text.isNotEmpty ? costController.text : '1.0'),
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}

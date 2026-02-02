import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/fund_provider.dart';
import '../providers/portfolio_provider.dart';
import '../models/fund_models.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        Provider.of<FundProvider>(context, listen: false).refreshAll();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTodaySummary(context),
            const SizedBox(height: 16),
            _buildQuickActions(),
            const SizedBox(height: 16),
            _buildMarketOverview(),
            const SizedBox(height: 16),
            _buildHotFunds(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySummary(BuildContext context) {
    return Consumer<PortfolioProvider>(
      builder: (context, portfolio, child) {
        final totalProfit = portfolio.totalProfit;
        final todayChange = portfolio.todayChange;
        
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  totalProfit >= 0 ? Colors.green.shade400 : Colors.red.shade400,
                  totalProfit >= 0 ? Colors.green.shade600 : Colors.red.shade600,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  '今日收益',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '¥${NumberFormat('#,##0.00').format(totalProfit)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${todayChange >= 0 ? '+' : ''}${todayChange.toStringAsFixed(2)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.add, 'label': '添加持仓', 'color': Colors.blue},
      {'icon': Icons.search, 'label': '查询估值', 'color': Colors.green},
      {'icon': Icons.trending_up, 'label': '基金排行', 'color': Colors.orange},
      {'icon': Icons.analytics, 'label': '收益分析', 'color': Colors.purple},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return GestureDetector(
          onTap: () {},
          child: Container(
            decoration: BoxDecoration(
              color: (action['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  action['icon'] as IconData,
                  color: action['color'] as Color,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  action['label'] as String,
                  style: TextStyle(
                    color: action['color'] as Color,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMarketOverview() {
    final indices = [
      {'name': '上证指数', 'change': 0.45},
      {'name': '深证成指', 'change': -0.23},
      {'name': '创业板', 'change': 1.12},
      {'name': '沪深300', 'change': 0.67},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '市场概览',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...indices.map((index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(index['name'] as String),
                  Text(
                    '${(index['change'] as double) >= 0 ? '+' : ''}${index['change']}%',
                    style: TextStyle(
                      color: (index['change'] as double) >= 0 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.w500,
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

  Widget _buildHotFunds(BuildContext context) {
    return Consumer<FundProvider>(
      builder: (context, fundProvider, child) {
        final hotFunds = fundProvider.hotFunds.take(5).toList();
        
        if (hotFunds.isEmpty) {
          return const Center(child: Text('加载中...'));
        }
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '热门基金',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('查看更多'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...hotFunds.map((fund) => _buildFundItem(fund)).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFundItem(FundModel fund) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fund.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  fund.code,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${fund.dayChange >= 0 ? '+' : ''}${fund.dayChange.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: fund.dayChange >= 0 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                fund.nav.toStringAsFixed(4),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

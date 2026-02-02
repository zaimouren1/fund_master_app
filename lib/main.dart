import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlphaFund',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'NotoSansSC',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E40AF),
          primary: const Color(0xFF1E40AF),
          secondary: const Color(0xFF06B6D4),
        ),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const Center(child: Text('持仓页面', style: TextStyle(fontSize: 24))),
    const Center(child: Text('估值页面', style: TextStyle(fontSize: 24))),
    const MarketPage(),
    const Center(child: Text('推荐页面', style: TextStyle(fontSize: 24))),
  ];

  final List<String> _titles = [
    'AlphaFund',
    '我的持仓',
    '估值查询',
    '行情',
    '智能推荐',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E40AF),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {},
          ),
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: '首页'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: '持仓'),
          NavigationDestination(icon: Icon(Icons.trending_up_outlined), selectedIcon: Icon(Icons.trending_up), label: '估值'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: '行情'),
          NavigationDestination(icon: Icon(Icons.star_outline), selectedIcon: Icon(Icons.star), label: '推荐'),
        ],
      ),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1E40AF)),
            accountName: const Text('投资者'),
            accountEmail: const Text('AlphaFund v2.0'),
            currentAccountPicture: const CircleAvatar(child: Icon(Icons.person, size: 40)),
          ),
          const ListTile(leading: Icon(Icons.settings), title: Text('设置')),
          const ListTile(leading: Icon(Icons.info), title: Text('关于')),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.warning, color: Colors.orange),
            title: const Text('风险提示'),
            subtitle: const Text('投资有风险，入市需谨慎'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 20),
          _buildSectionTitle('热门基金'),
          _buildHotFundList(),
          const SizedBox(height: 20),
          _buildSectionTitle('市场行情'),
          _buildMarketOverview(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E40AF), Color(0xFF06B6D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E40AF).withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'A',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E40AF),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '欢迎使用 AlphaFund',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '专业基金智能投顾平台',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('总收益', '+12.5%', Colors.green),
              _buildStat('持仓数', '8只', Colors.white),
              _buildStat('今日涨跌', '+0.85%', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF1E40AF),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotFundList() {
    final funds = [
      {'code': '161725', 'name': '招商中证白酒', 'change': 3.21},
      {'code': '005827', 'name': '易方达蓝筹精选', 'change': 2.15},
      {'code': '020274', 'name': '富国天惠成长', 'change': 1.85},
      {'code': '110022', 'name': '易方达消费行业', 'change': 1.52},
      {'code': '001594', 'name': '天弘中证银行', 'change': 0.89},
    ];

    return Column(
      children: funds.map((fund) {
        final changeColor = fund['change'] as double >= 0 ? Colors.green : Colors.red;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF1E40AF).withOpacity(0.1),
              child: Text(
                fund['code'] as String,
                style: const TextStyle(
                  color: Color(0xFF1E40AF),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(fund['code'] as String),
            subtitle: Text(fund['name'] as String),
            trailing: Text(
              '${(fund['change'] as double) >= 0 ? '+' : ''}${fund['change']}%',
              style: TextStyle(
                color: changeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMarketOverview() {
    final sectors = [
      {'name': '食品饮料', 'change': 2.35},
      {'name': '医药生物', 'change': 1.87},
      {'name': '电子', 'change': -0.85},
      {'name': '新能源', 'change': 3.12},
      {'name': '银行', 'change': 0.45},
    ];

    return Card(
      child: Column(
        children: sectors.map((sector) {
          final changeColor = (sector['change'] as double) >= 0 ? Colors.green : Colors.red;
          return ListTile(
            title: Text(sector['name'] as String),
            trailing: Text(
              '${(sector['change'] as double) >= 0 ? '+' : ''}${sector['change']}%',
              style: TextStyle(
                color: changeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// 简单的行情页面
class MarketPage extends StatelessWidget {
  const MarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectorCard('食品饮料', '行业', 2.35, 156),
        _buildSectorCard('医药生物', '行业', 1.87, 203),
        _buildSectorCard('电子', '行业', -0.85, 189),
        _buildSectorCard('新能源', '行业', 3.12, 167),
        _buildSectorCard('人工智能', '概念', 1.68, 134),
        _buildSectorCard('新能源车', '概念', 4.25, 89),
      ],
    );
  }

  Widget _buildSectorCard(String name, String type, double change, int fundCount) {
    final changeColor = change >= 0 ? Colors.green : Colors.red;
    final typeColor = type == '行业' ? const Color(0xFF3B82F6) : const Color(0xFF8B5CF6);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(color: typeColor, fontSize: 12),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: changeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: changeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.folder, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('$fundCount只基金', style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

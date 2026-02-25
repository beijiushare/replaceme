import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:replaceme/providers/app_provider.dart';
import 'package:replaceme/models/item.dart';

class DataStatisticsPage extends StatefulWidget {
  const DataStatisticsPage({super.key});

  @override
  State<DataStatisticsPage> createState() => _DataStatisticsPageState();
}

class _DataStatisticsPageState extends State<DataStatisticsPage> {
  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final items = appProvider.items;
    final statistics = _calculateStatistics(items);

    return Scaffold(
      appBar: AppBar(
        title: const Text('数据统计'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 总览
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('物品总览', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statisticItem('总物品数', statistics['total']!, Icons.inventory),
                        _statisticItem('已过期', statistics['expired']!, Icons.warning),
                        _statisticItem('即将过期', statistics['expiringSoon']!, Icons.access_alarm),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 保质期分布
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('保质期分布', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statisticItem('前30%', statistics['before30']!, Icons.trending_down),
                        _statisticItem('30%-70%', statistics['between30And70']!, Icons.trending_flat),
                        _statisticItem('70%-100%', statistics['between70And100']!, Icons.trending_up),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 分类统计
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('分类统计', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ...appProvider.categories.map((category) {
                      final categoryItems = appProvider.getItemsByCategory(category.id);
                      return ListTile(
                        title: Text(category.name),
                        subtitle: Text('共 ${categoryItems.length} 个物品'),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // 最近过期提醒
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('最近过期提醒', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ..._getSoonExpiredItems(items).map((item) {
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text('剩余 ${item.daysLeft} 天'),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 计算统计数据
  Map<String, int> _calculateStatistics(List<Item> items) {
    final now = DateTime.now();
    int total = items.length;
    int expired = 0;
    int expiringSoon = 0;
    int before30 = 0;
    int between30And70 = 0;
    int between70And100 = 0;

    for (final item in items) {
      if (item.isExpired) {
        expired++;
      } else if (item.isExpiringSoon) {
        expiringSoon++;
      }

      // 计算保质期百分比
      final totalDays = item.endDate.difference(item.startDate).inDays;
      if (totalDays > 0) {
        final usedDays = now.difference(item.startDate).inDays;
        final percentage = (usedDays / totalDays) * 100;

        if (percentage < 30) {
          before30++;
        } else if (percentage < 70) {
          between30And70++;
        } else {
          between70And100++;
        }
      }
    }

    return {
      'total': total,
      'expired': expired,
      'expiringSoon': expiringSoon,
      'before30': before30,
      'between30And70': between30And70,
      'between70And100': between70And100,
    };
  }

  // 获取即将过期的物品
  List<Item> _getSoonExpiredItems(List<Item> items) {
    return items
        .where((item) => !item.isExpired && item.daysLeft <= 7)
        .toList()
        ..sort((a, b) => a.daysLeft.compareTo(b.daysLeft))
        ..take(5).toList();
  }

  // 统计项组件
  Widget _statisticItem(String title, int value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(value.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
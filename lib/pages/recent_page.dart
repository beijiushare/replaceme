import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:replaceme/providers/app_provider.dart';
import 'package:replaceme/models/item.dart';
import 'package:replaceme/widgets/item_card.dart';
import 'package:replaceme/pages/add_item_page.dart';

class RecentPage extends StatelessWidget {
  const RecentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final dangerousItems = appProvider.getDangerousItems();

    return Scaffold(
      appBar: AppBar(
        title: const Text('最近'),
        centerTitle: true,
      ),
      body: dangerousItems.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text('暂无危险期限内的物品', style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: dangerousItems.length,
              itemBuilder: (context, index) {
                final item = dangerousItems[index];
                return ItemCard(
                  item: item,
                  onTap: () {
                    // 进入物品信息展示页
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemDetailPage(item: item),
                      ),
                    );
                  },
                  onLongPress: () {
                    // 显示操作菜单
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.edit),
                                title: const Text('编辑'),
                                onTap: () {
                                  Navigator.pop(context);
                                  // 跳转到编辑页面
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddItemPage(
                                        categoryId: item.categoryId,
                                        item: item,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.delete),
                                title: const Text('标记已处理'),
                                onTap: () {
                                  Navigator.pop(context);
                                  // 标记已处理逻辑，将物品移至回收站
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('确认标记已处理'),
                                        content: const Text('此操作将把物品移至回收站，确定要继续吗？'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('取消'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              final appProvider = Provider.of<AppProvider>(context, listen: false);
                                              appProvider.deleteItem(item.id);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('已标记为已处理')),
                                              );
                                            },
                                            child: const Text('确定'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}

// 物品信息展示页
class ItemDetailPage extends StatelessWidget {
  final Item item;

  const ItemDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('物品详情'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 物品图片
            if (item.imagePath != null) ...[
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: FileImage(File(item.imagePath!)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
                child: Center(
                  child: Text(
                    item.name.isNotEmpty ? item.name[0] : '无',
                    style: TextStyle(
                      fontSize: 64,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // 物品名称
            Text(
              item.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // 日期信息
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text('开始日期: ${item.formatDate(item.startDate)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.event_busy, size: 16),
                const SizedBox(width: 8),
                Text('截止日期: ${item.formatDate(item.endDate)}'),
              ],
            ),
            const SizedBox(height: 8),
            
            // 剩余天数
            Row(
              children: [
                const Icon(Icons.timer, size: 16),
                const SizedBox(width: 8),
                Text(
                  item.isExpired
                      ? '已过期 ${-item.daysLeft} 天'
                      : '剩余 ${item.daysLeft} 天',
                  style: TextStyle(
                    color: item.statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 物品描述
            if (item.description != null && item.description!.isNotEmpty) ...[
              const Text('描述:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(item.description!),
            ],
          ],
        ),
      ),
    );
  }
}
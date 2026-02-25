import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:replaceme/providers/app_provider.dart';
import 'package:replaceme/models/item.dart';
import 'package:replaceme/widgets/item_card.dart';

class RecycleBinPage extends StatefulWidget {
  const RecycleBinPage({super.key});

  @override
  State<RecycleBinPage> createState() => _RecycleBinPageState();
}

class _RecycleBinPageState extends State<RecycleBinPage> {
  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final recycledItems = appProvider.recycledItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('回收站'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              _showEmptyRecycleBinDialog(context, appProvider);
            },
          ),
        ],
      ),
      body: recycledItems.isEmpty
          ? const Center(
              child: Text('回收站为空'),
            )
          : ListView.builder(
              itemCount: recycledItems.length,
              itemBuilder: (context, index) {
                final item = recycledItems[index];
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
                                leading: const Icon(Icons.restore),
                                title: const Text('恢复'),
                                onTap: () {
                                  Navigator.pop(context);
                                  appProvider.restoreItem(item.id);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.delete_forever),
                                title: const Text('永久删除'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _showDeleteConfirmDialog(context, appProvider, item);
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

  // 显示清空回收站对话框
  void _showEmptyRecycleBinDialog(BuildContext context, AppProvider appProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认清空'),
          content: const Text('确定要清空回收站吗？此操作不可恢复。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                appProvider.emptyRecycleBin();
                Navigator.pop(context);
              },
              child: const Text('清空'),
            ),
          ],
        );
      },
    );
  }

  // 显示删除确认对话框
  void _showDeleteConfirmDialog(BuildContext context, AppProvider appProvider, Item item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: const Text('确定要永久删除此物品吗？此操作不可恢复。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                appProvider.permanentlyDeleteItem(item.id);
                Navigator.pop(context);
              },
              child: const Text('删除'),
            ),
          ],
        );
      },
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
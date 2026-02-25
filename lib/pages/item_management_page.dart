import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';
import 'package:replaceme/providers/app_provider.dart';
import 'package:replaceme/models/category.dart';
import 'package:replaceme/pages/category_items_page.dart';
import 'package:replaceme/pages/group_management_page.dart';
import 'package:replaceme/pages/recycle_bin_page.dart';
import 'package:replaceme/pages/data_statistics_page.dart';

class ItemManagementPage extends StatefulWidget {
  const ItemManagementPage({super.key});

  @override
  State<ItemManagementPage> createState() => _ItemManagementPageState();
}

class _ItemManagementPageState extends State<ItemManagementPage> {
  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final categories = appProvider.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('物品管理'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showSettingsMenu(context);
            },
          ),
        ],
      ),
      body: categories.isEmpty
          ? const Center(
              child: Text('暂无分类，请添加分类'),
            )
          : ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                appProvider.reorderCategories(oldIndex, newIndex);
              },
              children: categories.map((category) {
                final itemCount = appProvider.getItemsByCategory(category.id).length;
                
                return Card(
                  key: ValueKey(category.id),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(category.name),
                    subtitle: Text('共 $itemCount 个物品'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryItemsPage(category: category),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
    );
  }

  // 显示添加分类对话框
  void _showAddCategoryDialog(BuildContext context, AppProvider appProvider) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('添加分类'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: '分类名称'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  final category = Category(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: controller.text.trim(),
                  );
                  appProvider.addCategory(category);
                  Navigator.pop(context);
                }
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  // 显示设置菜单
  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('分组管理'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GroupManagementPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('回收站'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecycleBinPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('数据统计'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DataStatisticsPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 显示分类操作选项对话框
  void _showCategoryOptionsDialog(BuildContext context, AppProvider appProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('分类操作'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('编辑分类名称'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditCategoryDialog(context, appProvider);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('删除分类'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteCategoryDialog(context, appProvider);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 显示编辑分类对话框
  void _showEditCategoryDialog(BuildContext context, AppProvider appProvider) {
    if (appProvider.categories.isEmpty) return;

    final TextEditingController controller = TextEditingController();
    final selectedCategory = appProvider.categories[0];
    controller.text = selectedCategory.name;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('编辑分类'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Category>(
                value: selectedCategory,
                items: appProvider.categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.text = value.name;
                  }
                },
                decoration: const InputDecoration(labelText: '选择分类'),
              ),
              TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: '新分类名称'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  final updatedCategory = selectedCategory.copyWith(
                    name: controller.text.trim(),
                  );
                  appProvider.updateCategory(updatedCategory);
                  Navigator.pop(context);
                }
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  // 显示删除分类对话框
  void _showDeleteCategoryDialog(BuildContext context, AppProvider appProvider) {
    if (appProvider.categories.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('删除分类'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('请选择要删除的分类：'),
              const SizedBox(height: 16),
              ...appProvider.categories.map((category) {
                return ListTile(
                  title: Text(category.name),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('确认删除'),
                          content: Text('确定要删除分类 "${category.name}" 吗？'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('取消'),
                            ),
                            TextButton(
                              onPressed: () {
                                appProvider.deleteCategory(category.id);
                                Navigator.pop(context);
                              },
                              child: const Text('删除'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

// 扩展 Category 类，添加 copyWith 方法
extension CategoryExtension on Category {
  Category copyWith({String? id, String? name}) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';
import 'package:replaceme/providers/app_provider.dart';
import 'package:replaceme/models/category.dart';

class GroupManagementPage extends StatefulWidget {
  const GroupManagementPage({super.key});

  @override
  State<GroupManagementPage> createState() => _GroupManagementPageState();
}

class _GroupManagementPageState extends State<GroupManagementPage> {
  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final categories = appProvider.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('分组管理'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddCategoryDialog(context, appProvider);
            },
          ),
        ],
      ),
      body: categories.isEmpty
          ? const Center(
              child: Text('暂无分组，请添加分组'),
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
                    leading: const Icon(Icons.drag_handle),
                    title: Text(category.name),
                    subtitle: Text('共 $itemCount 个物品'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showEditCategoryDialog(context, appProvider, category);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _showDeleteCategoryDialog(context, appProvider, category);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  // 显示添加分组对话框
  void _showAddCategoryDialog(BuildContext context, AppProvider appProvider) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('添加分组'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: '分组名称'),
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

  // 显示编辑分组对话框
  void _showEditCategoryDialog(BuildContext context, AppProvider appProvider, Category category) {
    final TextEditingController controller = TextEditingController();
    controller.text = category.name;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('编辑分组'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: '分组名称'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  final updatedCategory = category.copyWith(
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

  // 显示删除分组对话框
  void _showDeleteCategoryDialog(BuildContext context, AppProvider appProvider, Category category) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('确定要删除分组 "${category.name}" 吗？'),
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
  }
}
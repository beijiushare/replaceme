import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:replaceme/providers/app_provider.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final TextEditingController _userNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final users = appProvider.users;
    final currentUserId = appProvider.currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('切换账号'),
        centerTitle: true,
      ),
      body: users.isEmpty
          ? const Center(
              child: Text('暂无用户，请添加用户'),
            )
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final isCurrentUser = user['id'] == currentUserId;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Radio<String>(
                      value: user['id']!,
                      groupValue: currentUserId,
                      onChanged: (value) {
                        appProvider.switchUser(value!);
                      },
                    ),
                    title: Text(user['name']!),
                    trailing: isCurrentUser
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              // 显示删除确认对话框
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('确认删除'),
                                    content: const Text('此操作将删除该用户的所有数据，确定要继续吗？'),
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
                                          appProvider.deleteUser(user['id']!);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('用户已删除')),
                                          );
                                        },
                                        child: const Text('删除'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 显示添加用户对话框
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('添加用户'),
                content: TextField(
                  controller: _userNameController,
                  decoration: const InputDecoration(
                    hintText: '请输入用户名',
                    border: OutlineInputBorder(),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _userNameController.clear();
                    },
                    child: const Text('取消'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (_userNameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('用户名不能为空')),
                        );
                        return;
                      }
                      
                      appProvider.addUser(_userNameController.text.trim());
                      Navigator.pop(context);
                      _userNameController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('用户已添加')),
                      );
                    },
                    child: const Text('添加'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:replaceme/services/storage_service.dart';
import 'package:replaceme/models/item.dart';
import 'package:replaceme/models/category.dart';

class AppProvider extends ChangeNotifier {
  // 警告规则类型：days 或 percentage
  String _warningRuleType = 'days';
  // 剩余天数警告值
  int _warningDays = 30;
  // 保质期百分比警告值
  int _warningPercentage = 80;
  // 物品列表
  List<Item> _items = [];
  // 已回收物品列表
  List<Item> _recycledItems = [];
  // 分类列表
  List<Category> _categories = [];
  // 存储服务
  late StorageService _storageService;
  // 用户列表
  List<Map<String, String>> _users = [];
  // 当前用户 ID
  String _currentUserId = '';

  // 构造函数
  AppProvider() {
    _init();
  }

  // 初始化
  Future<void> _init() async {
    _storageService = StorageService();
    await loadUsers();
    await loadData();
    await loadSettings();
  }

  // 加载设置
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _warningRuleType = prefs.getString('${_currentUserId}_warningRuleType') ?? 'days';
    _warningDays = prefs.getInt('${_currentUserId}_warningDays') ?? 30;
    _warningPercentage = prefs.getInt('${_currentUserId}_warningPercentage') ?? 80;
    
    notifyListeners();
  }

  // 保存设置
  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('${_currentUserId}_warningRuleType', _warningRuleType);
    prefs.setInt('${_currentUserId}_warningDays', _warningDays);
    prefs.setInt('${_currentUserId}_warningPercentage', _warningPercentage);
  }

  // 加载用户
  Future<void> loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users');
    if (usersJson != null) {
      try {
        final usersList = jsonDecode(usersJson) as List;
        _users = usersList.map((user) => Map<String, String>.from(user)).toList();
      } catch (e) {
        _users = [];
      }
    } else {
      // 如果没有用户，创建默认用户
      _users = [
        {'id': 'default', 'name': '默认用户'},
      ];
      await saveUsers();
    }
    
    _currentUserId = prefs.getString('currentUserId') ?? _users[0]['id']!;
    notifyListeners();
  }

  // 保存用户
  Future<void> saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('users', jsonEncode(_users));
    prefs.setString('currentUserId', _currentUserId);
  }

  // 添加用户
  void addUser(String name) {
    final newUser = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
    };
    _users.add(newUser);
    saveUsers();
    notifyListeners();
  }

  // 删除用户
  void deleteUser(String userId) {
    _users.removeWhere((user) => user['id'] == userId);
    // 如果删除的是当前用户，切换到第一个用户
    if (_currentUserId == userId && _users.isNotEmpty) {
      _currentUserId = _users[0]['id']!;
      loadData();
      loadSettings();
    }
    saveUsers();
    notifyListeners();
  }

  // 切换用户
  void switchUser(String userId) {
    _currentUserId = userId;
    loadData();
    loadSettings();
    saveUsers();
    notifyListeners();
  }

  // 加载数据
  Future<void> loadData() async {
    _items = await _storageService.loadItems(_currentUserId);
    _recycledItems = await _storageService.loadRecycledItems(_currentUserId);
    _categories = await _storageService.loadCategories(_currentUserId);
    
    // 如果没有分类，创建默认分类
    if (_categories.isEmpty) {
      _categories = [
        Category(id: '1', name: '食品'),
        Category(id: '2', name: '药物'),
        Category(id: '3', name: '日用品'),
        Category(id: '4', name: '其他'),
      ];
      await _storageService.saveCategories(_categories, _currentUserId);
    }
    
    notifyListeners();
  }

  // 保存数据
  Future<void> saveData() async {
    await _storageService.saveItems(_items, _currentUserId);
    await _storageService.saveRecycledItems(_recycledItems, _currentUserId);
    await _storageService.saveCategories(_categories, _currentUserId);
  }



  // 添加物品
  Future<void> addItem(Item item) async {
    _items.add(item);
    await saveData();
    notifyListeners();
  }

  // 更新物品
  Future<void> updateItem(Item item) async {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      // 获取旧物品
      final oldItem = _items[index];
      
      // 检查图片是否有变化
      if (oldItem.imagePath != null && oldItem.imagePath != item.imagePath) {
        // 删除旧的原图
        _deleteFile(oldItem.imagePath!);
      }
      
      // 检查缩略图是否有变化
      if (oldItem.thumbnailPath != null && oldItem.thumbnailPath != item.thumbnailPath) {
        // 删除旧的缩略图
        _deleteFile(oldItem.thumbnailPath!);
      }
      
      // 更新物品
      _items[index] = item;
      await saveData();
      notifyListeners();
    }
  }



  // 删除物品（移至回收站）
  Future<void> deleteItem(String itemId) async {
    final itemIndex = _items.indexWhere((item) => item.id == itemId);
    if (itemIndex != -1) {
      final item = _items.removeAt(itemIndex);
      _recycledItems.add(item);
      await saveData();
      notifyListeners();
    }
  }

  // 恢复物品
  Future<void> restoreItem(String itemId) async {
    final itemIndex = _recycledItems.indexWhere((item) => item.id == itemId);
    if (itemIndex != -1) {
      final item = _recycledItems.removeAt(itemIndex);
      _items.add(item);
      await saveData();
      notifyListeners();
    }
  }

  // 永久删除物品
  Future<void> permanentlyDeleteItem(String itemId) async {
    // 找到要删除的物品
    final itemToDelete = _recycledItems.firstWhere((item) => item.id == itemId, orElse: () => Item(id: '', name: '', startDate: DateTime.now(), endDate: DateTime.now(), categoryId: ''));
    
    // 删除物品的原图和缩略图
    if (itemToDelete.imagePath != null) {
      _deleteFile(itemToDelete.imagePath!);
    }
    if (itemToDelete.thumbnailPath != null) {
      _deleteFile(itemToDelete.thumbnailPath!);
    }
    
    // 从回收站中移除物品
    _recycledItems.removeWhere((item) => item.id == itemId);
    await saveData();
    notifyListeners();
  }

  // 清空回收站
  Future<void> emptyRecycleBin() async {
    // 删除所有回收物品的原图和缩略图
    for (final item in _recycledItems) {
      if (item.imagePath != null) {
        _deleteFile(item.imagePath!);
      }
      if (item.thumbnailPath != null) {
        _deleteFile(item.thumbnailPath!);
      }
    }
    
    // 清空回收站
    _recycledItems.clear();
    await saveData();
    notifyListeners();
  }

  // 删除文件（原图或缩略图）
  void _deleteFile(String filePath) {
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        file.deleteSync();
      }
    } catch (e) {
      print('删除文件失败: $e');
    }
  }

  // 添加分类
  Future<void> addCategory(Category category) async {
    _categories.add(category);
    await saveData();
    notifyListeners();
  }

  // 更新分类
  Future<void> updateCategory(Category category) async {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      await saveData();
      notifyListeners();
    }
  }

  // 删除分类
  Future<void> deleteCategory(String categoryId) async {
    _categories.removeWhere((category) => category.id == categoryId);
    // 将该分类下的物品移到其他分类
    for (final item in _items) {
      if (item.categoryId == categoryId) {
        item.categoryId = _categories.isNotEmpty ? _categories[0].id : '';
      }
    }
    await saveData();
    notifyListeners();
  }

  // 重新排序分类
  Future<void> reorderCategories(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final category = _categories.removeAt(oldIndex);
    _categories.insert(newIndex, category);
    await saveData();
    notifyListeners();
  }

  // 获取危险期限内的物品
  List<Item> getDangerousItems() {
    final now = DateTime.now();
    return _items.where((item) {
      final daysLeft = item.endDate.difference(now).inDays;
      if (daysLeft < 0) return true; // 已过期
      
      if (_warningRuleType == 'days') {
        return daysLeft <= _warningDays;
      } else {
        // 计算保质期百分比
        final totalDays = item.endDate.difference(item.startDate).inDays;
        if (totalDays <= 0) return true;
        final usedDays = now.difference(item.startDate).inDays;
        final percentage = (usedDays / totalDays) * 100;
        return percentage >= _warningPercentage;
      }
    }).toList()..sort((a, b) {
      final daysLeftA = a.endDate.difference(now).inDays;
      final daysLeftB = b.endDate.difference(now).inDays;
      return daysLeftA.compareTo(daysLeftB);
    });
  }

  // 获取分类下的物品
  List<Item> getItemsByCategory(String categoryId) {
    final now = DateTime.now();
    return _items
        .where((item) => item.categoryId == categoryId)
        .toList()
        ..sort((a, b) {
          final daysLeftA = a.endDate.difference(now).inDays;
          final daysLeftB = b.endDate.difference(now).inDays;
          return daysLeftA.compareTo(daysLeftB);
        });
  }

  // 数据导入导出
  String exportData() {
    return _storageService.exportData(_items, _categories, _recycledItems);
  }

  Future<bool> importData(String data) async {
    try {
      final result = _storageService.importData(data);
      _items = result['items'] ?? [];
      _recycledItems = result['recycledItems'] ?? [];
      _categories = result['categories'] ?? [];
      await saveData();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Getters and Setters
  String get warningRuleType => _warningRuleType;
  set warningRuleType(String value) {
    _warningRuleType = value;
    saveSettings();
    notifyListeners();
  }

  int get warningDays => _warningDays;
  set warningDays(int value) {
    _warningDays = value;
    saveSettings();
    notifyListeners();
  }

  int get warningPercentage => _warningPercentage;
  set warningPercentage(int value) {
    _warningPercentage = value;
    saveSettings();
    notifyListeners();
  }

  List<Item> get items => _items;
  List<Item> get recycledItems => _recycledItems;
  List<Category> get categories => _categories;
  List<Map<String, String>> get users => _users;
  String get currentUserId => _currentUserId;
}
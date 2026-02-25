import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:replaceme/models/item.dart';
import 'package:replaceme/models/category.dart';

class StorageService {
  // 存储键前缀
  static const String _itemsKeyPrefix = 'items_';
  static const String _recycledItemsKeyPrefix = 'recycledItems_';
  static const String _categoriesKeyPrefix = 'categories_';

  // 保存物品列表
  Future<void> saveItems(List<Item> items, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonItems = items.map((item) => item.toJson()).toList();
    await prefs.setString('${_itemsKeyPrefix}$userId', jsonEncode(jsonItems));
  }

  // 加载物品列表
  Future<List<Item>> loadItems(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('${_itemsKeyPrefix}$userId');
    if (jsonString == null) return [];
    
    try {
      final jsonItems = jsonDecode(jsonString) as List;
      return jsonItems.map((json) => Item.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // 保存已回收物品列表
  Future<void> saveRecycledItems(List<Item> items, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonItems = items.map((item) => item.toJson()).toList();
    await prefs.setString('${_recycledItemsKeyPrefix}$userId', jsonEncode(jsonItems));
  }

  // 加载已回收物品列表
  Future<List<Item>> loadRecycledItems(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('${_recycledItemsKeyPrefix}$userId');
    if (jsonString == null) return [];
    
    try {
      final jsonItems = jsonDecode(jsonString) as List;
      return jsonItems.map((json) => Item.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // 保存分类列表
  Future<void> saveCategories(List<Category> categories, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonCategories = categories.map((category) => category.toJson()).toList();
    await prefs.setString('${_categoriesKeyPrefix}$userId', jsonEncode(jsonCategories));
  }

  // 加载分类列表
  Future<List<Category>> loadCategories(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('${_categoriesKeyPrefix}$userId');
    if (jsonString == null) return [];
    
    try {
      final jsonCategories = jsonDecode(jsonString) as List;
      return jsonCategories.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // 导出数据
  String exportData(List<Item> items, List<Category> categories, List<Item> recycledItems) {
    final data = {
      'items': items.map((item) => item.toJson()).toList(),
      'recycledItems': recycledItems.map((item) => item.toJson()).toList(),
      'categories': categories.map((category) => category.toJson()).toList(),
      'exportTime': DateTime.now().toIso8601String(),
    };
    return jsonEncode(data);
  }

  // 导入数据
  Map<String, dynamic> importData(String data) {
    final jsonData = jsonDecode(data);
    final items = (jsonData['items'] as List)
        .map((json) => Item.fromJson(json))
        .toList();
    final recycledItems = (jsonData['recycledItems'] as List? ?? [])
        .map((json) => Item.fromJson(json))
        .toList();
    final categories = (jsonData['categories'] as List)
        .map((json) => Category.fromJson(json))
        .toList();
    
    return {
      'items': items,
      'recycledItems': recycledItems,
      'categories': categories,
    };
  }

  // 清除所有数据
  Future<void> clearAll(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_itemsKeyPrefix}$userId');
    await prefs.remove('${_recycledItemsKeyPrefix}$userId');
    await prefs.remove('${_categoriesKeyPrefix}$userId');
  }
}
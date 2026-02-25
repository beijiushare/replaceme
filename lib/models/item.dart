import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Item {
  String id;
  String name;
  DateTime startDate;
  DateTime endDate;
  String categoryId;
  String? description;
  String? imagePath;

  Item({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.categoryId,
    this.description,
    this.imagePath,
  });

  // 计算剩余天数
  int get daysLeft {
    final now = DateTime.now();
    return endDate.difference(now).inDays;
  }

  // 是否过期
  bool get isExpired {
    return daysLeft < 0;
  }

  // 是否即将过期（剩余7天内）
  bool get isExpiringSoon {
    return daysLeft >= 0 && daysLeft <= 7;
  }

  // 获取状态颜色
  Color get statusColor {
    if (isExpired) {
      return Colors.red;
    } else if (isExpiringSoon) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  // 格式化日期
  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'categoryId': categoryId,
      'description': description,
      'imagePath': imagePath,
    };
  }

  // 从JSON创建
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      categoryId: json['categoryId'],
      description: json['description'],
      imagePath: json['imagePath'],
    );
  }
}
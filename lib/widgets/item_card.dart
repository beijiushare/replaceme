import 'dart:io';
import 'package:flutter/material.dart';
import 'package:replaceme/models/item.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 图片列
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
                child: item.thumbnailPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(item.thumbnailPath!),
                          fit: BoxFit.cover,
                          width: 60,
                          height: 60,
                        ),
                      )
                    : item.imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(item.imagePath!),
                          fit: BoxFit.cover,
                          width: 60,
                          height: 60,
                        ),
                      )
                    : Center(
                        child: Text(
                          item.name.isNotEmpty ? item.name[0] : '无',
                          style: TextStyle(
                            fontSize: 24,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              
              // 日期列
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '开始: ${item.formatDate(item.startDate)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '截止: ${item.formatDate(item.endDate)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              
              // 剩余天数列
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: item.statusColor.withOpacity(0.1),
                ),
                child: Text(
                  item.isExpired
                      ? '已过期 ${-item.daysLeft} 天'
                      : '剩余 ${item.daysLeft} 天',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: item.statusColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
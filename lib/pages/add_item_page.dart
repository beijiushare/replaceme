import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:replaceme/providers/app_provider.dart';
import 'package:replaceme/models/item.dart';
import 'package:replaceme/widgets/custom_date_picker.dart';

class AddItemPage extends StatefulWidget {
  final String categoryId;
  final Item? item;

  const AddItemPage({super.key, required this.categoryId, this.item});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _imageFile;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  bool _useValidTime = false;
  int _validYears = 0;
  int _validMonths = 0;
  int _validDays = 30;

  @override
  void initState() {
    super.initState();
    // 编辑模式下加载现有物品信息
    if (widget.item != null) {
      _nameController.text = widget.item!.name;
      _descriptionController.text = widget.item!.description ?? '';
      _startDate = widget.item!.startDate;
      _endDate = widget.item!.endDate;
      if (widget.item!.imagePath != null) {
        _imageFile = File(widget.item!.imagePath!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item != null ? '编辑物品' : '添加物品'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 物品图片
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey, width: 1),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                            width: 120,
                            height: 120,
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey),
                            Text('点击添加图片', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 物品名称
            const Text('物品名称 *', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: '请输入物品名称',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 日期选择
            const Text('日期设置 *', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('截止日期'),
                    value: false,
                    groupValue: _useValidTime,
                    onChanged: (value) {
                      setState(() {
                        _useValidTime = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('有效时间'),
                    value: true,
                    groupValue: _useValidTime,
                    onChanged: (value) {
                      setState(() {
                        _useValidTime = value!;
                      });
                    },
                  ),
                ),
              ],
            ),

            if (!_useValidTime) ...[
              // 截止日期选择
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('开始日期'),
                        TextButton(
                          onPressed: () => _selectDate(context, true),
                          child: Text(
                            '${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}',
                            style: const TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('截止日期'),
                        TextButton(
                          onPressed: () => _selectDate(context, false),
                          child: Text(
                            '${_endDate.year}-${_endDate.month.toString().padLeft(2, '0')}-${_endDate.day.toString().padLeft(2, '0')}',
                            style: const TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              // 有效时间设置
              const Text('有效时间'),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _validYears = int.tryParse(value) ?? 0;
                          _updateEndDate();
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: '年',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _validMonths = int.tryParse(value) ?? 0;
                          _updateEndDate();
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: '月',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _validDays = int.tryParse(value) ?? 0;
                          _updateEndDate();
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: '日',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),

            // 物品描述
            const Text('物品描述', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '请输入物品描述（选填）',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // 保存按钮
            Center(
              child: ElevatedButton(
                onPressed: _saveItem,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
                child: const Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 选择图片
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // 选择日期
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return CustomDatePicker(
          frequency: '单次',
          initialDate: isStartDate
              ? '${_startDate.year}年${_startDate.month}月${_startDate.day}日'
              : '${_endDate.year}年${_endDate.month}月${_endDate.day}日',
        );
      },
    );

    if (result != null && result['dateTime'] != null) {
      setState(() {
        if (isStartDate) {
          _startDate = result['dateTime'] as DateTime;
          if (!_useValidTime) {
            // 更新截止日期，确保不早于开始日期
            if (_endDate.isBefore(_startDate)) {
              _endDate = _startDate.add(const Duration(days: 30));
            }
          }
        } else {
          _endDate = result['dateTime'] as DateTime;
          // 确保截止日期不早于开始日期
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 30));
          }
        }
      });
    }
  }

  // 更新截止日期
  void _updateEndDate() {
    setState(() {
      _endDate = _startDate.add(
        Duration(
          days: _validDays + _validMonths * 30 + _validYears * 365,
        ),
      );
    });
  }

  // 保存物品
  void _saveItem() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('物品名称不能为空')),
      );
      return;
    }

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    if (widget.item != null) {
      // 编辑模式
      final updatedItem = Item(
        id: widget.item!.id,
        name: _nameController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        categoryId: widget.categoryId,
        description: _descriptionController.text.trim(),
        imagePath: _imageFile?.path,
      );
      appProvider.updateItem(updatedItem);
    } else {
      // 添加模式
      final newItem = Item(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        categoryId: widget.categoryId,
        description: _descriptionController.text.trim(),
        imagePath: _imageFile?.path,
      );
      appProvider.addItem(newItem);
    }
    
    Navigator.pop(context);
  }
}
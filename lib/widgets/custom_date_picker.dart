import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

/// 自定义日期选择器组件
/// 根据不同频率显示不同的选择界面
class CustomDatePicker extends StatefulWidget {
  /// 选择的频率
  final String frequency;
  /// 当前选中的日期
  final String initialDate;

  const CustomDatePicker({
    Key? key,
    required this.frequency,
    required this.initialDate,
  }) : super(key: key);

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  // 统一文本样式常量（全局复用，字体固定为LXGWWenKai）
  static const TextStyle _baseTextStyle = TextStyle(
    fontFamily: 'LXGWWenKai', // 应用全局字体，所有文本统一使用
    fontSize: 14,
    fontWeight: FontWeight.w500,
    inherit: true,
    decoration: TextDecoration.none,
    backgroundColor: Colors.transparent,
    wordSpacing: 0.0,
    color: Colors.black87,
  );

  // 强调色文本样式（teal色，字体仍为LXGWWenKai）
  static TextStyle _accentTextStyle([double fontSize = 14]) {
    return _baseTextStyle.copyWith(
      color: Colors.teal,
      fontSize: fontSize,
    );
  }

  // 当前选择的年/月/日/星期
  int _currentYear = DateTime.now().year;
  int _currentMonth = DateTime.now().month;
  int _currentDay = DateTime.now().day;
  int _currentWeekday = DateTime.now().weekday; // 1=周一，7=周日

  // 解析初始日期
  @override
  void initState() {
    super.initState();
    _parseInitialDate();
  }

  // 解析初始日期字符串
  void _parseInitialDate() {
    try {
      final date = DateFormat('yyyy年MM月dd日').parse(widget.initialDate);
      _currentYear = date.year;
      _currentMonth = date.month;
      _currentDay = date.day;
      _currentWeekday = date.weekday;
    } catch (e) {
      // 如果解析失败，使用当前日期
      final now = DateTime.now();
      _currentYear = now.year;
      _currentMonth = now.month;
      _currentDay = now.day;
      _currentWeekday = now.weekday;
    }
  }

  // 构建日期选择器内容
  Widget _buildDatePickerContent() {
    switch (widget.frequency) {
      case '每周':
        return _buildWeekPicker();
      case '每月':
        return _buildMonthDayPicker();
      case '每年':
        return _buildYearMonthDayPicker(showYear: false);
      case '单次':
      default:
        return _buildYearMonthDayPicker(showYear: true);
    }
  }

  // 构建完整的年月日选择器（单次/每年）
  Widget _buildYearMonthDayPicker({required bool showYear}) {
    // 生成年份列表
    final years = List.generate(200, (index) => 1900 + index);
    // 生成月份列表
    final months = List.generate(12, (index) => index + 1);
    // 生成日期列表
    final daysInMonth = DateTime(_currentYear, _currentMonth + 1, 0).day;
    final days = List.generate(daysInMonth, (index) => index + 1);

    return Container(
      height: 200,
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (showYear) ...[
            Expanded(
              flex: 3,
              child: _buildCustomPicker(
                values: years.map((year) => '$year').toList(),
                currentValue: '$_currentYear',
                onChanged: (value) {
                  final year = int.parse(value);
                  setState(() {
                    _currentYear = year;
                    // 更新月份的天数
                    final newDaysInMonth = DateTime(_currentYear, _currentMonth + 1, 0).day;
                    if (_currentDay > newDaysInMonth) {
                      _currentDay = newDaysInMonth;
                    }
                  });
                },
              ),
            ),
            SizedBox(width: 8),
          ],
          Expanded(
            flex: 2,
            child: _buildCustomPicker(
              values: months.map((month) => '$month').toList(),
              currentValue: '$_currentMonth',
              onChanged: (value) {
                final month = int.parse(value);
                setState(() {
                  _currentMonth = month;
                  // 更新月份的天数
                  final newDaysInMonth = DateTime(_currentYear, _currentMonth + 1, 0).day;
                  if (_currentDay > newDaysInMonth) {
                    _currentDay = newDaysInMonth;
                  }
                });
              },
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: _buildCustomPicker(
              values: days.map((day) => '$day').toList(),
              currentValue: '$_currentDay',
              onChanged: (value) {
                final day = int.parse(value);
                setState(() {
                  _currentDay = day;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // 构建每月日期选择器（每月）
  Widget _buildMonthDayPicker() {
    // 生成日期列表（1-31）
    final days = List.generate(31, (index) => index + 1);

    return Container(
      height: 200,
      child: _buildCustomPicker(
        values: days.map((day) => '$day日').toList(),
        currentValue: '$_currentDay日',
        onChanged: (value) {
          final day = int.parse(value.replaceAll('日', ''));
          setState(() {
            _currentDay = day;
          });
        },
      ),
    );
  }

  // 构建每周星期选择器（每周）
  Widget _buildWeekPicker() {
    final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

    return Container(
      height: 200,
      child: _buildCustomPicker(
        values: weekdays,
        currentValue: weekdays[_currentWeekday - 1],
        onChanged: (value) {
          setState(() {
            _currentWeekday = weekdays.indexOf(value) + 1;
          });
        },
      ),
    );
  }

  // 构建自定义滚轮选择器
  Widget _buildCustomPicker({
    required List<String> values,
    required String currentValue,
    required ValueChanged<String> onChanged,
  }) {
    return ListWheelScrollView.useDelegate(
      itemExtent: 40,
      physics: const FixedExtentScrollPhysics(),
      controller: FixedExtentScrollController(
        initialItem: values.indexOf(currentValue),
      ),
      onSelectedItemChanged: (index) {
        onChanged(values[index]);
      },
      childDelegate: ListWheelChildLoopingListDelegate(
        children: values.map((value) {
          final isSelected = value == currentValue;
          return Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: 40,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value,
                style: _baseTextStyle.copyWith(
                  fontSize: 18,
                  color: isSelected ? Colors.teal : null,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 获取选择结果
  DateTime getSelectedDate() {
    switch (widget.frequency) {
      case '每周':
      // 计算下一个选中星期的日期
        final now = DateTime.now();
        final daysUntilTarget = _currentWeekday - now.weekday;
        return now.add(Duration(days: daysUntilTarget));
      case '每月':
      // 使用当前年份和月份，选中的日期
        final now = DateTime.now();
        return DateTime(now.year, now.month, _currentDay);
      case '每年':
      // 使用当前年份，选中的月份和日期
        final now = DateTime.now();
        return DateTime(now.year, _currentMonth, _currentDay);
      case '单次':
      default:
      // 使用选中的年月日
        return DateTime(_currentYear, _currentMonth, _currentDay);
    }
  }

  // 格式化显示日期
  String formatSelectedDate() {
    switch (widget.frequency) {
      case '每周':
        final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
        return weekdays[_currentWeekday - 1];
      case '每月':
        return '每月${_currentDay}日';
      case '每年':
        return '每年${_currentMonth}月${_currentDay}日';
      case '单次':
      default:
        return DateFormat('yyyy年MM月dd日').format(getSelectedDate());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('选择日期', style: _accentTextStyle(16)),
      content: SingleChildScrollView(
        child: _buildDatePickerContent(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('取消', style: _accentTextStyle()),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(
              context,
              {
                'dateTime': getSelectedDate(),
                'formattedDate': formatSelectedDate(),
              },
            );
          },
          child: Text('确定', style: _accentTextStyle()),
        ),
      ],
    );
  }
}
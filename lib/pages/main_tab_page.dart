import 'package:flutter/material.dart';
import 'package:replaceme/pages/recent_page.dart';
import 'package:replaceme/pages/item_management_page.dart';
import 'package:replaceme/pages/settings_page.dart';

class MainTabPage extends StatefulWidget {
  const MainTabPage({super.key});

  @override
  State<MainTabPage> createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const RecentPage(),
    const ItemManagementPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: '最近',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: '物品管理',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
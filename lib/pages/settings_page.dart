import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:replaceme/providers/app_provider.dart';
import 'package:replaceme/pages/user_management_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final List<String> _tips = [
    '内裤一般半年就该更换。私密部位容易残留汗液与细菌，长期穿着可能引发不适，加上面料失去弹性、发黄变形，就算频繁清洗也难以彻底除菌。当然，具体还是要以内裤实际情况如是否变色、失去弹性作为判断标准。',
    '牙刷建议两个月更换一次。刷毛用久了会磨损分叉，清洁力明显下降，再加上牙刷长期处于潮湿环境，很容易滋生细菌，越用越不卫生。',
    '洗发水开封后建议在 1 年内用完。时间久了有效清洁成分会慢慢流失，洗感大打折扣，而且开封后容易氧化，可能刺激头皮，引起头痒、头屑。',
    '牙膏开封后尽量在 6 个月内用完。其中的氟化物等护齿成分会随时间衰减，防蛀效果减弱，而且管口频繁接触空气和细菌，放太久不够卫生。',
    '防晒霜开封后最好在 1 年内用完。防晒成分会逐渐失效，无法起到应有的防护效果，同时质地氧化后也可能导致皮肤过敏、闷痘。',
    '食用油开封后建议半年内吃完。油脂接触空气容易氧化酸败，产生有害物质，不仅油烟变大、口感变差，还会影响身体健康。',
    '药品一旦过期就应立即丢弃。过期后药效会明显降低甚至完全失效，耽误正常使用，而且成分可能发生变化，服用后存在安全风险。',
    '口罩建议每天更换一次。使用时间过长会吸附灰尘、细菌和飞沫，防护效果大幅降低，潮湿后更是容易滋生细菌。',
    '床单被罩建议每两周清洗一次。长期使用会堆积皮屑、汗渍和螨虫，影响睡眠与皮肤健康，还容易发黄、产生异味。',
    '睡衣最好每三天更换一次。作为贴身衣物，很容易吸附汗液和皮屑，穿太久会滋生细菌，不利于睡眠卫生。',
    '眼药水开封后建议四周内用完。开封后很容易被细菌污染，药效也会慢慢下降，放置过久还可能变质，刺激眼睛引发不适。',
  ];
  String _currentTip = '一些建议，不一定严谨……婴幼儿、孕妇、老人及免疫力低下者应执行更严格的标准';

  @override
  void initState() {
    super.initState();
    _refreshTip();
  }

  void _refreshTip() {
    final randomIndex = DateTime.now().millisecond % _tips.length;
    setState(() {
      _currentTip = _tips[randomIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 警告规则设置
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('警告规则设置', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // 规则类型选择
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: RadioListTile<String>(
                          title: const Text('剩余天数'),
                          value: 'days',
                          groupValue: appProvider.warningRuleType,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (value) {
                            appProvider.warningRuleType = value!;
                          },
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: RadioListTile<String>(
                          title: const Text('保质期百分比'),
                          value: 'percentage',
                          groupValue: appProvider.warningRuleType,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (value) {
                            appProvider.warningRuleType = value!;
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 规则值设置
                  if (appProvider.warningRuleType == 'days') ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('剩余天数'),
                        Text('${appProvider.warningDays}天', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Slider(
                      value: appProvider.warningDays.toDouble(),
                      min: 1,
                      max: 90,
                      divisions: 89,
                      label: '${appProvider.warningDays}天',
                      onChanged: (value) {
                        appProvider.warningDays = value.toInt();
                      },
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('保质期百分比'),
                        Text('${appProvider.warningPercentage}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Slider(
                      value: appProvider.warningPercentage.toDouble(),
                      min: 10,
                      max: 100,
                      divisions: 9,
                      label: '${appProvider.warningPercentage}%',
                      onChanged: (value) {
                        appProvider.warningPercentage = value.toInt();
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),



          // Tips模块
          GestureDetector(
            onTap: () {
              _refreshTip();
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('小知识'),
                    content: Text(_currentTip),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('确定'),
                      ),
                    ],
                  );
                },
              );
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tips', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),

          // 切换账号
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserManagementPage(),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('切换账号', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),

          // 关于页面
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('关于', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  ListTile(
                    title: const Text('版本'),
                    subtitle: const Text('1.0.0'),
                  ),
                  GestureDetector(
                    onTap: () async {
                      try {
                        final url = Uri.parse('https://github.com/beijiushare/replaceme');
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      } catch (e) {
                        print('Error opening URL: $e');
                      }
                    },
                    child: ListTile(
                      title: const Text('项目地址'),
                      subtitle: const Text('github.com/beijiushare/replaceme'),
                      trailing: const Icon(Icons.open_in_new),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      try {
                        final url = Uri.parse('https://github.com/beijiushare/replaceme/releases/latest');
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      } catch (e) {
                        print('Error opening URL: $e');
                      }
                    },
                    child: ListTile(
                      title: const Text('最新版本'),
                      subtitle: const Text('点击获取最新版本'),
                      trailing: const Icon(Icons.open_in_new),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 数据导入导出
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('数据管理', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  ListTile(
                    leading: const Icon(Icons.import_export),
                    title: const Text('导出数据'),
                    onTap: () {
                      final data = appProvider.exportData();
                      Clipboard.setData(ClipboardData(text: data)).then((value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('数据已复制到剪贴板')),
                        );
                      });
                    },
                  ),
                  
                  ListTile(
                    leading: const Icon(Icons.import_export),
                    title: const Text('导入数据'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('导入数据'),
                            content: const Text('请将数据粘贴到此处'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('取消'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Clipboard.getData(Clipboard.kTextPlain).then((value) {
                                    if (value?.text != null) {
                                      appProvider.importData(value!.text!).then((success) {
                                        Navigator.pop(context);
                                        if (success) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('数据导入成功')),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('数据导入失败')),
                                          );
                                        }
                                      });
                                    } else {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('剪贴板为空')),
                                      );
                                    }
                                  });
                                },
                                child: const Text('确定'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


}
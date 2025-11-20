import 'package:flutter/material.dart';

class AcknowledgementsPage extends StatelessWidget {
  const AcknowledgementsPage({super.key});

  final List<Map<String, String>> acknowledgements = const [
    {
      'avatar': 'http://q1.qlogo.cn/g?b=qq&nk=2125714976&s=100',
      'name': '【夜风】NightWind',
      'contribution': '项目主要维护者',
    },
    {
      'avatar': 'http://q1.qlogo.cn/g?b=qq&nk=1651930562&s=100',
      'name': 'xuebi',
      'contribution': 'WebUI Docker 镜像维护者',
    },
    {
      'avatar': 'http://q1.qlogo.cn/g?b=qq&nk=2740324073&s=100',
      'name': 'Komorebi',
      'contribution': '项目Readme格式贡献者',
    },
    {
      'avatar': 'http://q1.qlogo.cn/g?b=qq&nk=1113956005&s=100',
      'name': 'concy',
      'contribution': '早期测试与反馈',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Text(
                  '鸣谢',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.black,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: acknowledgements.length,
                itemBuilder: (context, index) {
                  final item = acknowledgements[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(item['avatar']!),
                    ),
                    title: Text(
                      item['name']!,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AcknowledgementDetailPage(data: item),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AcknowledgementDetailPage extends StatelessWidget {
  final Map<String, String> data;

  const AcknowledgementDetailPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Text(
                  '详情',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.black,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(data['avatar']!),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              data['name']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              data['contribution']!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nonebot_webui_wear/ui/main_pages/createbot.dart';
import 'package:nonebot_webui_wear/ui/main_pages/import_bot.dart';
import 'package:nonebot_webui_wear/ui/main_pages/settings.dart';
import 'package:nonebot_webui_wear/ui/main_pages/bot_list.dart';
import 'package:nonebot_webui_wear/ui/main_pages/manage_bot.dart';
import 'package:nonebot_webui_wear/utils/core.dart';
import 'package:nonebot_webui_wear/utils/global.dart';

class MainPageMobile extends StatefulWidget {
  const MainPageMobile({super.key});

  @override
  State<MainPageMobile> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<MainPageMobile>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;
  Timer? timer;
  Timer? timer2;
  final PageController _pageController = PageController();
  int runningCount = 0;

  final List<String> _titles = ['主页', 'Bot列表', '控制台', '创建', '导入', '设置'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    connectToWebSocket(Config.wsHost, Config.wsPort, Config.useHttps);
    getSystemStatus();
    getBotLog();
  }

  getSystemStatus() async {
    timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) async {
      socket.sink.add('version&token=${Config.token}');
      socket.sink.add('ping&token=${Config.token}');
      socket.sink.add('system&token=${Config.token}');
      socket.sink.add('platform&token=${Config.token}');
      socket.sink.add('botList&token=${Config.token}');
      socket.sink.add('botList&token=${Config.token}');
      runningCount = Data.botList
          .where((bot) => bot['isRunning'] == true)
          .length;
      setState(() {});
    });
  }

  getBotLog() async {
    timer = Timer.periodic(const Duration(milliseconds: 1500), (timer2) async {
      if (gOnOpen.isNotEmpty) {
        socket.sink.add("bot/log/$gOnOpen&token=${Config.token}");
        socket.sink.add("botInfo/$gOnOpen&token=${Config.token}");
        socket.sink.add("bot/stderr/$gOnOpen&token=${Config.token}");
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    timer?.cancel();
    timer2?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      SystemNavigator.pop();
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 2 && gOnOpen.isNotEmpty) {
      socket.sink.add("botInfo/$gOnOpen&token=${Config.token}");
    }
  }

  Widget _buildProgressTile({
    required String title,
    required IconData icon,
    required String value,
    required double progress,
  }) {
    final validProgress = progress.isFinite ? progress.clamp(0.0, 1.0) : 0.0;

    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: validProgress,
                strokeWidth: 4.0,
                backgroundColor: Colors.grey[800],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color.fromRGBO(147, 112, 219, 1),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required IconData icon,
    required bool isConnected,
  }) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isConnected ? Colors.greenAccent : Colors.redAccent,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isConnected ? Colors.greenAccent : Colors.redAccent,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double cpuProgress =
        double.tryParse(Data.cpuUsage.replaceAll('%', '')) ?? 0.0;
    double ramProgress =
        double.tryParse(Data.ramUsage.replaceAll('%', '')) ?? 0.0;
    final runningCount = Data.botList
        .where((bot) => bot['isRunning'] == true)
        .length;

    double botProgress = Data.botList.isEmpty
        ? 0.0
        : runningCount / Data.botList.length;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  color: Colors.white,
                  onPressed: _selectedIndex > 0
                      ? () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                ),
                Text(
                  _titles[_selectedIndex],
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  color: Colors.white,
                  onPressed: _selectedIndex < _titles.length - 1
                      ? () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                ),
              ],
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                  // 主页
                  ListView(
                    children: [
                      _buildProgressTile(
                        title: 'CPU',
                        icon: Icons.memory,
                        value: Data.cpuUsage,
                        progress: cpuProgress / 100,
                      ),
                      _buildProgressTile(
                        title: 'RAM',
                        icon: Icons.sd_storage,
                        value: Data.ramUsage,
                        progress: ramProgress / 100,
                      ),
                      _buildProgressTile(
                        title: '运行',
                        icon: Icons.smart_toy_outlined,
                        value: '$runningCount/${Data.botList.length}',
                        progress: botProgress,
                      ),
                      Card(
                        color: const Color(0xFF1E1E1E),
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.computer_rounded,
                            color: Colors.white,
                          ),
                          title: Text(
                            Data.platform,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      _buildInfoTile(
                        title: Data.isConnected ? '已连接' : '未连接',
                        icon: Data.isConnected
                            ? Icons.check_circle
                            : Icons.error,
                        isConnected: Data.isConnected,
                      ),
                    ],
                  ),
                  BotListPage(pageController: _pageController),
                  gOnOpen.isNotEmpty
                      ? const ManageBot()
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.info_outline, color: Colors.white),
                              SizedBox(height: 8),
                              Text(
                                '请先在Bot列表选择一个Bot',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                  // 创建
                  const CreateBot(),
                  // 导入
                  const ImportBot(),
                  // 设置
                  const Settings(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

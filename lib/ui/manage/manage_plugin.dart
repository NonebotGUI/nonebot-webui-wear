import 'dart:async';
import 'dart:convert';
import 'package:marquee/marquee.dart';
import 'package:nonebot_webui_wear/utils/global.dart';
import 'package:flutter/material.dart';

class ManagePlugin extends StatefulWidget {
  const ManagePlugin({super.key});

  @override
  State<ManagePlugin> createState() => _ManagePluginState();
}

class _ManagePluginState extends State<ManagePlugin> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;
  Timer? _timer;
  List _pluginList = [];
  List _disabledPluginList = [];

  @override
  void initState() {
    super.initState();
    getData();
    broadcastStream?.listen((message) {
      String msg = message;
      String type = jsonDecode(msg)['type'];
      if (type == 'pluginList') {
        _pluginList = jsonDecode(msg)['data'];
      }
      if (type == 'disabledPluginList') {
        _disabledPluginList = jsonDecode(msg)['data'];
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  getData() async {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          socket.sink.add(
            'plugin/list/${Data.botInfo['id']}&token=${Config.token}',
          );
          socket.sink.add(
            'plugin/disabledList/${Data.botInfo['id']}&token=${Config.token}',
          );
        });
      }
    });
  }

  Widget _buildPageIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIndicatorItem(0, '已启用'),
          const SizedBox(width: 16),
          _buildIndicatorItem(1, '已禁用'),
        ],
      ),
    );
  }

  Widget _buildIndicatorItem(int index, String text) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 40,
            color: isSelected ? Colors.blue : Colors.transparent,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
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
                '插件管理',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              // Placeholder for alignment
              const IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.black,
                ),
                onPressed: null,
              ),
            ],
          ),
          _buildPageIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              children: [
                (_pluginList.isEmpty)
                    ? const Center(
                        child: Text(
                          '空空如也......',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _pluginList.length,
                        itemBuilder: (context, index) {
                          final pluginName = _pluginList[index];
                          if (pluginName.isEmpty)
                            return const SizedBox.shrink();
                          return Card(
                            color: Colors.grey[900],
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: ListTile(
                              title: SizedBox(
                                height: 20.0,
                                child: Marquee(
                                  text: pluginName,
                                  style: const TextStyle(color: Colors.white),
                                  scrollAxis: Axis.horizontal,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  blankSpace: 20.0,
                                  velocity: 50.0,
                                  pauseAfterRound: const Duration(seconds: 1),
                                  startPadding: 10.0,
                                  accelerationDuration: const Duration(
                                    seconds: 1,
                                  ),
                                  accelerationCurve: Curves.linear,
                                  decelerationDuration: const Duration(
                                    milliseconds: 500,
                                  ),
                                  decelerationCurve: Curves.easeOut,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => _PluginActionPage(
                                      pluginName: pluginName,
                                      isEnabled: true,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                (_disabledPluginList.isEmpty)
                    ? const Center(
                        child: Text(
                          '空空如也......',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _disabledPluginList.length,
                        itemBuilder: (context, index) {
                          final pluginName = _disabledPluginList[index];
                          if (pluginName.isEmpty)
                            return const SizedBox.shrink();
                          return Card(
                            color: Colors.grey[900],
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: ListTile(
                              title: SizedBox(
                                height: 20.0,
                                child: Marquee(
                                  text: pluginName,
                                  style: const TextStyle(color: Colors.white),
                                  scrollAxis: Axis.horizontal,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  blankSpace: 20.0,
                                  velocity: 50.0,
                                  pauseAfterRound: const Duration(seconds: 1),
                                  startPadding: 10.0,
                                  accelerationDuration: const Duration(
                                    seconds: 1,
                                  ),
                                  accelerationCurve: Curves.linear,
                                  decelerationDuration: const Duration(
                                    milliseconds: 500,
                                  ),
                                  decelerationCurve: Curves.easeOut,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => _PluginActionPage(
                                      pluginName: pluginName,
                                      isEnabled: false,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PluginActionPage extends StatelessWidget {
  final String pluginName;
  final bool isEnabled;

  const _PluginActionPage({required this.pluginName, required this.isEnabled});

  void _togglePlugin(BuildContext context) {
    final action = isEnabled ? 'disable' : 'enable';
    Map data = {'name': pluginName, 'id': gOnOpen};
    String dataStr = jsonEncode(data);
    socket.sink.add('plugin/$action?data=$dataStr&token=${Config.token}');
    Navigator.pop(context);
  }

  void _uninstallPlugin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _UninstallConfirmPage(pluginName: pluginName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
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
              Text(
                "操作",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.black,
                ),
                onPressed: null,
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      pluginName,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: Icon(
                        isEnabled
                            ? Icons.do_not_disturb_on_total_silence_rounded
                            : Icons.play_circle_outline_rounded,
                      ),
                      label: Text(isEnabled ? '禁用' : '启用'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isEnabled
                            ? Colors.orange
                            : Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => _togglePlugin(context),
                    ),
                    const SizedBox(height: 16),
                    isEnabled
                        ? ElevatedButton.icon(
                            icon: const Icon(Icons.delete_forever_rounded),
                            label: const Text('卸载插件'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () => _uninstallPlugin(context),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UninstallConfirmPage extends StatelessWidget {
  final String pluginName;
  const _UninstallConfirmPage({required this.pluginName});

  void _confirmUninstall(BuildContext context) {
    Map data = {'name': pluginName, 'id': Data.botInfo['id']};
    String dataStr = jsonEncode(data);
    socket.sink.add('plugin/uninstall?data=$dataStr&token=${Config.token}');
    // Pop twice to go back to the list page
    int count = 0;
    Navigator.of(context).popUntil((_) => count++ >= 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '确定要卸载插件 "$pluginName" 吗？',
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _confirmUninstall(context),
                child: const Text('确定'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white54),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

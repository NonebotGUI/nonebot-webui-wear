import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nonebot_webui_wear/utils/global.dart';

class ManageBot extends StatefulWidget {
  const ManageBot({super.key});

  @override
  State<ManageBot> createState() => _ManageBotState();
}

class _ManageBotState extends State<ManageBot> {
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    broadcastStream!.listen((event) {
      if (!mounted) return;
      try {
        Map response = jsonDecode(event);
        String type = response['type'];
        if (type == 'botLog' || type == 'botInfo') {
          setState(() {});
          _scrollToBottom();
        }
      } catch (e) {
        //
      }
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    _scrollTimer?.cancel();
    _scrollTimer = Timer(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (gOnOpen.isEmpty) {
      return const Center(
        child: Text(
          '请先在Bot列表中选择一个Bot',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return GestureDetector(
      onDoubleTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const _BotActionsPage()),
        );
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SelectableText.rich(
              TextSpan(
                children: _logSpans(Data.botLog),
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 10,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: '滚动到底部',
          onPressed: _scrollToBottom,
          mini: true,
          backgroundColor: Colors.grey[800],
          child: const Icon(
            Icons.arrow_downward,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}

// --- Bot 操作列表页面 ---
class _BotActionsPage extends StatelessWidget {
  const _BotActionsPage();

  @override
  Widget build(BuildContext context) {
    final bool isRunning = Data.botInfo['isRunning'] ?? false;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Center(
                child: Text(
                  Data.botInfo['name'] ?? '操作列表',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _buildActionTile(
                    context: context,
                    icon: Icons.play_arrow_rounded,
                    title: '启动',
                    color: Colors.green,
                    onTap: () {
                      if (isRunning) {
                        _showSnackBar(context, 'Bot已经在运行了！');
                      } else {
                        socket.sink.add(
                          'bot/run/${Data.botInfo['id']}&token=${Config.token}',
                        );
                        Navigator.pop(context);
                      }
                    },
                  ),
                  _buildActionTile(
                    context: context,
                    icon: Icons.stop_rounded,
                    title: '停止',
                    color: Colors.red,
                    onTap: () {
                      if (!isRunning) {
                        _showSnackBar(context, 'Bot未运行！');
                      } else {
                        socket.sink.add(
                          'bot/stop/${Data.botInfo['id']}&token=${Config.token}',
                        );
                        Navigator.pop(context);
                      }
                    },
                  ),
                  _buildActionTile(
                    context: context,
                    icon: Icons.refresh_rounded,
                    title: '重启',
                    color: Colors.blue,
                    onTap: () {
                      if (!isRunning) {
                        _showSnackBar(context, 'Bot未运行！');
                      } else {
                        socket.sink.add(
                          'bot/restart/${Data.botInfo['id']}&token=${Config.token}',
                        );
                        Navigator.pop(context);
                      }
                    },
                  ),
                  const Divider(color: Colors.white24),
                  _buildActionTile(
                    context: context,
                    icon: Icons.info_outline_rounded,
                    title: 'Bot信息',
                    color: Colors.cyan,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const _BotInfoPage(),
                        ),
                      );
                    },
                  ),
                  _buildActionTile(
                    context: context,
                    icon: Icons.edit_rounded,
                    title: '重命名',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const _RenameBotPage(),
                        ),
                      );
                    },
                  ),
                  const Divider(color: Colors.white24),
                  _buildActionTile(
                    context: context,
                    icon: Icons.delete_forever_rounded,
                    title: '删除',
                    color: Colors.redAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const _DeleteConfirmationPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 28),
      title: Text(title, style: TextStyle(color: color, fontSize: 16)),
      onTap: onTap,
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}

class _BotInfoPage extends StatelessWidget {
  const _BotInfoPage();

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 24.0),
            child: Center(
              child: Text(
                'Bot 信息',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          _buildInfoRow('名称', Data.botInfo['name'] ?? 'N/A'),
          _buildInfoRow('ID', Data.botInfo['id'] ?? 'N/A'),
          _buildInfoRow('路径', Data.botInfo['path'] ?? 'N/A'),
          _buildInfoRow('PID', (Data.botInfo['pid'] ?? 'N/A').toString()),
          _buildInfoRow(
            '状态',
            (Data.botInfo['isRunning'] ?? false) ? '运行中' : '未运行',
          ),
        ],
      ),
    );
  }
}

class _RenameBotPage extends StatefulWidget {
  const _RenameBotPage();

  @override
  State<_RenameBotPage> createState() => _RenameBotPageState();
}

class _RenameBotPageState extends State<_RenameBotPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: Data.botInfo['name'] ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _renameBot() {
    if (_controller.text.isNotEmpty &&
        _controller.text != Data.botInfo['name']) {
      Map data = {'id': Data.botInfo['id'], 'name': _controller.text};
      String res = jsonEncode(data);
      socket.sink.add('bot/rename?data=$res&token=${Config.token}');
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入新的名称')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '重命名 Bot',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: '新名称',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white38),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _renameBot,
              icon: const Icon(Icons.save_rounded),
              label: const Text('保存'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteConfirmationPage extends StatelessWidget {
  const _DeleteConfirmationPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '确认删除',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                Data.botInfo['name'] ?? '未命名 Bot',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 40),
                ),
                onPressed: () {
                  socket.sink.add(
                    'bot/remove/${Data.botInfo['id']}&token=${Config.token}',
                  );
                  gOnOpen = '';
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text(
                  '仅从列表移除',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 40),
                ),
                onPressed: () {
                  socket.sink.add(
                    'bot/delete/${Data.botInfo['id']}&token=${Config.token}',
                  );
                  gOnOpen = '';
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text(
                  '彻底删除 (包含文件)',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  '取消',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///终端字体颜色
//这一段AI写的我什么也不知道😭
List<TextSpan> _logSpans(text) {
  RegExp regex = RegExp(
    r'(\[[A-Z]+\])|(nonebot \|)|(uvicorn \|)|(Env: dev)|(Env: prod)|(Config)|(nonebot_plugin_[\S]+)|("nonebot_plugin_[\S]+)|(使用 Python: [\S]+)|(Using python: [\S]+)|(Loaded adapters: [\S]+)|(\d{2}-\d{2} \d{2}:\d{2}:\d{2})|(Calling API [\S]+)',
  );
  List<TextSpan> spans = [];
  int lastEnd = 0;

  for (Match match in regex.allMatches(text)) {
    if (match.start > lastEnd) {
      spans.add(
        TextSpan(
          text: text.substring(lastEnd, match.start),
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    Color color;
    switch (match.group(0)) {
      case '[SUCCESS]':
        color = Colors.greenAccent;
        break;
      case '[INFO]':
        color = Colors.white;
        break;
      case '[WARNING]':
        color = Colors.orange;
        break;
      case '[ERROR]':
        color = Colors.red;
        break;
      case '[DEBUG]':
        color = Colors.blue;
        break;
      case 'nonebot |':
        color = Colors.green;
        break;
      case 'uvicorn |':
        color = Colors.green;
        break;
      case 'Env: dev':
        color = Colors.orange;
        break;
      case 'Env: prod':
        color = Colors.orange;
        break;
      case 'Config':
        color = Colors.orange;
        break;
      default:
        if (match.group(0)!.startsWith('nonebot_plugin_')) {
          color = Colors.yellow;
        } else if (match.group(0)!.startsWith('"nonebot_plugin_')) {
          color = Colors.yellow;
        } else if (match.group(0)!.startsWith('Loaded adapters:')) {
          color = Colors.greenAccent;
        } else if (match.group(0)!.startsWith('使用 Python:')) {
          color = Colors.greenAccent;
        } else if (match.group(0)!.startsWith('Using python:')) {
          color = Colors.greenAccent;
        } else if (match.group(0)!.startsWith('Calling API')) {
          color = Colors.purple;
        } else if (match.group(0)!.contains('-') &&
            match.group(0)!.contains(':')) {
          color = Colors.green;
        } else {
          color = Colors.white;
        }
        break;
    }

    spans.add(
      TextSpan(
        text: match.group(0),
        style: TextStyle(color: color),
      ),
    );

    lastEnd = match.end;
  }
  if (lastEnd < text.length) {
    spans.add(
      TextSpan(
        text: text.substring(lastEnd),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  return spans;
}

// 组件模板
Widget _item(String title, content) {
  return Column(
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textScaler: const TextScaler.linear(1.15),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(content, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ),
    ],
  );
}

class BotInfoDialog extends StatefulWidget {
  const BotInfoDialog({super.key});

  @override
  _BotInfoDialogState createState() => _BotInfoDialogState();
}

class _BotInfoDialogState extends State<BotInfoDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dynamic size = MediaQuery.of(context).size;
    double height = size.height;
    double width = size.width;
    return Center(
      child: SizedBox(
        width: width * 0.8,
        height: height * 0.8,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Container(
            margin: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 14,
                  child: ListView(
                    children: <Widget>[
                      _item('名称', Data.botInfo['name']),
                      _item('ID', Data.botInfo['id']),
                      _item('路径', Data.botInfo['path']),
                      _item('PID', Data.botInfo['pid'].toString()),
                      _item('状态', Data.botInfo['isRunning'] ? '运行中' : '未运行'),
                    ],
                  ),
                ),
                const Divider(color: Colors.grey),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.delete_rounded),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('删除Bot'),
                                content: const Text('确定删除Bot吗？'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('取消'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      socket.sink.add(
                                        'bot/delete/${Data.botInfo['id']}&token=${Config.token}',
                                      );
                                      gOnOpen = '';
                                      setState(() {});
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      '确定(连同目录一起删除)',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      socket.sink.add(
                                        'bot/remove/${Data.botInfo['id']}&token=${Config.token}',
                                      );
                                      gOnOpen = '';
                                      setState(() {});
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      '确定',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              TextEditingController _controller =
                                  TextEditingController();
                              return AlertDialog(
                                title: const Text('重命名Bot'),
                                content: TextField(
                                  controller: _controller,
                                  decoration: const InputDecoration(
                                    hintText: '请输入新的Bot名称',
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('取消'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (_controller.text.isNotEmpty) {
                                        Map data = {
                                          'id': Data.botInfo['id'],
                                          'name': _controller.text,
                                        };
                                        String res = jsonEncode(data);
                                        socket.sink.add(
                                          'bot/rename?data=$res&token=${Config.token}',
                                        );
                                        Navigator.of(context).pop();
                                        setState(() {});
                                      }
                                    },
                                    child: const Text('确定'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.edit_rounded),
                      ),
                      const SizedBox(width: 4),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            Config.theme['color'] == 'light' ||
                                    Config.theme['color'] == 'default'
                                ? const Color.fromRGBO(234, 82, 82, 1)
                                : const Color.fromRGBO(147, 112, 219, 1),
                          ),
                          shape: MaterialStateProperty.all(
                            const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                          ),
                          minimumSize: MaterialStateProperty.all(
                            const Size(100, 40),
                          ),
                        ),
                        child: const Text(
                          '关闭',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

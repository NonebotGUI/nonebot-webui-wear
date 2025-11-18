import 'package:flutter/material.dart';
import 'package:nonebot_webui_wear/ui/main_pages/about.dart';
import 'package:nonebot_webui_wear/utils/core.dart';
import 'package:nonebot_webui_wear/utils/global.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.link_rounded, color: Colors.white),
            title: const Text('连接设置', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const _ConnectionSettingsPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.info_outline_rounded,
              color: Colors.white,
            ),
            title: const Text('关于', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const About()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ConnectionSettingsPage extends StatefulWidget {
  const _ConnectionSettingsPage();

  @override
  State<_ConnectionSettingsPage> createState() =>
      _ConnectionSettingsPageState();
}

class _ConnectionSettingsPageState extends State<_ConnectionSettingsPage> {
  final hostController = TextEditingController();
  final portController = TextEditingController();
  final tokenController = TextEditingController();
  int _selectedProtocol = 0;

  @override
  void initState() {
    super.initState();
    hostController.text = Config.wsHost;
    portController.text = Config.wsPort.toString();
    tokenController.text = Config.token;
    _selectedProtocol = Config.useHttps;
  }

  Future<void> _saveAndRestart() async {
    if (hostController.text.isEmpty || portController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请填写主机和端口')));
      return;
    }

    final protocol = _selectedProtocol == 1 ? 'https' : 'http';
    try {
      final res = await http
          .get(
            Uri.parse(
              "$protocol://${hostController.text}:${portController.text}/nbgui/v1/ping",
            ),
            headers: {"Authorization": "Bearer ${tokenController.text}"},
          )
          .timeout(const Duration(seconds: 5));

      if (!mounted) return;

      if (res.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('host', hostController.text);
        await prefs.setInt('port', int.parse(portController.text));
        await prefs.setString('token', tokenController.text);
        await prefs.setInt('https', _selectedProtocol);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('配置成功')));

        socket.sink.close();
        connectToWebSocket(Config.wsHost, Config.wsPort, Config.useHttps);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('连接失败: ${res.statusCode}')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('连接异常: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 24.0),
              child: Center(
                child: Text(
                  '连接设置',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const Text('协议', style: TextStyle(color: Colors.white70)),
            DropdownButton<int>(
              value: _selectedProtocol,
              dropdownColor: Colors.grey[850],
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: 0,
                  child: Text('ws://', style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem(
                  value: 1,
                  child: Text('wss://', style: TextStyle(color: Colors.white)),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _selectedProtocol = value);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: hostController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: '主机地址',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white38),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: portController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '端口',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white38),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: tokenController,
              style: const TextStyle(color: Colors.white),
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Token',
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
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save_rounded),
                label: const Text('保存'),
                onPressed: _saveAndRestart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

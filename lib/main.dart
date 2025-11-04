import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nonebot_webui_wear/ui/main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nonebot_webui_wear/utils/global.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  version = '0.1.0';
  debug = false;
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? getHost = prefs.getString('host');
  final int? getPort = prefs.getInt('port');
  final String? getToken = prefs.getString('token');
  final int? getHttps = prefs.getInt('https');
  final int? getAutoWrap = prefs.getInt('autoWrap');

  if (getAutoWrap != null) {
    Config.autoWrap = getAutoWrap;
  } else {
    Config.autoWrap = 1;
  }

  if (getHost != null &&
      getPort != null &&
      getToken != null &&
      getHttps != null) {
    Config.wsHost = getHost;
    Config.wsPort = getPort;
    Config.token = getToken;
    Config.useHttps = getHttps;
    hasData = true;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: hasData
          ? Builder(
              builder: (context) {
                return MainPageMobile();
              },
            )
          : const ConfigPage(),
    );
  }
}

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  final _pageController = PageController();
  final myController = TextEditingController();
  final portController = TextEditingController();
  final tokenController = TextEditingController();
  int _selectedProtocol = 0; // 0 for ws, 1 for wss
  String fileContent = '';
  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  Future<void> _register() async {
    final String license = await rootBundle.loadString('lib/assets/LICENSE');
    LicenseRegistry.addLicense(() async* {
      yield LicenseEntryWithLineBreaks(['NoneBot WebUI Mobile'], license);
    });
  }

  @override
  void initState() {
    super.initState();
    _register();
  }

  @override
  void dispose() {
    _pageController.dispose();
    myController.dispose();
    portController.dispose();
    tokenController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildPage({
    required String title,
    required Widget child,
    bool isLastPage = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            child,
            const SizedBox(height: 8),
            if (!isLastPage)
              ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                ),
                child: const Icon(Icons.chevron_right),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPage(
                  title: '选择协议',
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        title: const Text(
                          'ws://',
                          style: TextStyle(color: Colors.white),
                        ),
                        leading: Radio<int>(
                          value: 0,
                          groupValue: _selectedProtocol,
                          onChanged: (int? value) {
                            setState(() {
                              _selectedProtocol = value!;
                            });
                          },
                        ),
                        onTap: () => setState(() => _selectedProtocol = 0),
                      ),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        title: const Text(
                          'wss://',
                          style: TextStyle(color: Colors.white),
                        ),
                        leading: Radio<int>(
                          value: 1,
                          groupValue: _selectedProtocol,
                          onChanged: (int? value) {
                            setState(() {
                              _selectedProtocol = value!;
                            });
                          },
                        ),
                        onTap: () => setState(() => _selectedProtocol = 1),
                      ),
                    ],
                  ),
                ),
                _buildPage(
                  title: '输入主机地址',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: myController,
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
                  ),
                ),
                _buildPage(
                  title: '输入 Agent 端口',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: portController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Agent 端口',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white38),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                _buildPage(
                  title: '输入 Agent Token',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: tokenController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Agent Token',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white38),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                _buildPage(
                  title: '准备就绪',
                  isLastPage: true,
                  child: Column(
                    children: [
                      const Text(
                        '点击下方按钮保存并连接',
                        style: TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          final host = myController.text;
                          final port = int.tryParse(portController.text);
                          final token = tokenController.text;

                          if (host.isEmpty || port == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('请输入有效的主机和端口')),
                            );
                            _pageController.jumpToPage(1);
                            return;
                          }

                          try {
                            final protocol = _selectedProtocol == 1
                                ? 'https'
                                : 'http';
                            final res = await http
                                .get(
                                  Uri.parse(
                                    "$protocol://$host:$port/nbgui/v1/ping",
                                  ),
                                  headers: {"Authorization": "Bearer $token"},
                                )
                                .timeout(const Duration(seconds: 5));

                            if (res.statusCode == 200) {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString('host', host);
                              await prefs.setInt('port', port);
                              await prefs.setString('token', token);
                              await prefs.setInt('https', _selectedProtocol);

                              Config.wsHost = host;
                              Config.wsPort = port;
                              Config.token = token;
                              Config.useHttps = _selectedProtocol;
                              hasData = true;

                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('配置成功！')),
                              );

                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MainPageMobile(),
                                ),
                                (Route<dynamic> route) => false,
                              );
                            } else {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '连接失败: ${res.statusCode} ${res.body}',
                                  ),
                                ),
                              );
                              _pageController.jumpToPage(0);
                            }
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text('连接异常: $e')));
                            _pageController.jumpToPage(0);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(16),
                        ),
                        child: const Icon(Icons.check),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

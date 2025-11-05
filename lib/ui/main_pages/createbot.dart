// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';
import 'package:nonebot_webui_wear/utils/global.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateBot extends StatelessWidget {
  const CreateBot({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '创建新的 Bot',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(16),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Step1BasicInfo(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Step1BasicInfo extends StatefulWidget {
  const Step1BasicInfo({super.key});

  @override
  _Step1BasicInfoState createState() => _Step1BasicInfoState();
}

class _Step1BasicInfoState extends State<Step1BasicInfo> {
  final _nameController = TextEditingController();
  final _pathController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 24.0),
              child: Center(
                child: Text(
                  '1/4: 基本信息',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: '名称',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white38),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _pathController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: '路径',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white38),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('下一步'),
              onPressed: () {
                if (_nameController.text.isNotEmpty &&
                    _pathController.text.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Step2Config(
                        name: _nameController.text,
                        path: _pathController.text,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('名称和路径不能为空')));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Step2Config extends StatefulWidget {
  final String name;
  final String path;

  const Step2Config({super.key, required this.name, required this.path});

  @override
  _Step2ConfigState createState() => _Step2ConfigState();
}

class _Step2ConfigState extends State<Step2Config> {
  bool isVENV = true;
  bool isDep = true;
  String dropDownValue = 'bootstrap(初学者或用户)';
  final List<String> template = ['bootstrap(初学者或用户)', 'simple(插件开发者)'];

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
                '2/4: 配置',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('选择模板', style: TextStyle(color: Colors.white)),
            trailing: DropdownButton<String>(
              value: dropDownValue,
              dropdownColor: Colors.grey[850],
              style: const TextStyle(color: Colors.white),
              onChanged: (String? value) =>
                  setState(() => dropDownValue = value!),
              items: template
                  .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value.split('(').first),
                    ),
                  )
                  .toList(),
            ),
          ),
          SwitchListTile(
            title: const Text("开启虚拟环境", style: TextStyle(color: Colors.white)),
            value: isVENV,
            onChanged: (val) => setState(() => isVENV = val),
          ),
          SwitchListTile(
            title: const Text("安装依赖", style: TextStyle(color: Colors.white)),
            value: isDep,
            onChanged: (val) => setState(() => isDep = val),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              child: const Text('下一步'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Step3Drivers(
                    name: widget.name,
                    path: widget.path,
                    template: dropDownValue,
                    isVenv: isVENV,
                    isDep: isDep,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Step3Drivers extends StatefulWidget {
  final String name, path, template;
  final bool isVenv, isDep;

  const Step3Drivers({
    super.key,
    required this.name,
    required this.path,
    required this.template,
    required this.isVenv,
    required this.isDep,
  });

  @override
  _Step3DriversState createState() => _Step3DriversState();
}

class _Step3DriversState extends State<Step3Drivers> {
  Map<String, bool> drivers = {
    'FastAPI': true,
    'Quart': false,
    'HTTPX': false,
    'websockets': false,
    'AIOHTTP': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 24.0),
              child: Center(
                child: Text(
                  '3/4: 选择驱动器',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: drivers.keys.map((driver) {
                  return CheckboxListTile(
                    title: Text(
                      driver,
                      style: const TextStyle(color: Colors.white),
                    ),
                    value: drivers[driver],
                    onChanged: (bool? value) =>
                        setState(() => drivers[driver] = value!),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                child: const Text('下一步'),
                onPressed: () {
                  List<String> selectedDrivers = drivers.keys
                      .where((option) => drivers[option] == true)
                      .toList();
                  if (selectedDrivers.isEmpty) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('请至少选择一个驱动器')));
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Step4Adapters(
                        name: widget.name,
                        path: widget.path,
                        template: widget.template,
                        isVenv: widget.isVenv,
                        isDep: widget.isDep,
                        selectedDrivers: selectedDrivers,
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

class Step4Adapters extends StatefulWidget {
  final String name, path, template;
  final bool isVenv, isDep;
  final List<String> selectedDrivers;

  const Step4Adapters({
    super.key,
    required this.name,
    required this.path,
    required this.template,
    required this.isVenv,
    required this.isDep,
    required this.selectedDrivers,
  });

  @override
  _Step4AdaptersState createState() => _Step4AdaptersState();
}

class _Step4AdaptersState extends State<Step4Adapters> {
  List<dynamic> adapterList = [];
  Map<String, bool> adapterMap = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAdapters();
  }

  Future<void> _fetchAdapters() async {
    try {
      final response = await http.get(
        Uri.parse('https://registry.nonebot.dev/adapters.json'),
      );
      if (mounted && response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        setState(() {
          adapterList = json.decode(decodedBody);
          adapterMap = {for (var item in adapterList) item['name']: false};
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _createBot() {
    List<String> selectedAdapters = adapterMap.keys
        .where((option) => adapterMap[option] == true)
        .map((option) {
          String moduleName =
              adapterList.firstWhere(
                    (adapter) => adapter['name'] == option,
                  )['module_name']
                  as String;
          return moduleName
              .replaceAll('adapters', 'adapter')
              .replaceAll('.', '-')
              .replaceAll('-v11', '.v11')
              .replaceAll('-v12', '.v12');
        })
        .toList();

    if (selectedAdapters.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请至少选择一个适配器')));
      return;
    }

    Map data = {
      "name": widget.name,
      "path": widget.path,
      "template": widget.template,
      "pluginDir": "在[bot名称]/[bot名称]下",
      "venv": widget.isVenv,
      "installDep": widget.isDep,
      "drivers": widget.selectedDrivers,
      "adapters": selectedAdapters,
    };
    String dataJson = jsonEncode(data);
    socket.sink.add('bot/create?data=$dataJson&token=${Config.token}');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const InstallingBot()),
      (Route<dynamic> route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 24.0),
              child: Center(
                child: Text(
                  '4/4: 选择适配器',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      children: adapterMap.keys.map((name) {
                        return CheckboxListTile(
                          title: Text(
                            name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          value: adapterMap[name],
                          onChanged: (bool? value) =>
                              setState(() => adapterMap[name] = value!),
                        );
                      }).toList(),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child: Text('完成并创建'),
                onPressed: _createBot,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InstallingBot extends StatefulWidget {
  const InstallingBot({super.key});

  @override
  State<InstallingBot> createState() => _InstallingBotState();
}

class _InstallingBotState extends State<InstallingBot> {
  final List<String> _logLines = [];
  final ScrollController _scrollController = ScrollController();
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = broadcastStream!.listen((event) {
      if (!mounted) return;
      try {
        Map msgJson = jsonDecode(event);
        String type = msgJson['type'];
        if (type == 'installBotLog') {
          setState(() {
            _logLines.add(msgJson['data']);
          });
          Timer(const Duration(milliseconds: 100), () {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        } else if (type == 'installBotStatus' && msgJson['data'] == 'done') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('创建成功!'),
              duration: Duration(seconds: 2),
            ),
          );
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
        }
      } catch (e) {
        //
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 24.0),
              child: Center(
                child: Text(
                  '正在创建 Bot...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Text(
                  _logLines.join('\n'),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: 'JetBrainsMono',
                    fontSize: 10,
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

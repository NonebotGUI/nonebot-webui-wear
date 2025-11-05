import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nonebot_webui_wear/utils/global.dart';

class ImportBot extends StatelessWidget {
  const ImportBot({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '导入现有 Bot',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(16),
              ),
              child: const Icon(
                Icons.input_rounded,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const _Step1ImportName(),
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

class _Step1ImportName extends StatefulWidget {
  const _Step1ImportName();

  @override
  State<_Step1ImportName> createState() => _Step1ImportNameState();
}

class _Step1ImportNameState extends State<_Step1ImportName> {
  final _nameController = TextEditingController();

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
                  '1/2: 输入名称',
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
            ElevatedButton(
              child: const Text('下一步'),
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          _Step2ImportPath(name: _nameController.text),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('名称不能为空')));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Step2ImportPath extends StatefulWidget {
  final String name;
  const _Step2ImportPath({required this.name});

  @override
  State<_Step2ImportPath> createState() => _Step2ImportPathState();
}

class _Step2ImportPathState extends State<_Step2ImportPath> {
  final _pathController = TextEditingController();

  void _importBot() {
    if (_pathController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('路径不能为空')));
      return;
    }

    Map<String, dynamic> res = {
      'name': widget.name,
      'path': _pathController.text,
      'withProtocol': false,
      'protocolPath': '',
      'cmd': '',
    };
    String data = jsonEncode(res);
    socket.sink.add('bot/import?data=$data&token=${Config.token}');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('导入请求已发送')));

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

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
                  '2/2: 输入路径',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            TextField(
              controller: _pathController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Bot根目录绝对路径',
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              onPressed: _importBot,
              child: const Text('完成并导入'),
            ),
          ],
        ),
      ),
    );
  }
}

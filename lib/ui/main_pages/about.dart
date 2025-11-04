import 'package:flutter/material.dart';
import 'package:nonebot_webui_wear/utils/global.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _MoreState();
}

class _MoreState extends State<About> {
  int tapCount = 0;
  final int tapsToReveal = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        children: <Widget>[
          const Center(
            child: Text(
              "NoneBot WebUI Wear",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoTile('软件版本', version),
          _buildInfoTile('Agent 版本', Data.agentVersion['version'] ?? 'N/A'),
          _buildInfoTile('Python 版本', Data.agentVersion['python'] ?? 'N/A'),
          _buildInfoTile('nb-cli 版本', Data.agentVersion['nbcli'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, {VoidCallback? onTap}) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        subtitle: InkWell(
          onTap: onTap,
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }
}

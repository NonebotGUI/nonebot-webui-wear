// import 'package:nonebot_webui_wear/ui/manage/env.dart';
import 'package:nonebot_webui_wear/ui/manage/adapter.dart';
import 'package:nonebot_webui_wear/ui/manage/driver.dart';
// import 'package:nonebot_webui_wear/ui/manage/manage_plugin.dart';
import 'package:nonebot_webui_wear/ui/manage/plugin.dart';
import 'package:flutter/material.dart';

class ManageList extends StatefulWidget {
  const ManageList({super.key});

  @override
  State<ManageList> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<ManageList> {
  final myController = TextEditingController();

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
                '操作',
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
            child: ListView(
              children: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const PluginStore();
                        },
                      ),
                    );
                  },
                  child: const ListTile(
                    title: Text('插件商店', style: TextStyle(color: Colors.white)),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const AdapterStore();
                        },
                      ),
                    );
                  },
                  child: const ListTile(
                    title: Text('适配器商店', style: TextStyle(color: Colors.white)),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const DriverStore();
                        },
                      ),
                    );
                  },
                  child: const ListTile(
                    title: Text('驱动器商店', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const Divider(),
                // InkWell(
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) {
                //           return const ManagePlugin();
                //         },
                //       ),
                //     );
                //   },
                //   child: const ListTile(title: Text('插件管理')),
                // ),
                // const Divider(),
                // InkWell(
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) {
                //           return const EditEnv();
                //         },
                //       ),
                //     );
                //   },
                //   child: const ListTile(title: Text('env配置')),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:nonebot_webui_wear/utils/global.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DriverStore extends StatefulWidget {
  const DriverStore({super.key});

  @override
  State<DriverStore> createState() => _DriverStoreState();
}

class _DriverStoreState extends State<DriverStore> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> data = [];
  List<Map<String, dynamic>> search = [];
  bool _isLoading = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('https://registry.nonebot.dev/drivers.json'),
      );
      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          String decodedBody = utf8.decode(response.bodyBytes);
          final List<dynamic> jsonData = json.decode(decodedBody);
          data = jsonData.map((item) => item as Map<String, dynamic>).toList();
          search = data;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('加载驱动器列表失败')));
      }
    }
  }

  void _searchDrivers(value) {
    setState(() {
      search = data.where((driver) {
        return driver['name'].toLowerCase().contains(value.toLowerCase()) ||
            driver['desc'].toLowerCase().contains(value.toLowerCase()) ||
            driver['module_name'].toLowerCase().contains(value.toLowerCase()) ||
            driver['author'].toLowerCase().contains(value.toLowerCase());
      }).toList();
    });
  }

  Widget _buildTopBar() {
    if (_isSearching) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
        child: SizedBox(
          height: 40,
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: '搜索...',
              hintStyle: const TextStyle(color: Colors.white70),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.white38),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.white38),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.white),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                    _searchDrivers('');
                  });
                },
              ),
            ),
            onChanged: _searchDrivers,
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 8, 4),
        child: SizedBox(
          height: 40,
          child: Row(
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
                '商店',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _isSearching = true;
                  });
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color.fromRGBO(147, 112, 219, 1),
                          ),
                        ),
                        const Text(
                          '加载中...',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: search.length,
                    itemBuilder: (BuildContext context, int index) {
                      final driver = search[index];
                      return Card(
                        color: Colors.grey[900],
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        child: ListTile(
                          title: Text(
                            driver['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            driver['desc'],
                            style: const TextStyle(color: Colors.white70),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    _DriverDetailPage(driver: driver),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _DriverDetailPage extends StatelessWidget {
  final Map<String, dynamic> driver;
  const _DriverDetailPage({required this.driver});

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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "名称",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      driver['name'],
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "模块名",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      driver['module_name'],
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "作者",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      driver['author'],
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "描述",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      driver['desc'],
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.download_rounded),
                        label: const Text('安装'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Map data = {
                            'id': gOnOpen,
                            'name': driver['module_name'],
                          };
                          String dataStr = jsonEncode(data);
                          socket.sink.add(
                            'driver/install?data=$dataStr&token=${Config.token}',
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const _InstallingDriverPage(),
                            ),
                          );
                        },
                      ),
                    ),
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

class _InstallingDriverPage extends StatefulWidget {
  const _InstallingDriverPage();

  @override
  State<_InstallingDriverPage> createState() => _InstallingDriverPageState();
}

class _InstallingDriverPageState extends State<_InstallingDriverPage> {
  final List<String> _logLines = [];
  final ScrollController _scrollController = ScrollController();
  StreamSubscription? _broadcastSubscription;
  bool _isDone = false;

  @override
  void initState() {
    super.initState();
    _broadcastSubscription = broadcastStream?.listen((event) {
      if (!mounted) return;
      try {
        final msgJson = jsonDecode(event);
        final type = msgJson['type'];
        final data = msgJson['data'];

        if (type == 'driverInstallLog') {
          setState(() {
            _logLines.add(data);
          });
          _scrollToBottom();
        } else if (type == 'installDriverStatus' && data == 'done') {
          setState(() {
            _logLines.add("\n🎉 安装完成!");
            _isDone = true;
          });
          _scrollToBottom();
        }
      } catch (e) {
        //
      }
    });
  }

  @override
  void dispose() {
    _broadcastSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Center(
                child: Text(
                  _isDone ? '安装完成' : '正在安装驱动器...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                color: const Color.fromARGB(255, 18, 18, 18),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Text(
                    _logLines.join(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontFamily: 'JetBrainsMono',
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),
            if (_isDone)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('完成'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

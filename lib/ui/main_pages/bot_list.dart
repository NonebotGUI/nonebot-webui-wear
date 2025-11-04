import 'package:flutter/material.dart';
import 'package:nonebot_webui_wear/utils/global.dart';
import 'package:marquee/marquee.dart';

class BotListPage extends StatelessWidget {
  final PageController pageController;

  const BotListPage({super.key, required this.pageController});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: Data.botList.length,
      itemBuilder: (context, index) {
        final bot = Data.botList[index];
        return Card(
          color: const Color(0xFF1E1E1E),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: SizedBox(
              height: 20.0,
              child: Marquee(
                text: bot['name'],
                style: const TextStyle(color: Colors.white),
                scrollAxis: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.start,
                blankSpace: 20.0,
                velocity: 50.0,
                pauseAfterRound: const Duration(seconds: 1),
                startPadding: 10.0,
                accelerationDuration: const Duration(seconds: 1),
                accelerationCurve: Curves.linear,
                decelerationDuration: const Duration(milliseconds: 500),
                decelerationCurve: Curves.easeOut,
              ),
            ),
            subtitle: Text(
              bot['isRunning'] ? '运行中' : '未运行',
              style: TextStyle(
                color: bot['isRunning'] ? Colors.greenAccent : Colors.grey,
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                bot['isRunning']
                    ? Icons.stop_circle_outlined
                    : Icons.play_circle_outline,
                color: Colors.white,
              ),
              onPressed: () {
                final action = bot['isRunning'] ? 'stop' : 'run';
                socket.sink.add(
                  'bot/$action/${bot['id']}&token=${Config.token}',
                );
              },
            ),
            onTap: () {
              gOnOpen = bot['id'];
              socket.sink.add("botInfo/${bot['id']}&token=${Config.token}");
              pageController.jumpToPage(2);
            },
          ),
        );
      },
    );
  }
}

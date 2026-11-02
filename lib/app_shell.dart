import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dashboard.dart';
import 'screens/control_screen.dart';
import 'screens/graph_screen.dart';
import 'screens/settings_screen.dart';
import 'status_controller.dart';
import 'theme.dart';

/// 하단 탭(홈 · 그래프 · 제어 · 설정)을 가진 앱의 바깥 틀.
///
/// 네 화면은 [IndexedStack] 으로 모두 살아 있으므로, 탭을 옮겨도 스크롤 위치나
/// 그래프가 초기화되지 않습니다. 네 화면 모두 같은 [controller] 를 봅니다.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.controller});

  final StatusController controller;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const int _settingsTab = 3;

  int _index = 0;

  void _select(int index) {
    if (index == _index) return;
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final StatusController controller = widget.controller;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // 어두운 배경 위에서 상단 상태바(시계·배터리) 아이콘이 보이도록 밝게 지정합니다.
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: UpmColors.background,
        body: IndexedStack(
          index: _index,
          sizing: StackFit.expand,
          children: <Widget>[
            DashboardScreen(
              controller: controller,
              onOpenSettings: () => _select(_settingsTab),
            ),
            GraphScreen(controller: controller),
            ControlScreen(controller: controller),
            SettingsScreen(controller: controller),
          ],
        ),
        bottomNavigationBar: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: UpmColors.border)),
          ),
          child: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: _select,
            destinations: const <Widget>[
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: '홈',
              ),
              NavigationDestination(
                icon: Icon(Icons.show_chart_rounded),
                selectedIcon: Icon(Icons.insights_rounded),
                label: '그래프',
              ),
              NavigationDestination(
                icon: Icon(Icons.tune_rounded),
                selectedIcon: Icon(Icons.tune_rounded),
                label: '제어',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded),
                label: '설정',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

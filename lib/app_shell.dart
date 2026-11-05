import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dashboard.dart';
import 'screens/control_screen.dart';
import 'screens/graph_screen.dart';
import 'screens/settings_screen.dart';
import 'status_controller.dart';
import 'theme.dart';
import 'widgets/upm_card.dart';

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
      // 밝은 배경 위에서 상단 상태바(시계·배터리) 아이콘이 보이도록 어둡게 지정합니다.
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      // 배경 그라데이션을 화면 전체(하단 탭 주변 포함)에 깔고, 그 위에 Scaffold 를 투명하게 올립니다.
      child: UpmBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          // 하단 탭은 화면 아래 별도 영역에 고정됩니다. 콘텐츠는 탭 위에서 끝나므로 겹치지 않습니다.
          body: IndexedStack(
            index: _index,
            sizing: StackFit.expand,
            children: <Widget>[
              DashboardScreen(
                controller: controller,
                onOpenSettings: () => _select(_settingsTab),
              ),
              GraphScreen(controller: controller, onBack: () => _select(0)),
              ControlScreen(controller: controller),
              SettingsScreen(controller: controller),
            ],
          ),
          bottomNavigationBar: UpmBottomNav(selectedIndex: _index, onSelected: _select),
        ),
      ),
    );
  }
}

/// 하단 탭 항목 1개의 정보.
class _NavItem {
  const _NavItem(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const List<_NavItem> _navItems = <_NavItem>[
  _NavItem('홈', Icons.home_outlined, Icons.home_rounded),
  _NavItem('그래프', Icons.show_chart_rounded, Icons.insights_rounded),
  _NavItem('제어', Icons.tune_rounded, Icons.tune_rounded),
  _NavItem('설정', Icons.settings_outlined, Icons.settings_rounded),
];

/// 화면 아래에 떠 있는 둥근 반투명 하단 탭.
///
/// 선택된 탭은 블루 아이콘·글자 + 아래 작은 점, 나머지는 블루 그레이로 표시합니다.
class UpmBottomNav extends StatelessWidget {
  const UpmBottomNav({super.key, required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(UpmRadius.nav);

    // SafeArea: 안드로이드 하단 시스템 버튼(제스처 바) 영역과 겹치지 않게 합니다.
    return SafeArea(
      top: false,
      child: Padding(
        // 시안: 좌우 약 19pt 여백, 높이 약 60pt
        padding: const EdgeInsets.fromLTRB(19, 4, 19, 8),
        child: DecoratedBox(
          decoration: BoxDecoration(borderRadius: radius, boxShadow: UpmShadows.floating),
          child: ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                height: 62,
                decoration: BoxDecoration(
                  color: UpmColors.surface.withValues(alpha: 0.92),
                  borderRadius: radius,
                  border: Border.all(color: UpmColors.borderGlass),
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: Row(
                    children: <Widget>[
                      for (int i = 0; i < _navItems.length; i++)
                        Expanded(
                          child: _NavButton(
                            item: _navItems[i],
                            selected: i == selectedIndex,
                            onTap: () => onSelected(i),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item, required this.selected, required this.onTap});

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = selected ? UpmColors.blue : UpmColors.navInactive;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedSwitcher(
              duration: UpmMotion.fast,
              child: Icon(
                selected ? item.selectedIcon : item.icon,
                key: ValueKey<bool>(selected),
                size: 24,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              maxLines: 1,
              style: TextStyle(
                color: color,
                fontSize: 11.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: UpmMotion.normal,
              width: selected ? 4.5 : 0,
              height: 4.5,
              decoration: const BoxDecoration(color: UpmColors.blue, shape: BoxShape.circle),
            ),
          ],
        ),
      ),
    );
  }
}

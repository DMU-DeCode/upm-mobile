// 앱 뼈대(하단 탭) 동작 테스트.
//
// 실행: flutter test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:upm_app/dashboard.dart';
import 'package:upm_app/main.dart';
import 'package:upm_app/status_controller.dart';

void main() {
  testWidgets('하단 탭 4개가 보이고, 탭을 누르면 화면이 바뀐다', (WidgetTester tester) async {
    // 폴링을 시작하지 않은 컨트롤러를 넣어, 테스트 중에 실제 네트워크 요청이 나가지 않게 합니다.
    final StatusController controller = StatusController(
      client: MockClient((http.Request request) async => http.Response('', 503)),
    );

    await tester.pumpWidget(UpmApp(controller: controller));

    NavigationBar bar() => tester.widget<NavigationBar>(find.byType(NavigationBar));
    Finder tab(String label) =>
        find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

    expect(find.byType(NavigationDestination), findsNWidgets(4));
    for (final String label in <String>['홈', '그래프', '제어', '설정']) {
      expect(tab(label), findsWidgets);
    }
    expect(bar().selectedIndex, 0);

    // 제어 탭으로 이동하면 기존 제어 버튼 3개가 보여야 합니다.
    await tester.tap(tab('제어').first);
    await tester.pump(const Duration(milliseconds: 600));
    expect(bar().selectedIndex, 2);
    expect(find.text('빠른 최적화'), findsWidgets);
    expect(find.text('전원 끄기'), findsWidgets);
    expect(find.text('PC 재시작'), findsWidgets);

    // 홈으로 돌아와 오른쪽 위 설정 아이콘을 누르면 설정 탭으로 이동합니다.
    await tester.tap(tab('홈').first);
    await tester.pump(const Duration(milliseconds: 600));
    expect(bar().selectedIndex, 0);

    await tester.tap(
      find.descendant(
        of: find.byType(DashboardScreen),
        matching: find.byIcon(Icons.settings_outlined),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(bar().selectedIndex, 3);

    // 화면을 먼저 내린 뒤 컨트롤러를 정리합니다.
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });
}

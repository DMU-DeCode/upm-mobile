import 'package:flutter/material.dart';

import '../status_controller.dart';
import '../theme.dart';

/// 연결 상태를 나타내는 문구.
String linkStatusLabel(LinkStatus status) {
  return switch (status) {
    LinkStatus.connecting => '연결 중',
    LinkStatus.connected => '연결됨',
    LinkStatus.pcIdle => 'PC 응답 없음',
    LinkStatus.disconnected => '연결 안 됨',
  };
}

/// 연결 상태를 나타내는 색.
Color linkStatusColor(LinkStatus status) {
  return switch (status) {
    LinkStatus.connecting => UpmColors.textSecondary,
    LinkStatus.connected => UpmColors.green,
    LinkStatus.pcIdle => UpmColors.orange,
    LinkStatus.disconnected => UpmColors.red,
  };
}

/// "● 연결됨" / "○ 연결 안 됨" 형태의 연결 상태 표시.
///
/// 상태가 바뀌면 점 색과 문구가 부드럽게 바뀝니다.
class ConnectionStatusBadge extends StatelessWidget {
  const ConnectionStatusBadge({super.key, required this.status, this.chip = false, this.fontSize = 13});

  final LinkStatus status;

  /// true 면 옅은 색 배경의 둥근 알약 모양으로 그립니다 (예: 설정 화면 "● 연결됨").
  final bool chip;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final Color color = linkStatusColor(status);
    if (chip) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: ConnectionStatusBadge(status: status, fontSize: fontSize),
      );
    }
    // 연결된 상태는 채워진 점(●), 그 외는 빈 점(○)으로 구분합니다.
    final bool filled = status == LinkStatus.connected || status == LinkStatus.pcIdle;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? color : Colors.transparent,
            border: Border.all(color: color, width: 1.5),
            boxShadow: status == LinkStatus.connected
                ? <BoxShadow>[BoxShadow(color: color.withValues(alpha: 0.55), blurRadius: 8)]
                : const <BoxShadow>[],
          ),
        ),
        const SizedBox(width: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            linkStatusLabel(status),
            key: ValueKey<LinkStatus>(status),
            style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

/// 연결이 끊겼거나 PC 데이터가 오지 않을 때 보여 주는 안내 카드.
/// 정상 연결 상태에서는 아무것도 그리지 않습니다.
class LinkNotice extends StatelessWidget {
  const LinkNotice({super.key, required this.status, required this.onRetry});

  final LinkStatus status;

  /// "다시 연결" 버튼을 눌렀을 때.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (status == LinkStatus.connecting || status == LinkStatus.connected) {
      return const SizedBox.shrink();
    }
    final bool serverDown = status == LinkStatus.disconnected;
    final String title = serverDown ? '연결 끊김' : 'PC 응답 없음';
    final String message = serverDown
        ? 'PC와 연결할 수 없습니다.'
        : '서버에는 연결됐지만 PC에서 새 데이터가 오지 않습니다. '
            'PC의 UPM 프로그램이 실행 중인지 확인해 주세요.';
    final Color color = linkStatusColor(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(UpmRadius.card),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.wifi_off_rounded, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(color: UpmColors.textSecondary, fontSize: 12, height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(foregroundColor: color),
            child: const Text('다시 연결', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

/// 카드 제목 옆의 "● 실시간" 표시.
///
/// PC 데이터가 실제로 들어오는 동안에만 "실시간"이고, 그 외에는 회색 "일시정지"로 바뀝니다.
class LiveChip extends StatelessWidget {
  const LiveChip({super.key, required this.status});

  final LinkStatus status;

  @override
  Widget build(BuildContext context) {
    final bool live = status == LinkStatus.connected;
    return AnimatedContainer(
      duration: UpmMotion.normal,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF1F9),
        borderRadius: BorderRadius.circular(UpmRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: live ? UpmColors.green : UpmColors.textMuted,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            live ? '실시간' : '일시정지',
            style: const TextStyle(color: UpmColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w600),
          ),
          if (live) ...const <Widget>[
            SizedBox(width: 4),
            Icon(Icons.monitor_heart_outlined, size: 13, color: UpmColors.blueBright),
          ],
        ],
      ),
    );
  }
}

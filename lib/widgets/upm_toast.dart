import 'package:flutter/material.dart';

import '../theme.dart';

/// 토스트 종류. 아이콘과 색만 다르고 모양은 같습니다.
enum ToastType {
  success(Icons.check_rounded, UpmColors.green),
  info(Icons.info_outline_rounded, UpmColors.blue),
  error(Icons.error_outline_rounded, UpmColors.red);

  const ToastType(this.icon, this.color);

  final IconData icon;
  final Color color;
}

/// 화면 아래(하단 탭 바로 위)에 작게 떠오르는 안내창을 보여 줍니다.
///
/// 흰 배경 · 둥근 모서리 · 은은한 그림자 · 작은 상태 아이콘으로 구성되며,
/// 3초 뒤 자동으로 사라집니다. 새 안내가 오면 이전 안내는 바로 닫힙니다.
void showUpmToast(
  BuildContext context, {
  required ToastType type,
  required String title,
  String? message,
}) {
  final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  final String? detail = message;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.fromLTRB(UpmSpace.screen + 8, 0, UpmSpace.screen + 8, 10),
        // 그림자가 잘리지 않도록 자르기를 끕니다.
        clipBehavior: Clip.none,
        duration: const Duration(seconds: 3),
        content: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
          decoration: BoxDecoration(
            color: UpmColors.surface.withValues(alpha: 0.97),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: UpmColors.border),
            boxShadow: UpmShadows.floating,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: type.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(type.icon, size: 18, color: type.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        color: UpmColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (detail != null) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        detail,
                        style: const TextStyle(color: UpmColors.textSecondary, fontSize: 12, height: 1.35),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
}

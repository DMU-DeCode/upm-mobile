// 화면 표시용 문자열 변환 모음.

String _two(int n) => n.toString().padLeft(2, '0');

/// 시각을 "17:05:09" 형태로 바꿉니다. null 이면 "N/A".
String formatClock(DateTime? time) {
  if (time == null) return 'N/A';
  return '${_two(time.hour)}:${_two(time.minute)}:${_two(time.second)}';
}

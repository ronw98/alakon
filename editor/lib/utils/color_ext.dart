import 'dart:ui';

extension ColorExt on Color {
  String toHtmlString() {
    // ignore: deprecated_member_use
    final value = this.value.toRadixString(16);
    final regex = RegExp(r'..([A-Fa-f0-9]*)');
    final match = regex.firstMatch(value);
    return '#${match!.group(1)!}';
  }
}

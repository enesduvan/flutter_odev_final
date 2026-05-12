String formatDateTime(DateTime value) {
  String twoDigits(int number) => number.toString().padLeft(2, '0');

  return '${twoDigits(value.day)}.${twoDigits(value.month)}.${value.year} '
      '${twoDigits(value.hour)}:${twoDigits(value.minute)}';
}

class TextUtils{

  static const Map<String, String> polishToAscii = {
    'ą': 'a', 'ć': 'c', 'ę': 'e', 'ł': 'l',
    'ń': 'n', 'ó': 'o', 'ś': 's', 'ż': 'z', 'ź': 'z',
    'Ą': 'A', 'Ć': 'C', 'Ę': 'E', 'Ł': 'L',
    'Ń': 'N', 'Ó': 'O', 'Ś': 'S', 'Ż': 'Z', 'Ź': 'Z',
  };

  static String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  static String removeTextSeparators(String s) {
    return s.replaceAll(RegExp(r"[_-]"), ' ');
  }

  static String capitalizeAndRemoveTextSeparators(String s) {
    return capitalize(removeTextSeparators(s));
  }

  static final List<String> shortWords = ['i', 'a', 'o', 'u', 'w', 'z'];

  static String addNoBreakingSpaces(String text) {
    for (var word in shortWords) {
      text = text.replaceAllMapped(
        RegExp(r'\b' + word + r'\s'), 
        (match) => '${match[0]?[0]}\u00A0',
      );
    }
    return text;
  }

  static String sanitizeFileName(String value) {
    String sanitized = value.split('').map((c) => polishToAscii[c] ?? c).join();
    sanitized = sanitized.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), '_');
    return sanitized.isEmpty ? 'training' : sanitized;
  }

}
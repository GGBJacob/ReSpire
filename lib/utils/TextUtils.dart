class TextUtils{
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
    final sanitized = value.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
    return sanitized.isEmpty ? 'training' : sanitized.replaceAll(RegExp(r'\s+'), '_');
  }
}
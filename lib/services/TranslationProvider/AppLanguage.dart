class AppLanguage {
  final String code;
  final String localeCode;
  final String name;

  const AppLanguage({
    required this.code,
    required this.localeCode,
    required this.name,
  });

  static const AppLanguage polish = AppLanguage(
    code: 'pl',
    localeCode: 'pl-PL',
    name: 'Polski',
  );

  static const AppLanguage english = AppLanguage(
    code: 'en',
    localeCode: 'en-US',
    name: 'English',
  );

  static const List<AppLanguage> supportedLanguages = [
    polish,
    english,
  ];

  static AppLanguage fromCode(String? code) {
    if (code == null || code.isEmpty) {
      return polish;
    }
    return supportedLanguages.firstWhere(
      (lang) => lang.code == code,
      orElse: () => english,
    );
  }
}
class UpstyleConfig {
  UpstyleConfig._();

  // Gemini API Key (store securely in production)
  static const String geminiApiKey = 'AIzaSyCnYKkH5Jv6ou5NJXyaK8ZnbXMj5o-AmWU';

  // Feature Flags
  static const bool enableUpcycling = true;
  static const bool enableUpstyling = false;

  // API Timeouts
  static const Duration apiTimeout = Duration(minutes: 2);

  // Image Configuration
  static const int maxImageSize = 10 * 1024 * 1024; // 10MB

  // Default prompt
  static const String defaultUpcyclePrompt =
      "I would like to transform this clothing item into something useful and creative. "
      "Please suggest practical ideas that don't require advanced sewing skills.";
}

class FontRegistry {
  /// Most popular fonts in the world & region
  static final List<String> fonts = [
    'Cairo', // Most used in Arabic Web
    'Roboto', // Most used globally (Google standard)
    'Open Sans',
    'Tajawal',
    'Almarai',
    'Montserrat',
    'Oswald',
    'Playfair Display',
    'Amiri',
    'Changa',
  ];

  /// The absolute default for the entire platform
  static const String globalDefault = 'Cairo'; 
  
  static const String defaultArabic = 'Cairo';
  static const String defaultEnglish = 'Roboto';
}

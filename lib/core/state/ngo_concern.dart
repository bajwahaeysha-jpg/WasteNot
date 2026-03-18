class NgoConcern {
  static String? currentTitle;
  static String? currentConcern;
  static String? currentImagePath;

  static void update({
    String? title,
    String? concern,
    String? imagePath,
  }) {
    currentTitle = title;
    currentConcern = concern;
    currentImagePath = imagePath;
  }
}

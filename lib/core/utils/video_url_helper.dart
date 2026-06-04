class VideoUrlHelper {
  static const String providerYoutube = 'youtube';
  static const String providerVimeo = 'vimeo';
  static const String providerWistia = 'wistia';
  static const String providerCustom = 'custom_iframe';

  static String detectProvider(String url) {
    if (url.isEmpty) return providerCustom;
    final lowerUrl = url.toLowerCase();
    if (lowerUrl.contains('youtube.com') || lowerUrl.contains('youtu.be')) {
      return providerYoutube;
    } else if (lowerUrl.contains('vimeo.com')) {
      return providerVimeo;
    } else if (lowerUrl.contains('wistia.com')) {
      return providerWistia;
    }
    return providerCustom;
  }

  static String getEmbedUrl(String url) {
    final provider = detectProvider(url);
    if (provider == providerYoutube) {
      final videoId = _extractYouTubeId(url);
      if (videoId != null) {
        return 'https://www.youtube.com/embed/$videoId';
      }
    } else if (provider == providerVimeo) {
      final videoId = _extractVimeoId(url);
      if (videoId != null) {
        return 'https://player.vimeo.com/video/$videoId';
      }
    }
    // Wistia and Custom just return the original if it's already an embed
    // In a full implementation, we'd add wistia parsing here
    return url;
  }

  static String? getThumbnailUrl(String url) {
    final provider = detectProvider(url);
    if (provider == providerYoutube) {
      final videoId = _extractYouTubeId(url);
      if (videoId != null) {
        return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
      }
    }
    // Vimeo requires an API call to get the thumbnail, so we return null
    // and rely on custom thumbnail upload for non-youtube.
    return null;
  }

  static String? _extractYouTubeId(String url) {
    // Matches youtube.com/watch?v=ID, youtu.be/ID, youtube.com/embed/ID
    final RegExp regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
      caseSensitive: false,
      multiLine: false,
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  static String? _extractVimeoId(String url) {
    final RegExp regExp = RegExp(
      r'(?:vimeo\.com\/|player\.vimeo\.com\/video\/)([0-9]+)',
      caseSensitive: false,
      multiLine: false,
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }
}

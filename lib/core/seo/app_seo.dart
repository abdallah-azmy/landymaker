import 'package:flutter/foundation.dart';
import 'package:meta_seo/meta_seo.dart';

class AppSEO {
  static void config() {
    if (kIsWeb) {
      MetaSEO().config();
    }
  }

  static void updateMeta({
    required String title,
    required String description,
    String? image,
  }) {
    if (kIsWeb) {
      final meta = MetaSEO();
      meta.ogTitle(ogTitle: title);
      meta.description(description: description);
      meta.ogDescription(ogDescription: description);
      if (image != null) {
        meta.ogImage(ogImage: image);
      }
    }
  }
}

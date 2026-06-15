import 'dart:convert';
import 'dart:html' as html;
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
    String? keywords,
    Map<String, dynamic>? structuredData,
  }) {
    if (kIsWeb) {
      final meta = MetaSEO();
      meta.ogTitle(ogTitle: title);
      meta.description(description: description);
      meta.ogDescription(ogDescription: description);
      if (image != null) {
        meta.ogImage(ogImage: image);
      }
      if (keywords != null && keywords.isNotEmpty) {
        meta.keywords(keywords: keywords);
      }
      if (structuredData != null) {
        _injectJsonLd(structuredData);
      }
    }
  }

  static void _injectJsonLd(Map<String, dynamic> data) {
    final existing = html.document.querySelector('#json-ld-seo');
    existing?.remove();

    final script = html.ScriptElement();
    script.id = 'json-ld-seo';
    script.type = 'application/ld+json';
    script.text = jsonEncode(data);
    html.document.head!.append(script);
  }
}

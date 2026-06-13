/// Block property schema definition — single source of truth for AI validation.
/// Defines allowed properties, their types, defaults, and valid ranges per block type.

enum PropType { string, int, doubleNum, boolean, stringList, mapList, map, dynamic }

class PropDef {
  final PropType type;
  final dynamic defaultValue;
  final num? min;
  final num? max;
  final List<String>? allowedValues;
  final bool required;

  const PropDef({
    required this.type,
    this.defaultValue,
    this.min,
    this.max,
    this.allowedValues,
    this.required = false,
  });
}

/// Properties shared by every block type.
const Map<String, PropDef> _globalProps = {
  'type': PropDef(type: PropType.string, required: true),
  'title': PropDef(type: PropType.string, defaultValue: ''),
  'variant': PropDef(type: PropType.int, defaultValue: 0, min: 0, max: 9),
  'fontFamily': PropDef(type: PropType.string),
  'bg_image_url': PropDef(type: PropType.string),
  'bg_overlay_color': PropDef(type: PropType.string),
  'bg_overlay_opacity': PropDef(type: PropType.doubleNum, defaultValue: 0.4, min: 0, max: 1),
  'overlay_opacity': PropDef(type: PropType.doubleNum, min: 0, max: 1),
  'bg_blur': PropDef(type: PropType.doubleNum, min: 0),
  'is_visible': PropDef(type: PropType.boolean, defaultValue: true),
  'vertical_padding': PropDef(type: PropType.doubleNum, defaultValue: 80.0, min: 0, max: 300),
  'animation': PropDef(type: PropType.map),
  'card_layout_mode': PropDef(type: PropType.string, allowedValues: ['auto', 'equal']),
  '_index': PropDef(type: PropType.int),
};


/// Per-block-type property schemas.
const Map<String, Map<String, PropDef>> _blockSchemas = {
  'hero': {
    'subtitle': PropDef(type: PropType.string),
    'image_url': PropDef(type: PropType.string),
    'button_text': PropDef(type: PropType.string),
    'button_url': PropDef(type: PropType.string),
  },
  'hero_saas': {
    'subtitle': PropDef(type: PropType.string),
    'image_url': PropDef(type: PropType.string),
    'button_text': PropDef(type: PropType.string),
    'button_url': PropDef(type: PropType.string),
  },
  'logo_header': {
    'logo_url': PropDef(type: PropType.string),
    'logo_height': PropDef(type: PropType.doubleNum, defaultValue: 48.0),
    'alignment': PropDef(type: PropType.string, defaultValue: 'center', allowedValues: ['right', 'center', 'left']),
  },
  'features': {
    'layout_style': PropDef(type: PropType.string, defaultValue: 'grid', allowedValues: ['grid', 'bento']),
    'items': PropDef(type: PropType.mapList),
  },
  'lead_form': {
    'button_text': PropDef(type: PropType.string),
    'whatsapp_auto_open': PropDef(type: PropType.boolean, defaultValue: false),
    'whatsapp_number': PropDef(type: PropType.string),
    'whatsapp_message_template': PropDef(type: PropType.string),
    'fields': PropDef(type: PropType.mapList),
  },
  'lead_magnet': {
    'subtitle': PropDef(type: PropType.string),
    'button_text': PropDef(type: PropType.string),
    'image_url': PropDef(type: PropType.string),
    'whatsapp_auto_open': PropDef(type: PropType.boolean, defaultValue: false),
    'whatsapp_number': PropDef(type: PropType.string),
    'whatsapp_message_template': PropDef(type: PropType.string),
    'fields': PropDef(type: PropType.mapList),
  },
  'whatsapp': {
    'phone_number': PropDef(type: PropType.string, required: true),
    'message': PropDef(type: PropType.string),
    'button_text': PropDef(type: PropType.string),
  },
  'contact_info': {
    'email': PropDef(type: PropType.string),
    'phone': PropDef(type: PropType.string),
    'location': PropDef(type: PropType.string),
    'phone_icon': PropDef(type: PropType.string),
    'email_icon': PropDef(type: PropType.string),
    'location_icon': PropDef(type: PropType.string),
  },
  'location_map': {
    'address': PropDef(type: PropType.string),
    'map_iframe_url': PropDef(type: PropType.string),
  },
  'working_hours': {
    'schedule': PropDef(type: PropType.map),
  },
  'social_qr': {
    'subtitle': PropDef(type: PropType.string),
    'links': PropDef(type: PropType.mapList),
  },
  'qr_code': {
    'subtitle': PropDef(type: PropType.string),
    'qr_payload': PropDef(type: PropType.string),
    'qr_size': PropDef(type: PropType.doubleNum, defaultValue: 200.0, min: 100, max: 350),
  },
  'pricing': {
    'schema_version': PropDef(type: PropType.int, defaultValue: 2),
    'subtitle': PropDef(type: PropType.string),
    'has_toggle': PropDef(type: PropType.boolean, defaultValue: true),
    'toggle_labels': PropDef(type: PropType.map),
    'items': PropDef(type: PropType.mapList),
  },
  'products': {
    'layout_style': PropDef(type: PropType.string, defaultValue: 'grid_2', allowedValues: ['grid_2', 'grid_3', 'list']),
    'whatsapp_number': PropDef(type: PropType.string),
    'show_category_filter': PropDef(type: PropType.boolean, defaultValue: true),
    'categories': PropDef(type: PropType.stringList),
    'items': PropDef(type: PropType.mapList),
  },
  'faq': {
    'items': PropDef(type: PropType.mapList),
  },
  'testimonials': {
    'items': PropDef(type: PropType.mapList),
  },
  'gallery': {
    'display_mode': PropDef(type: PropType.string, defaultValue: 'grid', allowedValues: ['grid', 'carousel', 'masonry']),
    'grid_columns': PropDef(type: PropType.int, defaultValue: 3, min: 1, max: 6),
    'items': PropDef(type: PropType.stringList),
    'gallery_links': PropDef(type: PropType.stringList),
  },
  'trust_logos': {
    'items': PropDef(type: PropType.stringList),
  },
  'animated_counter': {
    'items': PropDef(type: PropType.mapList),
  },
  'basic_section': {
    'layout_direction': PropDef(type: PropType.string, defaultValue: 'column', allowedValues: ['column', 'row']),
    'spacing': PropDef(type: PropType.doubleNum, defaultValue: 20.0, min: 0, max: 100),
    'main_axis_alignment': PropDef(type: PropType.string, defaultValue: 'center', allowedValues: ['start', 'center', 'end', 'spaceBetween']),
    'cross_axis_alignment': PropDef(type: PropType.string, defaultValue: 'center', allowedValues: ['start', 'center', 'end', 'stretch']),
    'elements': PropDef(type: PropType.mapList),
  },
  'video_embed': {
    'subtitle': PropDef(type: PropType.string),
    'video_url': PropDef(type: PropType.string),
    'aspect_ratio': PropDef(type: PropType.string, defaultValue: '16:9', allowedValues: ['16:9', '4:3', '1:1', '9:16']),
    'max_width': PropDef(type: PropType.int, defaultValue: 900),
    'use_thumbnail': PropDef(type: PropType.boolean, defaultValue: true),
    'thumbnail_url': PropDef(type: PropType.string),
    'autoplay': PropDef(type: PropType.boolean, defaultValue: false),
    'show_controls': PropDef(type: PropType.boolean, defaultValue: true),
  },
  'multi_step_lead_form': {
    'schema_version': PropDef(type: PropType.int, defaultValue: 1),
    'subtitle': PropDef(type: PropType.string),
    'success_message': PropDef(type: PropType.string),
    'enable_local_save': PropDef(type: PropType.boolean, defaultValue: true),
    'whatsapp_auto_open': PropDef(type: PropType.boolean, defaultValue: false),
    'whatsapp_number': PropDef(type: PropType.string),
    'whatsapp_message_template': PropDef(type: PropType.string),
    'steps': PropDef(type: PropType.mapList),
  },
  'statistics_grid': {
    'subtitle': PropDef(type: PropType.string),
    'items': PropDef(type: PropType.mapList),
  },
  'team_members': {
    'subtitle': PropDef(type: PropType.string),
    'items': PropDef(type: PropType.mapList),
  },
  'service_steps': {
    'subtitle': PropDef(type: PropType.string),
    'items': PropDef(type: PropType.mapList),
  },
  'cta_banner': {
    'subtitle': PropDef(type: PropType.string),
    'button_text': PropDef(type: PropType.string),
    'button_url': PropDef(type: PropType.string),
    'secondary_button_text': PropDef(type: PropType.string),
    'secondary_button_url': PropDef(type: PropType.string),
  },
  'comparison_table': {
    'subtitle': PropDef(type: PropType.string),
    'plans': PropDef(type: PropType.mapList),
    'features': PropDef(type: PropType.mapList),
  },
};

class BlockPropertyMapper {
  /// Validate and coerce a block's properties against its type schema.
  /// Strips unknown keys, coerces types, clamps ranges, applies defaults.
  /// Returns the cleaned block map (mutates in place for performance).
  static Map<String, dynamic> sanitize(Map<String, dynamic> block, {bool isEdit = false}) {
    final type = block['type'] as String? ?? '';
    final schema = _blockSchemas[type] ?? {};
    final allDefs = <String, PropDef>{};
    allDefs.addAll(_globalProps);
    allDefs.addAll(schema);

    final keysToRemove = <String>[];
    for (final key in block.keys) {
      if (!allDefs.containsKey(key)) {
        keysToRemove.add(key);
        print('BlockPropertyMapper: removing unknown key "$key" from block type "$type"');
      }
    }
    for (final key in keysToRemove) {
      block.remove(key);
    }

    for (final entry in allDefs.entries) {
      final key = entry.key;
      final def = entry.value;
      final raw = block[key];

      if (raw == null) {
        if (!isEdit && def.defaultValue != null) {
          block[key] = def.defaultValue;
        }
        continue;
      }

      final coerced = _coerce(raw, def);
      if (coerced == null && !isEdit && def.defaultValue != null) {
        block[key] = def.defaultValue;
      } else if (coerced != null) {
        block[key] = coerced;
      }
    }

    return block;
  }

  static dynamic _coerce(dynamic raw, PropDef def) {
    try {
      switch (def.type) {
        case PropType.string:
          return raw.toString();
        case PropType.int:
          if (raw is int) return def._clamp(raw);
          if (raw is double) return def._clamp(raw.round());
          final parsed = int.tryParse(raw.toString());
          return parsed != null ? def._clamp(parsed) : null;
        case PropType.doubleNum:
          if (raw is double) return def._clamp(raw);
          if (raw is int) return def._clamp(raw.toDouble());
          final parsed = double.tryParse(raw.toString());
          return parsed != null ? def._clamp(parsed) : null;
        case PropType.boolean:
          if (raw is bool) return raw;
          if (raw is int) return raw != 0;
          if (raw is String) {
            if (raw == 'true' || raw == '1') return true;
            if (raw == 'false' || raw == '0') return false;
          }
          return null;
        case PropType.stringList:
          if (raw is List) {
            return raw.map((e) => e.toString()).toList();
          }
          return null;
        case PropType.mapList:
          if (raw is List) {
            return raw.map((e) => e is Map<String, dynamic> ? e : <String, dynamic>{}).toList();
          }
          return null;
        case PropType.map:
          if (raw is Map) return Map<String, dynamic>.from(raw as Map);
          return null;
        case PropType.dynamic:
          return raw;
      }
    } catch (_) {
      return null;
    }
  }
}

extension _ClampExt on PropDef {
  num _clamp(num value) {
    if (min != null && max != null) return value.clamp(min!, max!);
    if (min != null) return value < min! ? min! : value;
    if (max != null) return value > max! ? max! : value;
    return value;
  }
}

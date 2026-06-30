part of '../section_library_modal.dart';

class _SectionDefinition {
  final String type;
  final String name;
  final IconData icon;
  final String category;
  final String desc;
  final bool popular;
  final String aiRole;
  final String aiWhenToUse;
  final List<_SectionVariant> variants;

  const _SectionDefinition({
    required this.type,
    required this.name,
    required this.icon,
    required this.category,
    required this.desc,
    required this.popular,
    required this.aiRole,
    required this.aiWhenToUse,
    required this.variants,
  });
}

class _SectionVariant {
  final String name;
  final String description;
  final String preview;
  final Map<String, dynamic> overrides;

  const _SectionVariant({
    required this.name,
    required this.description,
    required this.preview,
    required this.overrides,
  });
}

_SectionDefinition _section({
  required String type,
  required String name,
  required IconData icon,
  required String category,
  required String desc,
  required String aiRole,
  required String aiWhenToUse,
  required List<_SectionVariant> variants,
  bool popular = false,
}) {
  return _SectionDefinition(
    type: type,
    name: name,
    icon: icon,
    category: category,
    desc: desc,
    popular: popular,
    aiRole: aiRole,
    aiWhenToUse: aiWhenToUse,
    variants: variants,
  );
}

_SectionVariant _variant(
  String name,
  String description,
  String preview,
  Map<String, dynamic> overrides,
) {
  return _SectionVariant(
    name: name,
    description: description,
    preview: preview,
    overrides: overrides,
  );
}

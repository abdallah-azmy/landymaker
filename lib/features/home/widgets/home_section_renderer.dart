import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../injection_container.dart';
import '../../../services/database_service.dart';
import '../../builder/registries/block_registry.dart';
import '../../builder/models/landing_page_theme.dart';
import '../../public_viewer/widgets/section_renderer.dart';

class HomeSectionRenderer extends StatefulWidget {
  final String landingPageId;
  final String? displayTitle;

  const HomeSectionRenderer({
    super.key,
    required this.landingPageId,
    this.displayTitle,
  });

  @override
  State<HomeSectionRenderer> createState() => _HomeSectionRendererState();
}

class _HomeSectionRendererState extends State<HomeSectionRenderer> {
  List<Map<String, dynamic>>? _blocks;
  LandingPageTheme? _theme;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  Future<void> _loadPage() async {
    try {
      final page = await sl<DatabaseService>().getLandingPageById(widget.landingPageId);
      if (page != null && mounted) {
        final rawDesign = page['design_json'];
        Map<String, dynamic> designJson = {};
        if (rawDesign is String) {
          try {
            designJson = Map<String, dynamic>.from(jsonDecode(rawDesign));
          } catch (_) {}
        } else if (rawDesign is Map) {
          designJson = Map<String, dynamic>.from(rawDesign);
        }

        final blocksRaw = designJson['blocks'] as List<dynamic>? ?? [];
        final themeRaw = designJson['theme'] as Map<String, dynamic>? ?? {};

        setState(() {
          _blocks = blocksRaw.cast<Map<String, dynamic>>();
          _theme = LandingPageTheme.fromJson(themeRaw);
          _loading = false;
        });
        return;
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox.shrink();
    }
    if (_blocks == null || _blocks!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (widget.displayTitle != null && widget.displayTitle!.isNotEmpty)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 32, 24, 8),
            child: Text(
              widget.displayTitle!,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
          ),
        SectionRenderer(
          blocks: _blocks!,
          pageId: widget.landingPageId,
          theme: _theme,
        ),
      ],
    );
  }
}

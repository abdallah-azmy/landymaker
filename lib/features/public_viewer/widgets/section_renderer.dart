import 'package:flutter/material.dart';
import 'custom_hero_widget.dart';
import 'custom_features_widget.dart';
import 'custom_lead_form_widget.dart';

class SectionRenderer extends StatelessWidget {
  final List<Map<String, dynamic>> blocks;
  final String pageId;

  const SectionRenderer({
    super.key,
    required this.blocks,
    required this.pageId,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: blocks.length,
      itemBuilder: (context, index) {
        final block = blocks[index];
        final String type = (block['type'] ?? '').toString().toLowerCase();

        switch (type) {
          case 'hero':
            return CustomHeroWidget(
              title: block['title'] ?? 'Stunning Landing Page Title',
              subtitle: block['subtitle'] ?? 'This is your value proposition subtitle.',
              buttonText: block['button_text'] ?? 'Get Started',
              imageUrl: block['image_url'] ?? 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800',
            );

          case 'features':
            final List rawItems = block['items'] ?? [];
            final List<Map<String, dynamic>> items = rawItems
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();

            return CustomFeaturesWidget(
              title: block['title'] ?? 'Why Choose Us',
              items: items,
            );

          case 'lead_form':
            return CustomLeadFormWidget(
              title: block['title'] ?? 'Get In Touch',
              buttonText: block['button_text'] ?? 'Submit',
              pageId: pageId,
            );

          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}

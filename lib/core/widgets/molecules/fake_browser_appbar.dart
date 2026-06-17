import 'package:flutter/material.dart';

class FakeBrowserAppbar extends StatelessWidget {
  final String pageSlug;
  
  const FakeBrowserAppbar({
    super.key,
    required this.pageSlug,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Row(
            children: List.generate(
              3,
              (i) => Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == 0
                      ? const Color(0xFFFF5F56) // Mac Red
                      : (i == 1
                          ? const Color(0xFFFFBD2E) // Mac Yellow
                          : const Color(0xFF27C93F)), // Mac Green
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.black12,
                ),
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_rounded, size: 12, color: Colors.green),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'landymaker.com/${pageSlug.isEmpty ? 'your-brand' : pageSlug}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black87,
                        fontFamily: 'Inter',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 50), // Balance the spacing for center alignment
        ],
      ),
    );
  }
}

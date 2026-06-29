import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

class TypewriterText extends StatefulWidget {
  final List<String> texts;
  final bool isMobile;
  final Color? colorOverride;

  const TypewriterText({
    super.key,
    required this.texts,
    required this.isMobile,
    this.colorOverride,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  String _currentText = "";
  Timer? _timer;
  bool _isDeleting = false;
  int _charIndex = 0;
  late AnimationController _cursorController;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _startTypewriter();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cursorController.dispose();
    super.dispose();
  }

  void _startTypewriter() {
    final int delayMs = _isDeleting ? 25 : 60;
    _timer = Timer(Duration(milliseconds: delayMs), () {
      if (!mounted) return;

      final fullText = widget.texts[_currentIndex];

      setState(() {
        if (!_isDeleting) {
          _currentText = fullText.substring(0, _charIndex);
          _charIndex++;
          if (_charIndex > fullText.length) {
            _isDeleting = true;
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) _startTypewriter();
            });
            return;
          }
        } else {
          _charIndex -= 2;
          if (_charIndex < 0) _charIndex = 0;
          _currentText = fullText.substring(0, _charIndex);
          if (_charIndex == 0) {
            _isDeleting = false;
            _currentIndex = (_currentIndex + 1) % widget.texts.length;
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) _startTypewriter();
            });
            return;
          }
        }
        _startTypewriter();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        widget.colorOverride ?? Theme.of(context).colorScheme.primary;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: _currentText),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 6),
              child: FadeTransition(
                opacity: _cursorController,
                child: Container(
                  width: 3,
                  height: widget.isMobile ? 24 : 32,
                  decoration: BoxDecoration(
                    color: textColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      style: AppTypography.h2.copyWith(
        color: textColor,
        fontSize: widget.isMobile ? 22 : 30,
        fontWeight: FontWeight.bold,
      ),
      textAlign: widget.isMobile ? TextAlign.center : TextAlign.start,
    );
  }
}

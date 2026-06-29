part of '../section_library_modal.dart';

class _DualMiniPreview extends StatelessWidget {
  final _SectionVariant variant;
  final Color accent;

  const _DualMiniPreview({required this.variant, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 35,
          child: _buildPreview(context, isMobile: true),
        ),
        SizedBox(width: 8),
        Expanded(
          flex: 65,
          child: _buildPreview(context, isMobile: false),
        ),
      ],
    );
  }

  Widget _buildPreview(BuildContext context, {required bool isMobile}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.66),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMobile
              ? accent.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: _buildPattern(),
    );
  }

  Widget _buildPattern() {
    switch (variant.preview) {
      case 'centered':
        return _centeredHero();
      case 'immersive':
      case 'dark':
      case 'cta_dark':
      case 'form_dark':
        return _darkPanel();
      case 'split':
        return _split();
      case 'stack':
        return _stack();
      case 'logos':
        return _logos();
      case 'metrics':
        return _metrics(3);
      case 'metrics4':
        return _metrics(4);
      case 'form':
      case 'form_steps':
        return _form();
      case 'offer':
        return _offer();
      case 'grid':
      case 'gallery_grid':
        return _grid(2);
      case 'grid3':
        return _grid(3);
      case 'bento':
        return _bento();
      case 'list':
        return _list();
      case 'pricing':
      case 'pricing_cards':
        return _pricing();
      case 'accordion':
      case 'accordion_dense':
        return _accordion();
      case 'quotes':
      case 'quotes_dense':
        return _quotes();
      case 'contact_cards':
        return _contact();
      case 'schedule':
      case 'schedule_split':
        return _schedule();
      case 'map':
      case 'map_pin':
        return _map();
      case 'video':
      case 'video_compact':
        return _video();
      case 'gallery_carousel':
        return _carousel();
      case 'qr':
      case 'qr_big':
        return _qr();
      case 'social':
      case 'social_creator':
        return _social();
      default:
        return _split();
    }
  }

  Widget _bar(double width, {double height = 8, Color? color}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }

  Widget _box({double? width, double? height, Color? color, double radius = 8}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? accent.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _split() {
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bar(74, height: 10, color: accent.withValues(alpha: 0.7)),
              SizedBox(height: 8),
              _bar(92),
              SizedBox(height: 6),
              _bar(58),
              SizedBox(height: 12),
              _box(width: 64, height: 18, color: accent),
            ],
          ),
        ),
        SizedBox(width: 10),
        Expanded(child: _box(height: double.infinity, radius: 12)),
      ],
    );
  }

  Widget _centeredHero() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _bar(96, height: 12, color: accent.withValues(alpha: 0.7)),
        SizedBox(height: 8),
        _bar(124),
        SizedBox(height: 6),
        _bar(82),
        SizedBox(height: 12),
        _box(width: 80, height: 20, color: accent),
      ],
    );
  }

  Widget _darkPanel() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        borderRadius: BorderRadius.circular(12),
      ),
      child: _centeredHero(),
    );
  }

  Widget _stack() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _box(width: double.infinity, height: 24),
        SizedBox(height: 8),
        _box(width: double.infinity, height: 24, color: accent.withValues(alpha: 0.34)),
        SizedBox(height: 8),
        _box(width: double.infinity, height: 24),
      ],
    );
  }

  Widget _logos() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (_) => _box(width: 26, height: 26, radius: 99)),
    );
  }

  Widget _metrics(int count) {
    return Row(
      children: List.generate(
        count,
        (index) => Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(end: index == count - 1 ? 0 : 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _bar(34, height: 14, color: accent),
                SizedBox(height: 8),
                _bar(42, height: 7),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _form() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _bar(90, height: 10, color: accent.withValues(alpha: 0.7)),
        SizedBox(height: 10),
        _box(width: double.infinity, height: 22, color: Colors.white.withValues(alpha: 0.12)),
        SizedBox(height: 7),
        _box(width: double.infinity, height: 22, color: Colors.white.withValues(alpha: 0.12)),
        SizedBox(height: 10),
        _box(width: double.infinity, height: 24, color: accent),
      ],
    );
  }

  Widget _offer() {
    return Row(
      children: [
        _box(width: 58, height: double.infinity, color: accent.withValues(alpha: 0.35)),
        SizedBox(width: 10),
        Expanded(child: _form()),
      ],
    );
  }

  Widget _grid(int columns) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: columns,
      crossAxisSpacing: 7,
      mainAxisSpacing: 7,
      children: List.generate(columns * 2, (index) => _box()),
    );
  }

  Widget _bento() {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Expanded(flex: 3, child: _box(color: accent.withValues(alpha: 0.32))),
              SizedBox(width: 7),
              Expanded(flex: 2, child: _box()),
            ],
          ),
        ),
        SizedBox(height: 7),
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Expanded(flex: 2, child: _box()),
              SizedBox(width: 7),
              Expanded(flex: 3, child: _box(color: accent.withValues(alpha: 0.32))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _list() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: Row(
            children: [
              _box(width: 36, height: 28),
              SizedBox(width: 8),
              Expanded(child: _bar(double.infinity)),
              SizedBox(width: 8),
              _box(width: 34, height: 18, color: accent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pricing() {
    return Row(
      children: List.generate(
        3,
        (index) => Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(end: index == 2 ? 0 : 7),
            child: _box(
              height: double.infinity,
              color: index == 1 ? accent.withValues(alpha: 0.45) : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _accordion() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: _box(width: double.infinity, height: 22),
        ),
      ),
    );
  }

  Widget _quotes() {
    return Row(
      children: List.generate(
        2,
        (index) => Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(end: index == 1 ? 0 : 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _box(width: double.infinity, height: 52),
                SizedBox(height: 8),
                _bar(48, height: 8, color: accent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _contact() {
    return Row(
      children: List.generate(
        3,
        (index) => Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(end: index == 2 ? 0 : 7),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _box(width: 32, height: 32, radius: 99, color: accent.withValues(alpha: 0.4)),
                SizedBox(height: 8),
                _bar(38, height: 7),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _schedule() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Row(
            children: [
              Expanded(child: _bar(double.infinity)),
              SizedBox(width: 18),
              _bar(50, color: index == 0 ? accent : null),
            ],
          ),
        ),
      ),
    );
  }

  Widget _map() {
    return Stack(
      children: [
        Positioned.fill(child: _box(color: Colors.white.withValues(alpha: 0.08))),
        Center(
          child: Icon(Icons.location_on_rounded, color: accent, size: 36),
        ),
      ],
    );
  }

  Widget _video() {
    return Stack(
      children: [
        Positioned.fill(child: _box(color: Colors.white.withValues(alpha: 0.1))),
        Center(
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            child: Icon(Icons.play_arrow_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _carousel() {
    return Row(
      children: [
        _box(width: 24, height: 54, color: Colors.white.withValues(alpha: 0.08)),
        SizedBox(width: 8),
        Expanded(child: _box(height: double.infinity, color: accent.withValues(alpha: 0.32))),
        SizedBox(width: 8),
        _box(width: 24, height: 54, color: Colors.white.withValues(alpha: 0.08)),
      ],
    );
  }

  Widget _qr() {
    return Center(
      child: Container(
        width: variant.preview == 'qr_big' ? 76 : 58,
        height: variant.preview == 'qr_big' ? 76 : 58,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: GridView.count(
          padding: const EdgeInsets.all(8),
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          children: List.generate(
            16,
            (index) => Container(
              margin: const EdgeInsets.all(1.4),
              color: index.isEven ? Colors.black87 : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _social() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Wrap(
          spacing: 8,
          children: List.generate(
            4,
            (_) => _box(width: 28, height: 28, radius: 99, color: accent.withValues(alpha: 0.35)),
          ),
        ),
        SizedBox(height: 12),
        _qr(),
      ],
    );
  }
}

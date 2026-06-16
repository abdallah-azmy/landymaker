import 'package:flutter/material.dart';

/// Reduces boilerplate for fade+slide entrance animations.
///
/// Mix this into a State that already has [TickerProviderStateMixin]:
/// ```dart
/// class MyState extends State<MyWidget>
///     with TickerProviderStateMixin, EntranceAnimationMixin {
/// ```
///
/// Override [entranceDuration] and [entranceSlideBegin] to customise.
/// Call [startEntrance()] to trigger the animation.
/// Use [entranceFade] and [entranceSlide] in [FadeTransition] /
/// [SlideTransition], or call [buildEntranceAnimation(child)].
mixin EntranceAnimationMixin<T extends StatefulWidget>
    on TickerProviderStateMixin<T> {
  late final AnimationController entranceCtrl;
  late final Animation<double> entranceFade;
  late final Animation<Offset> entranceSlide;

  Duration get entranceDuration => const Duration(milliseconds: 1200);
  Offset get entranceSlideBegin => const Offset(0, 0.3);

  @override
  void initState() {
    super.initState();
    entranceCtrl =
        AnimationController(vsync: this, duration: entranceDuration);
    entranceFade = CurvedAnimation(
      parent: entranceCtrl,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );
    entranceSlide =
        Tween<Offset>(begin: entranceSlideBegin, end: Offset.zero).animate(
      CurvedAnimation(parent: entranceCtrl, curve: Curves.fastOutSlowIn),
    );
  }

  void startEntrance() => entranceCtrl.forward();

  Widget buildEntranceAnimation(Widget child) {
    return FadeTransition(
      opacity: entranceFade,
      child: SlideTransition(
        position: entranceSlide,
        child: child,
      ),
    );
  }

  @override
  void dispose() {
    entranceCtrl.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension RouterExtension on BuildContext {
  /// Safely pops the current screen if possible, otherwise navigates to [fallbackPath]
  /// to prevent infinite loading screens or navigation loops.
  /// 
  /// Uses GoRouter's canPop() and pop() for O(1) performance.
  void safePop({String fallbackPath = '/'}) {
    if (this.canPop()) {
      this.pop();
    } else {
      this.go(fallbackPath);
    }
  }
}

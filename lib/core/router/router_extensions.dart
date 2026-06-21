import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../injection_container.dart';
import '../../services/supabase_service.dart';

extension RouterExtension on BuildContext {
  /// Safely pops the current screen if possible, otherwise navigates to [fallbackPath]
  /// to prevent infinite loading screens or navigation loops.
  /// 
  /// Uses GoRouter's canPop() and pop() for O(1) performance.
  void safePop({String fallbackPath = '/'}) {
    if (this.canPop()) {
      try {
        final router = GoRouter.of(this);
        final matches = router.routerDelegate.currentConfiguration.matches;
        if (matches.length > 1) {
          final previousLocation = matches[matches.length - 2].matchedLocation;
          final isPreviousProtected = previousLocation.startsWith('/dashboard') || 
                                     previousLocation.startsWith('/builder');
          final isAuthenticated = sl<SupabaseService>().isAuthenticated;
          
          if (isPreviousProtected && !isAuthenticated) {
            this.go(fallbackPath);
            return;
          }
        }
      } catch (_) {
        // Fallback to normal popping if checking fails
      }
      this.pop();
    } else {
      this.go(fallbackPath);
    }
  }
}

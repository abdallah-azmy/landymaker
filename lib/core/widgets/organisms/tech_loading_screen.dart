import 'package:flutter/material.dart';
import '../particles/cube_loader.dart';

class TechLoadingScreen extends StatelessWidget {
  const TechLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CubeLoader(
              variant: CubeLoaderVariant.logo,
              size: 80,
              state: CubeLoaderState.loading,
              glow: true,
            ),
            const SizedBox(height: 32),
            const CubeLoader(
              variant: CubeLoaderVariant.single,
              size: 24,
              state: CubeLoaderState.loading,
            ),
          ],
        ),
      ),
    );
  }
}

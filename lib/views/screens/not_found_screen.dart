import 'package:flutter/material.dart';
import 'package:shopease_mobile/core/theme/app_theme.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not Found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.travel_explore_rounded,
                size: 72,
                color: AppPalette.mutedForeground,
              ),
              const SizedBox(height: 12),
              const Text(
                'This screen does not exist.',
                style: TextStyle(
                  color: AppPalette.foreground,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Let\'s get you back to shopping.',
                style: TextStyle(color: AppPalette.mutedForeground),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed:
                    () => Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/', (route) => false),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

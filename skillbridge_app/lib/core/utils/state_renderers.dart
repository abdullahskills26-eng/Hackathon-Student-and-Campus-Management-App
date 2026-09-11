import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Shared Loading / Empty / Error renderers.
///
/// Every major screen is expected to handle all four UI states; these cover
/// the three non-success ones so screens only build their happy path.

/// Centred progress spinner for the loading state.
class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

/// Placeholder shown when a request succeeds but returns nothing.
///
/// Wrapped in a [ListView] so it still works as the child of a
/// [RefreshIndicator] (pull-to-refresh needs a scrollable).
class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(icon, size: 34, color: Colors.grey.shade500),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Error state with a retry button.
class ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorRetry({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                color: AppColors.crimsonRed, size: 42),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryIndigo,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

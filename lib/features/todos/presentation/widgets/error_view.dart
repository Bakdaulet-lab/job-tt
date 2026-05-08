import 'package:flutter/material.dart';

Color _fade(Color color, double opacity) => color.withAlpha((opacity * 255).round());

bool _isNetworkMessage(String message) {
  final normalized = message.toLowerCase();
  return normalized.contains('интернет') ||
      normalized.contains('сеть') ||
      normalized.contains('network') ||
      normalized.contains('connection') ||
      normalized.contains('offline');
}

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isOffline = _isNetworkMessage(message);
    final accentColor = isOffline ? const Color(0xFF2563EB) : const Color(0xFFEF4444);
    final iconData = isOffline ? Icons.wifi_off_rounded : Icons.cloud_off_rounded;
    final title = isOffline
        ? 'Нет подключения к интернету'
        : 'Не удалось загрузить задачи';
    final body = isOffline
        ? 'Проверьте Wi-Fi или мобильную сеть и нажмите «Повторить».'
        : message;
    final tip = isOffline
        ? 'После восстановления сети список можно обновить одним нажатием.'
        : 'Попробуйте еще раз через несколько секунд.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  _fade(accentColor, 0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: _fade(accentColor, 0.16)),
              boxShadow: [
                BoxShadow(
                  color: _fade(Colors.black, 0.08),
                  blurRadius: 28,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _fade(accentColor, 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    color: accentColor,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.blueGrey.shade600,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _fade(accentColor, 0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: accentColor,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          tip,
                          style: TextStyle(
                            fontSize: 12,
                            color: accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Повторить'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

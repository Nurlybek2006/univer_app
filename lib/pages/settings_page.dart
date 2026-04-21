import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/theme.dart';
import '../core/hive_service.dart';
import '../providers/app_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final notificationsOn = ref.watch(notificationsProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Параметрлер'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Сыртқы келбет ──────────────────────────────────
          _SectionHeader(title: 'Сыртқы келбет', isDark: isDarkMode),
          _SettingsCard(
            isDark: isDarkMode,
            children: [
              _ToggleTile(
                icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                iconColor: isDark ? const Color(0xFF7C83FF) : AppTheme.gold,
                title: 'Қараңғы режим',
                subtitle: isDark ? 'Іске қосулы' : 'Өшірулі',
                value: isDark,
                onChanged: (_) => ref.read(themeProvider.notifier).toggle(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ─── Хабарландырулар ─────────────────────────────────
          _SectionHeader(title: 'Хабарландырулар', isDark: isDarkMode),
          _SettingsCard(
            isDark: isDarkMode,
            children: [
              _ToggleTile(
                icon: notificationsOn
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_off_rounded,
                iconColor: notificationsOn ? AppTheme.accent : Colors.grey,
                title: 'Push-хабарламалар',
                subtitle: notificationsOn ? 'Іске қосулы' : 'Өшірулі',
                value: notificationsOn,
                onChanged: (_) =>
                    ref.read(notificationsProvider.notifier).toggle(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ─── Деректер ────────────────────────────────────────
          _SectionHeader(title: 'Деректер', isDark: isDarkMode),
          _SettingsCard(
            isDark: isDarkMode,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red.withValues(alpha: 0.12),
                  child: const Icon(Icons.delete_sweep_rounded,
                      color: Colors.redAccent, size: 20),
                ),
                title: const Text('Кэшті тазалау',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text('Офлайн деректерді жою',
                    style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode
                            ? Colors.white54
                            : Colors.black45)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _confirmClearCache(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ─── Қосымша туралы ──────────────────────────────────
          _SectionHeader(title: 'Қосымша туралы', isDark: isDarkMode),
          _SettingsCard(
            isDark: isDarkMode,
            children: [
              _InfoTile(
                icon: Icons.school_rounded,
                iconColor: AppTheme.primary,
                title: 'Студент Көмекшісі',
                subtitle: 'Абай атындағы ҚазҰПУ студенттеріне арналған',
                isDark: isDarkMode,
              ),
              Divider(
                height: 1,
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.06),
              ),
              _InfoTile(
                icon: Icons.info_outline_rounded,
                iconColor: AppTheme.accent,
                title: 'Нұсқасы',
                subtitle: '1.0.0',
                isDark: isDarkMode,
              ),
              Divider(
                height: 1,
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.06),
              ),
              _InfoTile(
                icon: Icons.code_rounded,
                iconColor: AppTheme.gold,
                title: 'Технологиялар',
                subtitle: 'Flutter • Firebase • Hive • Riverpod',
                isDark: isDarkMode,
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _confirmClearCache(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Кэшті тазалау'),
          ],
        ),
        content: const Text(
          'Офлайн сақталған деректер (кесте, жаңалықтар, тесттер) жойылады. Маңызды деректер (аккаунт, параметрлер) сақталады.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Болдырмау'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              minimumSize: Size.zero,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Тазалау'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await HiveService.schedule.clear();
      await HiveService.news.clear();
      await HiveService.quiz.clear();
      await HiveService.freeTime.clear();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Кэш тазаланды ✓'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}

// ─── Helper widgets ──────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: isDark
                ? Colors.white.withValues(alpha: 0.5)
                : AppTheme.primary.withValues(alpha: 0.6),
          ),
        ),
      );
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;
  const _SettingsCard({required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: Column(children: children),
      );
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SwitchListTile(
      secondary: CircleAvatar(
        backgroundColor: iconColor.withValues(alpha: 0.12),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.black45)),
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppTheme.accent,
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isDark;
  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.12),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle,
            style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.black45)),
      );
}

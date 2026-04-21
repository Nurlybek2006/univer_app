import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/theme.dart';
import '../models/hive/quiz_hive_model.dart';
import '../providers/app_providers.dart';

// Санат карточкалары үшін градиенттер
const List<List<Color>> _kGradients = [
  [Color(0xFF1A237E), Color(0xFF3949AB)],
  [Color(0xFF00695C), Color(0xFF00897B)],
  [Color(0xFF4A148C), Color(0xFF7B1FA2)],
  [Color(0xFF1565C0), Color(0xFF1E88E5)],
  [Color(0xFF880E4F), Color(0xFFD81B60)],
  [Color(0xFF1B5E20), Color(0xFF388E3C)],
  [Color(0xFFE65100), Color(0xFFF57C00)],
];

const List<IconData> _kIcons = [
  Icons.history_edu_rounded,
  Icons.science_rounded,
  Icons.calculate_rounded,
  Icons.language_rounded,
  Icons.psychology_rounded,
  Icons.biotech_rounded,
  Icons.public_rounded,
];

// ──────────────────────────────────────────────────────────────────
// Тест беті — санаттар тізімі
// ──────────────────────────────────────────────────────────────────
class QuizPage extends ConsumerWidget {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizAsync = ref.watch(quizProvider);
    final coins = ref.watch(coinsProvider);
    final completedIds = ref.watch(completedQuizzesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBg : const Color(0xFFF0F2FF),
      body: quizAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Қате: $e')),
        data: (cats) => CustomScrollView(
          slivers: [
            // ── SliverAppBar ──
            SliverAppBar(
              expandedHeight: 155,
              pinned: true,
              backgroundColor: AppTheme.primary,
              // Collapsed күйдегі title
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Тест',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  _CoinBadge(coins: coins, large: false),
                ],
              ),
              // Expanded күйдегі мазмұн (title жоқ — flexibleSpace.title алып тасталды)
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                titlePadding: EdgeInsets.zero,
                background: Container(
                  decoration:
                      const BoxDecoration(gradient: AppTheme.primaryGradient),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text('Тест',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('Тапсыр — балл жина!',
                                    style: TextStyle(
                                        color:
                                            Colors.white.withValues(alpha: 0.8),
                                        fontSize: 13)),
                              ],
                            ),
                          ),
                          _CoinBadge(coins: coins, large: true),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── List ──
            cats.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.quiz_outlined,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text('Тест жоқ',
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 16)),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _CategoryCard(
                          category: cats[i],
                          gradient: _kGradients[i % _kGradients.length],
                          icon: _kIcons[i % _kIcons.length],
                          isCompleted: completedIds.contains(cats[i].id),
                        ),
                        childCount: cats.length,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

// ── Coin Badge ──
class _CoinBadge extends StatelessWidget {
  final int coins;
  final bool large;
  const _CoinBadge({required this.coins, required this.large});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: large ? 14 : 10, vertical: large ? 9 : 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(50),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🪙', style: TextStyle(fontSize: large ? 20 : 14)),
          const SizedBox(width: 5),
          Text(
            '$coins',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: large ? 18 : 14),
          ),
        ],
      ),
    );
  }
}

// ── Category Card ──
class _CategoryCard extends ConsumerWidget {
  final QuizCategoryHiveModel category;
  final List<Color> gradient;
  final IconData icon;
  final bool isCompleted;
  const _CategoryCard(
      {required this.category,
      required this.gradient,
      required this.icon,
      required this.isCompleted});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _QuizPlayPage(
                  category: category, canEarnCoins: !isCompleted),
            ),
          ),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child:
                            Icon(icon, color: Colors.white, size: 26),
                      ),
                      const Spacer(),
                      if (isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  color: Colors.white, size: 13),
                              SizedBox(width: 4),
                              Text('Балл алынды',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(category.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold)),
                  if (category.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(category.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13)),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _SmallChip(
                          icon: Icons.help_outline_rounded,
                          label: '${category.questions.length} сұрақ'),
                      const SizedBox(width: 8),
                      _SmallChip(
                          icon: Icons.monetization_on_outlined,
                          label: isCompleted
                              ? 'Алынды'
                              : '+${category.questions.length} 🪙'),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SmallChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
// Тест ойнау беті
// ──────────────────────────────────────────────────────────────────
class _QuizPlayPage extends ConsumerStatefulWidget {
  final QuizCategoryHiveModel category;
  final bool canEarnCoins;
  const _QuizPlayPage(
      {required this.category, required this.canEarnCoins});

  @override
  ConsumerState<_QuizPlayPage> createState() => _QuizPlayPageState();
}

class _QuizPlayPageState extends ConsumerState<_QuizPlayPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int _score = 0;
  int? _selected;
  bool _answered = false;
  bool _coinsGiven = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  QuizQuestionHiveModel get _q =>
      widget.category.questions[_currentIndex];
  int get _total => widget.category.questions.length;
  bool get _isLast => _currentIndex == _total - 1;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _select(int idx) {
    if (_answered) return;
    setState(() {
      _selected = idx;
      _answered = true;
      if (idx == _q.correctIndex) _score++;
    });
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _animCtrl.reset();
      setState(() {
        _currentIndex++;
        _selected = null;
        _answered = false;
      });
      _animCtrl.forward();
    }
  }

  void _finish() {
    int earned = 0;
    if (widget.canEarnCoins && !_coinsGiven) {
      earned = _score;
      ref.read(coinsProvider.notifier).add(_score);
      ref.read(completedQuizzesProvider.notifier)
          .markCompleted(widget.category.id);
      _coinsGiven = true;
    }
    _showResult(earned);
  }

  void _showResult(int earned) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => _ResultSheet(
        score: _score,
        total: _total,
        coinsEarned: earned,
        wasFirstTime: widget.canEarnCoins,
        onRestart: () {
          Navigator.pop(context);
          _animCtrl.reset();
          setState(() {
            _currentIndex = 0;
            _score = 0;
            _selected = null;
            _answered = false;
          });
          _animCtrl.forward();
        },
        onBack: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.darkCard : Colors.white;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBg : const Color(0xFFF0F2FF),
      body: Column(
        children: [
          // ── Gradient header ──
          Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 16, 20),
                child: Column(
                  children: [
                    // Back + title + score
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(widget.category.title,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🪙'),
                              const SizedBox(width: 4),
                              Text('$_score',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Progress
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Сұрақ ${_currentIndex + 1} / $_total',
                                  style: TextStyle(
                                      color: Colors.white
                                          .withValues(alpha: 0.85),
                                      fontSize: 12)),
                              Text(
                                  '${((_currentIndex + 1) / _total * 100).round()}%',
                                  style: TextStyle(
                                      color: Colors.white
                                          .withValues(alpha: 0.85),
                                      fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: (_currentIndex + 1) / _total,
                              minHeight: 6,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.25),
                              valueColor:
                                  const AlwaysStoppedAnimation(Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Question + Options ──
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text('Сұрақ ${_currentIndex + 1}',
                          style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 12),
                    // Question text
                    Text(
                      _q.question,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.45,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1A1A2E)),
                    ),
                    const SizedBox(height: 22),
                    // Options
                    ...List.generate(
                      _q.options.length,
                      (i) => _OptionTile(
                        label: _kOptionLabels[i % _kOptionLabels.length],
                        text: _q.options[i],
                        index: i,
                        selected: _selected,
                        correctIndex: _q.correctIndex,
                        answered: _answered,
                        cardBg: cardBg,
                        isDark: isDark,
                        onTap: () => _select(i),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_answered)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: _next,
                          child: Text(
                            _isLast
                                ? 'Нәтижені көру  ›'
                                : 'Келесі сұрақ  ›',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _kOptionLabels = ['A', 'B', 'C', 'D', 'E', 'F'];

// ── Option Tile ──
class _OptionTile extends StatelessWidget {
  final String label;
  final String text;
  final int index;
  final int? selected;
  final int correctIndex;
  final bool answered;
  final Color cardBg;
  final bool isDark;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.text,
    required this.index,
    required this.selected,
    required this.correctIndex,
    required this.answered,
    required this.cardBg,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSel = selected == index;
    final isCorrect = index == correctIndex;

    Color bgColor;
    Color borderColor;
    Color labelBg;
    Color labelText;
    IconData? trailing;
    Color? trailingColor;

    if (answered) {
      if (isCorrect) {
        bgColor = const Color(0xFF4CAF50).withValues(alpha: 0.12);
        borderColor = const Color(0xFF4CAF50);
        labelBg = const Color(0xFF4CAF50);
        labelText = Colors.white;
        trailing = Icons.check_circle_rounded;
        trailingColor = const Color(0xFF4CAF50);
      } else if (isSel) {
        bgColor = const Color(0xFFF44336).withValues(alpha: 0.1);
        borderColor = const Color(0xFFF44336);
        labelBg = const Color(0xFFF44336);
        labelText = Colors.white;
        trailing = Icons.cancel_rounded;
        trailingColor = const Color(0xFFF44336);
      } else {
        bgColor = cardBg;
        borderColor = isDark ? Colors.white12 : Colors.grey.shade200;
        labelBg = isDark ? Colors.white12 : Colors.grey.shade100;
        labelText = isDark ? Colors.white54 : Colors.grey.shade500;
      }
    } else if (isSel) {
      bgColor = AppTheme.primary.withValues(alpha: 0.08);
      borderColor = AppTheme.primary;
      labelBg = AppTheme.primary;
      labelText = Colors.white;
    } else {
      bgColor = cardBg;
      borderColor = isDark ? Colors.white12 : Colors.grey.shade200;
      labelBg = isDark ? Colors.white10 : Colors.grey.shade100;
      labelText = isDark ? Colors.white54 : Colors.grey.shade500;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: answered ? null : onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 13),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: labelBg),
                    child: Center(
                      child: Text(label,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: labelText)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                          fontSize: 15,
                          height: 1.35,
                          fontWeight: (isSel || (answered && isCorrect))
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1A1A2E)),
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    Icon(trailing, color: trailingColor, size: 22),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
// Нәтиже парағы (Bottom Sheet)
// ──────────────────────────────────────────────────────────────────
class _ResultSheet extends StatelessWidget {
  final int score;
  final int total;
  final int coinsEarned;
  final bool wasFirstTime;
  final VoidCallback onRestart;
  final VoidCallback onBack;

  const _ResultSheet({
    required this.score,
    required this.total,
    required this.coinsEarned,
    required this.wasFirstTime,
    required this.onRestart,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.darkSurface : Colors.white;
    final double pct = score / total;

    final String emoji;
    final String msg;
    if (pct >= 0.9) {
      emoji = '🏆';
      msg = 'Керемет! Ең жоғары нәтиже!';
    } else if (pct >= 0.7) {
      emoji = '🎉';
      msg = 'Жақсы нәтиже!';
    } else if (pct >= 0.5) {
      emoji = '😊';
      msg = 'Жаман емес, жалғастыр!';
    } else {
      emoji = '📚';
      msg = 'Тағы бір рет қайталап көр!';
    }

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(emoji, style: const TextStyle(fontSize: 60)),
          const SizedBox(height: 10),
          Text(msg,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
          const SizedBox(height: 20),

          // Stats card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF1A237E), Color(0xFF3949AB)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat(
                    value: '$score/$total', label: 'Дұрыс'),
                Container(
                    width: 1, height: 36, color: Colors.white24),
                _Stat(
                    value: '${(pct * 100).round()}%',
                    label: 'Нәтиже'),
                Container(
                    width: 1, height: 36, color: Colors.white24),
                _Stat(
                    value: coinsEarned > 0
                        ? '+$coinsEarned 🪙'
                        : (wasFirstTime ? '0 🪙' : '—'),
                    label: wasFirstTime ? 'Балл' : 'Алынған'),
              ],
            ),
          ),

          // Info if not first time
          if (!wasFirstTime) ...[
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade400),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: Colors.amber.shade700, size: 17),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Балл бұрын алынды. Тест қайта тапсыруға болады.',
                      style: TextStyle(
                          fontSize: 12, color: Colors.amber.shade800),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 22),
          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Артқа'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: onRestart,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Қайтадан'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 3),
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
      ],
    );
  }
}


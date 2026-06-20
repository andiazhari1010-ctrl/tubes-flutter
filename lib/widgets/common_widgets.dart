import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_icons.dart';
import '../models/models.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';

// ─── Pressable Scale ─────────────────────────────────────────────────────────
/// Membungkus elemen interaktif dengan umpan-balik tekan (scale-down) halus,
/// memberi kesan tombol fisik. Dipakai konsisten agar setiap CTA terasa "hidup".
/// Feedback hanya muncul bila ada [onTap] (elemen non-aktif tetap diam).
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scale;
  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scale = 0.96,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _down = false;
  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final interactive = widget.onTap != null;
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: interactive ? (_) => _set(true) : null,
      onTapUp: interactive ? (_) => _set(false) : null,
      onTapCancel: interactive ? () => _set(false) : null,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

// ─── Reveal Once ─────────────────────────────────────────────────────────────
/// Entrance fade + slide-up sekali saat elemen pertama kali muncul. Motivasinya
/// jelas (hierarki: menuntun mata dari atas ke bawah), bukan animasi asal. Pakai
/// TweenAnimationBuilder agar tidak perlu controller & tidak re-trigger saat
/// state lain berubah.
class RevealOnce extends StatelessWidget {
  final Widget child;
  const RevealOnce({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.translate(offset: Offset(0, (1 - t) * 14), child: child),
      ),
      child: child,
    );
  }
}

// ─── Stat Bar ──────────────────────────────────────────────────────────────
class StatBar extends StatelessWidget {
  final String label;
  final int value;
  final int maxValue;
  final Color color;

  const StatBar({
    super.key,
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (maxValue <= 0 ? 0.0 : value / maxValue).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(label, style: AppText.body(10, color: color, weight: FontWeight.w700)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                return ClipRRect(
                  borderRadius: AppRadius.pillAll,
                  child: Stack(
                    children: [
                      Container(
                        height: 7,
                        width: c.maxWidth,
                        color: AppColors.t1.withValues(alpha: 0.06),
                      ),
                      // Fill bergradien — kesan stat-bar game yang lebih kaya.
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeOutCubic,
                        height: 7,
                        width: c.maxWidth * pct,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color.withValues(alpha: 0.55), color],
                          ),
                          borderRadius: AppRadius.pillAll,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 50,
            child: Text('$value/$maxValue',
                textAlign: TextAlign.right,
                style: AppText.body(10, color: color, weight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ─── Currency Chip ─────────────────────────────────────────────────────────
class CurrencyChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  const CurrencyChip(
      {super.key,
      required this.icon,
      required this.value,
      required this.label,
      required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.t1.withValues(alpha: 0.04),
          borderRadius: AppRadius.mdAll,
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: AppText.body(14, color: AppColors.t1, weight: FontWeight.w700)),
                Text(label.toUpperCase(),
                    style: AppText.body(10, color: AppColors.t3, weight: FontWeight.w600)
                        .copyWith(letterSpacing: 0.5)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Title ─────────────────────────────────────────────────────────
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg + 2, bottom: AppSpacing.md),
      child: Row(
        children: [
          // Accent tick — penanda hierarki yang disengaja.
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.accent2, AppColors.accent],
              ),
              borderRadius: AppRadius.pillAll,
            ),
          ),
          const SizedBox(width: AppSpacing.sm + 1),
          Text(title.toUpperCase(),
              style: AppText.display(11, color: AppColors.t2, spacing: 1.5)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Container(
              height: 0.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.border2, AppColors.border.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reward Pill ───────────────────────────────────────────────────────────
class RewardPill extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  const RewardPill(
      {super.key, required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.smAll),
      child: Text(text, style: AppText.body(10, color: fg, weight: FontWeight.w600)),
    );
  }
}

// ─── Priority Dot ──────────────────────────────────────────────────────────
class PriorityDot extends StatelessWidget {
  final TaskPriority priority;
  const PriorityDot(this.priority, {super.key});

  @override
  Widget build(BuildContext context) {
    Color c;
    switch (priority) {
      case TaskPriority.high: c = AppColors.red; break;
      case TaskPriority.medium: c = AppColors.gold2; break;
      case TaskPriority.low: c = AppColors.green; break;
    }
    return Container(
      width: 6, height: 6,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
    );
  }
}

// ─── Task Item ─────────────────────────────────────────────────────────────
class TaskItem extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool enabled;

  const TaskItem({
    super.key,
    required this.task,
    required this.onTap,
    this.onLongPress,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      // Saat tidak aktif (bukan jadwalnya hari ini), tap untuk menyelesaikan
      // dimatikan — tapi long-press tetap aktif agar masih bisa diedit/dihapus.
      onTap: enabled ? onTap : null,
      onLongPress: onLongPress,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.45,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: enabled ? AppColors.c1 : AppColors.c0,
            borderRadius: AppRadius.mdAll,
            border: Border.all(
              color: task.isDone ? AppColors.accent.withValues(alpha: 0.4) : AppColors.border,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              PriorityDot(task.priority),
              const SizedBox(width: AppSpacing.md),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22, height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isDone ? AppColors.accent : Colors.transparent,
                  border: Border.all(
                    color: enabled ? AppColors.accent : AppColors.t3,
                    width: 1.5,
                  ),
                ),
                child: task.isDone
                    ? const Icon(Icons.check, size: 13, color: Colors.white)
                    : (enabled
                        ? null
                        : Icon(Icons.lock_outline, size: 11, color: AppColors.t3)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: AppText.body(13,
                          color: task.isDone ? AppColors.t3 : AppColors.t1,
                          weight: FontWeight.w500).copyWith(
                        decoration: task.isDone ? TextDecoration.lineThrough : null,
                        decorationColor: AppColors.t3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(task.subtitle, style: AppText.body(11, color: AppColors.t3)),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (enabled)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RewardPill(
                      text: '+${task.xpReward} XP',
                      bg: AppColors.xp.withValues(alpha: 0.15),
                      fg: AppColors.xp,
                    ),
                    if (task.goldReward > 0) ...[
                      const SizedBox(height: 3),
                      RewardPill(
                        text: '+${task.goldReward}G',
                        bg: AppColors.gold.withValues(alpha: 0.15),
                        fg: AppColors.gold,
                      ),
                    ],
                  ],
                )
              else
                RewardPill(
                  text: 'Bukan hari ini',
                  bg: AppColors.t3.withValues(alpha: 0.12),
                  fg: AppColors.t3,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Habit Item ────────────────────────────────────────────────────────────
class HabitItem extends StatelessWidget {
  final HabitModel habit;
  final Color iconBg;
  final Function(bool) onAction;
  final VoidCallback? onLongPress;

  const HabitItem({
    super.key,
    required this.habit,
    required this.iconBg,
    required this.onAction,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.c1,
          borderRadius: AppRadius.mdAll,
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: iconBg, borderRadius: AppRadius.mdAll),
              child: Center(
                  child: Icon(AppIcons.skill(habit.attribute),
                      size: 18, color: AppColors.t1)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(habit.title, style: AppText.body(13, color: AppColors.t1, weight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        habit.streak > 0 ? Icons.local_fire_department_rounded : Icons.bolt_rounded,
                        size: 12,
                        color: AppColors.gold2,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        habit.streak > 0 ? '${habit.streak} hari streak' : 'Baru dimulai',
                        style: AppText.body(11, color: AppColors.gold2),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: [
                _habitBtn(Icons.add_rounded, AppColors.xp, () => onAction(true)),
                const SizedBox(width: AppSpacing.sm),
                _habitBtn(Icons.remove_rounded, AppColors.red, () => onAction(false)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _habitBtn(IconData icon, Color color, VoidCallback onTap) {
    return PressableScale(
      onTap: onTap,
      scale: 0.9,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: AppRadius.smAll,
          border: Border.all(color: color.withValues(alpha: 0.4), width: 0.5),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

// ─── Quest Card ────────────────────────────────────────────────────────────
class QuestCard extends StatelessWidget {
  final QuestModel quest;
  const QuestCard({super.key, required this.quest});

  void _showQuestActionSheet(BuildContext context) {
    final state = Provider.of<AppState>(context, listen: false);
    final isDone = quest.isBoss ? (quest.progress <= 0) : (quest.progress >= 100);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.c2,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.t3,
                    borderRadius: AppRadius.pillAll,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Icon(
                    quest.isBoss ? Icons.whatshot_rounded : Icons.menu_book_rounded,
                    size: 26,
                    color: quest.isBoss ? AppColors.red : AppColors.accent2,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(quest.title, style: AppText.display(15, color: AppColors.gold)),
                        Text(
                          quest.isBoss ? 'Quest Boss Komunitas' : 'Quest Harian Komunitas',
                          style: AppText.body(11, color: AppColors.t3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (quest.isBoss) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.08),
                    borderRadius: AppRadius.mdAll,
                    border: Border.all(color: AppColors.red.withValues(alpha: 0.2), width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.shield_outlined, size: 18, color: AppColors.red),
                      const SizedBox(width: AppSpacing.sm + 2),
                      Expanded(
                        child: Text(
                          'Boss ini hanya bisa diselesaikan bersama lewat halaman Party.',
                          style: AppText.body(12, color: AppColors.red, weight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('HP Boss: ${quest.progress}%',
                        style: AppText.body(13, color: AppColors.red, weight: FontWeight.w600)),
                    Text('Hadiah: +${quest.xpReward} XP',
                        style: AppText.body(13, color: AppColors.xp, weight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Tutup'),
                  ),
                ),
              ] else ...[
                Text(
                  'Kerjakan tugas harian atau tekan tombol di bawah untuk melaporkan progres quest ini.',
                  style: AppText.body(12, color: AppColors.t2),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Progres: ${quest.progress}%',
                        style: AppText.body(13, color: AppColors.accent2, weight: FontWeight.w600)),
                    Text('Hadiah: +${quest.xpReward} XP',
                        style: AppText.body(13, color: AppColors.xp, weight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isDone
                        ? null
                        : () {
                            Navigator.pop(ctx);
                            state.progressQuest(quest.id);
                          },
                    icon: Icon(isDone ? Icons.emoji_events_rounded : Icons.bolt_rounded, size: 18),
                    label: Text(isDone ? 'QUEST SELESAI' : 'KERJAKAN QUEST (+20%)'),
                    style: ElevatedButton.styleFrom(
                      disabledBackgroundColor: AppColors.border,
                      disabledForegroundColor: AppColors.t3,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final barColor = quest.isBoss ? AppColors.red : AppColors.accent;
    return PressableScale(
      onTap: () => _showQuestActionSheet(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm + 1),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.c1,
          borderRadius: AppRadius.lgAll,
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(quest.title,
                      style: AppText.body(13, color: AppColors.t1, weight: FontWeight.w500)),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
                  decoration: BoxDecoration(
                    color: (quest.isBoss ? AppColors.red : AppColors.xp).withValues(alpha: 0.12),
                    borderRadius: AppRadius.smAll,
                  ),
                  child: Text('+${quest.xpReward} XP',
                      style: AppText.body(10,
                          color: quest.isBoss ? AppColors.red : AppColors.xp,
                          weight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            LayoutBuilder(
              builder: (context, c) {
                final frac = (quest.progress / 100).clamp(0.0, 1.0);
                return ClipRRect(
                  borderRadius: AppRadius.pillAll,
                  child: Stack(
                    children: [
                      Container(
                        height: 5,
                        width: c.maxWidth,
                        color: AppColors.t1.withValues(alpha: 0.07),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeOutCubic,
                        height: 5,
                        width: c.maxWidth * frac,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [barColor.withValues(alpha: 0.5), barColor],
                          ),
                          borderRadius: AppRadius.pillAll,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xs + 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  quest.isBoss ? '${quest.progress}% HP' : '${quest.progress}% selesai',
                  style: AppText.body(10, color: AppColors.t3),
                ),
                Text(quest.timeLeft, style: AppText.body(10, color: AppColors.t3)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

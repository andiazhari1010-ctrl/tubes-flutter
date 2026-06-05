import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';

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
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            child: Text(label,
                style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w700, color: color)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: value / maxValue,
                minHeight: 6,
                backgroundColor: Colors.white.withValues(alpha: 0.07),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            child: Text('$value/$maxValue',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 10, color: color)),
          ),
        ],
      ),
    );
  }
}

// ─── Currency Chip ─────────────────────────────────────────────────────────
class CurrencyChip extends StatelessWidget {
  final String icon;
  final String value;
  final String label;

  const CurrencyChip(
      {super.key, required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07), width: 0.5),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.t1)),
                Text(label.toUpperCase(),
                    style: TextStyle(
                        fontSize: 9,
                        color: AppColors.t3,
                        letterSpacing: 0.5)),
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
      padding: const EdgeInsets.only(top: 16, bottom: 10),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 11,
              color: AppColors.t3,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(height: 0.5, color: AppColors.border),
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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(text,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg)),
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

  const TaskItem({
    super.key,
    required this.task,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.c1,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: task.isDone ? AppColors.accent.withValues(alpha: 0.4) : AppColors.border,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            PriorityDot(task.priority),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.isDone ? AppColors.accent : Colors.transparent,
                border: Border.all(color: AppColors.accent, width: 1.5),
              ),
              child: task.isDone
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: task.isDone ? AppColors.t3 : AppColors.t1,
                      decoration: task.isDone ? TextDecoration.lineThrough : null,
                      decorationColor: AppColors.t3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(task.subtitle,
                      style: TextStyle(fontSize: 10, color: AppColors.t3)),
                ],
              ),
            ),
            const SizedBox(width: 8),
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
            ),
          ],
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
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.c1,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(habit.emoji, style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(habit.title,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.t1)),
                  const SizedBox(height: 2),
                  Text(
                    habit.streak > 0
                        ? '🔥 ${habit.streak} hari streak'
                        : '⭐ Baru dimulai',
                    style: TextStyle(fontSize: 10, color: AppColors.gold2),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                _habitBtn('+', AppColors.xp.withValues(alpha: 0.4), AppColors.xp,
                    () => onAction(true)),
                const SizedBox(width: 6),
                _habitBtn('–', AppColors.red.withValues(alpha: 0.4), AppColors.red,
                    () => onAction(false)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _habitBtn(
      String label, Color borderColor, Color textColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: borderColor, width: 0.5),
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: textColor)),
        ),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
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
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    quest.isBoss ? '💀' : '📚',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quest.title,
                          style: TextStyle(
                            fontFamily: 'Cinzel',
                            fontSize: 15,
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          quest.isBoss ? 'Quest Boss Komunitas' : 'Quest Harian Komunitas',
                          style: TextStyle(fontSize: 10, color: AppColors.t3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                quest.isBoss
                    ? 'Serang boss ini bersama party Anda! Setiap serangan manual mengurangi HP boss.'
                    : 'Kerjakan tugas harian atau klik tombol di bawah untuk melaporkan progress quest ini.',
                style: TextStyle(fontSize: 12, color: AppColors.t2),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    quest.isBoss ? 'HP Boss: ${quest.progress}%' : 'Progress: ${quest.progress}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: quest.isBoss ? AppColors.red : AppColors.accent,
                    ),
                  ),
                  Text(
                    'Hadiah: +${quest.xpReward} XP',
                    style: TextStyle(fontSize: 13, color: AppColors.xp, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (isDone || quest.isBoss) ? null : () {
                    Navigator.pop(ctx);
                    state.progressQuest(quest.id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDone ? AppColors.border : (quest.isBoss ? AppColors.border : AppColors.accent),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.border,
                    disabledForegroundColor: AppColors.t3,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isDone 
                      ? (quest.isBoss ? '💀 BOSS TELAH DIKALAHKAN' : '🏆 QUEST SELESAI')
                      : (quest.isBoss ? '🛡️ SERANG BOSS DI HALAMAN PARTY' : '⚔️ KERJAKAN QUEST (+20%)'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final barColor = quest.isBoss ? AppColors.red : AppColors.accent;
    return GestureDetector(
      onTap: () => _showQuestActionSheet(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.c1,
          borderRadius: BorderRadius.circular(16),
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
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.t1)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (quest.isBoss ? AppColors.red : AppColors.xp)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('+${quest.xpReward} XP',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: quest.isBoss ? AppColors.red : AppColors.xp)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: quest.progress / 100,
                minHeight: 4,
                backgroundColor: Colors.white.withValues(alpha: 0.07),
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  quest.isBoss ? '${quest.progress}% HP' : '${quest.progress}% selesai',
                  style: TextStyle(fontSize: 10, color: AppColors.t3),
                ),
                Text(quest.timeLeft,
                    style: TextStyle(fontSize: 10, color: AppColors.t3)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
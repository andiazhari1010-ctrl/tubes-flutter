import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';
import 'focus_screen.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  static const _habitColors = [
    Color(0x2E7F77DD),
    Color(0x265DCAA5),
    Color(0x2285B7EB),
    Color(0x21F4C430),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Scaffold(
          backgroundColor: AppColors.c0,
          appBar: AppBar(
            title: const Text('Tasks & Habits'),
            actions: [
              // Focus Mode Trigger
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FocusScreen()),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.c2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: const Center(
                    child: Text('🎯',
                        style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _showAddTaskSheet(context, state),
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.c2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: const Center(
                    child: Text('＋',
                        style: TextStyle(fontSize: 18, color: AppColors.t2)),
                  ),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              const SectionTitle('Habits'),
              ...List.generate(state.habits.length, (i) {
                final h = state.habits[i];
                return HabitItem(
                  habit: h,
                  iconBg: _habitColors[i % _habitColors.length],
                  onAction: (positive) => state.doHabit(h, positive),
                );
              }),

              const SectionTitle('Daily Tasks'),
              ...state.dailyTasks.map((t) => TaskItem(
                    task: t,
                    onTap: () => state.toggleTask(t),
                  )),

              const SectionTitle('To-Do List'),
              ...state.todos.map((t) => TaskItem(
                    task: t,
                    onTap: () => state.toggleTask(t),
                  )),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showAddTaskSheet(BuildContext context, AppState state) {
    final titleCtrl = TextEditingController();
    final subCtrl = TextEditingController();
    TaskPriority priority = TaskPriority.medium;
    TaskType type = TaskType.todo;
    SkillAttribute attribute = SkillAttribute.focus;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.c2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setLocal) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20, right: 20, top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36, height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.t3,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Tambah Task Baru',
                      style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 16,
                        color: AppColors.t1,
                      )),
                  const SizedBox(height: 16),
                  _sheetInput(titleCtrl, 'Judul task', Icons.title),
                  const SizedBox(height: 10),
                  _sheetInput(subCtrl, 'Subtitle / deadline', Icons.info_outline),
                  const SizedBox(height: 16),

                  // Type selector
                  const Text('Tipe',
                      style: TextStyle(fontSize: 12, color: AppColors.t3)),
                  const SizedBox(height: 8),
                  Row(
                    children: TaskType.values.map((t) {
                      final labels = {
                        TaskType.habit: '🌀 Habit',
                        TaskType.daily: '📅 Daily',
                        TaskType.todo: '📝 To-Do'
                      };
                      final sel = type == t;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setLocal(() => type = t),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: sel
                                  ? AppColors.accent.withOpacity(0.15)
                                  : AppColors.c1,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: sel ? AppColors.accent : AppColors.border,
                                width: sel ? 1 : 0.5,
                              ),
                            ),
                            child: Text(labels[t]!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: sel ? AppColors.accent2 : AppColors.t3)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Attribute selector
                  const Text('Atribut Skill RPG',
                      style: TextStyle(fontSize: 12, color: AppColors.t3)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: SkillAttribute.values.map((attr) {
                      final sel = attribute == attr;
                      return GestureDetector(
                        onTap: () => setLocal(() => attribute = attr),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: sel
                                ? AppColors.accent.withOpacity(0.15)
                                : AppColors.c1,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: sel ? AppColors.accent : AppColors.border,
                              width: sel ? 1 : 0.5,
                            ),
                          ),
                          child: Text(
                            '${attr.emoji} ${attr.name}',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: sel ? AppColors.accent2 : AppColors.t3),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Priority selector
                  const Text('Prioritas',
                      style: TextStyle(fontSize: 12, color: AppColors.t3)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _priorityChip('High', TaskPriority.high, priority,
                          (p) => setLocal(() => priority = p)),
                      const SizedBox(width: 8),
                      _priorityChip('Medium', TaskPriority.medium, priority,
                          (p) => setLocal(() => priority = p)),
                      const SizedBox(width: 8),
                      _priorityChip('Low', TaskPriority.low, priority,
                          (p) => setLocal(() => priority = p)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleCtrl.text.trim().isEmpty) return;
                        final task = TaskModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleCtrl.text.trim(),
                          subtitle: subCtrl.text.trim().isEmpty
                              ? '📝 Task baru'
                              : subCtrl.text.trim(),
                          priority: priority,
                          type: type,
                          attribute: attribute,
                          xpReward: 30,
                          goldReward: 10,
                        );
                        if (type == TaskType.habit) {
                          state.addHabit(HabitModel(
                            id: task.id,
                            title: task.title,
                            emoji: '⭐',
                            xpReward: 15,
                            attribute: attribute,
                          ));
                        } else {
                          state.addTask(task);
                        }
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text('Tambahkan',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _sheetInput(
      TextEditingController ctrl, String hint, IconData icon) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(fontSize: 13, color: AppColors.t1),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.t3),
        prefixIcon: Icon(icon, color: AppColors.t3, size: 18),
        filled: true,
        fillColor: AppColors.c1,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 1),
        ),
      ),
    );
  }

  Widget _priorityChip(String label, TaskPriority p, TaskPriority current,
      Function(TaskPriority) onTap) {
    final sel = p == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(p),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: sel ? AppColors.accent.withOpacity(0.12) : AppColors.c1,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: sel ? AppColors.accent : AppColors.border,
              width: sel ? 1 : 0.5,
            ),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: sel ? AppColors.accent2 : AppColors.t3)),
        ),
      ),
    );
  }
}

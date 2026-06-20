import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/app_icons.dart';
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
                  child: Center(
                    child: Icon(AppIcons.focus, size: 18, color: AppColors.t2),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _showTaskFormSheet(context, state),
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.c2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Center(
                    child: Icon(Icons.add_rounded, size: 20, color: AppColors.t2),
                  ),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              const SectionTitle('Habits'),
              if (state.habits.isEmpty)
                _emptyHint(Icons.track_changes_rounded, 'Belum ada habit.', 'Tap + untuk membangun kebiasaan baru.')
              else
                ...List.generate(state.habits.length, (i) {
                  final h = state.habits[i];
                  return HabitItem(
                    habit: h,
                    iconBg: _habitColors[i % _habitColors.length],
                    onAction: (positive) => state.doHabit(h, positive),
                    onLongPress: () => _showOptionsSheet(context, state, habit: h),
                  );
                }),

              const SectionTitle('Daily Tasks'),
              if (state.dailyTasks.isEmpty)
                _emptyHint(Icons.event_repeat_rounded, 'Belum ada daily.', 'Tugas harian yang berulang akan muncul di sini.')
              else
                ...state.dailyTasks.map((t) => TaskItem(
                      task: t,
                      enabled: _isDailyActiveToday(t),
                      onTap: () => state.toggleTask(t),
                      onLongPress: () => _showOptionsSheet(context, state, task: t),
                    )),

              const SectionTitle('To-Do List'),
              if (state.todos.isEmpty)
                _emptyHint(Icons.checklist_rtl_rounded, 'To-do kosong.', 'Mantap, semua beres! Tap + untuk tugas baru.')
              else
                ...state.todos.map((t) => TaskItem(
                      task: t,
                      onTap: () => state.toggleTask(t),
                      onLongPress: () => _showOptionsSheet(context, state, task: t),
                    )),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // Label hari untuk tipe Daily (1=Senin … 7=Minggu).
  static const Map<int, String> _dayLabels = {
    1: 'Sen', 2: 'Sel', 3: 'Rab', 4: 'Kam', 5: 'Jum', 6: 'Sab', 7: 'Min',
  };

  // Daily hanya aktif (bisa diselesaikan) pada hari yang dipilih.
  bool _isDailyActiveToday(TaskModel t) => t.isActiveOn(DateTime.now().weekday);

  String _parseDescription(String subtitle) {
    // Catatan: Daily "setiap hari" disimpan sebagai 'Setiap hari' (tanpa titik dua),
    // jadi marker-nya harus ikut diperhitungkan agar tidak bocor ke deskripsi.
    for (final marker in const [' · Tenggat:', ' · Setiap:', ' · Setiap hari']) {
      final idx = subtitle.indexOf(marker);
      if (idx != -1) return subtitle.substring(0, idx);
    }
    if (subtitle.startsWith('Tenggat: ') ||
        subtitle.startsWith('Setiap: ') ||
        subtitle == 'Setiap hari') {
      return '';
    }
    return subtitle;
  }

  void _showOptionsSheet(
    BuildContext context,
    AppState state, {
    TaskModel? task,
    HabitModel? habit,
  }) {
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
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.t3,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              Text(
                task != null ? 'Kelola Task' : 'Kelola Habit',
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 16,
                  color: AppColors.t1,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.edit_outlined, color: AppColors.accent),
                title: Text('Edit', style: TextStyle(color: AppColors.t1)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showTaskFormSheet(context, state, taskToEdit: task, habitToEdit: habit);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: AppColors.red),
                title: Text('Hapus', style: TextStyle(color: AppColors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showDeleteConfirmation(context, state, task: task, habit: habit);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    AppState state, {
    TaskModel? task,
    HabitModel? habit,
  }) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.c2,
          title: Text(
            'Konfirmasi Hapus',
            style: TextStyle(fontFamily: 'Cinzel', color: AppColors.t1, fontSize: 16),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus ${task != null ? "task" : "habit"} ini?',
            style: TextStyle(color: AppColors.t2, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal', style: TextStyle(color: AppColors.t3)),
            ),
            TextButton(
              onPressed: () {
                if (task != null) {
                  state.deleteTask(task.id);
                } else if (habit != null) {
                  state.deleteHabit(habit.id);
                }
                Navigator.pop(ctx);
              },
              child: Text('Hapus', style: TextStyle(color: AppColors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showTaskFormSheet(
    BuildContext context,
    AppState state, {
    TaskModel? taskToEdit,
    HabitModel? habitToEdit,
  }) {
    final titleCtrl = TextEditingController(
      text: taskToEdit?.title ?? habitToEdit?.title ?? '',
    );
    final descCtrl = TextEditingController();
    DateTime? selectedDate;

    if (taskToEdit != null) {
      descCtrl.text = _parseDescription(taskToEdit.subtitle);
      selectedDate = taskToEdit.deadline;
    }

    TaskPriority priority = taskToEdit?.priority ?? TaskPriority.medium;
    TaskType type = taskToEdit != null
        ? taskToEdit.type
        : (habitToEdit != null ? TaskType.habit : TaskType.todo);
    SkillAttribute attribute =
        taskToEdit?.attribute ?? habitToEdit?.attribute ?? SkillAttribute.intelligence;

    // Untuk tipe Daily: hari pengulangan (1=Senin … 7=Minggu).
    Set<int> selectedDays = {};
    if (taskToEdit != null && taskToEdit.type == TaskType.daily) {
      selectedDays = taskToEdit.repeatDays;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.c2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setLocal) {
          final isEditing = taskToEdit != null || habitToEdit != null;
          final isHabit = type == TaskType.habit;

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
                  Text(
                    isEditing
                        ? (habitToEdit != null ? 'Edit Habit' : 'Edit Task')
                        : 'Tambah Task Baru',
                    style: TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 16,
                      color: AppColors.t1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _sheetInput(titleCtrl, 'Judul task/habit', Icons.title),
                  const SizedBox(height: 10),

                  if (!isHabit) ...[
                    _sheetInput(descCtrl, 'Deskripsi / subtitle (Opsional)', Icons.info_outline),
                    const SizedBox(height: 10),

                    // To-Do → tanggal deadline. Daily → hari pengulangan.
                    if (type == TaskType.todo)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.c1,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () async {
                                DateTime? picked = await showDatePicker(
                                  context: ctx,
                                  initialDate: selectedDate ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.dark(
                                          primary: AppColors.accent,
                                          onPrimary: Colors.white,
                                          surface: AppColors.c2,
                                          onSurface: AppColors.t1,
                                        ),
                                        textButtonTheme: TextButtonThemeData(
                                          style: TextButton.styleFrom(
                                            foregroundColor: AppColors.accent,
                                          ),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  setLocal(() {
                                    selectedDate = picked;
                                  });
                                }
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today_outlined, color: AppColors.t3, size: 18),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      selectedDate == null
                                          ? 'Pilih tanggal deadline (Opsional)'
                                          : 'Tenggat: ${selectedDate!.day.toString().padLeft(2, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.year}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: selectedDate == null ? AppColors.t3 : AppColors.t1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (selectedDate != null)
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                setLocal(() {
                                  selectedDate = null;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(Icons.clear, color: AppColors.t3, size: 18),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Daily → pilih hari pengulangan (boleh lebih dari satu).
                    if (type == TaskType.daily) ...[
                      Text('Hari Pengulangan',
                          style: TextStyle(fontSize: 12, color: AppColors.t3)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _dayLabels.entries.map((e) {
                          final sel = selectedDays.contains(e.key);
                          return GestureDetector(
                            onTap: () => setLocal(() {
                              if (sel) {
                                selectedDays.remove(e.key);
                              } else {
                                selectedDays.add(e.key);
                              }
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: sel
                                    ? AppColors.accent.withValues(alpha: 0.15)
                                    : AppColors.c1,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: sel ? AppColors.accent : AppColors.border,
                                  width: sel ? 1 : 0.5,
                                ),
                              ),
                              child: Text(
                                e.value,
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: sel ? AppColors.accent2 : AppColors.t3),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],

                  // Type selector
                  if (!isEditing || taskToEdit != null) ...[
                    Text('Tipe',
                        style: TextStyle(fontSize: 12, color: AppColors.t3)),
                    const SizedBox(height: 8),
                    Row(
                      children: TaskType.values.where((t) {
                        if (isEditing && t == TaskType.habit) return false;
                        return true;
                      }).map((t) {
                        final labels = {
                          TaskType.habit: 'Habit',
                          TaskType.daily: 'Daily',
                          TaskType.todo: 'To-Do'
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
                                    ? AppColors.accent.withValues(alpha: 0.15)
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
                  ],

                  // Attribute selector
                  Text('Atribut Skill RPG',
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
                                ? AppColors.accent.withValues(alpha: 0.15)
                                : AppColors.c1,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: sel ? AppColors.accent : AppColors.border,
                              width: sel ? 1 : 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(AppIcons.skill(attr),
                                  size: 13,
                                  color: sel ? AppColors.accent2 : AppColors.t3),
                              const SizedBox(width: 5),
                              Text(
                                attr.name,
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: sel ? AppColors.accent2 : AppColors.t3),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Priority selector
                  if (!isHabit) ...[
                    Text('Prioritas',
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
                  ],

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final title = titleCtrl.text.trim();
                        if (title.isEmpty) return;

                        if (type == TaskType.habit) {
                          if (habitToEdit != null) {
                            state.updateHabit(HabitModel(
                              id: habitToEdit.id,
                              title: title,
                              streak: habitToEdit.streak,
                              xpReward: habitToEdit.xpReward,
                              attribute: attribute,
                            ));
                          } else {
                            state.addHabit(HabitModel(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              title: title,
                              xpReward: 15,
                              attribute: attribute,
                            ));
                          }
                        } else {
                          final desc = descCtrl.text.trim();
                          String metaStr;
                          if (type == TaskType.daily) {
                            metaStr = selectedDays.isNotEmpty
                                ? 'Setiap: ${(selectedDays.toList()..sort()).map((d) => _dayLabels[d]).join(', ')}'
                                : 'Setiap hari';
                          } else {
                            metaStr = selectedDate != null
                                ? 'Tenggat: ${selectedDate!.day.toString().padLeft(2, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.year}'
                                : '';
                          }
                          String finalSubtitle = '';
                          if (desc.isNotEmpty && metaStr.isNotEmpty) {
                            finalSubtitle = '$desc · $metaStr';
                          } else if (desc.isNotEmpty) {
                            finalSubtitle = desc;
                          } else if (metaStr.isNotEmpty) {
                            finalSubtitle = metaStr;
                          } else {
                            finalSubtitle = 'Task baru';
                          }

                          if (taskToEdit != null) {
                            state.updateTask(TaskModel(
                              id: taskToEdit.id,
                              title: title,
                              subtitle: finalSubtitle,
                              isDone: taskToEdit.isDone,
                              xpReward: taskToEdit.xpReward,
                              goldReward: taskToEdit.goldReward,
                              priority: priority,
                              type: type,
                              attribute: attribute,
                            ));
                          } else {
                            state.addTask(TaskModel(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              title: title,
                              subtitle: finalSubtitle,
                              priority: priority,
                              type: type,
                              attribute: attribute,
                              xpReward: 30,
                              goldReward: 10,
                            ));
                          }
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
                      child: Text(
                        isEditing ? 'Simpan Perubahan' : 'Tambahkan',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
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
      style: TextStyle(fontSize: 13, color: AppColors.t1),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.t3),
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
          borderSide: BorderSide(color: AppColors.accent, width: 1),
        ),
      ),
    );
  }

  // Placeholder elegan saat sebuah section kosong (anti area-melompong).
  Widget _emptyHint(IconData icon, String title, String subtitle) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.c1.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          Icon(icon, size: 26, color: AppColors.t3),
          const SizedBox(height: 8),
          Text(title,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.t2)),
          const SizedBox(height: 3),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: AppColors.t3, height: 1.4)),
        ],
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
            color: sel ? AppColors.accent.withValues(alpha: 0.12) : AppColors.c1,
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
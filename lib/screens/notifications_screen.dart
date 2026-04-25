import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.c0,
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: AppColors.c1,
      ),
      body: Consumer<AppState>(
        builder: (ctx, state, _) {
          final notifs = state.notifications;

          if (notifs.isEmpty) {
            return const Center(
              child: Text('Belum ada notifikasi', style: TextStyle(color: AppColors.t3)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifs.length,
            itemBuilder: (ctx, i) {
              final notif = notifs[i];
              return GestureDetector(
                onTap: () {
                  if (!notif.isRead) {
                    state.markNotificationRead(notif.id);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: notif.isRead ? AppColors.c1 : AppColors.c2,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: notif.isRead ? AppColors.border : AppColors.accent.withOpacity(0.5),
                      width: notif.isRead ? 0.5 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.c3,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(notif.emoji, style: const TextStyle(fontSize: 20)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notif.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.t1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notif.body,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.t3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${notif.timestamp.day}/${notif.timestamp.month}/${notif.timestamp.year} ${notif.timestamp.hour}:${notif.timestamp.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.accent2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8, height: 8,
                          margin: const EdgeInsets.only(top: 6),
                          decoration: const BoxDecoration(
                            color: AppColors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

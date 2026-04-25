import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.c0,
      appBar: AppBar(
        title: const Text('Daftar Pengguna'),
        backgroundColor: AppColors.c1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('Belum ada pengguna terdaftar.', style: TextStyle(color: AppColors.t3)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Unknown';
              final email = data['email'] ?? 'No email';
              final role = data['role'] ?? 'user';
              final level = data['level'] ?? 1;

              return Card(
                color: AppColors.c2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.c3,
                    child: Icon(Icons.person, color: AppColors.t1),
                  ),
                  title: Text(name, style: const TextStyle(color: AppColors.t1, fontWeight: FontWeight.bold)),
                  subtitle: Text('$email\nLevel: $level | Role: $role', style: const TextStyle(color: AppColors.t3)),
                  isThreeLine: true,
                  trailing: role == 'admin' 
                      ? const Icon(Icons.security, color: AppColors.gold)
                      : const Icon(Icons.person_outline, color: AppColors.accent2),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

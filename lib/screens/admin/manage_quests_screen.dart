import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';

class ManageQuestsScreen extends StatefulWidget {
  const ManageQuestsScreen({super.key});

  @override
  State<ManageQuestsScreen> createState() => _ManageQuestsScreenState();
}

class _ManageQuestsScreenState extends State<ManageQuestsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showAddQuestDialog([DocumentSnapshot? doc]) {
    final isEdit = doc != null;
    final titleCtrl = TextEditingController(text: isEdit ? doc['title'] : '');
    final xpCtrl = TextEditingController(text: isEdit ? doc['xpReward'].toString() : '100');
    final timeLeftCtrl = TextEditingController(text: isEdit ? doc['timeLeft'] : '24h');
    bool isBoss = isEdit ? (doc['isBoss'] ?? false) : false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.c1,
          title: Text(isEdit ? 'Edit Quest' : 'Tambah Quest Global', style: const TextStyle(color: AppColors.t1)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(color: AppColors.t1),
                  decoration: const InputDecoration(labelText: 'Judul Quest', labelStyle: TextStyle(color: AppColors.t3)),
                ),
                TextField(
                  controller: xpCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.t1),
                  decoration: const InputDecoration(labelText: 'Reward (XP)', labelStyle: TextStyle(color: AppColors.t3)),
                ),
                TextField(
                  controller: timeLeftCtrl,
                  style: const TextStyle(color: AppColors.t1),
                  decoration: const InputDecoration(labelText: 'Waktu (contoh: 2d 12h)', labelStyle: TextStyle(color: AppColors.t3)),
                ),
                SwitchListTile(
                  title: const Text('Boss Quest?', style: TextStyle(color: AppColors.t1)),
                  activeColor: AppColors.accent,
                  value: isBoss,
                  onChanged: (val) => setState(() => isBoss = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: AppColors.t3))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
              onPressed: () async {
                final data = {
                  'title': titleCtrl.text,
                  'xpReward': int.tryParse(xpCtrl.text) ?? 100,
                  'timeLeft': timeLeftCtrl.text,
                  'isBoss': isBoss,
                  'progress': isEdit ? doc['progress'] : 0, // progress reset or keep
                };

                if (isEdit) {
                  await _firestore.collection('quests').doc(doc.id).update(data);
                } else {
                  await _firestore.collection('quests').add(data);
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteQuest(String id) async {
    await _firestore.collection('quests').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.c0,
      appBar: AppBar(
        title: const Text('Kelola Quests Global'),
        backgroundColor: AppColors.c1,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: () => _showAddQuestDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('quests').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('Belum ada quest global', style: TextStyle(color: AppColors.t3)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final doc = docs[i];
              final data = doc.data() as Map<String, dynamic>;
              final isBoss = data['isBoss'] == true;
              return Card(
                color: AppColors.c2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Text(isBoss ? '💀' : '📜', style: const TextStyle(fontSize: 24)),
                  title: Text(data['title'] ?? '', style: TextStyle(color: isBoss ? AppColors.red : AppColors.t1)),
                  subtitle: Text('XP: ${data['xpReward']} | Sisa waktu: ${data['timeLeft']}', style: const TextStyle(color: AppColors.t3)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: AppColors.accent2), onPressed: () => _showAddQuestDialog(doc)),
                      IconButton(icon: const Icon(Icons.delete, color: AppColors.red), onPressed: () => _deleteQuest(doc.id)),
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

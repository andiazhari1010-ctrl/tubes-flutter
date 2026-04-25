import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';

class ManageShopScreen extends StatefulWidget {
  const ManageShopScreen({super.key});

  @override
  State<ManageShopScreen> createState() => _ManageShopScreenState();
}

class _ManageShopScreenState extends State<ManageShopScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showAddItemDialog([DocumentSnapshot? doc]) {
    final isEdit = doc != null;
    final nameCtrl = TextEditingController(text: isEdit ? doc['name'] : '');
    final descCtrl = TextEditingController(text: isEdit ? doc['description'] : '');
    final emojiCtrl = TextEditingController(text: isEdit ? doc['emoji'] : '🎁');
    final priceCtrl = TextEditingController(text: isEdit ? doc['price'].toString() : '50');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.c1,
        title: Text(isEdit ? 'Edit Item' : 'Tambah Item Baru', style: const TextStyle(color: AppColors.t1)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: AppColors.t1),
                decoration: const InputDecoration(labelText: 'Nama Item', labelStyle: TextStyle(color: AppColors.t3)),
              ),
              TextField(
                controller: descCtrl,
                style: const TextStyle(color: AppColors.t1),
                decoration: const InputDecoration(labelText: 'Deskripsi', labelStyle: TextStyle(color: AppColors.t3)),
              ),
              TextField(
                controller: emojiCtrl,
                style: const TextStyle(color: AppColors.t1),
                decoration: const InputDecoration(labelText: 'Emoji', labelStyle: TextStyle(color: AppColors.t3)),
              ),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.t1),
                decoration: const InputDecoration(labelText: 'Harga (Gold)', labelStyle: TextStyle(color: AppColors.t3)),
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
                'name': nameCtrl.text,
                'description': descCtrl.text,
                'emoji': emojiCtrl.text,
                'price': int.tryParse(priceCtrl.text) ?? 50,
              };

              if (isEdit) {
                await _firestore.collection('shop').doc(doc.id).update(data);
              } else {
                await _firestore.collection('shop').add(data);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteItem(String id) async {
    await _firestore.collection('shop').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.c0,
      appBar: AppBar(
        title: const Text('Kelola Shop Items'),
        backgroundColor: AppColors.c1,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: () => _showAddItemDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('shop').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('Belum ada item di Shop', style: TextStyle(color: AppColors.t3)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final doc = docs[i];
              final data = doc.data() as Map<String, dynamic>;
              return Card(
                color: AppColors.c2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Text(data['emoji'] ?? '📦', style: const TextStyle(fontSize: 24)),
                  title: Text(data['name'] ?? '', style: const TextStyle(color: AppColors.t1)),
                  subtitle: Text('${data['description']} \n🪙 ${data['price']}', style: const TextStyle(color: AppColors.t3)),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: AppColors.accent2), onPressed: () => _showAddItemDialog(doc)),
                      IconButton(icon: const Icon(Icons.delete, color: AppColors.red), onPressed: () => _deleteItem(doc.id)),
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Menyimpan data user baru ke Firestore
  Future<void> createUserDoc({
    required String uid,
    required String email,
    required String role,
    required String username,
    required String fullName,
    required String phone,
  }) async {
    try {
      // Periksa apakah ada dokumen pengguna yang dibuat sebelumnya oleh Admin berdasarkan email
      final query = await _db
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase().trim())
          .get();
      
      Map<String, dynamic> existingData = {};
      if (query.docs.isNotEmpty) {
        final preCreatedDoc = query.docs.firstWhere((d) => d.id != uid, orElse: () => query.docs.first);
        if (preCreatedDoc.id != uid) {
          existingData = preCreatedDoc.data();
          // Hapus dokumen sementara dengan ID acak yang dibuat oleh admin
          await preCreatedDoc.reference.delete();
        }
      } else {
        // Cari lagi dengan email persis jika di input berbeda huruf besar/kecil
        final queryExact = await _db
            .collection('users')
            .where('email', isEqualTo: email.trim())
            .get();
        if (queryExact.docs.isNotEmpty) {
          final preCreatedDoc = queryExact.docs.firstWhere((d) => d.id != uid, orElse: () => queryExact.docs.first);
          if (preCreatedDoc.id != uid) {
            existingData = preCreatedDoc.data();
            await preCreatedDoc.reference.delete();
          }
        }
      }

      await _db.collection('users').doc(uid).set({
        'email': email.toLowerCase().trim(),
        'role': existingData['role'] ?? role,
        'username': existingData['username'] ?? username,
        'fullName': existingData['fullName'] ?? fullName,
        'phone': existingData['phone'] ?? phone,
        'isBanned': existingData['isBanned'] ?? false,
        'isActive': existingData['isActive'] ?? true,
        'createdAt': existingData['createdAt'] ?? FieldValue.serverTimestamp(),
        // Gunakan data hero dari dokumen sebelumnya jika ada
        'hero': existingData['hero'] ?? {
          'name': fullName.isNotEmpty ? fullName : 'New Hero',
          'heroClass': 'warrior',
          'level': 1,
          'hp': 150,
          'maxHp': 150,
          'xp': 0,
          'maxXp': 100,
          'mp': 100,
          'maxMp': 100,
          'gold': 0,
          'gems': 0,
          'streak': 0,
        }
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error createUserDoc: $e");
    }
  }

  // Memeriksa apakah document user sudah ada di Firestore
  Future<bool> userDocExists(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.exists;
    } catch (e) {
      debugPrint("Error checking user doc existence: $e");
      return false;
    }
  }

  // Mendapatkan stream data user
  Stream<DocumentSnapshot> getUserStream(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  // Stream all user documents for real-time updates
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsersStream() {
    return _db.collection('users').snapshots();
  }

  // Aggregate total tasks completed across all users
  Future<int> getTotalTasksCompleted() async {
    final snapshot = await _db.collection('users').get();
    int total = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      total += (data['totalTasksCompleted'] ?? 0) as int;
    }
    return total;
  }

  // Aggregate total quests completed across all users
  Future<int> getTotalQuestsCompleted() async {
    final snapshot = await _db.collection('users').get();
    int total = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      total += (data['totalQuestsCompleted'] ?? 0) as int;
    }
    return total;
  }

  // Aggregate total XP across all users
  Future<int> getTotalXp() async {
    final snapshot = await _db.collection('users').get();
    int total = 0;
    for (var doc in snapshot.docs) {
      final hero = doc.data()['hero'];
      if (hero != null && hero is Map<String, dynamic>) {
        total += (hero['xp'] ?? 0) as int;
      }
    }
    return total;
  }

  // Count active users (example: streak > 0)
  Future<int> getActiveUserCount() async {
    final snapshot = await _db.collection('users').get();
    int count = 0;
    for (var doc in snapshot.docs) {
      final hero = doc.data()['hero'];
      if (hero != null && hero is Map<String, dynamic>) {
        final streak = hero['streak'] ?? 0;
        if ((streak as int) > 0) count++;
      }
    }
    return count;
  }

  // Menyimpan perubahan data hero
  Future<void> updateHeroData(String uid, HeroModel hero) async {
    try {
      await _db.collection('users').doc(uid).update({
        'hero': {
          'name': hero.name,
          'heroClass': hero.heroClass.name,
          'level': hero.level,
          'hp': hero.hp,
          'maxHp': hero.maxHp,
          'xp': hero.xp,
          'maxXp': hero.maxXp,
          'mp': hero.mp,
          'maxMp': hero.maxMp,
          'gold': hero.gold,
          'gems': hero.gems,
          'streak': hero.streak,
        }
      });
    } catch (e) {
      debugPrint("Error updateHeroData: $e");
    }
  }
}

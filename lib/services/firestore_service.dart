import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Menyimpan data user baru ke Firestore
  Future<void> createUserDoc(String uid, String email, String role) async {
    try {
      await _db.collection('users').doc(uid).set({
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        // Data default hero
        'hero': {
          'name': 'New Hero',
          'heroClass': 'warrior',
          'level': 1,
          'hp': 100,
          'maxHp': 100,
          'xp': 0,
          'maxXp': 1000,
          'mp': 100,
          'maxMp': 100,
          'gold': 0,
          'gems': 0,
          'streak': 0,
        }
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error createUserDoc: $e");
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
      print("Error updateHeroData: $e");
    }
  }
}

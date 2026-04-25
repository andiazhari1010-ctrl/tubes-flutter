import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import 'package:flutter/material.dart' show Color, ChangeNotifier;

class AppState extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  HeroModel hero = HeroModel(
    name: 'Memuat...',
    heroClass: HeroClass.warrior,
  );

  List<HabitModel> habits = [];
  List<TaskModel> dailyTasks = [];
  List<TaskModel> todos = [];
  List<QuestModel> quests = [];
  List<ShopItem> shopItems = [];
  List<PartyMember> partyMembers = [];
  List<NotificationModel> notifications = [];
  List<Map<String, dynamic>> friendRequests = [];

  AppState() {
    loadUserData();
  }

  void loadUserData() {
    final user = _auth.currentUser;
    if (user != null) {
      // Stream user data (HeroModel)
      _firestore.collection('users').doc(user.uid).snapshots().listen((snapshot) {
        if (snapshot.exists) {
          hero = HeroModel.fromJson(snapshot.data() as Map<String, dynamic>);
          notifyListeners();
        }
      });

      // Fetch global quests
      _firestore.collection('quests').snapshots().listen((snapshot) {
        quests = snapshot.docs.map((doc) => QuestModel.fromJson(doc.data(), doc.id)).toList();
        notifyListeners();
      });

      // Fetch shop items and sync with user's inventory
      _firestore.collection('shop').snapshots().listen((shopSnapshot) {
        final globalItems = shopSnapshot.docs.map((doc) => ShopItem.fromJson(doc.data(), doc.id)).toList();
        
        _firestore.collection('users').doc(user.uid).collection('inventory').snapshots().listen((invSnapshot) {
          final ownedIds = invSnapshot.docs.map((doc) => doc.id).toSet();
          
          shopItems = globalItems.map((item) {
            item.owned = ownedIds.contains(item.id);
            return item;
          }).toList();
          
          notifyListeners();
        });
      });
      
      // Fetch user's tasks
      _firestore.collection('users').doc(user.uid).collection('tasks').snapshots().listen((snapshot) {
        final tasks = snapshot.docs.map((doc) => TaskModel.fromJson(doc.data(), doc.id)).toList();
        todos = tasks.where((t) => t.type == TaskType.todo).toList();
        dailyTasks = tasks.where((t) => t.type == TaskType.daily).toList();
        notifyListeners();
      });
      
      // Fetch user's habits
      _firestore.collection('users').doc(user.uid).collection('habits').snapshots().listen((snapshot) {
        habits = snapshot.docs.map((doc) => HabitModel.fromJson(doc.data(), doc.id)).toList();
        notifyListeners();
      });

      // Fetch user's notifications
      _firestore.collection('users').doc(user.uid).collection('notifications').orderBy('timestamp', descending: true).snapshots().listen((snapshot) {
        notifications = snapshot.docs.map((doc) => NotificationModel.fromJson(doc.data(), doc.id)).toList();
        notifyListeners();
      });

      // Fetch friend requests
      _firestore.collection('users').doc(user.uid).collection('friendRequests').snapshots().listen((snapshot) {
        friendRequests = snapshot.docs.map((doc) {
          final data = doc.data();
          data['uid'] = doc.id;
          return data;
        }).toList();
        notifyListeners();
      });

      // Load friends dynamically
      loadFriends();
    }
  }

  void addNotification(String title, String body, String emoji) {
    final user = _auth.currentUser;
    if (user != null) {
      _firestore.collection('users').doc(user.uid).collection('notifications').add({
        'title': title,
        'body': body,
        'emoji': emoji,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    }
  }

  void markNotificationRead(String id) {
    final user = _auth.currentUser;
    if (user != null) {
      _firestore.collection('users').doc(user.uid).collection('notifications').doc(id).update({'isRead': true});
    }
  }

  void saveHero() {
    final user = _auth.currentUser;
    // Jangan simpan jika data belum benar-benar termuat dari Firestore
    if (user != null && hero.name != 'Memuat...') {
      _firestore.collection('users').doc(user.uid).update(hero.toJson());
    }
  }

  void _checkLevelUp() {
    bool leveledUp = false;
    while (hero.xp >= hero.maxXp) {
      hero.xp -= hero.maxXp;
      hero.level++;
      hero.maxXp = (hero.maxXp * 1.5).toInt(); // XP dibutuhkan naik 50%
      hero.maxHp += 20;
      hero.hp = hero.maxHp; // Full heal
      hero.gems += 5; // Dapet 5 Gems tiap level up!
      leveledUp = true;
    }
    
    if (leveledUp) {
      addNotification('Level Up! 🎉', 'Selamat! Kamu naik ke Level ${hero.level}. Kamu mendapatkan 5 Gems dan HP dipulihkan penuh!', '⭐');
    }
  }

  // ── Actions ──────────────────────────────────────────────────────────

  void toggleTask(TaskModel task) {
    task.isDone = !task.isDone;
    if (task.isDone) {
      hero.xp += task.xpReward;
      hero.gold += task.goldReward;
      
      _checkLevelUp(); // Cek level up
      
      // Kirim notifikasi quest selesai
      addNotification('Quest Selesai!', 'Kamu mendapatkan ${task.xpReward} XP dan ${task.goldReward} Gold dari: ${task.title}', '✨');
    } else {
      hero.xp = (hero.xp - task.xpReward).clamp(0, hero.maxXp);
      hero.gold = (hero.gold - task.goldReward).clamp(0, 999999);
    }
    
    // Save to Firestore
    final user = _auth.currentUser;
    if (user != null) {
      _firestore.collection('users').doc(user.uid).collection('tasks').doc(task.id).update({'isDone': task.isDone});
      saveHero();
    }
    notifyListeners();
  }

  void doHabit(HabitModel habit, bool positive) {
    if (positive) {
      hero.xp += habit.xpReward;
      hero.gold += 5;
      habit.streak++;
      
      _checkLevelUp(); // Cek level up
      
      addNotification('Habit Selesai!', 'Kamu mendapatkan ${habit.xpReward} XP dan 5 Gold dari: ${habit.title}', habit.emoji);
    } else {
      hero.hp = (hero.hp - 6).clamp(0, hero.maxHp);
    }
    
    final user = _auth.currentUser;
    if (user != null) {
      _firestore.collection('users').doc(user.uid).collection('habits').doc(habit.id).update({'streak': habit.streak});
      saveHero();
    }
    notifyListeners();
  }

  void buyItem(ShopItem item) {
    if (hero.gold >= item.price && !item.owned) {
      hero.gold -= item.price;
      item.owned = true;
      
      final user = _auth.currentUser;
      if (user != null) {
        _firestore.collection('users').doc(user.uid).collection('inventory').doc(item.id).set(item.toJson());
        saveHero();
      }
      notifyListeners();
    }
  }

  void changeClass(HeroClass newClass) {
    hero.heroClass = newClass;
    saveHero();
    notifyListeners();
  }

  // ── Social & Friends ──────────────────────────────────────────────────

  Future<void> sendFriendRequest(String email) async {
    final user = _auth.currentUser;
    if (user == null || email.isEmpty) return;

    // Cari user berdasarkan email
    final query = await _firestore.collection('users').where('email', isEqualTo: email.trim()).get();
    if (query.docs.isEmpty) throw Exception('User dengan email tersebut tidak ditemukan');

    final targetDoc = query.docs.first;
    if (targetDoc.id == user.uid) throw Exception('Tidak bisa menambahkan diri sendiri');

    // Tambahkan request ke target
    await _firestore.collection('users').doc(targetDoc.id).collection('friendRequests').doc(user.uid).set({
      'name': hero.name,
      'emoji': hero.classEmoji,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Kirim notifikasi ke target
    await _firestore.collection('users').doc(targetDoc.id).collection('notifications').add({
      'title': 'Permintaan Pertemanan',
      'body': '${hero.name} ingin berteman denganmu',
      'emoji': '👋',
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  Future<void> acceptFriendRequest(String senderUid, String senderName) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Tambahkan sender ke friends target
    await _firestore.collection('users').doc(user.uid).collection('friends').doc(senderUid).set({
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Tambahkan target ke friends sender
    await _firestore.collection('users').doc(senderUid).collection('friends').doc(user.uid).set({
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Hapus dari friendRequests
    await _firestore.collection('users').doc(user.uid).collection('friendRequests').doc(senderUid).delete();

    // Kirim notifikasi ke sender bahwa sudah diterima
    await _firestore.collection('users').doc(senderUid).collection('notifications').add({
      'title': 'Permintaan Diterima!',
      'body': '${hero.name} telah menerima permintaan pertemananmu',
      'emoji': '🎉',
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  Future<void> loadFriends() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _firestore.collection('users').doc(user.uid).collection('friends').snapshots().listen((snapshot) async {
      final List<PartyMember> friends = [];
      
      // Ambil data terbaru dari setiap teman
      for (var doc in snapshot.docs) {
        final friendDoc = await _firestore.collection('users').doc(doc.id).get();
        if (friendDoc.exists) {
          friends.add(PartyMember.fromJson(friendDoc.data() as Map<String, dynamic>, friendDoc.id));
        }
      }
      
      partyMembers = friends;
      notifyListeners();
    });
  }

  Future<void> contributeToQuest(String questId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final questRef = _firestore.collection('quests').doc(questId);
    final questDoc = await questRef.get();

    if (questDoc.exists) {
      final data = questDoc.data() as Map<String, dynamic>;
      int currentProgress = data['progress'] ?? 0;
      int xpReward = data['xpReward'] ?? 0;

      if (currentProgress < 100) {
        // Tambah progress 10% setiap klik untuk demo
        int newProgress = (currentProgress + 10).clamp(0, 100);
        await questRef.update({'progress': newProgress});

        // Beri reward kecil ke pahlawan karena berkontribusi
        hero.xp += 20;
        hero.gold += 10;
        _checkLevelUp();
        saveHero();

        if (newProgress >= 100) {
          addNotification('Quest Selesai! 🏆', 'Quest "${data['title']}" telah berhasil diselesaikan oleh Party!', '👑');
        } else {
          addNotification('Kontribusi Quest', 'Kamu berkontribusi pada "${data['title']}"! (+20 XP, +10 Gold)', '⚔️');
        }
        notifyListeners();
      }
    }
  }
}

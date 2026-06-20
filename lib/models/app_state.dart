import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../services/audio_service.dart';
import '../models/models.dart';
import 'dart:async';

class AppState extends ChangeNotifier {
  // Real-time stream subscriptions
  StreamSubscription<DocumentSnapshot>? _currentUserSubscription;
  StreamSubscription<QuerySnapshot>? _publicProfilesSubscription;
  StreamSubscription<DocumentSnapshot>? _partySubscription;
  StreamSubscription<QuerySnapshot>? _invitesSubscription;
  StreamSubscription<QuerySnapshot>? _globalQuestsSubscription;
  StreamSubscription<QuerySnapshot>? _globalBossesSubscription;
  StreamSubscription<QuerySnapshot>? _shopItemsSubscription;
  StreamSubscription<QuerySnapshot>? _broadcastsSubscription;
  // Agar broadcast lama tidak muncul lagi sebagai notifikasi tiap login.
  bool _broadcastsInit = false;

  // Party state fields
  String? partyId;
  String? partyName;
  bool isPartyLeader = false;
  List<PartyMember> allUsers = [];
  List<Map<String, dynamic>> pendingInvites = [];
  List<String> partyMemberIds = [];

  HeroModel hero = HeroModel(
    name: 'Novice Hero',
    heroClass: HeroClass.warrior,
    level: 1,
    hp: 150,
    maxHp: 150,
    xp: 0,
    maxXp: 100,
    mp: 100,
    maxMp: 100,
    gold: 0,
    gems: 0,
    streak: 0,
    momentum: 0,
    intelligence: 0,
    strength: 0,
    creativity: 0,
    knowledge: 0,
    focus: 0,
    totalTasksCompleted: 0,
    totalQuestsCompleted: 0,
  );

  String username = '';
  String fullName = '';
  String phone = '';

  List<HabitModel> habits = [];
  List<TaskModel> dailyTasks = [];
  List<TaskModel> todos = [];
  List<QuestModel> quests = [];

  List<ShopItem> shopItems = [
    ShopItem(id: 's1', name: 'Iron Sword', description: '+15 ATK · Pedang standar prajurit.', emoji: '🗡️', price: 80, category: ItemCategory.weapon, rarity: ItemRarity.common, bonuses: {'atk': 15}),
    ShopItem(id: 's2', name: 'Study Shield', description: '+20 DEF · Melindungi dari deadline.', emoji: '🛡️', price: 120, category: ItemCategory.armor, rarity: ItemRarity.rare, bonuses: {'def': 20}),
    ShopItem(id: 's3', name: 'HP Potion', description: 'Restore 30 HP', emoji: '🧪', price: 50, category: ItemCategory.potion, rarity: ItemRarity.common),
    ShopItem(id: 's4', name: 'XP Scroll', description: '+100 XP instan', emoji: '📜', price: 200, category: ItemCategory.potion, rarity: ItemRarity.rare),
    ShopItem(id: 's5', name: 'Wizard Hat', description: '+25 Mana · Topi penyihir bintang.', emoji: '🧙', price: 250, category: ItemCategory.armor, rarity: ItemRarity.epic, bonuses: {'mp': 25}),
    ShopItem(id: 's6', name: 'Excalibur', description: '+100 ATK · Pedang legendaris.', emoji: '⚔️', price: 1500, category: ItemCategory.weapon, rarity: ItemRarity.legendary, bonuses: {'atk': 100}),
    ShopItem(id: 's7', name: 'Titan Ring', description: '+10 Strength · Cincin raksasa.', emoji: '💍', price: 400, category: ItemCategory.accessory, rarity: ItemRarity.rare, bonuses: {'atk': 10, 'def': 10}),
    ShopItem(id: 's8', name: 'Coffee Cup', description: 'Anti-Sleep · Restore 15 MP', emoji: '☕', price: 30, category: ItemCategory.potion, rarity: ItemRarity.common),
  ];

  int get extraAtk => shopItems.where((i) => i.isEquipped).fold(0, (total, i) => total + (i.bonuses['atk'] ?? 0));
  int get extraDef => shopItems.where((i) => i.isEquipped).fold(0, (total, i) => total + (i.bonuses['def'] ?? 0));
  List<PartyMember> partyMembers = [];

  // Global Quests (for Admin Content management & User views)
  List<QuestModel> globalQuests = [
    QuestModel(id: 'gq1', title: 'UTS Pemrograman Mobile', progress: 100, xpReward: 200, timeLeft: '3 Hari Tersisa', isBoss: false),
    QuestModel(id: 'gq2', title: 'Laporan Praktikum Jaringan', progress: 100, xpReward: 150, timeLeft: '5 Hari Tersisa', isBoss: false),
    QuestModel(id: 'gq3', title: 'Quiz Basis Data', progress: 0, xpReward: 100, timeLeft: 'Draft', isBoss: false),
    QuestModel(id: 'gq4', title: 'Project Akhir RPL', progress: 100, xpReward: 500, timeLeft: '14 Hari Tersisa', isBoss: false),
  ];

  // Global Bosses
  List<QuestModel> globalBosses = [
    QuestModel(id: 'gb1', title: 'Deadline Boss Lv.3', progress: 70, xpReward: 500, timeLeft: '3 Party', isBoss: true),
    QuestModel(id: 'gb2', title: 'UTS Boss Lv.2', progress: 53, xpReward: 350, timeLeft: '2 Party', isBoss: true),
    QuestModel(id: 'gb3', title: 'Final Project Boss Lv.5', progress: 0, xpReward: 1000, timeLeft: 'Draft', isBoss: true),
  ];

  void addGlobalQuest(QuestModel q) {
    FirebaseFirestore.instance.collection('global_quests').doc(q.id).set(q.toMap());
  }

  void updateGlobalQuest(String id, String title, int xp) {
    FirebaseFirestore.instance.collection('global_quests').doc(id).update({
      'title': title,
      'xpReward': xp,
    });
  }

  void deleteGlobalQuest(String id) {
    FirebaseFirestore.instance.collection('global_quests').doc(id).delete();
  }

  void toggleGlobalQuest(String id) {
    final idx = globalQuests.indexWhere((q) => q.id == id);
    if (idx != -1) {
      final newProg = globalQuests[idx].progress == 0 ? 100 : 0;
      FirebaseFirestore.instance.collection('global_quests').doc(id).update({
        'progress': newProg,
      });
    }
  }

  void addGlobalBoss(QuestModel b) {
    FirebaseFirestore.instance.collection('global_bosses').doc(b.id).set(b.toMap());
  }

  void updateGlobalBoss(String id, String title, int xp) {
    FirebaseFirestore.instance.collection('global_bosses').doc(id).update({
      'title': title,
      'xpReward': xp,
    });
  }

  void deleteGlobalBoss(String id) {
    FirebaseFirestore.instance.collection('global_bosses').doc(id).delete();
  }

  void toggleGlobalBoss(String id) {
    final idx = globalBosses.indexWhere((b) => b.id == id);
    if (idx != -1) {
      final newProg = globalBosses[idx].progress == 0 ? 100 : 0;
      FirebaseFirestore.instance.collection('global_bosses').doc(id).update({
        'progress': newProg,
      });
    }
  }

  void addShopItem(ShopItem item) {
    FirebaseFirestore.instance.collection('shop_items').doc(item.id).set(item.toMap());
  }

  void updateShopItem(String id, String name, int price) {
    FirebaseFirestore.instance.collection('shop_items').doc(id).update({
      'name': name,
      'price': price,
    });
  }

  void deleteShopItem(String id) {
    FirebaseFirestore.instance.collection('shop_items').doc(id).delete();
  }

  void toggleShopItem(String id) {
    final idx = shopItems.indexWhere((i) => i.id == id);
    if (idx != -1) {
      final newOwned = !shopItems[idx].owned;
      FirebaseFirestore.instance.collection('shop_items').doc(id).update({
        'owned': newOwned,
      });
    }
  }

  // Admin: kirim pengumuman ke semua user. Tertulis ke koleksi 'broadcasts';
  // setiap perangkat yang online menampilkannya sebagai notifikasi real-time.
  void sendBroadcast(String message) {
    FirebaseFirestore.instance.collection('broadcasts').add({
      'message': message,
      'by': fullName.isNotEmpty ? fullName : 'Admin',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // User: kirim laporan/keluhan ke admin (collection 'reports'). Admin membaca
  // & menindaklanjuti di panel Statistik → Laporan Masuk.
  Future<void> submitReport(String category, String message) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance.collection('reports').add({
        'uid': user.uid,
        'reporterName': fullName.isNotEmpty
            ? fullName
            : (username.isNotEmpty ? username : 'User'),
        'category': category,
        'message': message,
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
      });
      addNotification('Laporan terkirim ke admin. Terima kasih!');
    } catch (e) {
      addNotification('Gagal mengirim laporan: $e');
    }
  }

  // In-app notifications
  List<String> notifications = [];
  List<String> notificationHistory = [];
  bool hasUnreadNotifications = false;
  bool hasClaimedDaily = false;
  // Tanggal (yyyy-MM-dd) terakhir Daily di-reset. null = belum pernah.
  String? lastDailyReset;
  // Tanggal (yyyy-MM-dd) terakhir hadiah harian di-klaim. Dipakai untuk
  // menentukan apakah streak berlanjut (klaim kemarin) atau mulai dari 1.
  String? lastClaimDate;
  List<String> completedGlobalQuests = [];
  // Boss yang BENAR-BENAR diserang user ini (per-perangkat). XP boss hanya
  // diberikan ke peserta — bukan ke siapa pun yang kebetulan online saat boss
  // mati. Disimpan agar tahan restart. Lihat [attackGlobalBoss] & listener boss.
  List<String> attackedBosses = [];
  // Inventory milik user ini (per-akun). Dulu status owned/equipped menempel di
  // koleksi GLOBAL shop_items (dibagi semua user & tidak ikut tersimpan) →
  // pembelian hilang saat restart. Kini disimpan di dokumen user.
  List<String> ownedItemIds = [];
  List<String> equippedItemIds = [];

  bool _isDarkMode = true;
  bool _isMusicOn = true;
  bool _isSfxOn = true;

  bool get isDarkMode => _isDarkMode;
  bool get isMusicOn => _isMusicOn;
  bool get isSfxOn => _isSfxOn;

  AppState() {
    _loadSettings();
    // Listen to Firebase Auth state changes
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        loadFromFirestore();
      } else {
        // Reset state on logout
        _currentUserSubscription?.cancel();
        _currentUserSubscription = null;
        _publicProfilesSubscription?.cancel();
        _publicProfilesSubscription = null;
        _partySubscription?.cancel();
        _partySubscription = null;
        _invitesSubscription?.cancel();
        _invitesSubscription = null;
        _globalQuestsSubscription?.cancel();
        _globalQuestsSubscription = null;
        _globalBossesSubscription?.cancel();
        _globalBossesSubscription = null;
        _shopItemsSubscription?.cancel();
        _shopItemsSubscription = null;
        _broadcastsSubscription?.cancel();
        _broadcastsSubscription = null;
        _broadcastsInit = false;

        partyId = null;
        partyName = null;
        isPartyLeader = false;
        partyMembers = [];
        allUsers = [];
        pendingInvites = [];
        partyMemberIds = [];

        hero = HeroModel(
          name: 'Novice Hero',
          heroClass: HeroClass.warrior,
          level: 1,
          hp: 150,
          maxHp: 150,
          xp: 0,
          maxXp: 100,
          mp: 100,
          maxMp: 100,
          gold: 0,
          gems: 0,
          streak: 0,
          momentum: 0,
          intelligence: 0,
          strength: 0,
          creativity: 0,
          knowledge: 0,
          focus: 0,
          totalTasksCompleted: 0,
          totalQuestsCompleted: 0,
        );
        username = '';
        fullName = '';
        phone = '';
        habits = [];
        dailyTasks = [];
        todos = [];
        quests = [];
        hasClaimedDaily = false;
        lastDailyReset = null;
        lastClaimDate = null;
        completedGlobalQuests = [];
        attackedBosses = [];
        ownedItemIds = [];
        equippedItemIds = [];
        notifyListeners();
      }
    });
  }

  void addNotification(String msg) {
    notifications.add(msg);
    notificationHistory.insert(0, msg);
    if (notificationHistory.length > 30) {
      notificationHistory.removeLast();
    }
    hasUnreadNotifications = true;
    notifyListeners();
    Future.delayed(const Duration(seconds: 3), () {
      notifications.remove(msg);
      notifyListeners();
    });
  }

  void clearNotifications() {
    notificationHistory.clear();
    hasUnreadNotifications = false;
    notifyListeners();
  }

  void markNotificationsAsRead() {
    hasUnreadNotifications = false;
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('isDarkMode') ?? true;
      AppColors.isDarkMode = _isDarkMode;
      _isMusicOn = prefs.getBool('isMusicOn') ?? true;
      _isSfxOn = prefs.getBool('isSfxOn') ?? true;
      if (_isMusicOn) {
        AudioHelper.startBgm();
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading settings: $e");
    }
  }

  Future<void> setDarkMode(bool val) async {
    _isDarkMode = val;
    AppColors.isDarkMode = val;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', val);
  }

  Future<void> setMusicOn(bool val) async {
    _isMusicOn = val;
    if (val) {
      AudioHelper.startBgm();
    } else {
      AudioHelper.stopBgm();
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isMusicOn', val);
  }

  Future<void> setSfxOn(bool val) async {
    _isSfxOn = val;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSfxOn', val);
  }

  double get momentumMultiplier {
    if (hero.momentum >= 80) return 1.5;
    if (hero.momentum >= 50) return 1.25;
    return 1.0;
  }

  // ── Firestore Sync ───────────────────────────────────────────────────

  Future<void> saveToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'username': username,
        'fullName': fullName,
        'phone': phone,
        'hero': hero.toMap(),
        'habits': habits.map((h) => h.toMap()).toList(),
        'dailyTasks': dailyTasks.map((t) => t.toMap()).toList(),
        'todos': todos.map((t) => t.toMap()).toList(),
        'quests': quests.map((q) => q.toMap()).toList(),
        'hasClaimedDaily': hasClaimedDaily,
        'lastDailyReset': lastDailyReset,
        'lastClaimDate': lastClaimDate,
        'completedGlobalQuests': completedGlobalQuests,
        'attackedBosses': attackedBosses,
        'ownedItemIds': ownedItemIds,
        'equippedItemIds': equippedItemIds,
        'partyId': partyId ?? FieldValue.delete(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error saving to Firestore: $e");
    }
  }

  // Cermin publik dari profil + stat hero untuk leaderboard & party. Sengaja
  // TANPA email/telepon. Merupakan proyeksi dari dokumen user; ditulis ulang
  // setiap dokumen user berubah agar selalu sinkron.
  Future<void> _savePublicProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('public_profiles')
          .doc(user.uid)
          .set({
        'fullName': fullName,
        'username': username,
        'heroClass': hero.heroClass.name,
        'level': hero.level,
        // XP total lintas level agar urutan leaderboard benar.
        'xp': (hero.level - 1) * 100 + hero.xp,
        'streak': hero.streak,
      });
    } catch (e) {
      debugPrint("Error saving public profile: $e");
    }
  }

  Future<void> loadFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _currentUserSubscription?.cancel();
    _publicProfilesSubscription?.cancel();
    _partySubscription?.cancel();
    _invitesSubscription?.cancel();
    _globalQuestsSubscription?.cancel();
    _globalBossesSubscription?.cancel();
    _shopItemsSubscription?.cancel();
    _broadcastsSubscription?.cancel();
    _broadcastsInit = false;

    // 1. Subscribe to the current user's document
    _currentUserSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          final isBanned = (data['isBanned'] ?? false) as bool;
          if (isBanned) {
            FirebaseAuth.instance.signOut();
            addNotification("Akun Anda diblokir oleh admin!");
            return;
          }

          username = data['username'] ?? '';
          fullName = data['fullName'] ?? '';
          phone = data['phone'] ?? '';

          final newPartyId = data['partyId'] as String?;
          if (newPartyId != partyId) {
            partyId = newPartyId;
            _setupPartySubscription(user.uid);
          }

          if (data['hero'] != null) {
            hero = HeroModel.fromMap(Map<String, dynamic>.from(data['hero']));
            _checkLevelUp();
            _migrateLegacySkills();
          }
          if (data['habits'] != null) {
            habits = (data['habits'] as List)
                .map((h) => HabitModel.fromMap(Map<String, dynamic>.from(h)))
                .toList();
          }
          if (data['dailyTasks'] != null) {
            dailyTasks = (data['dailyTasks'] as List)
                .map((t) => TaskModel.fromMap(Map<String, dynamic>.from(t)))
                .toList();
          }
          if (data['todos'] != null) {
            todos = (data['todos'] as List)
                .map((t) => TaskModel.fromMap(Map<String, dynamic>.from(t)))
                .toList();
          }
          if (data['quests'] != null) {
            quests = (data['quests'] as List)
                .map((q) => QuestModel.fromMap(Map<String, dynamic>.from(q)))
                .where((q) => !q.isBoss)
                .toList();
          } else {
            // Default Quest if empty
            quests = [
              QuestModel(id: 'q1', title: 'Selesaikan 5 Tugas Hari Ini', progress: 0, xpReward: 150, timeLeft: '12 Jam Tersisa', isBoss: false),
            ];
          }
          hasClaimedDaily = data['hasClaimedDaily'] ?? false;
          lastDailyReset = data['lastDailyReset'] as String?;
          lastClaimDate = data['lastClaimDate'] as String?;
          if (data['completedGlobalQuests'] != null) {
            completedGlobalQuests = List<String>.from(data['completedGlobalQuests']);
          } else {
            completedGlobalQuests = [];
          }
          attackedBosses = data['attackedBosses'] != null
              ? List<String>.from(data['attackedBosses'])
              : [];
          ownedItemIds = data['ownedItemIds'] != null
              ? List<String>.from(data['ownedItemIds'])
              : [];
          equippedItemIds = data['equippedItemIds'] != null
              ? List<String>.from(data['equippedItemIds'])
              : [];
          _applyInventoryToShopItems();
          _maybeResetDailies();
          _syncGlobalQuestsToUser();
          _savePublicProfile();
          notifyListeners();
        }
      } else {
        // Document doesn't exist yet, populate with default quests
        quests = [
          QuestModel(id: 'q1', title: 'Selesaikan 5 Tugas Hari Ini', progress: 0, xpReward: 150, timeLeft: '12 Jam Tersisa', isBoss: false),
        ];
        saveToFirestore();
      }
    }, onError: (e) {
      debugPrint("Error loading user doc: $e");
    });

    // 2. Subscribe to public profiles for the leaderboard & party list.
    //    Hanya berisi nama + stat hero (tanpa email/telepon), jadi aman dibaca
    //    semua user. Dokumen user lengkap kini tertutup untuk non-pemilik.
    _publicProfilesSubscription = FirebaseFirestore.instance
        .collection('public_profiles')
        .snapshots()
        .listen((snapshot) {
      final List<PartyMember> members = [];
      for (var pDoc in snapshot.docs) {
        final data = pDoc.data();
        final fullNameVal = (data['fullName'] ?? '').toString();
        final usernameVal = (data['username'] ?? '').toString();
        final name = fullNameVal.isNotEmpty
            ? fullNameVal
            : (usernameVal.isNotEmpty ? usernameVal : 'Hero');

        HeroClass parsedClass = HeroClass.warrior;
        try {
          parsedClass = HeroClass.values.firstWhere((e) => e.name == data['heroClass']);
        } catch (_) {}

        members.add(PartyMember(
          uid: pDoc.id,
          name: name,
          heroClass: parsedClass,
          level: ((data['level'] ?? 1) as num).toInt(),
          xp: ((data['xp'] ?? 0) as num).toInt(),
          streak: ((data['streak'] ?? 0) as num).toInt(),
          avatarColor: parsedClass == HeroClass.warrior
              ? AppColors.accent
              : (parsedClass == HeroClass.mage
                  ? const Color(0xFF185FA5)
                  : (parsedClass == HeroClass.healer ? const Color(0xFF0F6E56) : const Color(0xFF854F0B))),
        ));
      }
      allUsers = members;
      _updatePartyMembersList();
    }, onError: (e) {
      debugPrint("Error loading public profiles: $e");
    });

    // 3. Subscribe to invites
    _invitesSubscription = FirebaseFirestore.instance
        .collection('parties')
        .where('invitedIds', arrayContains: user.uid)
        .snapshots()
        .listen((snapshot) {
      final List<Map<String, dynamic>> invites = [];
      for (var doc in snapshot.docs) {
        invites.add({
          'partyId': doc.id,
          'name': doc.data()['name'] ?? 'Unnamed Party',
          'leaderId': doc.data()['leaderId'] ?? '',
        });
      }
      pendingInvites = invites;
      notifyListeners();
    }, onError: (e) {
      debugPrint("Error loading invites: $e");
    });

    // 4. Subscribe to global quests
    _globalQuestsSubscription = FirebaseFirestore.instance
        .collection('global_quests')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        globalQuests = snapshot.docs.map((doc) => QuestModel.fromMap(doc.data(), doc.id)).toList();
      } else {
        _populateDefaultGlobalQuests();
      }
      _syncGlobalQuestsToUser();
      notifyListeners();
    }, onError: (e) {
      debugPrint("Error loading global quests: $e");
    });

    // 5. Subscribe to global bosses
    _globalBossesSubscription = FirebaseFirestore.instance
        .collection('global_bosses')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final newBosses = snapshot.docs.map((doc) => QuestModel.fromMap(doc.data(), doc.id)).toList();
        bool changed = false;

        for (var newB in newBosses) {
          final oldIdx = globalBosses.indexWhere((b) => b.id == newB.id);
          if (oldIdx == -1) continue; // boss baru, belum ada transisi untuk dinilai
          final oldB = globalBosses[oldIdx];

          // Admin mengaktifkan boss lagi → buka kembali kesempatan award.
          if (oldB.progress <= 0 && newB.progress > 0) {
            completedGlobalQuests.remove(newB.id);
          }

          // Boss dikalahkan: HANYA user yang benar-benar menyerang yang dapat XP,
          // dan hanya sekali. Mencegah XP "hantu" saat login (boss yang sudah mati
          // sebelum user join) dan free-rider yang cuma online.
          if (oldB.progress > 0 &&
              newB.progress <= 0 &&
              attackedBosses.contains(newB.id) &&
              !completedGlobalQuests.contains(newB.id)) {
            completedGlobalQuests.add(newB.id);
            attackedBosses = List<String>.from(attackedBosses)..remove(newB.id);
            addNotification("Boss ${newB.title} Berhasil Dikalahkan! (+${newB.xpReward} XP)");
            _applyXp(newB.xpReward);
            changed = true;
          }
        }

        globalBosses = newBosses;
        if (changed) saveToFirestore();
      } else {
        _populateDefaultGlobalBosses();
      }
      notifyListeners();
    }, onError: (e) {
      debugPrint("Error loading global bosses: $e");
    });

    // 6. Subscribe to shop items
    _shopItemsSubscription = FirebaseFirestore.instance
        .collection('shop_items')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        shopItems = snapshot.docs.map((doc) => ShopItem.fromMap(doc.data(), doc.id)).toList();
        // Katalog global tidak menyimpan owned/equipped per-user; ambil dari
        // dokumen user agar inventory milik pribadi, bukan dibagi semua orang.
        _applyInventoryToShopItems();
      } else {
        _populateDefaultShopItems();
      }
      notifyListeners();
    }, onError: (e) {
      debugPrint("Error loading shop items: $e");
    });

    // 7. Subscribe to admin broadcasts → muncul sebagai notifikasi ke user.
    _broadcastsSubscription = FirebaseFirestore.instance
        .collection('broadcasts')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .listen((snapshot) {
      // Lewati snapshot pertama agar broadcast lama tidak muncul lagi saat login.
      if (!_broadcastsInit) {
        _broadcastsInit = true;
        return;
      }
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final msg = (change.doc.data()?['message'] ?? '').toString();
          if (msg.isNotEmpty) addNotification('Broadcast: $msg');
        }
      }
    }, onError: (e) {
      debugPrint("Error loading broadcasts: $e");
    });
  }

  void _setupPartySubscription(String currentUserId) {
    _partySubscription?.cancel();
    _partySubscription = null;

    if (partyId == null || partyId!.isEmpty) {
      partyName = null;
      isPartyLeader = false;
      partyMemberIds = [];
      partyMembers = [];
      notifyListeners();
      return;
    }

    _partySubscription = FirebaseFirestore.instance
        .collection('parties')
        .doc(partyId)
        .snapshots()
        .listen((partyDoc) {
      if (partyDoc.exists) {
        final partyData = partyDoc.data();
        if (partyData != null) {
          final memberIds = List<String>.from(partyData['memberIds'] ?? []);

          // Dikeluarkan leader: user ini tak lagi terdaftar sebagai anggota.
          // Bersihkan partyId DI DOKUMEN SENDIRI — aturan keamanan melarang leader
          // menulis dokumen user lain, jadi korban yang membersihkan sendiri.
          if (!memberIds.contains(currentUserId)) {
            _clearOwnPartyId();
            return;
          }

          partyName = partyData['name'] ?? 'No Name';
          final leaderId = partyData['leaderId'] ?? '';
          isPartyLeader = (leaderId == currentUserId);
          partyMemberIds = memberIds;
          _updatePartyMembersList();
        }
      } else {
        // Party dibubarkan leader: dokumennya hilang → bersihkan partyId sendiri.
        _clearOwnPartyId();
      }
    }, onError: (e) {
      debugPrint("Error loading party doc: $e");
    });
  }

  // Membersihkan partyId milik user ini (lokal + Firestore) saat ia dikeluarkan
  // atau party dibubarkan. Owner boleh menulis dokumennya sendiri, jadi ini lolos
  // aturan keamanan — beda dengan leader yang tak boleh menyentuh dokumen lain.
  Future<void> _clearOwnPartyId() async {
    final user = FirebaseAuth.instance.currentUser;
    _partySubscription?.cancel();
    _partySubscription = null;
    partyId = null;
    partyName = null;
    isPartyLeader = false;
    partyMemberIds = [];
    partyMembers = [];
    notifyListeners();
    if (user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'partyId': FieldValue.delete()});
    } catch (e) {
      debugPrint("Error clearing own partyId: $e");
    }
  }

  void _syncGlobalQuestsToUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    bool updated = false;

    // 1. Remove user-copied global quests that are no longer active/deleted by admin
    final originalCount = quests.length;
    quests.removeWhere((q) {
      final isGlobal = globalQuests.any((gq) => gq.id == q.id);
      if (isGlobal) {
        final isActive = globalQuests.any((gq) => gq.id == q.id && gq.progress > 0);
        return !isActive;
      }
      return false;
    });
    if (quests.length != originalCount) {
      updated = true;
    }

    // 2. Add active global quests that are not yet in the user's quests list
    final activeGlobalQuests = globalQuests.where((gq) => gq.progress > 0 && !gq.isBoss).toList();
    for (var gq in activeGlobalQuests) {
      if (!quests.any((q) => q.id == gq.id)) {
        quests.add(QuestModel(
          id: gq.id,
          title: gq.title,
          progress: 0,
          xpReward: gq.xpReward,
          timeLeft: gq.timeLeft,
          isBoss: gq.isBoss,
        ));
        updated = true;
      }
    }

    // 3. Update title/xpReward of existing copied global quests if they changed in the admin panel
    for (var i = 0; i < quests.length; i++) {
      final q = quests[i];
      try {
        final gq = globalQuests.firstWhere((g) => g.id == q.id);
        if (q.title != gq.title || q.xpReward != gq.xpReward || q.timeLeft != gq.timeLeft) {
          quests[i] = QuestModel(
            id: q.id,
            title: gq.title,
            progress: q.progress,
            xpReward: gq.xpReward,
            timeLeft: gq.timeLeft,
            isBoss: gq.isBoss,
          );
          updated = true;
        }
      } catch (_) {}
    }

    if (updated) {
      saveToFirestore();
    }
  }

  void _updatePartyMembersList() {
    final List<PartyMember> members = [];
    for (var uid in partyMemberIds) {
      try {
        final u = allUsers.firstWhere((user) => user.uid == uid);
        members.add(u);
      } catch (_) {}
    }
    partyMembers = members;
    notifyListeners();
  }

  // ── Daily rollover & migrasi ─────────────────────────────────────────

  // Kunci tanggal lokal (yyyy-MM-dd) untuk mendeteksi pergantian hari.
  String _todayKey() => _dateKey(DateTime.now());

  String _dateKey(DateTime n) {
    final m = n.month.toString().padLeft(2, '0');
    final d = n.day.toString().padLeft(2, '0');
    return '${n.year}-$m-$d';
  }

  // Reset status "selesai" semua Daily saat hari berganti, sehingga tipe Daily
  // benar-benar berulang. Hadiah login harian juga dibuka kembali.
  void _maybeResetDailies() {
    final today = _todayKey();

    // Pengguna lama / sesi pertama: tandai hari ini tanpa menghapus progres.
    if (lastDailyReset == null) {
      lastDailyReset = today;
      saveToFirestore();
      return;
    }

    if (lastDailyReset == today) return;

    for (final t in dailyTasks) {
      t.isDone = false;
      t.grantedXp = 0;
      t.grantedGold = 0;
    }
    hasClaimedDaily = false;
    lastDailyReset = today;
    addNotification("Hari baru - Daily-mu sudah di-reset!");
    saveToFirestore();
  }

  // Lebur nilai lama Knowledge & Focus ke Intelligence (atribut tunggal kini).
  // Dijalankan sekali saat load; setelahnya kedua field selalu 0.
  void _migrateLegacySkills() {
    if (hero.knowledge != 0 || hero.focus != 0) {
      hero.intelligence += hero.knowledge + hero.focus;
      hero.knowledge = 0;
      hero.focus = 0;
      saveToFirestore();
    }
  }

  // ── Actions ──────────────────────────────────────────────────────────

  void claimDailyReward() {
    if (hasClaimedDaily) return;

    if (_isSfxOn) {
      AudioHelper.playSfx();
    }

    // Streak hanya berlanjut bila klaim terakhir tepat kemarin; bila ada hari
    // yang terlewat (atau klaim pertama), streak dimulai lagi dari 1.
    final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));
    hero.streak = (lastClaimDate == yesterday) ? hero.streak + 1 : 1;
    lastClaimDate = _todayKey();
    hasClaimedDaily = true;

    final int goldReward = hero.streak * 15;
    final int gemReward = (hero.streak % 7 == 0) ? 5 : 1;
    hero.gold += goldReward;
    hero.gems += gemReward;
    hero.momentum = (hero.momentum + 20).clamp(0, 100);

    addNotification("Daily Streak Claimed (+${hero.streak} Days)!");
    addNotification("+$goldReward Gold / +$gemReward Gems");
    addNotification("Momentum Restored!");

    notifyListeners();
    saveToFirestore();
  }

  void resetDailyClaim() {
    hasClaimedDaily = false;
    notifyListeners();
    saveToFirestore();
  }

  // Dipakai saat load data: normalisasi xp yang mungkin tersimpan >= 100.
  void _checkLevelUp() {
    bool leveledUp = false;
    while (hero.xp >= 100) {
      hero.xp -= 100;
      hero.level += 1;
      leveledUp = true;
    }
    if (leveledUp) {
      hero.maxXp = 100;
      hero.maxHp = 150;
      hero.hp = 150;
      hero.maxMp = 100;
      hero.mp = 100;
      addNotification("LEVEL UP! Reached Level ${hero.level}");
      saveToFirestore();
    }
  }

  /// Menambah/mengurangi XP dengan benar — level ikut naik DAN turun.
  /// Mencegah bug XP jadi 0 / level nyangkut saat task di-cancel.
  void _applyXp(int delta) {
    // Total XP terkumpul lintas level (Lv.1 = 0..99, Lv.2 mulai dari 100, dst).
    final currentTotal = (hero.level - 1) * 100 + hero.xp;
    var total = currentTotal + delta;
    if (total < 0) total = 0;

    final newLevel = 1 + (total ~/ 100);
    final leveledUp = newLevel > hero.level;

    hero.level = newLevel;
    hero.xp = total % 100;
    hero.maxXp = 100;

    if (leveledUp) {
      hero.maxHp = 150;
      hero.hp = 150;
      hero.maxMp = 100;
      hero.mp = 100;
      addNotification("LEVEL UP! Reached Level ${hero.level}");
    }
  }

  void _incrementSkill(SkillAttribute attr) {
    switch (attr) {
      case SkillAttribute.intelligence: hero.intelligence += 1; break;
      case SkillAttribute.strength: hero.strength += 1; break;
      case SkillAttribute.creativity: hero.creativity += 1; break;
    }
  }

  void _decrementSkill(SkillAttribute attr) {
    switch (attr) {
      case SkillAttribute.intelligence: hero.intelligence = (hero.intelligence - 1).clamp(0, 9999); break;
      case SkillAttribute.strength: hero.strength = (hero.strength - 1).clamp(0, 9999); break;
      case SkillAttribute.creativity: hero.creativity = (hero.creativity - 1).clamp(0, 9999); break;
    }
  }

  // Memajukan satu quest (+20%) saat sebuah task diselesaikan, sambil mencatat
  // PADA task quest mana yang dimajukan — agar bisa dikembalikan persis bila
  // ceklis dibatalkan. Tanpa ini, ceklis→batal→ceklis berulang bisa di-"farm".
  void _updateQuestProgress(TaskModel task) {
    for (var q in quests) {
      if (q.progress < 100) {
        q.progress = (q.progress + 20).clamp(0, 100);
        task.grantedQuestId = q.id;
        addNotification("Quest Progress Updated");
        if (q.progress >= 100) {
          hero.totalQuestsCompleted += 1;
          task.grantedQuestCompleted = true;
          addNotification("Quest Completed: ${q.title}");
          _applyXp(q.xpReward);
        }
        break;
      }
    }
  }

  // Kebalikan persis dari [_updateQuestProgress] saat ceklis task dibatalkan.
  void _reverseQuestProgress(TaskModel task) {
    final qid = task.grantedQuestId;
    if (qid == null) return;
    final idx = quests.indexWhere((q) => q.id == qid);
    if (idx != -1) {
      final q = quests[idx];
      if (task.grantedQuestCompleted) {
        hero.totalQuestsCompleted = (hero.totalQuestsCompleted - 1).clamp(0, 999999);
        _applyXp(-q.xpReward);
      }
      q.progress = (q.progress - 20).clamp(0, 100);
    }
    task.grantedQuestId = null;
    task.grantedQuestCompleted = false;
  }

  void progressQuest(String id) {
    final idx = quests.indexWhere((q) => q.id == id);
    if (idx != -1) {
      final q = quests[idx];
      if (q.progress < 100) {
        q.progress = (q.progress + 20).clamp(0, 100);
        addNotification("Progres Quest '${q.title}' bertambah (+20%)");
        if (q.progress >= 100) {
          hero.totalQuestsCompleted += 1;
          addNotification("Quest Selesai: ${q.title} (+${q.xpReward} XP)");
          _applyXp(q.xpReward);
        }
        notifyListeners();
        saveToFirestore();
      } else {
        addNotification("Quest '${q.title}' sudah selesai!");
      }
    }
  }

  void attackGlobalBoss(String id) {
    final idx = globalBosses.indexWhere((b) => b.id == id);
    if (idx == -1) return;

    final b = globalBosses[idx];
    if (b.progress <= 0) {
      addNotification("Boss ${b.title} sudah dikalahkan!");
      return;
    }

    // Progres boss bersama: aturan Firestore mengizinkan setiap user mengubah
    // field 'progress' ini.
    final newProg = (b.progress - 10).clamp(0, 100);
    FirebaseFirestore.instance.collection('global_bosses').doc(id).update({
      'progress': newProg,
    });

    // Tandai user ini sebagai peserta → syarat menerima XP saat boss tumbang.
    if (!attackedBosses.contains(id)) {
      attackedBosses = List<String>.from(attackedBosses)..add(id);
    }

    // Boss menyerang balik: HP penyerang berkurang. Setiap anggota party
    // menyerang dari perangkatnya sendiri sehingga HP-nya berkurang sendiri —
    // aturan Firestore tidak mengizinkan satu user menulis HP user lain.
    hero.hp = (hero.hp - 10).clamp(0, hero.maxHp);
    addNotification("Menyerang ${b.title}! HP-mu berkurang (-10)");

    notifyListeners();
    saveToFirestore();
  }

  void toggleTask(TaskModel task) {
    task.isDone = !task.isDone;

    if (task.isDone) {
      if (_isSfxOn) {
        AudioHelper.playSfx();
      }
      final double mult = momentumMultiplier;
      final int xpGained = (task.xpReward * mult).toInt();
      final int goldGained = (task.goldReward * mult).toInt();

      // Catat reward aktual agar bisa dikembalikan persis saat ceklis dibatalkan.
      task.grantedXp = xpGained;
      task.grantedGold = goldGained;

      hero.gold += goldGained;
      hero.totalTasksCompleted += 1;
      hero.momentum = (hero.momentum + 15).clamp(0, 100);

      _incrementSkill(task.attribute);
      _applyXp(xpGained);
      _updateQuestProgress(task);

      addNotification("XP Gained (x$mult bonus!)");
      addNotification("Gravity Resistance Increased");
    } else {
      // Kembalikan tepat sebanyak yang dulu diberikan — bukan dihitung ulang
      // dengan multiplier momentum yang mungkin sudah berbeda.
      _applyXp(-task.grantedXp);
      hero.gold = (hero.gold - task.grantedGold).clamp(0, 999999);
      hero.totalTasksCompleted = (hero.totalTasksCompleted - 1).clamp(0, 999999);
      hero.momentum = (hero.momentum - 15).clamp(0, 100);

      _decrementSkill(task.attribute);
      _reverseQuestProgress(task);

      task.grantedXp = 0;
      task.grantedGold = 0;
    }
    notifyListeners();
    saveToFirestore();
  }

  void doHabit(HabitModel habit, bool positive) {
    double mult = momentumMultiplier;
    if (positive) {
      if (_isSfxOn) {
        AudioHelper.playSfx();
      }
      int xpGained = (habit.xpReward * mult).toInt();
      hero.gold += 5;
      habit.streak++;
      hero.momentum = (hero.momentum + 8).clamp(0, 100);

      _incrementSkill(habit.attribute);
      _applyXp(xpGained);

      addNotification("XP Increased!");
      addNotification("Habit Streak Up!");
    } else {
      hero.hp = (hero.hp - 6).clamp(0, hero.maxHp);
      hero.momentum = (hero.momentum - 20).clamp(0, 100);
      habit.streak = 0;

      addNotification("Health Reduced!");
      addNotification("Momentum Lost!");
    }
    notifyListeners();
    saveToFirestore();
  }

  // Reward setelah menyelesaikan satu sesi Focus Mode.
  void completeFocusSession() {
    hero.gold += 20;
    hero.intelligence += 5; // dulu menambah 'focus' (kini dilebur ke Intelligence)
    _applyXp(50);
    addNotification("Focus Session Complete! (+50 XP / +20G)");
    notifyListeners();
    saveToFirestore();
  }

  // Menyalin status inventory milik user (ownedItemIds/equippedItemIds) ke objek
  // ShopItem dalam memori. Dipanggil setiap katalog global atau dokumen user
  // dimuat ulang, agar kepemilikan bersifat per-akun & tahan restart.
  void _applyInventoryToShopItems() {
    for (final item in shopItems) {
      item.owned = ownedItemIds.contains(item.id);
      item.isEquipped = equippedItemIds.contains(item.id);
    }
  }

  void buyItem(ShopItem item) {
    if (hero.gold >= item.price && !item.owned) {
      hero.gold -= item.price;
      item.owned = true;
      if (!ownedItemIds.contains(item.id)) ownedItemIds.add(item.id);
      notifyListeners();
      saveToFirestore();
    }
  }

  void sellItem(ShopItem item) {
    if (item.owned) {
      item.owned = false;
      item.isEquipped = false;
      ownedItemIds.remove(item.id);
      equippedItemIds.remove(item.id);
      hero.gold += (item.price * 0.5).toInt();
      notifyListeners();
      saveToFirestore();
    }
  }

  void equipItem(ShopItem item) {
    if (!item.owned) return;

    if (item.category == ItemCategory.potion) {
      if (item.id == 's3') hero.hp = (hero.hp + 30).clamp(0, hero.maxHp);
      if (item.id == 's4') {
        _applyXp(100);
      }
      if (item.id == 's8') hero.mp = (hero.mp + 15).clamp(0, hero.maxMp);

      // Potion habis dipakai → keluar dari inventory user.
      item.owned = false;
      ownedItemIds.remove(item.id);
      equippedItemIds.remove(item.id);
    } else {
      if (item.isEquipped) {
        item.isEquipped = false;
        equippedItemIds.remove(item.id);
      } else {
        // Hanya satu item ter-equip per kategori.
        for (var i in shopItems) {
          if (i.category == item.category) {
            i.isEquipped = false;
            equippedItemIds.remove(i.id);
          }
        }
        item.isEquipped = true;
        if (!equippedItemIds.contains(item.id)) equippedItemIds.add(item.id);
      }
    }
    notifyListeners();
    saveToFirestore();
  }

  void changeClass(HeroClass newClass) {
    hero.heroClass = newClass;
    notifyListeners();
    saveToFirestore();
  }

  void updateHeroName(String newName) {
    hero.name = newName;
    notifyListeners();
    saveToFirestore();
  }

  void addTask(TaskModel task) {
    if (task.type == TaskType.daily) {
      dailyTasks.add(task);
    } else {
      todos.add(task);
    }
    addNotification("Task Ditambahkan!");
    notifyListeners();
    saveToFirestore();
  }

  void updateTask(TaskModel updatedTask) {
    dailyTasks.removeWhere((t) => t.id == updatedTask.id);
    todos.removeWhere((t) => t.id == updatedTask.id);
    if (updatedTask.type == TaskType.daily) {
      dailyTasks.add(updatedTask);
    } else {
      todos.add(updatedTask);
    }
    addNotification("Task Diperbarui!");
    notifyListeners();
    saveToFirestore();
  }

  void deleteTask(String id) {
    dailyTasks.removeWhere((t) => t.id == id);
    todos.removeWhere((t) => t.id == id);
    addNotification("Task Dihapus");
    notifyListeners();
    saveToFirestore();
  }

  void addHabit(HabitModel habit) {
    habits.add(habit);
    addNotification("Habit Ditambahkan!");
    notifyListeners();
    saveToFirestore();
  }

  void updateHabit(HabitModel updatedHabit) {
    final idx = habits.indexWhere((h) => h.id == updatedHabit.id);
    if (idx != -1) {
      habits[idx] = updatedHabit;
      addNotification("Habit Diperbarui!");
      notifyListeners();
      saveToFirestore();
    }
  }

  void deleteHabit(String id) {
    habits.removeWhere((h) => h.id == id);
    addNotification("Habit Dihapus");
    notifyListeners();
    saveToFirestore();
  }

  void updateUserInfo({
    required String newUsername,
    required String newFullName,
    required String newPhone,
  }) {
    username = newUsername;
    fullName = newFullName;
    phone = newPhone;
    
    if (hero.name == 'Novice Hero' || hero.name == 'New Hero' || hero.name.isEmpty) {
      hero.name = newFullName;
    }
    
    notifyListeners();
    saveToFirestore();
  }

  String getLeaderName(String leaderId) {
    try {
      final u = allUsers.firstWhere((user) => user.uid == leaderId);
      return u.name;
    } catch (_) {
      return 'Leader';
    }
  }

  Future<void> createParty(String name) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final partyRef = FirebaseFirestore.instance.collection('parties').doc();
      await partyRef.set({
        'name': name,
        'leaderId': user.uid,
        'memberIds': [user.uid],
        'invitedIds': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'partyId': partyRef.id,
      });
      addNotification("Party '$name' Berhasil Dibuat!");
    } catch (e) {
      addNotification("Gagal membuat Party: $e");
    }
  }

  Future<void> inviteUser(String targetUid) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || partyId == null) return;
    try {
      await FirebaseFirestore.instance.collection('parties').doc(partyId).update({
        'invitedIds': FieldValue.arrayUnion([targetUid]),
      });
      addNotification("Undangan Terkirim!");
    } catch (e) {
      addNotification("Gagal mengirim undangan: $e");
    }
  }

  Future<void> removeMember(String targetUid) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || partyId == null || !isPartyLeader) return;
    try {
      await FirebaseFirestore.instance.collection('parties').doc(partyId).update({
        'memberIds': FieldValue.arrayRemove([targetUid]),
      });
      // partyId di dokumen member yang dikeluarkan TIDAK ditulis dari sini —
      // aturan keamanan melarang menulis dokumen user lain. Member yang
      // dikeluarkan membersihkan partyId-nya sendiri lewat listener party-nya.
      addNotification("Member Berhasil Dikeluarkan!");
    } catch (e) {
      addNotification("Gagal mengeluarkan member: $e");
    }
  }

  Future<void> leaveParty() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || partyId == null) return;
    try {
      if (isPartyLeader) {
        // Bubarkan: cukup hapus dokumen party (hanya leader yang boleh). Setiap
        // anggota lain membersihkan partyId-nya sendiri begitu listener-nya
        // melihat party sudah tiada — leader tak boleh menulis dokumen mereka.
        await FirebaseFirestore.instance.collection('parties').doc(partyId).delete();
        await _clearOwnPartyId();
        addNotification("Party Dibubarkan!");
      } else {
        await FirebaseFirestore.instance.collection('parties').doc(partyId).update({
          'memberIds': FieldValue.arrayRemove([user.uid]),
        });
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'partyId': FieldValue.delete(),
        });
        addNotification("Keluar dari Party!");
      }
    } catch (e) {
      addNotification("Gagal keluar Party: $e");
    }
  }

  Future<void> acceptInvite(String partyIdToAccept) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance.collection('parties').doc(partyIdToAccept).update({
        'memberIds': FieldValue.arrayUnion([user.uid]),
        'invitedIds': FieldValue.arrayRemove([user.uid]),
      });
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'partyId': partyIdToAccept,
      });
      addNotification("Berhasil Bergabung dengan Party!");
    } catch (e) {
      addNotification("Gagal menerima undangan: $e");
    }
  }

  Future<void> declineInvite(String partyIdToDecline) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance.collection('parties').doc(partyIdToDecline).update({
        'invitedIds': FieldValue.arrayRemove([user.uid]),
      });
      addNotification("Menolak Undangan.");
    } catch (e) {
      addNotification("Gagal menolak undangan: $e");
    }
  }

  Future<void> _populateDefaultGlobalQuests() async {
    final defaultQuests = [
      QuestModel(id: 'gq1', title: 'UTS Pemrograman Mobile', progress: 100, xpReward: 200, timeLeft: '3 Hari Tersisa', isBoss: false),
      QuestModel(id: 'gq2', title: 'Laporan Praktikum Jaringan', progress: 100, xpReward: 150, timeLeft: '5 Hari Tersisa', isBoss: false),
      QuestModel(id: 'gq3', title: 'Quiz Basis Data', progress: 0, xpReward: 100, timeLeft: 'Draft', isBoss: false),
      QuestModel(id: 'gq4', title: 'Project Akhir RPL', progress: 100, xpReward: 500, timeLeft: '14 Hari Tersisa', isBoss: false),
    ];
    for (var q in defaultQuests) {
      await FirebaseFirestore.instance.collection('global_quests').doc(q.id).set(q.toMap());
    }
  }

  Future<void> _populateDefaultGlobalBosses() async {
    final defaultBosses = [
      QuestModel(id: 'gb1', title: 'Deadline Boss Lv.3', progress: 70, xpReward: 500, timeLeft: '3 Party', isBoss: true),
      QuestModel(id: 'gb2', title: 'UTS Boss Lv.2', progress: 53, xpReward: 350, timeLeft: '2 Party', isBoss: true),
      QuestModel(id: 'gb3', title: 'Final Project Boss Lv.5', progress: 0, xpReward: 1000, timeLeft: 'Draft', isBoss: true),
    ];
    for (var b in defaultBosses) {
      await FirebaseFirestore.instance.collection('global_bosses').doc(b.id).set(b.toMap());
    }
  }

  Future<void> _populateDefaultShopItems() async {
    final defaultShopItems = [
      ShopItem(id: 's1', name: 'Iron Sword', description: '+15 ATK · Pedang standar prajurit.', emoji: '🗡️', price: 80, category: ItemCategory.weapon, rarity: ItemRarity.common, bonuses: {'atk': 15}),
      ShopItem(id: 's2', name: 'Study Shield', description: '+20 DEF · Melindungi dari deadline.', emoji: '🛡️', price: 120, category: ItemCategory.armor, rarity: ItemRarity.rare, bonuses: {'def': 20}),
      ShopItem(id: 's3', name: 'HP Potion', description: 'Restore 30 HP', emoji: '🧪', price: 50, category: ItemCategory.potion, rarity: ItemRarity.common),
      ShopItem(id: 's4', name: 'XP Scroll', description: '+100 XP instan', emoji: '📜', price: 200, category: ItemCategory.potion, rarity: ItemRarity.rare),
      ShopItem(id: 's5', name: 'Wizard Hat', description: '+25 Mana · Topi penyihir bintang.', emoji: '🧙', price: 250, category: ItemCategory.armor, rarity: ItemRarity.epic, bonuses: {'mp': 25}),
      ShopItem(id: 's6', name: 'Excalibur', description: '+100 ATK · Pedang legendaris.', emoji: '⚔️', price: 1500, category: ItemCategory.weapon, rarity: ItemRarity.legendary, bonuses: {'atk': 100}),
      ShopItem(id: 's7', name: 'Titan Ring', description: '+10 Strength · Cincin raksasa.', emoji: '💍', price: 400, category: ItemCategory.accessory, rarity: ItemRarity.rare, bonuses: {'atk': 10, 'def': 10}),
      ShopItem(id: 's8', name: 'Coffee Cup', description: 'Anti-Sleep · Restore 15 MP', emoji: '☕', price: 30, category: ItemCategory.potion, rarity: ItemRarity.common),
    ];
    for (var i in defaultShopItems) {
      await FirebaseFirestore.instance.collection('shop_items').doc(i.id).set(i.toMap());
    }
  }

  @override
  void dispose() {
    _currentUserSubscription?.cancel();
    _publicProfilesSubscription?.cancel();
    _partySubscription?.cancel();
    _invitesSubscription?.cancel();
    _globalQuestsSubscription?.cancel();
    _globalBossesSubscription?.cancel();
    _shopItemsSubscription?.cancel();
    _broadcastsSubscription?.cancel();
    super.dispose();
  }
}

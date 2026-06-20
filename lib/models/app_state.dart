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
  StreamSubscription<QuerySnapshot>? _usersSubscription;
  StreamSubscription<DocumentSnapshot>? _partySubscription;
  StreamSubscription<QuerySnapshot>? _invitesSubscription;
  StreamSubscription<QuerySnapshot>? _globalQuestsSubscription;
  StreamSubscription<QuerySnapshot>? _globalBossesSubscription;
  StreamSubscription<QuerySnapshot>? _shopItemsSubscription;

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

  // In-app notifications
  List<String> notifications = [];
  List<String> notificationHistory = [];
  bool hasUnreadNotifications = false;
  bool hasClaimedDaily = false;
  List<String> completedGlobalQuests = [];

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
        _usersSubscription?.cancel();
        _usersSubscription = null;
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
        'completedGlobalQuests': completedGlobalQuests,
        'partyId': partyId ?? FieldValue.delete(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error saving to Firestore: $e");
    }
  }

  Future<void> loadFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _currentUserSubscription?.cancel();
    _usersSubscription?.cancel();
    _partySubscription?.cancel();
    _invitesSubscription?.cancel();
    _globalQuestsSubscription?.cancel();
    _globalBossesSubscription?.cancel();
    _shopItemsSubscription?.cancel();

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
            addNotification("🚫 Akun Anda diblokir oleh admin!");
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
          if (data['completedGlobalQuests'] != null) {
            completedGlobalQuests = List<String>.from(data['completedGlobalQuests']);
          } else {
            completedGlobalQuests = [];
          }
          _syncGlobalQuestsToUser();
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

    // 2. Subscribe to the users collection to construct partyMembers/leaderboard dynamically
    _usersSubscription = FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .listen((usersSnapshot) {
      final List<PartyMember> members = [];
      for (var uDoc in usersSnapshot.docs) {
        final uData = uDoc.data();
        final heroMap = uData['hero'] as Map<String, dynamic>?;
        final email = uData['email'] ?? '';
        final fullNameVal = uData['fullName'] ?? '';
        String name = 'Unknown';
        if (fullNameVal.toString().isNotEmpty) {
          name = fullNameVal.toString();
        } else if (email.toString().isNotEmpty) {
          name = email.toString().split('@').first;
        }

        if (heroMap != null) {
          HeroClass parsedClass = HeroClass.warrior;
          try {
            parsedClass = HeroClass.values.firstWhere((e) => e.name == heroMap['heroClass']);
          } catch (_) {}

          members.add(PartyMember(
            uid: uDoc.id,
            name: name,
            emoji: parsedClass == HeroClass.warrior
                ? '⚔️'
                : (parsedClass == HeroClass.mage
                    ? '🧙'
                    : (parsedClass == HeroClass.healer ? '💚' : '🏹')),
            heroClass: parsedClass,
            level: heroMap['level'] ?? 1,
            xp: heroMap['xp'] ?? 0,
            streak: heroMap['streak'] ?? 0,
            avatarColor: parsedClass == HeroClass.warrior
                ? AppColors.accent
                : (parsedClass == HeroClass.mage
                    ? const Color(0xFF185FA5)
                    : (parsedClass == HeroClass.healer ? const Color(0xFF0F6E56) : const Color(0xFF854F0B))),
          ));
        }
      }
      allUsers = members;
      _updatePartyMembersList();
    }, onError: (e) {
      debugPrint("Error loading users stream: $e");
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
        globalQuests = snapshot.docs.map((doc) => QuestModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
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
        final newBosses = snapshot.docs.map((doc) => QuestModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
        
        for (var newB in newBosses) {
          final oldB = globalBosses.firstWhere((b) => b.id == newB.id, orElse: () => newB);
          if (newB.progress == 0 && oldB.progress > 0) {
            if (!completedGlobalQuests.contains(newB.id)) {
              completedGlobalQuests.add(newB.id);
              addNotification("🎉 Boss ${newB.title} Berhasil Dikalahkan! (+${newB.xpReward} XP)");
              _applyXp(newB.xpReward);
              saveToFirestore();
            }
          }
        }
        globalBosses = newBosses;
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
        shopItems = snapshot.docs.map((doc) => ShopItem.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
      } else {
        _populateDefaultShopItems();
      }
      notifyListeners();
    }, onError: (e) {
      debugPrint("Error loading shop items: $e");
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
          partyName = partyData['name'] ?? 'No Name';
          final leaderId = partyData['leaderId'] ?? '';
          isPartyLeader = (leaderId == currentUserId);
          partyMemberIds = List<String>.from(partyData['memberIds'] ?? []);
          _updatePartyMembersList();
        }
      } else {
        partyId = null;
        partyName = null;
        isPartyLeader = false;
        partyMemberIds = [];
        partyMembers = [];
        notifyListeners();
      }
    }, onError: (e) {
      debugPrint("Error loading party doc: $e");
    });
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

  // ── Actions ──────────────────────────────────────────────────────────

  void claimDailyReward() {
    if (!hasClaimedDaily) {
      if (_isSfxOn) {
        AudioHelper.playSfx();
      }
      hero.streak += 1;
      hasClaimedDaily = true;
      int goldReward = hero.streak * 15;
      int gemReward = (hero.streak % 7 == 0) ? 5 : 1;
      hero.gold += goldReward;
      hero.gems += gemReward;
      
      hero.momentum = (hero.momentum + 20).clamp(0, 100);

      addNotification("📆 Daily Streak Claimed (+${hero.streak} Days)!");
      addNotification("🪙 +$goldReward Gold / 💎 +$gemReward Gems");
      addNotification("⚡ Momentum Restored!");
      
      notifyListeners();
      saveToFirestore();
    }
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
      addNotification("🎉 LEVEL UP! Reached Level ${hero.level}");
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
      addNotification("🎉 LEVEL UP! Reached Level ${hero.level}");
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

  void _updateQuestProgress() {
    for (var q in quests) {
      if (q.progress < 100) {
        q.progress = (q.progress + 20).clamp(0, 100);
        addNotification("⚔️ Quest Progress Updated");
        if (q.progress >= 100) {
          hero.totalQuestsCompleted += 1;
          addNotification("🏆 Quest Completed: ${q.title}");
          _applyXp(q.xpReward);
        }
        break;
      }
    }
  }

  void progressQuest(String id) {
    final idx = quests.indexWhere((q) => q.id == id);
    if (idx != -1) {
      final q = quests[idx];
      if (q.progress < 100) {
        q.progress = (q.progress + 20).clamp(0, 100);
        addNotification("⚔️ Progres Quest '${q.title}' bertambah (+20%)");
        if (q.progress >= 100) {
          hero.totalQuestsCompleted += 1;
          addNotification("🏆 Quest Selesai: ${q.title} (+${q.xpReward} XP)");
          _applyXp(q.xpReward);
        }
        notifyListeners();
        saveToFirestore();
      } else {
        addNotification("✨ Quest '${q.title}' sudah selesai!");
      }
    }
  }

  void attackGlobalBoss(String id) {
    final idx = globalBosses.indexWhere((b) => b.id == id);
    if (idx != -1) {
      final b = globalBosses[idx];
      if (b.progress > 0) {
        final newProg = (b.progress - 10).clamp(0, 100);
        FirebaseFirestore.instance.collection('global_bosses').doc(id).update({
          'progress': newProg,
        });

        // Kurangi HP dari semua anggota party (atau user sendiri jika tidak ada party)
        final List<String> targets = [];
        if (partyId != null && partyId!.isNotEmpty && partyMemberIds.isNotEmpty) {
          targets.addAll(partyMemberIds);
        } else {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            targets.add(currentUser.uid);
          }
        }

        final batch = FirebaseFirestore.instance.batch();
        for (var uid in targets) {
          final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
          batch.update(userDoc, {
            'hero.hp': FieldValue.increment(-10),
          });
        }
        batch.commit().catchError((e) {
          debugPrint("Error updating party members HP: $e");
        });

        addNotification("💥 Menyerang ${b.title}! HP berkurang (-10%)");
      } else {
        addNotification("💀 Boss ${b.title} sudah dikalahkan!");
      }
    }
  }

  void toggleTask(TaskModel task) {
    task.isDone = !task.isDone;
    double mult = momentumMultiplier;
    
    if (task.isDone) {
      if (_isSfxOn) {
        AudioHelper.playSfx();
      }
      int xpGained = (task.xpReward * mult).toInt();
      int goldGained = (task.goldReward * mult).toInt();

      hero.gold += goldGained;
      hero.totalTasksCompleted += 1;
      hero.momentum = (hero.momentum + 15).clamp(0, 100);

      _incrementSkill(task.attribute);
      _applyXp(xpGained);
      _updateQuestProgress();

      addNotification("✨ XP Gained (x$mult bonus!)");
      addNotification("⚡ Gravity Resistance Increased");
    } else {
      int xpLost = (task.xpReward * mult).toInt();
      int goldLost = (task.goldReward * mult).toInt();

      _applyXp(-xpLost);
      hero.gold = (hero.gold - goldLost).clamp(0, 999999);
      hero.totalTasksCompleted = (hero.totalTasksCompleted - 1).clamp(0, 999999);
      hero.momentum = (hero.momentum - 15).clamp(0, 100);

      _decrementSkill(task.attribute);
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

      addNotification("✨ XP Increased!");
      addNotification("🔥 Habit Streak Up!");
    } else {
      hero.hp = (hero.hp - 6).clamp(0, hero.maxHp);
      hero.momentum = (hero.momentum - 20).clamp(0, 100);
      habit.streak = 0;

      addNotification("💔 Health Reduced!");
      addNotification("⚠️ Momentum Lost!");
    }
    notifyListeners();
    saveToFirestore();
  }

  // Reward setelah menyelesaikan satu sesi Focus Mode.
  void completeFocusSession() {
    hero.gold += 20;
    hero.focus += 5;
    _applyXp(50);
    addNotification("🎯 Focus Session Complete! (+50 XP / +20G)");
    notifyListeners();
    saveToFirestore();
  }

  void buyItem(ShopItem item) {
    if (hero.gold >= item.price && !item.owned) {
      hero.gold -= item.price;
      item.owned = true;
      notifyListeners();
      saveToFirestore();
    }
  }

  void sellItem(ShopItem item) {
    if (item.owned) {
      item.owned = false;
      item.isEquipped = false;
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
      
      item.owned = false;
    } else {
      if (item.isEquipped) {
        item.isEquipped = false;
      } else {
        for (var i in shopItems) {
          if (i.category == item.category) i.isEquipped = false;
        }
        item.isEquipped = true;
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
    addNotification("🆕 Task Ditambahkan!");
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
    addNotification("✏️ Task Diperbarui!");
    notifyListeners();
    saveToFirestore();
  }

  void deleteTask(String id) {
    dailyTasks.removeWhere((t) => t.id == id);
    todos.removeWhere((t) => t.id == id);
    addNotification("🗑️ Task Dihapus");
    notifyListeners();
    saveToFirestore();
  }

  void addHabit(HabitModel habit) {
    habits.add(habit);
    addNotification("🆕 Habit Ditambahkan!");
    notifyListeners();
    saveToFirestore();
  }

  void updateHabit(HabitModel updatedHabit) {
    final idx = habits.indexWhere((h) => h.id == updatedHabit.id);
    if (idx != -1) {
      habits[idx] = updatedHabit;
      addNotification("✏️ Habit Diperbarui!");
      notifyListeners();
      saveToFirestore();
    }
  }

  void deleteHabit(String id) {
    habits.removeWhere((h) => h.id == id);
    addNotification("🗑️ Habit Dihapus");
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
      addNotification("🏰 Party '$name' Berhasil Dibuat!");
    } catch (e) {
      addNotification("❌ Gagal membuat Party: $e");
    }
  }

  Future<void> inviteUser(String targetUid) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || partyId == null) return;
    try {
      await FirebaseFirestore.instance.collection('parties').doc(partyId).update({
        'invitedIds': FieldValue.arrayUnion([targetUid]),
      });
      addNotification("✉️ Undangan Terkirim!");
    } catch (e) {
      addNotification("❌ Gagal mengirim undangan: $e");
    }
  }

  Future<void> removeMember(String targetUid) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || partyId == null || !isPartyLeader) return;
    try {
      await FirebaseFirestore.instance.collection('parties').doc(partyId).update({
        'memberIds': FieldValue.arrayRemove([targetUid]),
      });
      await FirebaseFirestore.instance.collection('users').doc(targetUid).update({
        'partyId': FieldValue.delete(),
      });
      addNotification("🗑️ Member Berhasil Dikeluarkan!");
    } catch (e) {
      addNotification("❌ Gagal mengeluarkan member: $e");
    }
  }

  Future<void> leaveParty() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || partyId == null) return;
    try {
      if (isPartyLeader) {
        // Disband party: remove partyId for all members, then delete party doc.
        final partyDoc = await FirebaseFirestore.instance.collection('parties').doc(partyId).get();
        final memberIds = List<String>.from(partyDoc.data()?['memberIds'] ?? []);
        for (var mid in memberIds) {
          await FirebaseFirestore.instance.collection('users').doc(mid).update({
            'partyId': FieldValue.delete(),
          });
        }
        await FirebaseFirestore.instance.collection('parties').doc(partyId).delete();
        addNotification("🏰 Party Dibubarkan!");
      } else {
        await FirebaseFirestore.instance.collection('parties').doc(partyId).update({
          'memberIds': FieldValue.arrayRemove([user.uid]),
        });
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'partyId': FieldValue.delete(),
        });
        addNotification("🚪 Keluar dari Party!");
      }
    } catch (e) {
      addNotification("❌ Gagal keluar Party: $e");
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
      addNotification("🤝 Berhasil Bergabung dengan Party!");
    } catch (e) {
      addNotification("❌ Gagal menerima undangan: $e");
    }
  }

  Future<void> declineInvite(String partyIdToDecline) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance.collection('parties').doc(partyIdToDecline).update({
        'invitedIds': FieldValue.arrayRemove([user.uid]),
      });
      addNotification("🚷 Menolak Undangan.");
    } catch (e) {
      addNotification("❌ Gagal menolak undangan: $e");
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
    _usersSubscription?.cancel();
    _partySubscription?.cancel();
    _invitesSubscription?.cancel();
    _globalQuestsSubscription?.cancel();
    _globalBossesSubscription?.cancel();
    _shopItemsSubscription?.cancel();
    super.dispose();
  }
}

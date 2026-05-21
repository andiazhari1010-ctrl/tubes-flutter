import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  HeroModel hero = HeroModel(
    name: 'Novice Hero',
    heroClass: HeroClass.warrior,
    level: 1,
    hp: 100,
    maxHp: 100,
    xp: 0,
    maxXp: 100,
    mp: 50,
    maxMp: 50,
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

  int get extraAtk => shopItems.where((i) => i.isEquipped).fold(0, (sum, i) => sum + (i.bonuses['atk'] ?? 0));
  int get extraDef => shopItems.where((i) => i.isEquipped).fold(0, (sum, i) => sum + (i.bonuses['def'] ?? 0));
  List<PartyMember> partyMembers = const [];

  // In-app notifications
  List<String> notifications = [];
  bool hasClaimedDaily = false;

  AppState() {
    // Listen to Firebase Auth state changes
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        loadFromFirestore();
      } else {
        // Reset state on logout
        hero = HeroModel(
          name: 'Novice Hero',
          heroClass: HeroClass.warrior,
          level: 1,
          hp: 100,
          maxHp: 100,
          xp: 0,
          maxXp: 100,
          mp: 50,
          maxMp: 50,
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
    notifyListeners();
    Future.delayed(const Duration(seconds: 3), () {
      notifications.remove(msg);
      notifyListeners();
    });
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
        'hero': hero.toMap(),
        'habits': habits.map((h) => h.toMap()).toList(),
        'dailyTasks': dailyTasks.map((t) => t.toMap()).toList(),
        'todos': todos.map((t) => t.toMap()).toList(),
        'quests': quests.map((q) => q.toMap()).toList(),
        'hasClaimedDaily': hasClaimedDaily,
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error saving to Firestore: $e");
    }
  }

  Future<void> loadFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          if (data['hero'] != null) {
            hero = HeroModel.fromMap(Map<String, dynamic>.from(data['hero']));
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
                .toList();
          } else {
            // Default Quest if empty
            quests = [
              QuestModel(id: 'q1', title: 'Selesaikan 5 Tugas Hari Ini', progress: 0, xpReward: 150, timeLeft: '12 Jam Tersisa', isBoss: false),
              QuestModel(id: 'q2', title: 'Kalahkan Midterm Exam Boss', progress: 0, xpReward: 300, timeLeft: '3 Hari Tersisa', isBoss: true),
            ];
          }
          hasClaimedDaily = data['hasClaimedDaily'] ?? false;
          notifyListeners();
        }
      } else {
        // Document doesn't exist yet, populate with default quests
        quests = [
          QuestModel(id: 'q1', title: 'Selesaikan 5 Tugas Hari Ini', progress: 0, xpReward: 150, timeLeft: '12 Jam Tersisa', isBoss: false),
          QuestModel(id: 'q2', title: 'Kalahkan Midterm Exam Boss', progress: 0, xpReward: 300, timeLeft: '3 Hari Tersisa', isBoss: true),
        ];
        saveToFirestore();
      }
    } catch (e) {
      print("Error loading from Firestore: $e");
    }
  }

  // ── Actions ──────────────────────────────────────────────────────────

  void claimDailyReward() {
    if (!hasClaimedDaily) {
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

  void _checkLevelUp() {
    if (hero.xp >= hero.maxXp) {
      hero.xp -= hero.maxXp;
      hero.level += 1;
      hero.maxXp = (hero.level * 100);
      hero.maxHp = 100 + (hero.level * 10);
      hero.hp = hero.maxHp;
      hero.maxMp = 50 + (hero.level * 5);
      hero.mp = hero.maxMp;
      addNotification("🎉 LEVEL UP! Reached Level ${hero.level}");
    }
  }

  void _incrementSkill(SkillAttribute attr) {
    switch (attr) {
      case SkillAttribute.intelligence: hero.intelligence += 1; break;
      case SkillAttribute.strength: hero.strength += 1; break;
      case SkillAttribute.creativity: hero.creativity += 1; break;
      case SkillAttribute.knowledge: hero.knowledge += 1; break;
      case SkillAttribute.focus: hero.focus += 1; break;
    }
  }

  void _decrementSkill(SkillAttribute attr) {
    switch (attr) {
      case SkillAttribute.intelligence: hero.intelligence = (hero.intelligence - 1).clamp(0, 9999); break;
      case SkillAttribute.strength: hero.strength = (hero.strength - 1).clamp(0, 9999); break;
      case SkillAttribute.creativity: hero.creativity = (hero.creativity - 1).clamp(0, 9999); break;
      case SkillAttribute.knowledge: hero.knowledge = (hero.knowledge - 1).clamp(0, 9999); break;
      case SkillAttribute.focus: hero.focus = (hero.focus - 1).clamp(0, 9999); break;
    }
  }

  void _updateQuestProgress() {
    for (var q in quests) {
      if (q.progress < 100) {
        q.progress = (q.progress + 20).clamp(0, 100);
        addNotification("⚔️ Quest Progress Updated");
        if (q.progress >= 100) {
          hero.xp = hero.xp + q.xpReward;
          hero.totalQuestsCompleted += 1;
          addNotification("🏆 Quest Completed: ${q.title}");
          _checkLevelUp();
        }
        break;
      }
    }
  }

  void toggleTask(TaskModel task) {
    task.isDone = !task.isDone;
    double mult = momentumMultiplier;
    
    if (task.isDone) {
      int xpGained = (task.xpReward * mult).toInt();
      int goldGained = (task.goldReward * mult).toInt();
      
      hero.xp = (hero.xp + xpGained);
      hero.gold += goldGained;
      hero.totalTasksCompleted += 1;
      hero.momentum = (hero.momentum + 15).clamp(0, 100);
      
      _incrementSkill(task.attribute);
      _checkLevelUp();
      _updateQuestProgress();

      addNotification("✨ XP Gained (x$mult bonus!)");
      addNotification("⚡ Gravity Resistance Increased");
    } else {
      int xpLost = (task.xpReward * mult).toInt();
      int goldLost = (task.goldReward * mult).toInt();
      
      hero.xp = (hero.xp - xpLost).clamp(0, hero.maxXp);
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
      int xpGained = (habit.xpReward * mult).toInt();
      hero.xp = (hero.xp + xpGained);
      hero.gold += 5;
      habit.streak++;
      hero.momentum = (hero.momentum + 8).clamp(0, 100);
      
      _incrementSkill(habit.attribute);
      _checkLevelUp();

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
        hero.xp = (hero.xp + 100);
        _checkLevelUp();
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
    saveToFirestore();
  }

  void addHabit(HabitModel habit) {
    habits.add(habit);
    addNotification("🆕 Habit Ditambahkan!");
    saveToFirestore();
  }
}

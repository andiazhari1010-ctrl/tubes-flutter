import 'package:flutter/material.dart';
import '../models/models.dart';
import 'package:flutter/material.dart' show Color, ChangeNotifier;

class AppState extends ChangeNotifier {
  HeroModel hero = HeroModel(
    name: 'Lingga the Brave',
    heroClass: HeroClass.warrior,
    level: 12,
  );

  List<HabitModel> habits = [
    HabitModel(id: 'h1', title: 'Belajar 2 jam', emoji: '🧠', streak: 7, xpReward: 20),
    HabitModel(id: 'h2', title: 'Olahraga pagi', emoji: '🏃', streak: 3, xpReward: 15),
    HabitModel(id: 'h3', title: 'Minum 8 gelas', emoji: '💧', streak: 12, xpReward: 10),
    HabitModel(id: 'h4', title: 'Baca buku 30 mnt', emoji: '📖', streak: 0, xpReward: 10),
  ];

  List<TaskModel> dailyTasks = [
    TaskModel(id: 'd1', title: 'Absen semua kelas', subtitle: 'Reset tiap hari', xpReward: 40, priority: TaskPriority.high, type: TaskType.daily),
    TaskModel(id: 'd2', title: 'Review catatan kuliah', subtitle: 'Reset tiap hari', xpReward: 25, isDone: true, priority: TaskPriority.medium, type: TaskType.daily),
    TaskModel(id: 'd3', title: 'Rapikan kamar', subtitle: 'Reset tiap hari', xpReward: 20, priority: TaskPriority.low, type: TaskType.daily),
  ];

  List<TaskModel> todos = [
    TaskModel(id: 't1', title: 'Kerjakan tugas Basis Data', subtitle: '📅 Hari ini · Basis Data', xpReward: 50, goldReward: 20, priority: TaskPriority.high, type: TaskType.todo),
    TaskModel(id: 't2', title: 'Review materi Jaringan', subtitle: '📅 Hari ini · Jaringan', xpReward: 30, isDone: true, priority: TaskPriority.medium, type: TaskType.todo),
    TaskModel(id: 't3', title: 'Kumpulkan laporan praktikum', subtitle: '📅 2 hari · RPL', xpReward: 80, goldReward: 30, priority: TaskPriority.high, type: TaskType.todo),
    TaskModel(id: 't4', title: 'Buat slide presentasi', subtitle: '📅 5 hari · APM', xpReward: 60, goldReward: 20, priority: TaskPriority.medium, type: TaskType.todo),
    TaskModel(id: 't5', title: 'Baca paper penelitian', subtitle: '📅 7 hari · Riset', xpReward: 45, goldReward: 15, priority: TaskPriority.low, type: TaskType.todo),
  ];

  List<QuestModel> quests = [
    QuestModel(id: 'q1', title: '📚 UTS Pemrograman Mobile', progress: 65, xpReward: 200, timeLeft: '3 hari tersisa'),
    QuestModel(id: 'q2', title: '👾 Boss: Deadline Lv.3', progress: 30, xpReward: 500, timeLeft: 'Boss: 70% HP', isBoss: true),
  ];

  List<ShopItem> shopItems = [
<<<<<<< HEAD
    ShopItem(id: 's1', name: 'Iron Sword', description: '+15 ATK · Pedang standar prajurit.', emoji: '🗡️', price: 80, category: ItemCategory.weapon, rarity: ItemRarity.common, bonuses: {'atk': 15}, owned: true, isEquipped: true),
    ShopItem(id: 's2', name: 'Study Shield', description: '+20 DEF · Melindungi dari deadline.', emoji: '🛡️', price: 120, category: ItemCategory.armor, rarity: ItemRarity.rare, bonuses: {'def': 20}, owned: true),
    ShopItem(id: 's3', name: 'HP Potion', description: 'Restore 30 HP', emoji: '🧪', price: 50, category: ItemCategory.potion, rarity: ItemRarity.common),
    ShopItem(id: 's4', name: 'XP Scroll', description: '+100 XP instan', emoji: '📜', price: 200, category: ItemCategory.potion, rarity: ItemRarity.rare),
    ShopItem(id: 's5', name: 'Wizard Hat', description: '+25 Mana · Topi penyihir bintang.', emoji: '🧙', price: 250, category: ItemCategory.armor, rarity: ItemRarity.epic, bonuses: {'mp': 25}),
    ShopItem(id: 's6', name: 'Excalibur', description: '+100 ATK · Pedang legendaris.', emoji: '⚔️', price: 1500, category: ItemCategory.weapon, rarity: ItemRarity.legendary, bonuses: {'atk': 100}),
    ShopItem(id: 's7', name: 'Titan Ring', description: '+10 Strength · Cincin raksasa.', emoji: '💍', price: 400, category: ItemCategory.accessory, rarity: ItemRarity.rare, bonuses: {'atk': 10, 'def': 10}),
    ShopItem(id: 's8', name: 'Coffee Cup', description: 'Anti-Sleep · Restore 15 MP', emoji: '☕', price: 30, category: ItemCategory.potion, rarity: ItemRarity.common),
  ];

  // Logic to get total stats
  int get extraAtk => shopItems.where((i) => i.isEquipped).fold(0, (sum, i) => sum + (i.bonuses['atk'] ?? 0));
  int get extraDef => shopItems.where((i) => i.isEquipped).fold(0, (sum, i) => sum + (i.bonuses['def'] ?? 0));

=======
    ShopItem(id: 's1', name: 'Iron Sword', description: '+15 ATK · Cocok untuk Warrior', emoji: '🗡️', price: 80),
    ShopItem(id: 's2', name: 'Study Shield', description: '+20 DEF · Kurangi HP damage', emoji: '🛡️', price: 120),
    ShopItem(id: 's3', name: 'HP Potion', description: 'Restore 30 HP', emoji: '🧪', price: 50),
    ShopItem(id: 's4', name: 'XP Scroll', description: '+100 XP instan', emoji: '📜', price: 200),
  ];

>>>>>>> 5fd606cb57a6114a3116f136f5cf02c2f4a7e518
  List<PartyMember> partyMembers = const [
    PartyMember(name: 'Zhielton', emoji: '🧙', heroClass: HeroClass.mage, level: 15, xp: 2840, streak: 14, avatarColor: Color(0xFF185FA5)),
    PartyMember(name: 'Lingga', emoji: '⚔️', heroClass: HeroClass.warrior, level: 12, xp: 2580, streak: 7, avatarColor: Color(0xFF534AB7)),
    PartyMember(name: 'Yafi', emoji: '🏹', heroClass: HeroClass.rogue, level: 11, xp: 2210, streak: 5, avatarColor: Color(0xFF0F6E56)),
    PartyMember(name: 'Andy', emoji: '🛡️', heroClass: HeroClass.warrior, level: 10, xp: 1960, streak: 3, avatarColor: Color(0xFF854F0B)),
    PartyMember(name: 'Disha', emoji: '💚', heroClass: HeroClass.healer, level: 9, xp: 1720, streak: 2, avatarColor: Color(0xFF993556)),
  ];

  // ── Actions ──────────────────────────────────────────────────────────

  void toggleTask(TaskModel task) {
    task.isDone = !task.isDone;
    if (task.isDone) {
      hero.xp = (hero.xp + task.xpReward).clamp(0, hero.maxXp);
      hero.gold += task.goldReward;
    } else {
      hero.xp = (hero.xp - task.xpReward).clamp(0, hero.maxXp);
      hero.gold = (hero.gold - task.goldReward).clamp(0, 999999);
    }
    notifyListeners();
  }

  void doHabit(HabitModel habit, bool positive) {
    if (positive) {
      hero.xp = (hero.xp + habit.xpReward).clamp(0, hero.maxXp);
      hero.gold += 5;
      habit.streak++;
    } else {
      hero.hp = (hero.hp - 6).clamp(0, hero.maxHp);
    }
    notifyListeners();
  }

  void buyItem(ShopItem item) {
    if (hero.gold >= item.price && !item.owned) {
      hero.gold -= item.price;
      item.owned = true;
      notifyListeners();
    }
  }

<<<<<<< HEAD
  void sellItem(ShopItem item) {
    if (item.owned) {
      item.owned = false;
      item.isEquipped = false;
      hero.gold += (item.price * 0.5).toInt();
      notifyListeners();
    }
  }

  void equipItem(ShopItem item) {
    if (!item.owned) return;
    
    if (item.category == ItemCategory.potion) {
      // Use potion & Consume it
      if (item.id == 's3') hero.hp = (hero.hp + 30).clamp(0, hero.maxHp);
      if (item.id == 's4') hero.xp = (hero.xp + 100).clamp(0, hero.maxXp);
      if (item.id == 's8') hero.mp = (hero.mp + 15).clamp(0, hero.maxMp);
      
      item.owned = false; // Consumed
    } else {
      // Toggle Equip
      if (item.isEquipped) {
        item.isEquipped = false;
      } else {
        // Unequip others in same category
        for (var i in shopItems) {
          if (i.category == item.category) i.isEquipped = false;
        }
        item.isEquipped = true;
      }
    }
    notifyListeners();
  }

=======
>>>>>>> 5fd606cb57a6114a3116f136f5cf02c2f4a7e518
  void changeClass(HeroClass newClass) {
    hero.heroClass = newClass;
    notifyListeners();
  }
}

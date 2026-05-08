import 'package:flutter/material.dart' show Color;
enum HeroClass { warrior, mage, healer, rogue }

enum TaskPriority { high, medium, low }

class HeroModel {
  String name;
  HeroClass heroClass;
  int level;
  int hp;
  int maxHp;
  int xp;
  int maxXp;
  int mp;
  int maxMp;
  int gold;
  int gems;
  int streak;

  HeroModel({
    required this.name,
    required this.heroClass,
    this.level = 1,
    this.hp = 72,
    this.maxHp = 100,
    this.xp = 580,
    this.maxXp = 1000,
    this.mp = 90,
    this.maxMp = 100,
    this.gold = 340,
    this.gems = 25,
    this.streak = 7,
  });

  String get className {
    switch (heroClass) {
      case HeroClass.warrior: return 'Warrior';
      case HeroClass.mage: return 'Mage';
      case HeroClass.healer: return 'Healer';
      case HeroClass.rogue: return 'Rogue';
    }
  }

  String get classEmoji {
    switch (heroClass) {
      case HeroClass.warrior: return '⚔️';
      case HeroClass.mage: return '🧙';
      case HeroClass.healer: return '💚';
      case HeroClass.rogue: return '🏹';
    }
  }
}

class TaskModel {
  final String id;
  String title;
  String subtitle;
  bool isDone;
  int xpReward;
  int goldReward;
  TaskPriority priority;
  TaskType type;

  TaskModel({
    required this.id,
    required this.title,
    required this.subtitle,
    this.isDone = false,
    this.xpReward = 30,
    this.goldReward = 0,
    this.priority = TaskPriority.medium,
    this.type = TaskType.todo,
  });
}

enum TaskType { habit, daily, todo }

class HabitModel {
  final String id;
  String title;
  String emoji;
  int streak;
  int xpReward;

  HabitModel({
    required this.id,
    required this.title,
    required this.emoji,
    this.streak = 0,
    this.xpReward = 15,
  });
}

class QuestModel {
  final String id;
  String title;
  int progress; // 0–100
  int xpReward;
  String timeLeft;
  bool isBoss;

  QuestModel({
    required this.id,
    required this.title,
    this.progress = 0,
    this.xpReward = 100,
    this.timeLeft = '',
    this.isBoss = false,
  });
}

class PartyMember {
  final String name;
  final String emoji;
  final HeroClass heroClass;
  final int level;
  final int xp;
  final int streak;
  final Color avatarColor;

  const PartyMember({
    required this.name,
    required this.emoji,
    required this.heroClass,
    required this.level,
    required this.xp,
    required this.streak,
    required this.avatarColor,
  });

  String get className {
    switch (heroClass) {
      case HeroClass.warrior: return 'Warrior';
      case HeroClass.mage: return 'Mage';
      case HeroClass.healer: return 'Healer';
      case HeroClass.rogue: return 'Rogue';
    }
  }
}

<<<<<<< HEAD
enum ItemCategory { weapon, armor, potion, accessory }
enum ItemRarity { common, rare, epic, legendary }

=======
>>>>>>> 5fd606cb57a6114a3116f136f5cf02c2f4a7e518
class ShopItem {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final int price;
<<<<<<< HEAD
  final ItemCategory category;
  final ItemRarity rarity;
  final Map<String, int> bonuses; // e.g. {'hp': 10, 'atk': 5}
  bool owned;
  bool isEquipped;
=======
  bool owned;
>>>>>>> 5fd606cb57a6114a3116f136f5cf02c2f4a7e518

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.price,
<<<<<<< HEAD
    this.category = ItemCategory.potion,
    this.rarity = ItemRarity.common,
    this.bonuses = const {},
    this.owned = false,
    this.isEquipped = false,
  });

  Color get rarityColor {
    switch (rarity) {
      case ItemRarity.common: return const Color(0xFF9999BB);
      case ItemRarity.rare: return const Color(0xFF5DCAA5);
      case ItemRarity.epic: return const Color(0xFF7F77DD);
      case ItemRarity.legendary: return const Color(0xFFF4C430);
    }
  }
=======
    this.owned = false,
  });
>>>>>>> 5fd606cb57a6114a3116f136f5cf02c2f4a7e518
}

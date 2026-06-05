import 'package:flutter/material.dart' show Color;

enum HeroClass { warrior, mage, healer, rogue }

enum TaskPriority { high, medium, low }

enum SkillAttribute { intelligence, strength, creativity, knowledge, focus }

extension SkillAttributeExtension on SkillAttribute {
  String get name {
    switch (this) {
      case SkillAttribute.intelligence: return 'Intelligence';
      case SkillAttribute.strength: return 'Strength';
      case SkillAttribute.creativity: return 'Creativity';
      case SkillAttribute.knowledge: return 'Knowledge';
      case SkillAttribute.focus: return 'Focus';
    }
  }

  String get emoji {
    switch (this) {
      case SkillAttribute.intelligence: return '🧠';
      case SkillAttribute.strength: return '💪';
      case SkillAttribute.creativity: return '🎨';
      case SkillAttribute.knowledge: return '📚';
      case SkillAttribute.focus: return '🎯';
    }
  }
}

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
  int momentum; // Momentum System (0-100)
  int intelligence; // Skill Attribute System
  int strength;
  int creativity;
  int knowledge;
  int focus;
  int totalTasksCompleted; // Statistics Dashboard
  int totalQuestsCompleted;

  HeroModel({
    required this.name,
    required this.heroClass,
    this.level = 1,
    this.hp = 100,
    this.maxHp = 100,
    this.xp = 0,
    this.maxXp = 100,
    this.mp = 50,
    this.maxMp = 50,
    this.gold = 0,
    this.gems = 0,
    this.streak = 0,
    this.momentum = 0,
    this.intelligence = 0,
    this.strength = 0,
    this.creativity = 0,
    this.knowledge = 0,
    this.focus = 0,
    this.totalTasksCompleted = 0,
    this.totalQuestsCompleted = 0,
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

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'heroClass': heroClass.name,
      'level': level,
      'hp': hp,
      'maxHp': maxHp,
      'xp': xp,
      'maxXp': maxXp,
      'mp': mp,
      'maxMp': maxMp,
      'gold': gold,
      'gems': gems,
      'streak': streak,
      'momentum': momentum,
      'intelligence': intelligence,
      'strength': strength,
      'creativity': creativity,
      'knowledge': knowledge,
      'focus': focus,
      'totalTasksCompleted': totalTasksCompleted,
      'totalQuestsCompleted': totalQuestsCompleted,
    };
  }

  factory HeroModel.fromMap(Map<String, dynamic> map) {
    HeroClass parsedClass = HeroClass.warrior;
    try {
      parsedClass = HeroClass.values.firstWhere((e) => e.name == map['heroClass']);
    } catch (_) {}

    final maxHpVal = ((map['maxHp'] ?? 100) as num).toInt();
    final hpVal = ((map['hp'] ?? 100) as num).toInt().clamp(0, maxHpVal);

    return HeroModel(
      name: map['name'] ?? 'Novice Hero',
      heroClass: parsedClass,
      level: map['level'] ?? 1,
      hp: hpVal,
      maxHp: maxHpVal,
      xp: map['xp'] ?? 0,
      maxXp: map['maxXp'] ?? 100,
      mp: map['mp'] ?? 50,
      maxMp: map['maxMp'] ?? 50,
      gold: map['gold'] ?? 0,
      gems: map['gems'] ?? 0,
      streak: map['streak'] ?? 0,
      momentum: map['momentum'] ?? 0,
      intelligence: map['intelligence'] ?? 0,
      strength: map['strength'] ?? 0,
      creativity: map['creativity'] ?? 0,
      knowledge: map['knowledge'] ?? 0,
      focus: map['focus'] ?? 0,
      totalTasksCompleted: map['totalTasksCompleted'] ?? 0,
      totalQuestsCompleted: map['totalQuestsCompleted'] ?? 0,
    );
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
  SkillAttribute attribute; // Skill Attribute System

  TaskModel({
    required this.id,
    required this.title,
    required this.subtitle,
    this.isDone = false,
    this.xpReward = 30,
    this.goldReward = 10,
    this.priority = TaskPriority.medium,
    this.type = TaskType.todo,
    this.attribute = SkillAttribute.focus,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'isDone': isDone,
      'xpReward': xpReward,
      'goldReward': goldReward,
      'priority': priority.name,
      'type': type.name,
      'attribute': attribute.name,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    TaskPriority priorityVal = TaskPriority.medium;
    try {
      priorityVal = TaskPriority.values.firstWhere((e) => e.name == map['priority']);
    } catch (_) {}

    TaskType typeVal = TaskType.todo;
    try {
      typeVal = TaskType.values.firstWhere((e) => e.name == map['type']);
    } catch (_) {}

    SkillAttribute attrVal = SkillAttribute.focus;
    try {
      attrVal = SkillAttribute.values.firstWhere((e) => e.name == map['attribute']);
    } catch (_) {}

    return TaskModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      isDone: map['isDone'] ?? false,
      xpReward: map['xpReward'] ?? 30,
      goldReward: map['goldReward'] ?? 10,
      priority: priorityVal,
      type: typeVal,
      attribute: attrVal,
    );
  }
}

enum TaskType { habit, daily, todo }

class HabitModel {
  final String id;
  String title;
  String emoji;
  int streak;
  int xpReward;
  SkillAttribute attribute;

  HabitModel({
    required this.id,
    required this.title,
    required this.emoji,
    this.streak = 0,
    this.xpReward = 15,
    this.attribute = SkillAttribute.focus,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'emoji': emoji,
      'streak': streak,
      'xpReward': xpReward,
      'attribute': attribute.name,
    };
  }

  factory HabitModel.fromMap(Map<String, dynamic> map) {
    SkillAttribute attrVal = SkillAttribute.focus;
    try {
      attrVal = SkillAttribute.values.firstWhere((e) => e.name == map['attribute']);
    } catch (_) {}

    return HabitModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      emoji: map['emoji'] ?? '⭐',
      streak: map['streak'] ?? 0,
      xpReward: map['xpReward'] ?? 15,
      attribute: attrVal,
    );
  }
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'progress': progress,
      'xpReward': xpReward,
      'timeLeft': timeLeft,
      'isBoss': isBoss,
    };
  }

  factory QuestModel.fromMap(Map<String, dynamic> map) {
    return QuestModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      progress: map['progress'] ?? 0,
      xpReward: map['xpReward'] ?? 100,
      timeLeft: map['timeLeft'] ?? '',
      isBoss: map['isBoss'] ?? false,
    );
  }
}

class PartyMember {
  final String uid;
  final String name;
  final String emoji;
  final HeroClass heroClass;
  final int level;
  final int xp;
  final int streak;
  final Color avatarColor;

  const PartyMember({
    required this.uid,
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

enum ItemCategory { weapon, armor, potion, accessory }
enum ItemRarity { common, rare, epic, legendary }
class ShopItem {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final int price;
  final ItemCategory category;
  final ItemRarity rarity;
  final Map<String, int> bonuses; // e.g. {'hp': 10, 'atk': 5}
  bool owned;
  bool isEquipped;

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.price,
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

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'emoji': emoji,
      'price': price,
      'category': category.name,
      'rarity': rarity.name,
      'bonuses': bonuses,
      'owned': owned,
      'isEquipped': isEquipped,
    };
  }

  factory ShopItem.fromMap(Map<String, dynamic> map, String docId) {
    ItemCategory catVal = ItemCategory.potion;
    try {
      catVal = ItemCategory.values.firstWhere((e) => e.name == map['category']);
    } catch (_) {}

    ItemRarity rarVal = ItemRarity.common;
    try {
      rarVal = ItemRarity.values.firstWhere((e) => e.name == map['rarity']);
    } catch (_) {}

    final bonusesMap = Map<String, dynamic>.from(map['bonuses'] ?? {});
    final Map<String, int> bonusesInt = {};
    bonusesMap.forEach((key, val) {
      bonusesInt[key] = (val as num).toInt();
    });

    return ShopItem(
      id: docId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      emoji: map['emoji'] ?? '🛡️',
      price: (map['price'] ?? 0) as int,
      category: catVal,
      rarity: rarVal,
      bonuses: bonusesInt,
      owned: map['owned'] ?? false,
      isEquipped: map['isEquipped'] ?? false,
    );
  }
}

import 'package:flutter/material.dart' show Color;

enum HeroClass { warrior, mage, healer, rogue }

HeroClass heroClassFromString(String value) {
  return HeroClass.values.firstWhere(
    (e) => e.name == value,
    orElse: () => HeroClass.warrior,
  );
}

enum TaskPriority { high, medium, low }

TaskPriority priorityFromString(String value) {
  return TaskPriority.values.firstWhere(
    (e) => e.name == value,
    orElse: () => TaskPriority.medium,
  );
}

enum TaskType { habit, daily, todo }

TaskType taskTypeFromString(String value) {
  return TaskType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => TaskType.todo,
  );
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
  });

  factory HeroModel.fromJson(Map<String, dynamic> json) {
    return HeroModel(
      name: json['name'] ?? 'Unknown',
      heroClass: heroClassFromString(json['heroClass'] ?? 'warrior'),
      level: json['level'] ?? 1,
      hp: json['hp'] ?? 100,
      maxHp: json['maxHp'] ?? 100,
      xp: json['xp'] ?? 0,
      maxXp: json['maxXp'] ?? 100,
      mp: json['mp'] ?? 50,
      maxMp: json['maxMp'] ?? 50,
      gold: json['gold'] ?? 0,
      gems: json['gems'] ?? 0,
      streak: json['streak'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
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
    };
  }

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

  factory TaskModel.fromJson(Map<String, dynamic> json, String docId) {
    return TaskModel(
      id: docId,
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      isDone: json['isDone'] ?? false,
      xpReward: json['xpReward'] ?? 30,
      goldReward: json['goldReward'] ?? 0,
      priority: priorityFromString(json['priority'] ?? 'medium'),
      type: taskTypeFromString(json['type'] ?? 'todo'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'isDone': isDone,
      'xpReward': xpReward,
      'goldReward': goldReward,
      'priority': priority.name,
      'type': type.name,
    };
  }
}

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

  factory HabitModel.fromJson(Map<String, dynamic> json, String docId) {
    return HabitModel(
      id: docId,
      title: json['title'] ?? '',
      emoji: json['emoji'] ?? '🔥',
      streak: json['streak'] ?? 0,
      xpReward: json['xpReward'] ?? 15,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'emoji': emoji,
      'streak': streak,
      'xpReward': xpReward,
    };
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

  factory QuestModel.fromJson(Map<String, dynamic> json, String docId) {
    return QuestModel(
      id: docId,
      title: json['title'] ?? '',
      progress: json['progress'] ?? 0,
      xpReward: json['xpReward'] ?? 100,
      timeLeft: json['timeLeft'] ?? '',
      isBoss: json['isBoss'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'progress': progress,
      'xpReward': xpReward,
      'timeLeft': timeLeft,
      'isBoss': isBoss,
    };
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

  factory PartyMember.fromJson(Map<String, dynamic> json, String docId) {
    return PartyMember(
      uid: docId,
      name: json['name'] ?? 'Unknown',
      emoji: json['emoji'] ?? '👤',
      heroClass: heroClassFromString(json['heroClass'] ?? 'warrior'),
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
      streak: json['streak'] ?? 0,
      avatarColor: Color(json['avatarColor'] ?? 0xFF185FA5),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'emoji': emoji,
      'heroClass': heroClass.name,
      'level': level,
      'xp': xp,
      'streak': streak,
      'avatarColor': avatarColor.value,
    };
  }

  String get className {
    switch (heroClass) {
      case HeroClass.warrior: return 'Warrior';
      case HeroClass.mage: return 'Mage';
      case HeroClass.healer: return 'Healer';
      case HeroClass.rogue: return 'Rogue';
    }
  }
}

class ShopItem {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final int price;
  bool owned;

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.price,
    this.owned = false,
  });

  factory ShopItem.fromJson(Map<String, dynamic> json, String docId) {
    return ShopItem(
      id: docId,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      emoji: json['emoji'] ?? '📦',
      price: json['price'] ?? 0,
      owned: json['owned'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'emoji': emoji,
      'price': price,
      'owned': owned,
    };
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String emoji;
  final DateTime timestamp;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.emoji,
    required this.timestamp,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json, String docId) {
    return NotificationModel(
      id: docId,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      emoji: json['emoji'] ?? '🔔',
      timestamp: json['timestamp'] != null ? (json['timestamp'] as dynamic).toDate() : DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'emoji': emoji,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }
}

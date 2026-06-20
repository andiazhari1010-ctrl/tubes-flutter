import 'package:flutter/material.dart' show Color;

enum HeroClass { warrior, mage, healer, rogue }

enum TaskPriority { high, medium, low }

enum SkillAttribute { intelligence, strength, creativity }

extension SkillAttributeExtension on SkillAttribute {
  String get name {
    switch (this) {
      case SkillAttribute.intelligence: return 'Intelligence';
      case SkillAttribute.strength: return 'Strength';
      case SkillAttribute.creativity: return 'Creativity';
    }
  }

  // Deskripsi singkat per atribut (dipakai di layar Statistics).
  String get description {
    switch (this) {
      case SkillAttribute.intelligence: return 'Belajar, Logika & Fokus';
      case SkillAttribute.strength: return 'Olahraga & Fisik';
      case SkillAttribute.creativity: return 'Desain & Seni';
    }
  }
}

/// Mengubah string tersimpan menjadi [SkillAttribute].
/// Nilai lama 'knowledge' & 'focus' kini dilebur ke Intelligence.
SkillAttribute parseSkillAttribute(dynamic raw) {
  switch (raw) {
    case 'strength':
      return SkillAttribute.strength;
    case 'creativity':
      return SkillAttribute.creativity;
    default:
      return SkillAttribute.intelligence;
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
    this.hp = 150,
    this.maxHp = 150,
    this.xp = 0,
    this.maxXp = 100,
    this.mp = 100,
    this.maxMp = 100,
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

    const maxHpVal = 150;
    final hpVal = ((map['hp'] ?? 150) as num).toInt().clamp(0, maxHpVal);
    const maxMpVal = 100;
    final mpVal = ((map['mp'] ?? 100) as num).toInt().clamp(0, maxMpVal);

    return HeroModel(
      name: map['name'] ?? 'Novice Hero',
      heroClass: parsedClass,
      level: map['level'] ?? 1,
      hp: hpVal,
      maxHp: maxHpVal,
      xp: map['xp'] ?? 0,
      maxXp: 100,
      mp: mpVal,
      maxMp: maxMpVal,
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
  // XP/Gold yang benar-benar diberikan saat task ini diselesaikan (sudah
  // termasuk bonus momentum). Disimpan agar pembatalan ceklis mengembalikan
  // nilai yang sama persis, bukan dihitung ulang dengan multiplier momentum
  // yang mungkin sudah berubah.
  int grantedXp;
  int grantedGold;
  // Pelacakan progres Quest yang disumbang task ini. Disimpan agar saat ceklis
  // dibatalkan, +20% (dan efek penyelesaian quest) bisa dikembalikan PERSIS —
  // mencegah exploit "farming" lewat ceklis-batal berulang.
  String? grantedQuestId;
  bool grantedQuestCompleted;
  // Apakah task ini sudah memberi 1 Token Serang (untuk menyerang Boss). Disimpan
  // agar pembatalan ceklis menarik token kembali — anti-farming, sama seperti XP.
  bool grantedToken;
  // Apakah To-Do yang sudah lewat deadline ini SUDAH dikenai penalti HP. Agar
  // satu To-Do telat hanya menghukum HP sekali, bukan tiap pergantian hari.
  bool overduePenalized;

  TaskModel({
    required this.id,
    required this.title,
    required this.subtitle,
    this.isDone = false,
    this.xpReward = 30,
    this.goldReward = 10,
    this.priority = TaskPriority.medium,
    this.type = TaskType.todo,
    this.attribute = SkillAttribute.intelligence,
    this.grantedXp = 0,
    this.grantedGold = 0,
    this.grantedQuestId,
    this.grantedQuestCompleted = false,
    this.grantedToken = false,
    this.overduePenalized = false,
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
      'grantedXp': grantedXp,
      'grantedGold': grantedGold,
      'grantedQuestId': grantedQuestId,
      'grantedQuestCompleted': grantedQuestCompleted,
      'grantedToken': grantedToken,
      'overduePenalized': overduePenalized,
    };
  }

  // Hari pengulangan untuk Daily, di-encode di subtitle ("Setiap: Sen, Rab").
  // 1=Senin … 7=Minggu. Kosong = berlaku setiap hari.
  Set<int> get repeatDays {
    const labels = {'Sen': 1, 'Sel': 2, 'Rab': 3, 'Kam': 4, 'Jum': 5, 'Sab': 6, 'Min': 7};
    final match = RegExp(r'Setiap: ([^·]+)').firstMatch(subtitle);
    final result = <int>{};
    if (match != null) {
      for (final p in match.group(1)!.split(',').map((e) => e.trim())) {
        final n = labels[p];
        if (n != null) result.add(n);
      }
    }
    return result;
  }

  // Apakah daily ini aktif pada [weekday] (1=Senin..7=Minggu)?
  bool isActiveOn(int weekday) {
    final days = repeatDays;
    return days.isEmpty || days.contains(weekday);
  }

  // Tenggat To-Do, di-encode di subtitle ("Tenggat: dd-MM-yyyy"). null = tanpa tenggat.
  DateTime? get deadline {
    final m = RegExp(r'Tenggat: (\d{2})-(\d{2})-(\d{4})').firstMatch(subtitle);
    if (m == null) return null;
    return DateTime(
      int.parse(m.group(3)!),
      int.parse(m.group(2)!),
      int.parse(m.group(1)!),
    );
  }

  // Apakah To-Do ini jatuh tempo hari ini?
  bool get isDueToday {
    final d = deadline;
    if (d == null) return false;
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  // Apakah To-Do ini sudah lewat deadline (sebelum hari ini)?
  bool get isOverdue {
    final d = deadline;
    if (d == null) return false;
    final now = DateTime.now();
    return d.isBefore(DateTime(now.year, now.month, now.day));
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

    final SkillAttribute attrVal = parseSkillAttribute(map['attribute']);

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
      grantedXp: ((map['grantedXp'] ?? 0) as num).toInt(),
      grantedGold: ((map['grantedGold'] ?? 0) as num).toInt(),
      grantedQuestId: map['grantedQuestId'] as String?,
      grantedQuestCompleted: map['grantedQuestCompleted'] ?? false,
      grantedToken: map['grantedToken'] ?? false,
      overduePenalized: map['overduePenalized'] ?? false,
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
    this.attribute = SkillAttribute.intelligence,
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
    final SkillAttribute attrVal = parseSkillAttribute(map['attribute']);

    return HabitModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      emoji: map['emoji'] ?? '',
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

  factory QuestModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return QuestModel(
      id: docId ?? map['id'] ?? '',
      title: map['title'] ?? '',
      progress: ((map['progress'] ?? 0) as num).toInt(),
      xpReward: ((map['xpReward'] ?? 100) as num).toInt(),
      timeLeft: map['timeLeft'] ?? '',
      isBoss: map['isBoss'] ?? false,
    );
  }
}

class PartyMember {
  final String uid;
  final String name;
  final HeroClass heroClass;
  final int level;
  final int xp;
  final int streak;
  final Color avatarColor;

  const PartyMember({
    required this.uid,
    required this.name,
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
      emoji: map['emoji'] ?? '',
      price: (map['price'] ?? 0) as int,
      category: catVal,
      rarity: rarVal,
      bonuses: bonusesInt,
      owned: map['owned'] ?? false,
      isEquipped: map['isEquipped'] ?? false,
    );
  }
}

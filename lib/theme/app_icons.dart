import 'package:flutter/material.dart';
import '../models/models.dart';

/// ─── Icon language (pengganti emoji) ───────────────────────────────────────
/// Satu sumber kebenaran untuk semua ikon semantik aplikasi. Mengganti emoji
/// dengan Material Icons agar tampilan terasa rapi & native, bukan tempelan.
class AppIcons {
  // Kelas hero.
  static IconData heroClass(HeroClass c) {
    switch (c) {
      case HeroClass.warrior:
        return Icons.shield_rounded;
      case HeroClass.mage:
        return Icons.auto_fix_high_rounded;
      case HeroClass.healer:
        return Icons.healing_rounded;
      case HeroClass.rogue:
        return Icons.gps_fixed_rounded;
    }
  }

  // Mata uang & resource hero.
  static const IconData gold = Icons.monetization_on_rounded;
  static const IconData gems = Icons.diamond_rounded;
  static const IconData streak = Icons.local_fire_department_rounded;
  static const IconData hp = Icons.favorite_rounded;
  static const IconData xp = Icons.auto_awesome_rounded;
  static const IconData mp = Icons.water_drop_rounded;
  static const IconData momentum = Icons.bolt_rounded;
  static const IconData level = Icons.military_tech_rounded;

  // Atribut skill RPG.
  static IconData skill(SkillAttribute a) {
    switch (a) {
      case SkillAttribute.intelligence:
        return Icons.psychology_rounded;
      case SkillAttribute.strength:
        return Icons.fitness_center_rounded;
      case SkillAttribute.creativity:
        return Icons.palette_rounded;
    }
  }

  // Kategori item.
  static IconData itemCategory(ItemCategory c) {
    switch (c) {
      case ItemCategory.weapon:
        return Icons.sports_martial_arts_rounded;
      case ItemCategory.armor:
        return Icons.shield_rounded;
      case ItemCategory.potion:
        return Icons.science_rounded;
      case ItemCategory.accessory:
        return Icons.star_rounded;
    }
  }

  // Navigasi & area utama.
  static const IconData home = Icons.home_rounded;
  static const IconData tasks = Icons.checklist_rounded;
  static const IconData inventory = Icons.backpack_rounded;
  static const IconData party = Icons.groups_rounded;
  static const IconData hero = Icons.person_rounded;
  static const IconData shop = Icons.storefront_rounded;
  static const IconData focus = Icons.center_focus_strong_rounded;
  static const IconData notifications = Icons.notifications_rounded;
  static const IconData stats = Icons.insights_rounded;
  static const IconData content = Icons.dashboard_customize_rounded;
  static const IconData users = Icons.people_alt_rounded;

  // Quest / boss / gameplay.
  static const IconData quest = Icons.menu_book_rounded;
  static const IconData boss = Icons.dangerous_rounded;
  static const IconData attack = Icons.flash_on_rounded;
  static const IconData trophy = Icons.emoji_events_rounded;
  static const IconData shield = Icons.shield_outlined;
  static const IconData broadcast = Icons.campaign_rounded;
  static const IconData admin = Icons.shield_moon_rounded;

  // Aksi & status umum.
  static const IconData add = Icons.add_rounded;
  static const IconData edit = Icons.edit_rounded;
  static const IconData delete = Icons.delete_outline_rounded;
  static const IconData check = Icons.check_circle_rounded;
  static const IconData warning = Icons.warning_amber_rounded;
  static const IconData report = Icons.flag_rounded;
  static const IconData locked = Icons.lock_rounded;
  static const IconData banned = Icons.block_rounded;
  static const IconData logout = Icons.logout_rounded;
  static const IconData success = Icons.celebration_rounded;
  static const IconData sunrise = Icons.wb_twilight_rounded;
  static const IconData newItem = Icons.fiber_new_rounded;
  static const IconData music = Icons.music_note_rounded;
  static const IconData musicOff = Icons.music_off_rounded;
  static const IconData sfx = Icons.volume_up_rounded;
  static const IconData sfxOff = Icons.volume_off_rounded;
  static const IconData darkMode = Icons.dark_mode_rounded;
  static const IconData lightMode = Icons.light_mode_rounded;
}

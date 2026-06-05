# ⚔️ HeroQuest – Gamified Task Management

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white"/>
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black"/>
</p>

> **HeroQuest** adalah aplikasi manajemen tugas berbasis gamifikasi (RPG) yang dibangun dengan Flutter dan Firebase. Ubah produktivitas harian Anda menjadi petualangan epik — selesaikan tugas, naik level, dan kalahkan boss bersama teman!

---

## 📖 Deskripsi Aplikasi

**HeroQuest** menggabungkan sistem manajemen tugas modern dengan elemen permainan RPG (Role-Playing Game). Setiap tugas yang diselesaikan memberikan **XP**, setiap kebiasaan baik menambah **HP & Momentum**, dan setiap quest global yang berhasil diselesaikan bersama kelompok (Party) memberikan hadiah besar.

Aplikasi ini dibuat sebagai proyek Tugas Besar Mata Kuliah **Aplikasi Perangkat Bergerak**.

---

## ✨ Fitur Utama

### 🦸 Sistem Hero (Karakter)
- Pilih kelas hero: **Warrior ⚔️**, **Mage 🧙**, **Healer 💚**, atau **Rogue 🏹**
- Statistik karakter: **HP** (Health Points), **XP** (Experience), **MP** (Mana), **Level**
- Sistem **level up**: kumpulkan 100 XP → level naik, XP reset ke 0, HP & MP dipulihkan penuh
- Sistem **Momentum (MM)**: performa konsisten memberikan bonus multiplier XP dan Gold

### ✅ Manajemen Tugas
- **Daily Tasks**: tugas harian yang bisa ditandai selesai setiap hari
- **To-Do List**: tugas bebas yang bisa ditambah, diubah, dan dihapus kapan saja
- Setiap tugas memiliki prioritas, kategori skill, dan reward XP & Gold

### 🔥 Sistem Habit
- Tambah kebiasaan positif/negatif yang ingin dibangun
- Habit positif → XP + Streak naik + Momentum naik
- Habit negatif → HP berkurang + Momentum turun
- Streak tracking untuk motivasi jangka panjang

### ⚔️ Quest & Global Boss
- **Quest Pribadi**: tantangan personal yang bisa di-progress secara manual
- **Global Quest**: quest yang di-publish oleh Admin — aktif secara otomatis di semua akun pengguna
- **Global Boss**: boss bersama yang bisa diserang oleh Party — kalahkan untuk meraih XP besar!
- HP semua anggota party berkurang saat boss menyerang balik

### 🏰 Sistem Party (Kelompok)
- Buat party dan undang teman menggunakan UID atau email
- Real-time sync: lihat progress anggota party secara langsung
- Leaderboard XP antar anggota party
- Pemimpin party dapat mengelola anggota

### 🛒 Shop (Toko Item)
- Beli item menggunakan Gold yang dikumpulkan dari tugas
- Kategori item: **Weapon**, **Armor**, **Accessory**, **Potion**
- Raritas item: Common, Rare, Epic, Legendary
- Potion langsung memberikan efek (restore HP, XP instan, restore MP)

### 📅 Daily Reward & Streak
- Klaim hadiah harian (Gold + Gems) setiap hari login
- Hadiah meningkat sesuai panjang streak harian

### 👑 Admin Panel
- Kelola akun pengguna (ban/unban)
- Publish/edit/hapus **Global Quest** dan **Global Boss**
- Kelola item-item di toko
- Dashboard statistik pengguna

---

## 🛠️ Tech Stack

| Teknologi | Keterangan |
|-----------|-----------|
| **Flutter** | Framework utama cross-platform (Android, iOS, Web) |
| **Dart** | Bahasa pemrograman |
| **Firebase Auth** | Autentikasi pengguna (Email/Password & Google Sign-In) |
| **Cloud Firestore** | Database real-time NoSQL |
| **Provider** | State management |
| **Google Fonts** | Tipografi premium (DM Sans & Cinzel) |
| **Shared Preferences** | Penyimpanan pengaturan lokal |
| **UUID** | Generate ID unik untuk data |

---

## 🎮 Glossary / Istilah Game

| Istilah | Kepanjangan | Penjelasan |
|---------|-------------|-----------|
| **XP** | Experience Points | Poin pengalaman. Kumpulkan 100 XP untuk naik level |
| **HP** | Health Points | Nyawa karakter (Maks 150). Berkurang jika gagal habit |
| **MP** | Mana Points | Energi magis (Maks 100). Direstore dengan potion |
| **MM** | Momentum | Semangat/fokus (0-100). Tinggi = bonus multiplier XP & Gold |
| **Gold** | - | Mata uang utama untuk belanja di toko |
| **Gems** | - | Mata uang premium, didapat dari daily streak |

---

## 🚀 Cara Menjalankan

### Prasyarat
- Flutter SDK `>=3.0.0`
- Android Studio / VS Code
- Akun Firebase (sudah dikonfigurasi)

### Langkah Instalasi

```bash
# Clone repositori ini
git clone https://github.com/andiazhari1010-ctrl/tubes-flutter.git
cd tubes-flutter

# Install dependensi
flutter pub get

# Jalankan di Android
flutter run

# Jalankan di Web (dengan port tetap untuk Google Sign-In)
flutter run -d chrome --web-port=5000
```

> ⚠️ **Catatan**: Untuk login via Google di platform Web, pastikan `http://localhost:5000` sudah terdaftar sebagai *Authorized JavaScript Origin* di Google Cloud Console.

---

## 📁 Struktur Proyek

```
lib/
├── main.dart                    # Entry point aplikasi
├── models/
│   ├── app_state.dart           # Global state (Provider) + Firestore sync
│   └── models.dart              # Model data (HeroModel, TaskModel, dll)
├── screens/
│   ├── home_screen.dart         # Halaman utama
│   ├── tasks_screen.dart        # Manajemen tugas & habit
│   ├── quest_screen.dart        # Quest & global boss
│   ├── party_screen.dart        # Sistem party/kelompok
│   ├── shop_screen.dart         # Toko item
│   ├── settings_screen.dart     # Pengaturan & profil
│   ├── login_screen.dart        # Login & Register
│   ├── focus_screen.dart        # Focus/Pomodoro timer
│   └── admin/                   # Panel admin
│       ├── admin_dashboard_screen.dart
│       ├── admin_content_screen.dart
│       └── admin_users_screen.dart
├── services/
│   ├── auth_service.dart        # Layanan autentikasi
│   ├── firestore_service.dart   # Layanan Firestore
│   └── audio_service.dart       # Layanan audio/BGM
├── theme/
│   └── app_theme.dart           # Tema & warna aplikasi
└── widgets/
    └── common_widgets.dart      # Widget yang dapat digunakan ulang
```

---


## 📄 Lisensi

Proyek ini dibuat untuk keperluan akademik dan tidak untuk diperjualbelikan.

---

<p align="center">
  Made with ❤️ using Flutter & Firebase
</p>

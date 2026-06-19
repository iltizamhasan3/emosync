# 🌿 EmoSync - Mood Tracking App

<div align="center">

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![Laravel](https://img.shields.io/badge/Laravel-11-FF2D20?style=for-the-badge&logo=laravel)](https://laravel.com)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker)](https://docker.com)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

**Synchronize Your Mind and Body** 🧠✨

</div>

---

## 📋 **Daftar Isi**

- [Tentang EmoSync](#-tentang-emosync)
- [Tech Stack](#-tech-stack)
- [Fitur Utama](#-fitur-utama)
- [Struktur Project](#-struktur-project)
- [Instalasi & Setup](#-instalasi--setup)
- [Cara Menjalankan](#-cara-menjalankan)
- [Docker Setup](#-docker-setup)
- [API Endpoints](#-api-endpoints)
- [Screenshots](#-screenshots)
- [Team](#-team)
- [License](#-license)

---

## 🌟 **Tentang EmoSync**

**EmoSync** adalah aplikasi pelacakan mood dan kesehatan mental yang membantu pengguna untuk:

- 📊 **Memantau** kondisi mental harian melalui 4 kuadran mood
- 📝 **Mencatat** aktivitas dan faktor yang mempengaruhi suasana hati
- 📈 **Melihat pola** emosi melalui statistik visual dan chart interaktif
- 🤝 **Terhubung** dengan teman dan berbagi dukungan
- 🧘 **Mengakses** konten mindfulness dan meditasi

Aplikasi ini dibangun dengan **Flutter** untuk frontend yang responsif dan **Laravel** untuk backend yang scalable.

---

## 🛠️ **Tech Stack**

### **Frontend**
| Teknologi | Deskripsi |
|-----------|-----------|
| ![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter) | Framework UI cross-platform |
| ![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart) | Bahasa pemrograman |
| ![Provider](https://img.shields.io/badge/Provider-6.1-01579B?style=flat-square) | State Management |
| ![SharedPreferences](https://img.shields.io/badge/SharedPreferences-2.5-FF6F00?style=flat-square) | Local Storage |

### **Backend**
| Teknologi | Deskripsi |
|-----------|-----------|
| ![Laravel](https://img.shields.io/badge/Laravel-11-FF2D20?style=flat-square&logo=laravel) | Framework PHP |
| ![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?style=flat-square&logo=mysql) | Database |
| ![Redis](https://img.shields.io/badge/Redis-7.2-DC382D?style=flat-square&logo=redis) | Cache & Session |
| ![Sanctum](https://img.shields.io/badge/Sanctum-4.0-FF2D20?style=flat-square) | Authentication |

### **DevOps**
| Teknologi | Deskripsi |
|-----------|-----------|
| ![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat-square&logo=docker) | Containerization |
| ![Git](https://img.shields.io/badge/Git-F05032?style=flat-square&logo=git) | Version Control |

---

## ✨ **Fitur Utama**

### 🔐 **Authentication**
- Register & Login (email/username)
- Reset Password
- Session Management with Sanctum

### 📊 **Mood Check-in**
- 4 Quadrant Mood Selection
- Daily Streak Tracking
- Weekly Mood Chart
- Journal & Notes
- Pemicu (Trigger) Selection

### 📝 **Journal & Calendar**
- Calendar View dengan Mood Color
- Riwayat Check-in
- AI Insight (Premium Feature)

### 📚 **Content**
- Artikel, Video, & Kutipan
- Premium Content (Lock/Unlock)
- Content Filter & Search

### 🤝 **Friendship**
- Add & Accept Friend Request
- Delete Friend
- Search Friend
- Chat Real-time

### 💬 **Chat**
- Real-time Messaging
- Read Receipts
- Message Status (Sent, Read)

### ⭐ **Premium**
- Monthly & Yearly Plans
- Payment Gateway Demo
- Access to All Content
- AI Insight

### ⚙️ **Settings**
- Notification Preferences
- Privacy Settings
- Help Center

---

## 📁 **Struktur Project**
EmoSync/
├── emosync_app/ # Flutter Frontend
│ ├── lib/
│ │ ├── models/ # Data Models
│ │ │ ├── user_model.dart
│ │ │ ├── mood_model.dart
│ │ │ ├── content_model.dart
│ │ │ ├── friend_model.dart
│ │ │ └── settings_model.dart
│ │ ├── providers/ # State Management
│ │ │ └── auth_provider.dart
│ │ ├── screens/ # UI Screens
│ │ │ ├── home_screen.dart
│ │ │ ├── journal_screen.dart
│ │ │ ├── content_screen.dart
│ │ │ ├── friend_screen.dart
│ │ │ ├── chat_screen.dart
│ │ │ ├── profile_screen.dart
│ │ │ ├── edit_profile_screen.dart
│ │ │ ├── premium_plan_screen.dart
│ │ │ ├── payment_screen.dart
│ │ │ └── settings_*.dart
│ │ ├── services/ # API Services
│ │ │ └── api_service.dart
│ │ ├── utils/ # Utilities
│ │ │ ├── constants.dart
│ │ │ └── mood_helper.dart
│ │ └── main.dart # Entry Point
│ ├── pubspec.yaml
│ └── README.md
│
├── emosync-backend/ # Laravel Backend
│ ├── app/
│ │ ├── Http/
│ │ │ └── Controllers/
│ │ │ └── Api/
│ │ │ ├── AuthController.php
│ │ │ ├── ChatController.php
│ │ │ ├── ContentController.php
│ │ │ ├── FriendshipController.php
│ │ │ ├── MoodCheckinController.php
│ │ │ ├── PaymentController.php
│ │ │ ├── PremiumController.php
│ │ │ ├── ProfileController.php
│ │ │ └── SettingsController.php
│ │ └── Models/
│ │ ├── User.php
│ │ ├── MoodCheckin.php
│ │ ├── Content.php
│ │ ├── Friendship.php
│ │ ├── Chat.php
│ │ ├── Transaction.php
│ │ └── UserSetting.php
│ ├── database/
│ │ └── migrations/
│ │ ├── 0001_01_01_000000_create_users_table.php
│ │ ├── 2026_04_27_161848_create_mood_checkins_table.php
│ │ ├── 2026_06_09_142658_create_add_avatar_to_users_table.php
│ │ └── ...other migrations
│ ├── routes/
│ │ └── api.php
│ ├── .env.example
│ └── artisan
│
├── docker-compose.yml # Docker Configuration
├── README.md
└── .gitignore
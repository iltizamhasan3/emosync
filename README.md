<h1 align="center">🧠 EmoSync</h1>

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white" alt="Laravel"/>
  <img src="https://img.shields.io/badge/Railway-0B0D0E?style=for-the-badge&logo=railway&logoColor=white" alt="Railway"/>
</div>

<br/>

<p align="center">
  📱 Pantau kesehatan emosional harianmu &nbsp;·&nbsp; 🤝 Terhubung dengan teman &nbsp;·&nbsp; 🧘 Konten mindfulness & meditasi &nbsp;·&nbsp; ⭐ Fitur Premium eksklusif
</p>

<hr/>

## ✨ Fitur Utama

### 🔐 Autentikasi & Profil
| Fitur | Deskripsi |
|-------|-----------|
| 📝 Registrasi & Login | Daftar akun baru atau masuk dengan email/username |
| 🔑 Logout Aman | Hapus sesi dan data lokal |
| 👤 Profil Pengguna | Lihat & edit nama, avatar, info akun |
| 🖼️ Pilihan Avatar | Kustomisasi avatar (male/female/custom) |

### 📊 Mood Tracking
| Fitur | Deskripsi |
|-------|-----------|
| 😊 Daily Check-in | Catat mood harian dengan emoji interaktif |
| ⚡ Pemicu Mood | Identifikasi faktor pemicu mood (stres, lelah, dll) |
| 🔥 Streak Tracker | Pantau konsistensi check-in harian |
| 📈 Dashboard Statistik | Grafik distribusi mood & riwayat mingguan |
| 📝 Catatan Pribadi | Tambahkan catatan setiap check-in |

### 👥 Sosial
| Fitur | Deskripsi |
|-------|-----------|
| 🔍 Cari Teman | Temukan pengguna lain berdasarkan username |
| ➕ Tambah Teman | Kirim & terima permintaan pertemanan |
| 💬 Chat & Messaging | Ngobrol dengan teman dalam aplikasi |
| 📨 Notifikasi Pesan | Lihat jumlah pesan belum dibaca |
| 👀 Lihat Mood Teman | Lihat mood terbaru teman (jika diizinkan) |

### 📚 Konten Edukasi
| Fitur | Deskripsi |
|-------|-----------|
| 📖 Artikel Mindfulness | Baca artikel tentang kesehatan mental |
| 🎥 Video Relaksasi | Tonton video panduan meditasi |
| 🔒 Konten Premium | Akses konten eksklusif untuk pengguna Premium |

### ⭐ Premium & Pembayaran
| Fitur | Deskripsi |
|-------|-----------|
| 💎 Paket Premium | Pilih langganan (bulanan/tahunan) |
| 💳 Sistem Pembayaran | Simulasi transaksi pembayaran |
| 📋 Riwayat Transaksi | Lihat histori pembayaran |
| 🔄 Manajemen Langganan | Berlangganan atau batalkan kapan saja |

### ⚙️ Pengaturan
| Fitur | Deskripsi |
|-------|-----------|
| 🔔 Notifikasi | Atur pengingat harian, laporan mingguan |
| 🔒 Privasi | Kontrol visibilitas mood & aktivitas |
| 🆘 Bantuan & Dukungan | Pusat bantuan dan kontak support |

### 🧘 Fitur Kesehatan Tambahan
| Fitur | Deskripsi |
|-------|-----------|
| 🌬️ Latihan Pernapasan | Panduan pernapasan 4-7-8 |
| 🧘 Meditasi | Timer meditasi terpandu |
| 📓 Jurnal Pribadi | Menulis refleksi harian |
| 💧 Pelacak Hidrasi | Catat asupan air putih |
| 📵 Digital Detox | Timer untuk detoksifikasi digital |
| 🏠 Onboarding Flow | Panduan interaktif saat pertama kali pakai |

<hr/>

## 🖼️ Tangkapan Layar

| Halaman | Tampilan |
|---------|----------|
| 🏠 Beranda | Dashboard ringkasan mood & streak |
| 😊 Check-in | Pilih mood & pemicu harian |
| 👥 Teman | Daftar teman & permintaan pertemanan |
| 💬 Chat | Percakapan real-time dengan teman |
| 📚 Konten | Artikel & video mindfulness |
| 💎 Premium | Daftar paket langganan premium |

<hr/>

## 🛠️ Tech Stack

### 📱 Frontend (Flutter)
| Teknologi | Kegunaan |
|-----------|----------|
| [Flutter](https://flutter.dev/) | Framework UI cross-platform |
| [Dart](https://dart.dev/) | Bahasa pemrograman |
| [Provider](https://pub.dev/packages/provider) | State management |
| [HTTP](https://pub.dev/packages/http) | Networking & API calls |
| [SharedPreferences](https://pub.dev/packages/shared_preferences) | Penyimpanan lokal |
| [FL Chart](https://pub.dev/packages/fl_chart) | Grafik & visualisasi data |
| [URL Launcher](https://pub.dev/packages/url_launcher) | Membuka link eksternal |

### 🖥️ Backend (Laravel)
| Teknologi | Kegunaan |
|-----------|----------|
| [Laravel 11](https://laravel.com/) | Framework PHP |
| [Sanctum](https://laravel.com/docs/sanctum) | Autentikasi API token |
| [MySQL](https://www.mysql.com/) | Database relasional |
| [REST API](https://laravel.com/docs/routing) | Arsitektur API |

### ☁️ Deployment
| Teknologi | Kegunaan |
|-----------|----------|
| [Railway](https://railway.app/) | Hosting backend API & database |

<hr/>

## 🚀 Deployed API

Backend aktif di Railway:

```
https://emosync-backend-production.up.railway.app
```

<hr/>

## 📋 API Endpoints

### 🔓 Public
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| `POST` | `/api/register` | Registrasi akun baru |
| `POST` | `/api/login` | Login pengguna |
| `GET` | `/api/pemicu` | Daftar pemicu mood |
| `GET` | `/api/konten` | Daftar konten publik |

### 🔒 Protected (Auth Required)
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| `POST` | `/api/logout` | Logout & hapus token |
| `GET` | `/api/user` | Data user saat ini |
| `GET` | `/api/profile` | Lihat profil |
| `PUT` | `/api/profile` | Edit profil |
| `POST` | `/api/checkin` | Catat mood check-in |
| `GET` | `/api/checkin` | Riwayat check-in |
| `GET` | `/api/dashboard` | Dashboard statistik |
| `GET/POST` | `/api/friends` | Daftar/manage teman |
| `POST` | `/api/friends/add` | Kirim permintaan teman |
| `DELETE` | `/api/friends/{id}` | Hapus teman |
| `GET` | `/api/friends/search` | Cari pengguna |
| `GET` | `/api/friends/requests` | Permintaan teman masuk |
| `POST` | `/api/friends/accept/{id}` | Terima permintaan |
| `GET` | `/api/konten/{id}` | Detail konten |
| `GET` | `/api/settings` | Pengaturan akun |
| `PUT` | `/api/settings/notification` | Atur notifikasi |
| `PUT` | `/api/settings/privacy` | Atur privasi |
| `GET` | `/api/chat/{friendId}` | Pesan dengan teman |
| `POST` | `/api/chat/send` | Kirim pesan |
| `GET` | `/api/chat/unread/count` | Jumlah pesan baru |
| `PUT` | `/api/chat/read/{friendId}` | Tandai sudah dibaca |
| `GET` | `/api/premium/status` | Status premium |
| `GET` | `/api/premium/plans` | Daftar paket premium |
| `POST` | `/api/premium/subscribe` | Langganan premium |
| `POST` | `/api/premium/cancel` | Batalkan premium |
| `GET` | `/api/payment/plans` | Paket pembayaran |
| `POST` | `/api/payment/create` | Buat transaksi |
| `GET` | `/api/payment/status/{id}` | Cek status transaksi |
| `POST` | `/api/payment/simulate/{id}` | Simulasi bayar |
| `DELETE` | `/api/payment/cancel/{id}` | Batal transaksi |
| `GET` | `/api/payment/history` | Riwayat transaksi |

<hr/>

## 🚀 Cara Install & Jalankan

### 📱 Frontend (Flutter)

```bash
# Clone repositori
git clone https://github.com/iltizamhasan3/emosync.git
cd emosync

# Install dependencies
flutter pub get

# Jalankan di emulator
flutter run

# Build APK release (konek ke Railway)
flutter build apk --release --dart-define=API_BASE_URL=https://emosync-backend-production.up.railway.app/api

# Build APK release (konek ke backend lokal)
flutter build apk --release --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```

> **Note:** `baseUrl` dikontrol via `--dart-define=API_BASE_URL=...`. Default: `http://10.0.2.2:8000/api` (emulator Android).

### 🖥️ Backend (Laravel)

```bash
# Clone repositori backend
git clone https://github.com/iltizamhasan3/emosync-backend.git
cd emosync-backend

# Install dependencies
composer install

# Setup environment
cp .env.example .env
php artisan key:generate

# Konfigurasi database di .env, lalu migrasi
php artisan migrate

# Jalankan server lokal
php artisan serve
```

### ☁️ Backend di Railway

Backend sudah terdeploy otomatis via Railway. Setiap push ke branch `main` di [emosync-backend](https://github.com/iltizamhasan3/emosync-backend) akan mendeploy ulang.

<hr/>

## 📁 Struktur Proyek

```
emosync_app/
├── lib/
│   ├── main.dart              # Entry point aplikasi
│   ├── models/                # Model data
│   │   ├── user_model.dart
│   │   ├── mood_model.dart
│   │   ├── friend_model.dart
│   │   ├── content_model.dart
│   │   └── settings_model.dart
│   ├── providers/             # State management
│   │   └── auth_provider.dart
│   ├── screens/               # Halaman aplikasi
│   │   ├── splash_screen.dart
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── home_screen.dart
│   │   ├── daily_checkin_screen.dart
│   │   ├── friend_screen.dart
│   │   ├── chat_screen.dart
│   │   ├── content_screen.dart
│   │   ├── premium_plan_screen.dart
│   │   ├── payment_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── edit_profile_screen.dart
│   │   ├── settings_notifications_screen.dart
│   │   ├── settings_privacy_screen.dart
│   │   ├── settings_help_screen.dart
│   │   ├── journal_screen.dart
│   │   ├── meditation_screen.dart
│   │   ├── breathing_screen.dart
│   │   ├── hydration_screen.dart
│   │   ├── digital_detox_screen.dart
│   │   ├── onboarding_screen.dart
│   │   └── support_screen.dart
│   ├── services/              # Layanan API & storage
│   │   ├── api_service.dart
│   │   └── local_storage_service.dart
│   └── utils/                 # Konstanta & utilitas
│       └── constants.dart
├── web/                       # Konfigurasi web
│   └── index.html
├── pubspec.yaml
└── README.md
```

<hr/>

<div align="center">
  <p>Dibuat dengan ❤️ menggunakan Flutter & Laravel</p>
  <p>
    <a href="https://github.com/iltizamhasan3/emosync">Frontend Repo</a> •
    <a href="https://github.com/iltizamhasan3/emosync-backend">Backend Repo</a>
  </p>
</div>

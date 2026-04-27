# KOMET — Media Pembelajaran Kreativitas Digital

> Aplikasi Android berbasis visual block programming untuk membuat cerita interaktif bercabang. Mendukung penuh mode offline-first dengan sinkronisasi ke cloud saat koneksi tersedia.

**Program Studi D3 Teknik Informatika — Politeknik Negeri Bandung 2026**
**Proyek 4 — Kelompok C2**

---

## Anggota Tim

| Role | Nama | NIM |
|------|------|-----|
| Fullstack + UI/UX | Wyandhanu Maulidan Nugraha | 241511092 |
| Fullstack + Database | Helga Athifa Hidayat | 241511077 |
| Fullstack + Dokumenter | Nike Kustiane | 241511086 |
| Fullstack + Project Manager | Dzakir Tsabit Asy Syafiq | 241511071 |

---

## Tech Stack

- **Framework:** Flutter (Dart)
- **Local Storage:** Hive (offline-first)
- **Cloud Database:** MongoDB Atlas (`mongo_dart`)
- **State Management:** Clean Architecture
- **Platform:** Android

---

## Cara Clone & Setup

### 1. Clone Repository

```bash
git clone https://github.com/[username]/komet.git
cd komet
```

### 2. Install Flutter

Pastikan Flutter sudah terinstall. Cek versi:

```bash
flutter --version
```

Jika belum, ikuti panduan resmi: https://docs.flutter.dev/get-started/install

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Setup Hive

Hive digunakan untuk penyimpanan lokal (offline-first). Generate adapter jika belum ada:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. Setup MongoDB Atlas

1. Buat akun di [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. Buat cluster baru (free tier cukup)
3. Buat file `.env` di root project (jangan di-commit):

```env
MONGO_URI=mongodb+srv://<username>:<password>@cluster0.xxxxx.mongodb.net/komet
```

> ⚠️ File `.env` sudah masuk `.gitignore`. Minta connection string ke PIC B (Fullstack + Database).

### 6. Jalankan Aplikasi

```bash
flutter run
```

---

## Cara Build APK

```bash
flutter build apk --release
```

APK tersimpan di: `build/app/outputs/flutter-apk/app-release.apk`

---

## Akun Testing

Gunakan akun berikut untuk testing. Jangan ubah password tanpa koordinasi tim.

| Role | Email | Password |
|------|-------|----------|
| Guru | `guru.test@komet.dev` | `KometGuru2026` |
| Siswa | `siswa.test@komet.dev` | `KometSiswa2026` |

---

## Struktur Folder

```
komet-app/
  lib/
    core/             — PIC D (Foundation: Routing, DI, Theme, Base Classes) 
    data/             — PIC B (Models, Hive service, MongoDB Atlas setup) 
    features/
      auth/           — PIC A (Login, Register Guru/Siswa, Persistence) 
      kelas/          — PIC B (Manajemen Kelas & Daftar Siswa) 
      assignment/     — PIC A (Manajemen Tugas & Deadline) 
      dashboard/      — PIC B (Helga - Guru) & PIC C (Nike - Siswa) 
      editor_engine/  — PIC D (Logic Interpreter: Cara blok diproses jadi cerita) 
      editor_canvas/  — PIC D (UI Foundation: Drag-and-drop & Canvas area) 
      editor_assets/  — PIC C (Manajemen Karakter & Background) 
      editor_script/  — PIC C (Logika Alur: Percabangan & Variabel Karakter) 
      submission/     — PIC B (Local storage handling & Submit logic) 
      subm_view/      — PIC C (Interface pengerjaan & preview siswa) 
      review/         — PIC A (Interface penilaian & feedback guru) [cite: 4]
      sync/           — PIC B (Sync Manager: Antrian & Deteksi Koneksi) 
      notifikasi/     — PIC A (In-app notification system) [cite: 4]
  docs/               
    spec_arch/        — PIC D (Spesifikasi teknis & Diagram Arsitektur) 
    ui_design/        — PIC C (Wireframe & Design System) 
    test_report/      — PIC D (Unit Testing & Laporan Bug) [cite: 4]
    logbook/          — PIC D (Manajemen Progress Tim) 
  README.md           — PIC D (Dokumentasi Setup & Run) 
  .gitignore
  pubspec.yaml        — PIC D (Dependency Management)
```

---

## Branching Strategy

| Branch | Fungsi |
|--------|--------|
| `main` | Kode stabil — tidak boleh push langsung |
| `develop` | Branch utama pengembangan |
| `feature/nama-fitur` | Setiap fitur baru dari `develop` |
| `hotfix/nama-bug` | Perbaikan bug mendesak dari `main` |

**Alur kerja:**
1. Buat branch dari `develop`: `git checkout -b feature/nama-fitur`
2. Kerjakan fitur, commit secara rutin
3. Buat Pull Request ke `develop`
4. Setelah di-review dan approve, merge ke `develop`
5. Setiap akhir milestone, merge `develop` ke `main`

---

## Aturan Commit Message

```
feat: tambah fitur login guru
fix: perbaiki bug sesi login tidak tersimpan
docs: update README cara setup MongoDB
refactor: pisahkan HiveService ke core/data
test: tambah unit test blok alur cerita
chore: update pubspec dependency
```

---

## Timeline Proyek

| Minggu | Fokus | Milestone |
|--------|-------|-----------|
| 1 | Fondasi — setup project, auth, model data | Repo aktif, auth berjalan |
| 2 | Dashboard — assignment guru, dashboard siswa, MongoDB | MongoDB terhubung |
| 3 | Canvas — editor cerita, blok konten, auto-save | Milestone 1 Report |
| 4 | Scripting — blok alur, variabel, story map, read mode | Semua blok selesai |
| 5 | Sync — submit, sync manager, review guru | Milestone 2 Report |
| 6 | Testing — unit test, e2e, bug fix, APK release | APK release siap |
| 7 | Presentasi — slide, video demo, dokumen final | Demo live |

---

## Lisensi

Proyek ini dibuat untuk keperluan akademik — Proyek 4, D3 Teknik Informatika, Politeknik Negeri Bandung 2026.

# 🌿 LokaNusantara: Aplikasi Rekomendasi Destinasi Wisata & Kuliner Lokal (Malang Raya & Kota Batu)

> **Proyek Ujian Tengah Semester (UTS) - Praktikum Mobile Programming**  
> **Mata Kuliah:** Mobile Programming  
> **Semester:** Ganjil 2025/2026  
> **Framework:** Flutter (Dart SDK ^3.13.2 / Flutter 3.47+)  
> **Arsitektur:** Clean Architecture (Model-View-Data/Assets)  
> **Design System:** Figma And Google Stitch MCP Design System (Emerald Teal `#0D9488`, Warm Amber `#F59E0B`, Terracotta `#C36D4B`)

---

## 📌 1. Deskripsi & Tujuan Proyek

**LokaNusantara** adalah aplikasi mobile cerdas berbasis Flutter yang dirancang untuk memberikan rekomendasi komprehensif mengenai destinasi wisata unggulan (wisata alam, cagar budaya/sejarah, wahana rekreasi keluarga) serta kuliner legendaris otentik di wilayah Malang Raya dan Kota Wisata Batu, Jawa Timur.

### Tujuan Utama Aplikasi:
1. **Pemandu Wisata & Kuliner Konkret:** Menyajikan data konkret 16 destinasi nyata yang terverifikasi (harga tiket, jam buka, fasilitas, ulasan, foto, dan koordinat GPS presisi).
2. **Pengalaman Pengguna (UX) Minimalis & Modern:** Mengadopsi prinsip desain antarmuka bersih (*clean interface*), bernafas (*breathing whitespace*), dan berkontras tinggi agar mudah dibaca di luar ruangan.
3. **Penerapan Kurikulum Praktikum Modul 01 - 13:** Seluruh fitur dan kode sumber disusun secara terstruktur untuk mengimplementasikan materi praktikum secara nyata dan mudah dipelajari.

---

## 📱 2. Tampilan Antarmuka & Wireframe (Figma MCP)


| 1. Beranda (Home Page) | 2. Eksplor (Category Page) | 3. Detail (Detail Page) |
| :---: | :---: | :---: |
| ![Home Screen](assets/stitch_wireframes/01_Home_Screen.png) | ![Category Screen](assets/stitch_wireframes/02_Category_Explore_Screen.png) | ![Detail Screen](assets/stitch_wireframes/03_Detail_Screen_Gunung_Bromo.png) |

---

## 🗂️ 3. Struktur Proyek (Project Structure)

```text
UTS_Aplikasi_Rekomendasi_Destinasi_Wisata_Kuliner_Lokal/
├── assets/
│   ├── data/
│   │   └── destinations.json         # 16 Data konkret destinasi Malang & Batu
│   └── figma/                        # Aset PNG  
│       ├── home_page.png
│       ├── eksplor_page.png
│       ├── saved_page.png
│       ├── profile_page.png
│       ├── detail_page.png
│       ├── mockup.png
│       └── desain_system.png
├── lib/
│   ├── assets/
│   │   └── data/
│   │       └── destinations.json     # Backup aset data lokal
│   ├── models/
│   │   └── destination_model.dart    # Model Class Dart (fromJson, toJson, copyWith)
│   ├── views/
│   │   ├── home_page.dart            # Beranda, GPS, Search & Carousel
│   │   ├── profile_page.dart         # Menampilkan Profil 
│   │   ├── saved_page.dart           # Menyimpan Destinasi Favorit
│   │   ├── category_page.dart        # Filter Kategori & Sort Card Feed
│   │   └── detail_page.dart          # Hero Banner, Stats, GPS Card & CTA
│   └── main.dart                     # Inisialisasi tema & Named Routes
├── test/
│   └── widget_test.dart              # Pengujian unit/smoke test widget
├── pubspec.yaml                      # Konfigurasi dependensi & aset proyek
└── README.md                         # Dokumentasi panduan utama proyek
```

---

## 📑 4. Rincian Halaman dan Fungsinya

### 1. `HomePage` (`lib/views/home_page.dart`)
* **Header Bar GPS Interaktif (Modul 12):** Menampilkan posisi geografis pengguna (*Klojen, Kota Malang*) dengan tombol penyegaran lokasi.
* **Search Input (Modul 10):** Kolom pencarian dinamis yang memfilter nama tempat, kecamatan, kota, dan kategori secara real-time.
* **Category Chips Selector (Modul 02 & 06):** Deretan filter horizontal berkategori (*Semua, Wisata Alam, Budaya & Edukasi, Wahana Rekreasi, Kuliner Legendaris, Kafe & Santai*).
* **Featured Destinations Carousel (Modul 04 & 05):** Kartu horizontal destinasi bertaraf rating tertinggi dengan foto visual, rating emas, harga tiket, dan tombol simpan favorit (Modul 09).
* **Kuliner Legendaris List (Modul 06):** Daftar kuliner otentik vertikal dengan waktu buka, kisaran harga, dan rating.
* **Bottom Navigation Bar (Modul 04 & 05):** Navigasi 4 tab (*Beranda, Eksplor, Disimpan, Akun*).

### 2. `CategoryPage` (`lib/views/category_page.dart`)
* **Top App Bar dengan Navigator.pop (Modul 07):** Navigasi kembali ke beranda.
* **Category Chips dengan Badge Counter:** Menghitung otomatis jumlah destinasi per kategori (*Semua (16), Wisata Alam (4), Kuliner Legendaris (5), dll.*).
* **Opsi Pengurutan (Sorting):** Menyaring destinasi berdasarkan *Populer (Ulasan terbanyak)*, *Harga Terendah*, atau *Rating > 4.6*.
* **Feed Kartu Destinasi (Modul 05 & 06):** Menggunakan `ListView.builder` untuk menampilkan kartu lengkap dengan thumbnail, tag kategori, tombol bookmark, dan tombol *"Lihat Detail"*.

### 3. `DetailPage` (`lib/views/detail_page.dart`)
* **Argument Passing (Modul 08):** Menerima objek utuh `DestinationModel` dari halaman sebelumnya melalui `ModalRoute.of(context)!.settings.arguments`.
* **Hero Photography Banner (Modul 10):** Foto lanskap berukuran 320px dengan tombol kembali melayang.
* **Interactive Bookmark Toggle (Modul 09):** Mengubah status favorit destinasi secara dinamis dengan pembaruan instan dan notifikasi `SnackBar`.
* **Quick Stats Box (Modul 03, 04, 05):** 3 kotak metrik sejajar: ⭐ *Rating (4.9)*, 🕒 *Jam Buka (24 Jam)*, dan 📍 *Kecamatan/Kota*.
* **Fasilitas & Layanan:** Tag chips representatif (*Sewa Jeep 4x4, Kuda, Musholla, Spot Sunrise, dll.*).
* **GPS Coordinates & Map Integration Card (Modul 12):** Menampilkan koordinat garis lintang & bujur presisi serta tombol integrasi Google Maps.
* **Fixed Bottom Action Bar (Modul 04):** Ringkasan tiket/biaya dan tombol aksi utama *"Petunjuk Arah"*.

### 4. `SavedPage` (`lib/views/saved_page.dart`) - *Halaman Disimpan / Favorit*
* **Koleksi Favorit Reaktif (Modul 09):** Menampilkan seluruh destinasi wisata dan kuliner yang telah disimpan oleh pengguna.
* **Filter Kategori Cepat:** Chip horizontal untuk menyaring koleksi disimpan (*Semua, Wisata Alam, Kuliner*).
* **Manajemen State Dinamis:** Menghapus item dari daftar favorit secara langsung dengan tombol hapus/batal dan pembaruan instan (*Modul 09, 13*).
* **Empty State Estetik:** Tampilan visual ramah saat belum ada destinasi yang disimpan, disertai tombol jalan pintas untuk mulai menjelajah.

### 5. `ProfilePage` (`lib/views/profile_page.dart`) - *Halaman Akun & Profil Mahasiswa*
* **Header Kartu Mahasiswa (Modul 05):** Menampilkan foto profil dengan border aksen Emerald Teal, nama lengkap (**Muhammad Nailul Ghufron Majid**), NIM (**240605110160**), dan badge resmi kampus **🎓 UIN Maulana Malik Ibrahim Malang**.
* **Quick Stat Row (Modul 04 Expanded):** 3 box metrik sejajar: *Disimpan*, *12 Dikunjungi*, dan *8 Ulasan*.
* **Menu Pengaturan & Praktikum:**
    * *Koleksi Favorit Saya* (jalan pintas ke tab Disimpan).
    * *Status Lokasi GPS Aktif* (Modul 12, menampilkan *Klojen, Kota Malang*).
    * *Dialog Catatan Modul Praktikum 01-13* (daftar verifikasi penyelesaian seluruh modul).
    * *Tentang Aplikasi LokaNusantara* (v1.0.0 UTS Mobile Programming).
    * *Dialog Konfirmasi Reset Data* (Modul 13).

---

## 🎨 5. Design System Tokens (Stitch Canvas)

* **Palet Warna:**
    * **Primary (Emerald Teal):** `#0D9488`
    * **Primary Dark:** `#0F766E`
    * **Primary Light / Tint:** `#CCFBF1`
    * **Secondary / Accent (Warm Amber):** `#F59E0B`
    * **Tertiary (Terracotta):** `#C36D4B`
    * **Surface:** `#FFFFFF`
    * **Background:** `#F8FAFC`
    * **Border:** `#E2E8F0`
    * **Text Primary:** `#0F172A`
    * **Text Muted:** `#64748B`
    * **Favorite Red:** `#EF4444`
* **Tipografi:** Plus Jakarta Sans / Poppins (Display 22-24sp bold, Headline 16-18sp semibold, Body 13-14sp regular, Caption 10-12sp medium).

---

## 🚀 6. Cara Menjalankan Aplikasi

### A. Prasyarat (Prerequisites)
* Flutter SDK (versi 3.16+ atau 3.47+).
* Android Studio / VS Code dengan plugin Flutter terpasang.
* Emulator Android (AVD) atau Smartphone Android fisik dengan USB Debugging aktif.

### B. Langkah Eksekusi

1. **Buka Terminal pada direktori proyek:**
   ```bash
   cd C:\Users\nailul\Documents\android_studio_projects\uts_lokanusantara_app
   ```

2. **Periksa kelengkapan dependensi:**
   ```bash
   flutter pub get
   ```

3. **Verifikasi kesehatan kode program:**
   ```bash
   flutter analyze
   ```
   *(Hasil pengujian: No issues found! 0 errors, 0 warnings)*

4. **Jalankan tes otomatis:**
   ```bash
   flutter test
   ```
   *(Hasil pengujian: All tests passed!)*

5. **Jalankan aplikasi pada emulator atau perangkat fisik:**
   ```bash
   flutter run
   ```

---

## 👨‍💻 Identitas Pengembang
* **Nama Mahasiswa:** Muhammad Nailul Ghufron Majid
* **NIM:** 240605110160
* **Mata Kuliah:** Praktikum Mobile Programming
* **Institusi:** UIN Maulana Malik Ibrahim Malang

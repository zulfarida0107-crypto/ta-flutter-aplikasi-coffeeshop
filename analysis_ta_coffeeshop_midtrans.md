# 📊 Analisis Tugas Akhir — Coffee Shop "Classic Coffee / Kopi Kenangan Petang"

## 🎯 Ringkasan Situasi

Kalian sudah memiliki **3 komponen** proyek:

| # | Komponen | Teknologi | Status |
|---|----------|-----------|--------|
| 1 | **Web User** (repo ini) | PHP Native + Alpine.js + Midtrans | ✅ Sudah jalan, tapi **bukan CI4** |
| 2 | **Admin Dashboard Web** | CodeIgniter 4 | ✅ Ada (repo terpisah) |
| 3 | **Admin Dashboard Mobile** | Flutter (offline, Android Studio) | ✅ Ada (repo terpisah) |

---

## 🔍 Gap Analysis: Ketentuan TA vs Kondisi Saat Ini

| Ketentuan Dosen | Status | Penjelasan |
|:---|:---:|:---|
| **Web: CI (CodeIgniter)** | ⚠️ PARTIAL | Admin dashboard sudah CI4, tapi **web user (repo ini) masih PHP Native** — bukan CI4 |
| **Mobile Apps: Flutter** | ⚠️ PARTIAL | Ada, tapi masih **offline** (belum terkoneksi API/database online) |
| **API: Spring Boot** | ❌ BELUM ADA | Belum ada API layer sama sekali. Ini **komponen kunci** yang menghubungkan semuanya |
| **DB (min 5 tabel): MySQL** | ✅ TERPENUHI | Sudah ada 5 tabel: `menu`, `user`, `pesanan`, `detail_pesanan`, `pesan_kontak` |
| **Responsive** | ✅ TERPENUHI | Web user sudah responsive (ada CSS media queries) |
| **Blackbox Testing** | ❌ BELUM | Belum ada dokumen/skenario testing |
| **Wireframe: Figma** | ⚠️ PARTIAL | Disebutkan tinggal Figma, tapi belum disambungkan dengan project nyata |
| **Hosting (opsional)** | ⏳ Belum | Opsional, bisa belakangan |
| **Git (opsional)** | ✅ TERPENUHI | Repo ini sudah di GitHub |

---

## 🚨 Masalah Kritis yang Harus Diselesaikan

### 1. Web User Bukan CI4 (KRITIS)
Repo ini ([index.php](file:///c:/Dokumen/midtrans-coffee-web/kopi-kenangan-petang/index.php)) menggunakan **PHP Native** dengan Alpine.js, bukan CodeIgniter 4.

> [!CAUTION]
> Dosen mensyaratkan **web pakai CI**. Web user saat ini hanya PHP biasa + Midtrans. Jika dinilai, ini bisa **tidak memenuhi ketentuan**.

**Opsi solusi:**
- **Opsi A (Recommended):** Ubah web CI4 admin menjadi web utama yang mencakup admin + user-facing pages. Tambahkan halaman publik (menu, pemesanan, kontak) di dalam project CI4 yang sudah ada.
- **Opsi B:** Migrasi web user ini ke CI4 (butuh rombak controller, routes, views — cukup effort tapi terstruktur).

### 2. Belum Ada Spring Boot API (KRITIS)

> [!CAUTION]
> Ini **GAP terbesar**. Tanpa Spring Boot API, Flutter tidak bisa online dan integrasi antar komponen tidak terjadi.

Spring Boot API menjadi **jembatan** antara:
- Flutter Mobile ↔ Database MySQL
- Web CI4 ↔ Database MySQL (opsional, CI4 bisa langsung ke DB juga)

### 3. Flutter Masih Offline (KRITIS)

> [!WARNING]
> Flutter saat ini berjalan offline (data lokal). Harus diubah agar mengakses Spring Boot REST API agar terintegrasi dengan sistem.

---

## 🏗️ Arsitektur yang Direkomendasikan

```
┌─────────────────────────────────────────────────────────────┐
│                    ARSITEKTUR SISTEM TA                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐     ┌──────────────────┐                  │
│  │  Web CI4     │────▶│                  │                  │
│  │  (Admin +    │     │  Spring Boot     │                  │
│  │   User Web)  │     │  REST API        │                  │
│  └──────────────┘     │                  │     ┌──────────┐ │
│                       │  /api/menu       │────▶│  MySQL   │ │
│  ┌──────────────┐     │  /api/pesanan    │     │  DB      │ │
│  │  Flutter     │────▶│  /api/user       │     │          │ │
│  │  Mobile App  │     │  /api/pesan      │     │ 5+ tabel │ │
│  │  (Admin)     │     │  /api/pembayaran │     └──────────┘ │
│  └──────────────┘     └──────────────────┘                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Penjelasan Alur:
1. **Web CI4** → Bisa langsung ke MySQL ATAU melalui Spring Boot API
2. **Flutter** → **WAJIB** melalui Spring Boot API (HTTP client seperti `http` / `dio` package)
3. **Spring Boot API** → Mengelola semua CRUD ke MySQL, menjadi single source of truth
4. **MySQL** → Database terpusat, minimal 5 tabel

---

## 💡 Saran & Pendapat

### Tentang Midtrans
> [!IMPORTANT]
> **Saran: Hapus Midtrans dari scope TA ini.**

Alasan:
- Midtrans memperkompleks proyek tanpa menambah nilai terhadap ketentuan TA
- Dosen tidak meminta payment gateway pihak ketiga
- Fokuskan energi ke integrasi CI4 + Spring Boot + Flutter
- Ganti dengan **sistem konfirmasi pembayaran manual** (upload bukti transfer) yang lebih realistis dan lebih mudah diimplementasi

### Tentang Fokus Admin vs User
Berdasarkan diskusi kalian, ada 2 opsi:

| Aspek | Opsi 1: Admin + User | Opsi 2: Admin Only |
|:---|:---|:---|
| **Scope** | Lebih besar, lebih lengkap | Lebih kecil, lebih fokus |
| **Nilai TA** | Lebih tinggi (end-to-end) | Cukup jika disetujui dosen |
| **Effort** | Tinggi | Sedang |
| **Risiko** | Bisa tidak selesai tepat waktu | Aman |
| **Rekomendasi** | ✅ **Pilih ini jika masih ada waktu** | ⚠️ Pilih ini jika mepet |

**Rekomendasi saya: Opsi 1** — buat Admin + User, karena:
- Membuat alur bisnis lebih masuk akal (user pesan → admin kelola)
- Semua ketentuan TA lebih mudah terpenuhi
- Web CI4 punya 2 sisi: public pages (user) + admin panel

### Tentang Database (Sudah OK, tapi bisa diperkuat)

5 tabel saat ini ([classic_coffee_setup.sql](file:///c:/Dokumen/midtrans-coffee-web/kopi-kenangan-petang/classic_coffee_setup.sql)):
1. `menu` ✅
2. `user` ✅
3. `pesanan` ✅
4. `detail_pesanan` ✅
5. `pesan_kontak` ✅

**Tambahan tabel yang disarankan untuk memperkuat:**

| Tabel | Deskripsi | Tujuan |
|:---|:---|:---|
| `kategori_menu` | Kategori produk (Kopi, Non-Kopi, Makanan, Dessert) | Normalisasi data menu |
| `pembayaran` | Tracking pembayaran per pesanan | Ganti Midtrans, bisa manual |
| `desain_pesanan` | Custom cake orders | Sudah ada di admin Flutter, perlu tabel DB |

Dengan ini total bisa **7-8 tabel** — lebih kuat untuk nilai TA.

---

## 📋 Workflow Pengerjaan yang Direkomendasikan

### Phase 1: Persiapan & Desain (2-3 hari)
- [ ] **Finalisasi database schema** — tambah tabel yang kurang, pastikan relasi antar tabel benar
- [ ] **Buat/lengkapi wireframe Figma** — versi mobile (Flutter) dan versi web (CI4)
- [ ] **Buat ERD (Entity Relationship Diagram)** — wajib untuk dokumentasi TA
- [ ] **Buat Use Case Diagram** — aktor: Admin, Kasir, User/Pelanggan
- [ ] **Konfirmasi ke Bu Ayu** — apakah scope Admin+User atau Admin only

### Phase 2: Spring Boot API (3-5 hari) ← PRIORITAS TERTINGGI
- [ ] **Setup project Spring Boot** dengan Spring Initializr:
  - Dependencies: Spring Web, Spring Data JPA, MySQL Driver, Lombok
- [ ] **Buat entity classes** untuk setiap tabel (Menu, User, Pesanan, dll)
- [ ] **Buat Repository interfaces** (JpaRepository)
- [ ] **Buat REST Controller** dengan endpoint:

```
GET    /api/menu              → Daftar semua menu
POST   /api/menu              → Tambah menu (admin)
PUT    /api/menu/{id}         → Update menu (admin)
DELETE /api/menu/{id}         → Hapus menu (admin)

GET    /api/pesanan           → Daftar pesanan
POST   /api/pesanan           → Buat pesanan baru
PUT    /api/pesanan/{id}      → Update status pesanan
DELETE /api/pesanan/{id}      → Hapus pesanan

GET    /api/user              → Daftar user
POST   /api/user/login        → Login
POST   /api/user              → Register

GET    /api/pesan-kontak      → Daftar pesan masuk
POST   /api/pesan-kontak      → Kirim pesan
PUT    /api/pesan-kontak/{id} → Update status baca

GET    /api/pembayaran        → Daftar pembayaran
POST   /api/pembayaran        → Konfirmasi pembayaran
```

- [ ] **Test API** menggunakan Postman/Thunder Client
- [ ] **Buat dokumentasi API** (endpoint list + request/response format)

### Phase 3: Integrasi Flutter (3-4 hari)
- [ ] **Tambah package HTTP** (`http` atau `dio`) di Flutter
- [ ] **Buat service/provider classes** untuk setiap entity
- [ ] **Hubungkan setiap halaman Flutter** ke API endpoint yang sesuai
- [ ] **Test di emulator** — pastikan CRUD berjalan online
- [ ] **Handle error states** (no internet, server down, dll)

### Phase 4: Web CI4 (3-4 hari)
- [ ] **Pastikan admin dashboard CI4** berfungsi lengkap:
  - Manajemen User (CRUD) ✅
  - Menu Produk (CRUD) ✅
  - Pesanan (CRUD) ✅
  - Desain Pesanan (CRUD) ✅
  - Pesan Masuk (DR) ✅
  - Pembayaran ✅
- [ ] **Tambahkan halaman publik** di CI4 (jika scope Admin+User):
  - Landing page (informasi toko)
  - Katalog menu
  - Form pemesanan online
  - Form kontak
- [ ] **Pastikan responsive** di semua halaman
- [ ] **Opsional:** CI4 bisa consume Spring Boot API, ATAU langsung ke MySQL

### Phase 5: Blackbox Testing (2-3 hari)
- [ ] **Buat dokumen Test Case** format tabel:

```
| No | Skenario | Langkah | Input | Expected Output | Actual Output | Status |
|----|----------|---------|-------|-----------------|---------------|--------|
| 1  | Login valid | Buka halaman login, isi username & password | admin/admin123 | Masuk ke dashboard | - | - |
| 2  | Login invalid | Isi username/password salah | admin/salah | Tampil pesan error | - | - |
```

- [ ] **Test semua fitur** di web CI4 dan Flutter:
  - Login/Logout
  - CRUD Menu
  - CRUD Pesanan
  - CRUD User
  - Kirim & Baca Pesan
  - Konfirmasi Pembayaran
- [ ] **Screenshot setiap test case** untuk lampiran laporan

### Phase 6: Finalisasi (2-3 hari sebelum presentasi)
- [ ] **Finalisasi wireframe Figma** — pastikan sesuai aplikasi final
- [ ] **Push semua ke Git** (GitHub)
- [ ] **Hosting** (opsional) — bisa pakai Railway/Render untuk Spring Boot, Hostinger/InfinityFree untuk CI4
- [ ] **Siapkan presentasi** — demo live + slide
- [ ] **Buat dokumentasi teknis** (ERD, flowchart, arsitektur sistem)

---

## ⏰ Estimasi Timeline

Berdasarkan presentasi **18-19 Juni** (dari chat), kalian punya sekitar **10 hari**.

```
8 Jun  ─── Hari ini (analisis & planning)
9-10   ─── Phase 1: Database + Figma + Diagram
11-13  ─── Phase 2: Spring Boot API (PRIORITAS!)
14-15  ─── Phase 3: Flutter → API integrasi
14-15  ─── Phase 4: CI4 finalisasi (paralel dengan Flutter)
16-17  ─── Phase 5: Blackbox Testing + Dokumentasi
18-19  ─── PRESENTASI 🎤
```

> [!WARNING]
> Timeline ini **sangat ketat**. Pembagian tugas yang jelas antara kalian berdua (Namira & Zulfarida) sangat penting!

### Saran Pembagian Tugas:

| Person | Fokus Utama |
|:---|:---|
| **Person A** | Spring Boot API + Database + Flutter integrasi |
| **Person B** | Web CI4 (admin + public pages) + Figma + Blackbox Testing |
| **Bersama** | Testing akhir + Presentasi + Dokumentasi |

---

## 🎯 Kesimpulan & Action Items Prioritas

1. **🔴 URGENT:** Buat Spring Boot REST API — ini fondasi integrasi semua komponen
2. **🔴 URGENT:** Ubah Flutter dari offline → online (consume API)
3. **🟡 PENTING:** Pastikan web CI4 lengkap dan responsive
4. **🟡 PENTING:** Buat wireframe Figma untuk web + mobile
5. **🟢 BISA PARALEL:** Blackbox testing document
6. **🟢 OPSIONAL:** Hosting & Git (sudah ada Git sebagian)

> [!TIP]
> **Soal Midtrans di repo ini:** Repo ini bisa dijadikan **referensi desain UI** saja. Ambil inspirasi tampilan dan layout-nya, tapi implementasi final harus di dalam project CI4. Jangan presentasikan repo PHP Native ini sebagai web CI — dosen bisa langsung mendeteksi perbedaannya.

---

## 📂 Status Repo Ini (midtrans-coffee-web)

File-file penting di repo ini dan perannya ke depan:

| File | Peran Saat Ini | Peran ke Depan |
|:---|:---|:---|
| [index.php](file:///c:/Dokumen/midtrans-coffee-web/kopi-kenangan-petang/index.php) | Halaman utama user (PHP Native) | **Referensi UI** untuk CI4 views |
| [app.js](file:///c:/Dokumen/midtrans-coffee-web/kopi-kenangan-petang/src/app.js) | Cart + Midtrans checkout logic | **Referensi logika** keranjang belanja |
| [style.css](file:///c:/Dokumen/midtrans-coffee-web/kopi-kenangan-petang/css/style.css) | Styling responsive | **Bisa reuse** di CI4 views |
| [classic_coffee_setup.sql](file:///c:/Dokumen/midtrans-coffee-web/kopi-kenangan-petang/classic_coffee_setup.sql) | Schema 5 tabel | **Basis schema** untuk Spring Boot entities |
| [placeOrder.php](file:///c:/Dokumen/midtrans-coffee-web/kopi-kenangan-petang/php/placeOrder.php) | Midtrans integration | **Tidak dipakai** (ganti manual payment) |
| [koneksi.php](file:///c:/Dokumen/midtrans-coffee-web/kopi-kenangan-petang/koneksi.php) | Direct MySQL connection | **Tidak dipakai** (ganti Spring Boot JPA) |

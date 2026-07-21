# Panduan Menjalankan Aplikasi Flutter di Emulator Android Studio

## 1. Siapkan Emulator di Android Studio
1. Buka **Android Studio**.
2. Pergi ke menu **Tools** > **Device Manager** (atau ikon Device Manager di panel kanan).
3. Pilih salah satu Virtual Device (Emulator), lalu klik tombol **Play** (▶️) untuk menjalankannya.
4. Tunggu hingga layar emulator menyala dan masuk ke tampilan utama Android (Home Screen).

## 2. Pastikan Emulator Terdeteksi
1. Buka Terminal
2. Jalankan perintah berikut untuk mengecek daftar *device* yang aktif:
   ```bash
   flutter devices
   ```
4. Anda akan melihat nama emulator Anda dalam daftar (misalnya `emulator-5554` atau `sdk gphone64...`).

## 3. Jalankan Aplikasi
1. Jika hanya ada satu *device* (emulator) yang aktif, bisa langsung menjalankan perintah:
   ```bash
   flutter run
   ```
2. Jika ada lebih dari satu device (misalnya ada browser Chrome aktif atau device lain), gunakan perintah berikut dengan memasukkan ID device emulator Anda:
   ```bash
   flutter run -d emulator-5554
   ```
3. *(Catatan: Proses pertama kali run / build akan memakan waktu sedikit lebih lama karena Flutter harus mengunduh dependensi Gradle dan menyusun file APK).*

## 4. Lihat Hasil Output
1. Jika proses *build* tidak memiliki error (`assembleDebug` berhasil), terminal akan menampilkan pesan **"Syncing files to device..."**.
2. Aplikasi akan otomatis terbuka dan tampil langsung di layar emulator Anda.

## 5. Fitur Bantuan Saat Aplikasi Berjalan (Hot Reload)
Saat aplikasi sedang berjalan di terminal, Anda dapat menggunakan tombol berikut tanpa harus mematikan dan menjalankan ulang aplikasi:
* Tekan **`r`** (huruf kecil): **Hot Reload** (Memuat ulang perubahan kode UI secara instan dalam beberapa detik).
* Tekan **`R`** (huruf kapital): **Hot Restart** (Memuat ulang aplikasi secara penuh dari awal).
* Tekan **`q`** : Keluar / Menghentikan berjalannya aplikasi.
* Tekan **`h`** : Menampilkan daftar opsi lengkap di terminal.



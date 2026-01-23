# Projek Agate (4.4)

Projek Agate adalah game 2D yang dikembangkan menggunakan Godot Engine versi 4.4. Game ini menerapkan sistem state machine untuk mengatur perilaku karakter dan memiliki sistem gerakan pemain serta AI musuh dasar.

## Daftar Isi
- [Deskripsi](#deskripsi)
- [Fitur Utama](#fitur-utama)
- [Struktur Proyek](#struktur-proyek)
- [Persyaratan Sistem](#persyaratan-sistem)
- [Instalasi dan Setup](#instalasi-dan-setup)
- [Kontribusi Tim](#kontribusi-tim)
- [Workflow Kolaborasi](#workflow-kolaborasi)
- [Manajemen Git](#manajemen-git)
- [Testing dan Debugging](#testing-dan-debugging)
- [Build dan Deployment](#build-dan-deployment)
- [Troubleshooting](#troubleshooting)
- [Lisensi](#lisensi)

## Deskripsi

Game ini merupakan proyek kolaboratif tim yang dirancang sebagai game aksi petualangan 2D. Pemain dapat bergerak dalam empat arah, menyerang, dan berinteraksi dengan lingkungan dan musuh. Sistem state machine digunakan untuk mengelola transisi antara berbagai perilaku karakter seperti idle, berjalan, dan menyerang.

## Fitur Utama

- Sistem kontrol pemain 2D dengan animasi
- State machine untuk manajemen perilaku karakter
- AI musuh dasar dengan deteksi pemain
- Animasi karakter untuk berbagai arah gerak
- Sistem input yang responsif
- Arsitektur modular untuk ekspansi fitur

## Struktur Proyek

```
projek-agate-(4.4)/
├── .editorconfig              # Konfigurasi format kode
├── .gitattributes             # Atribut Git
├── .gitignore                 # File yang diabaikan oleh Git
├── project.godot              # File konfigurasi utama Godot
├── dunia.tscn                 # Scene utama dunia game
├── icon.svg                   # Ikon proyek
├── player.gd                  # Script kontrol pemain utama
├── enemy.gd                   # Script AI musuh
├── state.gd                   # Base class untuk state machine
├── animated_sprite_2d.gd      # Script animasi sprite
├── states/                    # Subdirektori untuk state-state karakter
│   ├── IdleState.gd           # State idle pemain
│   ├── JalanState.gd          # State berjalan pemain
│   └── SerangState.gd         # State menyerang pemain
├── arts/                      # Aset visual
│   ├── characters/            # Sprite karakter
│   ├── objects/               # Objek dunia
│   ├── particles/             # Efek partikel
│   └── tilesets/              # Tileset dunia
└── .godot/                    # Data internal Godot (diabaikan oleh Git)
```

## Persyaratan Sistem

- Godot Engine versi 4.4 atau lebih baru
- Sistem operasi: Windows, macOS, atau Linux
- RAM minimal 4GB (disarankan 8GB untuk pengembangan)
- Ruang penyimpanan kosong minimal 500MB

## Instalasi dan Setup

### Prasyarat
Pastikan Anda telah menginstal Godot Engine versi 4.4 atau lebih baru.

### Langkah-langkah Instalasi

1. Clone repositori ini:
   ```bash
   git clone <URL_REPOSITORI_INI>
   cd projek-agate-(4.4)
   ```

2. Buka proyek di Godot:
   - Jalankan Godot Editor
   - Klik "Import" dan pilih file `project.godot` di direktori proyek
   - Klik "Import & Edit"

3. Pastikan semua aset dimuat dengan benar
4. Jalankan proyek dengan menekan tombol F5 atau klik tombol "Play" di Godot Editor

## Kontribusi Tim

Tim terdiri dari 3 anggota dengan pembagian tugas sebagai berikut:

### Pembagian Peran
- **Programmer 1**: Pengembangan sistem inti (state machine, kontrol pemain)
- **Programmer 2**: Implementasi AI musuh dan sistem pertempuran
- **Programmer 3**: Implementasi grafik, animasi, dan UI

### Tanggung Jawab Umum
- Menjaga kualitas kode sesuai standar tim
- Melakukan code review sebelum merge
- Membuat dokumentasi kode yang jelas
- Mengupdate README saat ada perubahan signifikan

## Workflow Kolaborasi

### Git Workflow
Kami menggunakan model Git Flow sederhana:

1. **Main Branch**: Kode produksi yang stabil
2. **Develop Branch**: Kode untuk pengembangan aktif
3. **Feature Branches**: Cabang untuk fitur individual (nama: `feature/nama-fitur`)
4. **Hotfix Branches**: Cabang untuk perbaikan cepat (nama: `hotfix/nama-perbaikan`)

### Alur Kerja Harian
1. Pull perubahan terbaru dari branch develop:
   ```bash
   git checkout develop
   git pull origin develop
   ```

2. Buat branch baru untuk fitur yang akan dikerjakan:
   ```bash
   git checkout -b feature/nama-fitur
   ```

3. Lakukan perubahan dan commit secara berkala:
   ```bash
   git add .
   git commit -m "Deskripsi singkat perubahan"
   ```

4. Push branch ke remote:
   ```bash
   git push origin feature/nama-fitur
   ```

5. Buat Pull Request ke branch develop ketika fitur selesai

### Standar Penamaan
- **Branch**: `feature/nama-fitur`, `bugfix/deskripsi-bug`, `hotfix/perbaikan-urgent`
- **Commit**: Gunakan format imperatif, contoh: "Tambah sistem serangan pemain", "Perbaiki bug deteksi tabrakan"
- **File GDScript**: Gunakan format snake_case, contoh: `player_controller.gd`, `enemy_ai.gd`

## Manajemen Git

### Git Hooks (Opsional)
Untuk menjaga kualitas kode, Anda dapat mengatur pre-commit hooks:

1. Buat file `.git/hooks/pre-commit`:
   ```bash
   #!/bin/sh
   # Tambahkan pengecekan kualitas kode di sini
   echo "Memeriksa perubahan sebelum commit..."
   # Contoh: periksa apakah ada pesan debug yang tertinggal
   if git diff --cached | grep -q "print(" || git diff --cached | grep -q "print_debug"; then
       echo "Ditemukan perintah debug dalam perubahan. Hapus sebelum commit."
       exit 1
   fi
   ```

2. Berikan izin eksekusi:
   ```bash
   chmod +x .git/hooks/pre-commit
   ```

### Konvensi Commit
Gunakan format berikut untuk pesan commit:
```
[Tipe]: Deskripsi singkat perubahan

[Keterangan opsional lebih rinci tentang perubahan jika diperlukan]
```

**Tipe Commit**:
- `feat`: Fitur baru
- `fix`: Perbaikan bug
- `docs`: Perubahan dokumentasi
- `style`: Perubahan format tanpa mempengaruhi logika
- `refactor`: Perubahan kode tanpa mempengaruhi fungsionalitas
- `test`: Menambahkan atau memperbaiki tes
- `chore`: Pembaruan build atau alat bantu

Contoh:
```
feat: Tambah sistem serangan pemain

- Implementasi animasi serangan
- Tambah efek suara saat menyerang
- Hubungkan dengan sistem deteksi kerusakan
```

## Testing dan Debugging

### Prosedur Testing
1. Uji coba manual setiap fitur baru
2. Pastikan tidak ada error atau warning di Godot Editor
3. Uji kompatibilitas lintas platform (Windows, macOS, Linux)
4. Periksa performa game (FPS, penggunaan memori)

### Debugging Tips
- Gunakan `print()` statements untuk melacak alur eksekusi
- Aktifkan Godot debugger untuk analisis runtime
- Gunakan scene debugger untuk memeriksa struktur node
- Periksa log error di Godot Editor

### Debug Variabel
Godot menyediakan beberapa variabel global untuk debugging:
- `DEBUG_ENABLED`: True saat dalam mode debug
- `OS.has_feature("debug")`: Memeriksa apakah build dalam mode debug

## Build dan Deployment

### Membuat Build Lokal
1. Di Godot Editor, buka menu "Project"
2. Pilih "Export"
3. Pilih platform target (Windows, macOS, Linux, Android, dll.)
4. Atur opsi ekspor sesuai kebutuhan
5. Klik "Export Project" untuk membuat build

### Build Otomatis (Opsional)
Tim dapat mengatur CI/CD pipeline untuk build otomatis:
- Build otomatis pada setiap push ke branch develop
- Build untuk berbagai platform
- Upload hasil build ke GitHub Releases

## Troubleshooting

### Masalah Umum dan Solusi

#### 1. Error saat membuka proyek di Godot
- Pastikan versi Godot ≥ 4.4
- Periksa apakah file `project.godot` ada di root direktori
- Restart Godot Editor dan coba lagi

#### 2. Animasi tidak berfungsi
- Pastikan nama animasi sesuai dengan yang didefinisikan di AnimatedSprite2D
- Periksa apakah file sprite sheet sudah terhubung dengan benar
- Verifikasi bahwa nama animasi dalam kode cocok dengan nama di editor

#### 3. Player tidak bisa bergerak
- Pastikan input map "ui_right", "ui_left", "ui_up", "ui_down" sudah terdefinisi
- Cek apakah tombol "tombol_serang" sudah ditambahkan ke input map
- Verifikasi bahwa state machine berfungsi dengan benar

#### 4. Musuh tidak mengejar pemain
- Pastikan CollisionShape di DetectionArea sudah diatur
- Periksa apakah signal body_entered dan body_exited terkoneksi dengan benar
- Verifikasi bahwa reference ke player tidak null

### Debugging State Machine
Jika state machine tidak berfungsi:
- Pastikan semua state diinisialisasi di `_ready()`
- Periksa apakah fungsi `change_state()` dipanggil dengan nama state yang benar
- Verifikasi bahwa setiap state memiliki referensi ke player

## Lisensi

Projek ini dilisensikan di bawah lisensi MIT. Lihat file `LICENSE` untuk detail selengkapnya.

---

*Dokumen ini terakhir diperbarui: Januari 2026*
# SIMANTAP

**Sistem Informasi Manajemen Tugas dan Produktivitas Harian**

Aplikasi desktop Java 17 berbasis Swing untuk mengelola tugas sekali selesai
(berbatas waktu) dan kebiasaan harian (rutinitas), lengkap dengan gamifikasi poin,
riwayat penyelesaian, dan ekspor laporan CSV.

> Status: Minggu 10 — fondasi proyek, skema database, dan rancangan kelas.
> Target rilis: Minggu 15 (Demo Day).

---

## 1. Deskripsi

SIMANTAP membantu pengguna mencatat aktivitas harian dalam satu tempat. Tugas
dibagi menjadi dua jenis:

- **Tugas berbatas waktu**, yaitu pekerjaan sekali selesai dengan *deadline*
  (contoh: mengumpulkan laporan PBO).
- **Rutinitas harian**, yaitu kebiasaan berulang tanpa *deadline* ketat
  (contoh: olahraga 30 menit atau *coding* 1 jam).

Setiap penyelesaian tugas menghasilkan poin. Poin masuk ke riwayat dan
mengakumulasi total poin pada kategori terkait. Data disimpan di MySQL melalui
JDBC dengan pola DAO. Antarmuka dibuat dengan Java Swing, sedangkan ekspor CSV
dijalankan di latar belakang memakai `SwingWorker` agar UI tidak membeku.

---

## 2. Fitur

| Fitur | Keterangan | Status |
|---|---|---|
| CRUD kategori | Tambah, lihat, ubah, hapus kategori produktivitas | Rencana |
| CRUD tugas | Kelola tugas berbatas waktu dan rutinitas harian | Rencana |
| Penyelesaian tugas | Menyimpan riwayat dan menambah poin kategori dalam satu transaksi | Rencana |
| Penyortiran deadline | Urut sisa waktu terdekat memakai `Comparator`/lambda | Rencana |
| Pencarian/filter | Filter berdasarkan kategori, status, atau jenis tugas | Rencana |
| Gamifikasi | Poin dasar polimorfik + bonus streak lewat Strategy Pattern | Rencana |
| Riwayat | Daftar penyelesaian beserta status tepat waktu/terlambat | Rencana |
| Ekspor CSV | Rekap 7 hari terakhir via `SwingWorker` | Rencana |
| Validasi | Input salah ditangani exception, aplikasi tidak crash | Rencana |

---

## 3. Cara Menjalankan

### Prasyarat

- JDK 17 atau lebih baru (proyek dikompilasi dengan `--release 17`)
- MySQL 8.x / MariaDB 10.4+ (Laragon)
- Maven 3.9+ atau ekstensi Java di Visual Studio Code
- Git

### Langkah

1. Clone repositori:

   ```bash
   git clone https://github.com/katapirmaniniaja/SIMANTAP.git
   cd SIMANTAP
   ```

2. Buat database dan tabel:

   ```bash
   mysql -u root < sql/01_schema_simantap.sql
   ```

   Atau buka file `sql/01_schema_simantap.sql` di HeidiSQL/phpMyAdmin lalu
   jalankan seluruh isinya.

3. Salin konfigurasi database:

   ```bash
   copy db.properties.example db.properties
   ```

   Sesuaikan `db.url`, `db.user`, dan `db.password` dengan Laragon Anda.

4. Jalankan aplikasi:

   ```bash
   mvn clean package
   java -jar target/simantap.jar
   ```

   Saat pengembangan, kelas `com.simantap.App` dapat dijalankan langsung dari
   Visual Studio Code.

### Catatan

- `db.properties` tidak ikut di-commit karena berisi kredensial lokal.
- Skema SQL aman dijalankan ulang; tabel akan dibuat ulang dan data contoh
  dimuat kembali.

---

## 4. Struktur Paket

```text
src/main/java/com/simantap/
├── App.java                  # composition root, menjalankan Swing di EDT
├── config/                   # konfigurasi aplikasi dan database
├── model/                    # entitas domain + aturan bisnis (bebas Swing/SQL)
│   └── strategy/             # Strategy Pattern untuk bonus poin
├── exception/                # hierarki custom exception
├── dao/                      # kontrak DAO
│   └── impl/                 # implementasi JDBC + PreparedStatement
├── controller/               # penghubung view dan dao
├── view/                     # Swing: frame, panel, dialog
│   ├── panel/
│   └── dialog/
└── util/                     # koneksi database, ekspor CSV, format tanggal
```

Aturan ketergantungan:

```text
view -> controller -> dao -> MySQL
  |         |
  +---------+-> model
```

`view` tidak boleh mengimpor `java.sql` atau `dao`; `model` tidak boleh mengimpor
Swing maupun JDBC.

Dokumen pendukung:

- `sql/01_schema_simantap.sql` — DDL tiga tabel utama + data contoh + view.
- `docs/class-diagram.md` — class diagram dan penjelasan relasi.
- `ROADMAP.md` — rencana Minggu 10 sampai 15.
- `docs/checkpoint-log.md` — catatan progres tiap checkpoint.

---

## 5. Atribusi AI

Proyek ini dikembangkan dengan bantuan AI generatif. Bagian yang dibantu AI
ditandai dengan komentar di atas kode terkait, misalnya:

```java
// Dibantu AI (OpenCode/DeepSeek): saran struktur method dan penanganan null.
```

Ringkasan penggunaan:

| Minggu | Bagian | Bantuan AI | Verifikasi mahasiswa |
|---|---|---|---|
| 10 | Skema SQL, struktur paket, roadmap, kerangka README | Saran rancangan dan penulisan awal | SQL dijalankan di MySQL 8.4, constraint diuji |
| 11–15 | *Diisi saat pengerjaan* | *Diisi* | *Diisi* |

Semua kode yang dihasilkan AI dipahami, diuji, dan dapat dijelaskan oleh penulis.
AI tidak digunakan untuk menyalin proyek lain atau menggantikan pemahaman konsep.

# Log Checkpoint SIMANTAP

Dokumen ini mencatat bukti progres setiap checkpoint. Isi tanggal, commit hash,
dan hasil demo singkat. Jangan menulis klaim yang belum benar-benar berjalan.

---

## Minggu 10 — Fondasi & Administrasi

**Tanggal:** 7–8 November 2026
**Fokus:** administrasi, repositori, class diagram, skema database
**Checkpoint berikutnya:** Minggu 11 — OOP inti (CP1)

### Checklist

- [ ] Judul proyek tercatat di spreadsheet kelas
- [ ] Class diagram diunggah ke e-learning/sianakdara
- [x] Repositori Git lokal dibuat
- [x] `.gitignore` mencegah `target/`, IDE, dan `db.properties` masuk repo
- [x] Struktur package MVC dibuat
- [x] Skema SQL tiga tabel + view + data contoh dibuat
- [x] SQL dijalankan di MySQL 8.4.3 Laragon
- [x] Constraint `CHECK` diuji: kombinasi kolom tidak valid ditolak
- [x] README kerangka lima bagian dibuat
- [x] `pom.xml` dengan Java 17, Connector/J, dan JUnit 5 dibuat
- [ ] Remote GitHub ditambahkan dan commit pertama di-push
- [ ] Tautan repositori dicatat di spreadsheet/e-learning

### Bukti Teknis

| Item | Hasil |
|---|---|
| Database | `simantap` dibuat |
| Tabel | `kategori_produktivitas`, `tugas`, `riwayat_penyelesaian` |
| View | `v_rekap_mingguan` |
| Data contoh | 3 kategori, 4 tugas |
| Uji constraint | `INSERT` tugas berbatas waktu tanpa deadline ditolak (`ERROR 3819`) |
| Uji transaksi | Insert riwayat + update status + update poin berhasil, lalu `ROLLBACK` mengembalikan ketiganya ke kondisi awal |
| Build | Maven 3.9.11, `mvn -DskipTests package` berhasil (JAR masih placeholder sampai kode Java dibuat) |
| Versi MySQL | 8.4.3 |

### Catatan

- Server MySQL Laragon sempat tidak berjalan; dinyalakan manual untuk validasi.
- Kolom `batas_waktu` ditambahkan ke `riwayat_penyelesaian` agar
  `RiwayatPenyelesaian` dapat mengimplementasikan interface `BatasWaktu` secara
  bermakna (snapshot deadline untuk audit keterlambatan).
- Pekerjaan yang belum bisa diselesaikan dari sisi teknis: pengisian
  spreadsheet, unggah class diagram, dan pembuatan repo GitHub (butuh akun).

### Commit

| Hash | Pesan | Isi |
|---|---|---|
| `b680fda` | `chore: inisialisasi proyek SIMANTAP minggu 10` | struktur, SQL, README, class diagram, pom, roadmap |

---

## Minggu 11 — Checkpoint 1

**Tanggal:** 9–15 November 2026
**Fokus:** abstract class, turunan, interface, collection, exception, unit test

### Checklist

- [ ] `Tugas` abstract + dua turunan
- [ ] Interface `BatasWaktu` dipakai dua kelas
- [ ] `List<Tugas>` + `Map<Kategori, List<Tugas>>`
- [ ] Comparator/lambda deadline
- [ ] `SimantapException` + tiga turunan
- [ ] Demo CLI tanpa GUI dan tanpa database
- [ ] Minimal 4 unit test lulus

### Bukti

| Item | Hasil |
|---|---|
| Test | _diisi_ |
| Demo CLI | _diisi_ |
| Commit | _diisi_ |

---

## Minggu 12 — Checkpoint 2

**Tanggal:** 16–22 November 2026
**Fokus:** JDBC, DAO, PreparedStatement, transaksi

### Checklist

- [ ] `DatabaseConnection`
- [ ] CRUD kategori, tugas, riwayat
- [ ] `TugasMapper` polimorfik
- [ ] Transaksi penyelesaian + rollback
- [ ] Data bertahan setelah aplikasi ditutup

### Bukti

| Item | Hasil |
|---|---|
| CRUD | _diisi_ |
| Transaksi | _diisi_ |
| Commit | _diisi_ |

---

## Minggu 13 — Checkpoint 3

**Tanggal:** 23–29 November 2026
**Fokus:** Swing, controller, validasi, end-to-end

### Checklist

- [ ] `MainFrame` + panel tugas/kategori/riwayat
- [ ] CRUD lewat GUI
- [ ] Sorting dan filter
- [ ] Exception deadline ditangkap dan ditampilkan
- [ ] Poin kategori ter-refresh

### Bukti

| Item | Hasil |
|---|---|
| Alur end-to-end | _diisi_ |
| Screenshot | _diisi_ |
| Commit | _diisi_ |

---

## Minggu 14 — Checkpoint 4

**Tanggal:** 30 November–6 Desember 2026
**Fokus:** Strategy, SwingWorker CSV, JUnit, JAR, dokumentasi

### Checklist

- [ ] Strategy Pattern + komentar tiga kalimat + dua skenario
- [ ] Ekspor CSV via `SwingWorker`
- [ ] Minimal 5 unit test (2 batas, 1 gagal)
- [ ] JavaDoc lima method
- [ ] README final + class diagram final
- [ ] JAR + GitHub Release

### Bukti

| Item | Hasil |
|---|---|
| Test | _diisi_ |
| JAR | _diisi_ |
| CSV | _diisi_ |
| Release | _diisi_ |

---

## Minggu 15 — Demo Day

**Tanggal:** 7–13 Desember 2026

### Checklist

- [ ] Data demo wajar
- [ ] Lima screenshot
- [ ] Thumbnail 1200 x 630
- [ ] Video maksimal tiga menit
- [ ] Entri showcase
- [ ] Latihan presentasi tujuh menit
- [ ] Repo bersih dan tag rilis tersedia

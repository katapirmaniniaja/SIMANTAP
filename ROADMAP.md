# ROADMAP SIMANTAP — Minggu 10 s.d. 15

> Status saat ini: **Minggu 10**. Repositori dan kerangka paket sudah ada, tetapi
> pekerjaan Minggu 9–10 (judul di spreadsheet, class diagram, repo + commit pertama)
> harus dipastikan selesai **akhir pekan ini**.
>
> Asumsi tanggal: Minggu 10 = 2–8 Nov 2026, Checkpoint 1 = 9–15 Nov,
> Checkpoint 2 = 16–22 Nov, Checkpoint 3 = 23–29 Nov, Checkpoint 4 = 30 Nov–6 Des,
> Demo Day = 7–13 Des 2026. Sesuaikan bila kalender kampus berbeda.

---

## 0. Prinsip Eksekusi

1. **Checkpoint dulu, penyempurnaan kemudian.** Setiap minggu harus ada demo yang
   bisa dijalankan, walau UI masih sederhana.
2. **Satu commit = satu unit kerja kecil.** Commit setiap 45–90 menit, jangan
   menumpuk sampai akhir minggu.
3. **Layer tidak boleh bocor.** `view` tidak boleh import `java.sql`/`dao`;
   `model` tidak boleh import Swing/SQL.
4. **Logika poin wajib bebas Swing.** Semua perhitungan di `model`/`strategy`.
5. **Siapkan buffer 1 hari** per minggu untuk bug dan revisi dosen.
6. **Rekam bukti checkpoint**: screenshot, commit hash, dan catatan singkat
   "apa yang berfungsi minggu ini".

---

## 1. Critical Path

```text
Minggu 10  : administrasi + repo + class diagram + skema SQL
Minggu 11  : hierarki kelas + polimorfisme + collection + exception  -> CP1
Minggu 12  : JDBC + DAO + CRUD + transaksi penyelesaian              -> CP2
Minggu 13  : Swing + controller + aplikasi end-to-end                -> CP3
Minggu 14  : Strategy + SwingWorker CSV + JUnit + JAR + README        -> CP4
Minggu 15  : screenshot, thumbnail, video, showcase, latihan demo
```

Jangan mengerjakan GUI sebelum DAO stabil. Jangan mengerjakan Strategy sebelum
perhitungan poin dasar lulus unit test.

---

## 2. Ringkasan Mingguan

| Minggu | Tanggal | Fokus | Bukti Checkpoint | Estimasi |
|---|---|---|---|---|
| 10 | 7–8 Nov | Administrasi, repo, class diagram, SQL | Link repo + commit pertama + SQL jalan | 6–8 jam |
| 11 | 9–15 Nov | OOP inti, collection, exception, unit test awal | Demo CLI `List<Tugas>` + 5 test lulus | 12–15 jam |
| 12 | 16–22 Nov | JDBC DAO, CRUD, transaksi | CRUD via `main`/CLI, data persist setelah restart | 12–15 jam |
| 13 | 23–29 Nov | Swing, controller, validasi, end-to-end | Aplikasi bisa tambah/edit/hapus/selesaikan tugas | 15–18 jam |
| 14 | 30 Nov–6 Des | Strategy, SwingWorker CSV, JUnit, JAR, dokumentasi | 5+ test, ekspor CSV, JAR, README, release | 15–18 jam |
| 15 | 7–13 Des | Showcase & demo | 5 screenshot, thumbnail, video, presentasi | 8–10 jam |

Total realistis: **68–84 jam** di luar jam kuliah. Kalau minggu 10–11 dipadatkan,
beban minggu 13–14 bisa turun.

---

## 3. Rincian per Minggu

### Minggu 10 — Fondasi & Administrasi (7–8 Nov)

**Tujuan:** tidak ada lagi utang administrasi; repo siap dinilai sejak commit pertama.

- [ ] Cek spreadsheet: judul `SIMANTAP (Sistem Informasi)` sudah tercatat dan
      statusnya tidak meminta revisi.
- [ ] Finalkan class diagram: 5 kelas domain, abstract `Tugas`, 2 turunan,
      interface, relasi, dan hierarki exception.
- [ ] Upload class diagram ke e-learning/sianakdara bila belum.
- [ ] Buat repo GitHub **public** (atau sesuai instruksi kampus), branch `main`.
- [ ] Tambahkan `.gitignore`: `target/`, `*.class`, `.idea/`, `.vscode/`,
      `db.properties`, `*.log`, file CSV hasil ekspor.
- [ ] Commit pertama berisi: `README.md` kerangka 5 bagian, `sql/01_schema_simantap.sql`,
      struktur folder `src/main/java`, dan class diagram (PNG/PDF).
- [ ] Jalankan SQL di Laragon; pastikan 3 tabel + view + data contoh muncul.
- [ ] Tulis `docs/checkpoint-log.md`: tanggal, commit, fitur, kendala.

**Definition of Done:** repo bisa dibuka orang lain, SQL bisa dijalankan ulang,
dan README menyebut cara menjalankan serta atribusi AI.

---

### Minggu 11 — Checkpoint 1: OOP Inti (9–15 Nov)

**Tujuan:** seluruh syarat 1–4 berfungsi tanpa database dan tanpa GUI.

- [ ] `Tugas` abstract: field umum, `hitungPoinDasar()` abstract.
- [ ] `TugasBerbatasWaktu`: deadline, estimasi menit, override poin.
- [ ] `RutinitasHarian`: durasi, target harian, streak, override poin.
- [ ] Interface `BatasWaktu` dipakai minimal 2 kelas yang relevan.
- [ ] `KategoriProduktivitas` dan `RiwayatPenyelesaian` sebagai kelas domain.
- [ ] Hierarki exception: `SimantapException` + 3 turunan, termasuk
      `TugasKedaluwarsaException`; pesan ramah pengguna.
- [ ] `List<Tugas>` + `Comparator`/lambda untuk urut deadline terdekat
      (null-safe: rutinitas di belakang).
- [ ] `Map<KategoriProduktivitas, List<Tugas>>` untuk pengelompokan.
- [ ] Demo `main`/CLI: isi 5 tugas, urutkan, hitung total poin dengan
      pemanggilan polimorfik **tanpa `instanceof` di loop**.
- [ ] 4–5 unit test awal: poin normal, rutinitas, deadline lewat (gagal),
      batas tepat waktu, urutan comparator.

**Definition of Done:** `mvn test` lulus; demo CLI bisa dijalankan; tidak ada
`instanceof` di kode pemroses koleksi.

**Commit yang diharapkan:** `feat(model): hierarki Tugas`, `feat(exception): ...`,
`feat(collection): comparator deadline`, `test(model): ...`.

---

### Minggu 12 — Checkpoint 2: JDBC & DAO (16–22 Nov)

**Tujuan:** data benar-benar tersimpan di MySQL dan bertahan setelah aplikasi ditutup.

- [ ] `db.properties` + `DatabaseConnection` (Singleton/utility, tanpa hardcode password).
- [ ] `KategoriDAO` + impl: `insert`, `findById`, `findAll`, `update`, `delete`.
- [ ] `TugasDAO` + impl: CRUD, filter status/kategori, urut deadline.
- [ ] `RiwayatDAO` + impl: insert riwayat, rekap mingguan, total poin.
- [ ] `TugasMapper`: `ResultSet` → objek polimorfik berdasarkan `jenis_tugas`.
- [ ] Semua query memakai `PreparedStatement`; tidak ada string concatenation.
- [ ] Transaksi penyelesaian tugas: insert riwayat + update status + update
      `total_poin` kategori dalam satu `Connection` dengan `autoCommit(false)`;
      `rollback` bila gagal.
- [ ] Uji manual: tambah → tutup aplikasi → buka lagi → data masih ada.
- [ ] Uji DAO terpisah memakai database `simantap_test` bila memungkinkan.
- [ ] Perbarui README: cara setup database dan koneksi.

**Definition of Done:** CRUD berjalan lewat kode (boleh CLI), transaksi tidak
meninggalkan data setengah jadi, dan exception SQL dibungkus menjadi exception
aplikasi yang mudah dipahami.

---

### Minggu 13 — Checkpoint 3: Swing End-to-End (23–29 Nov)

**Tujuan:** pengguna bisa memakai aplikasi dari awal sampai akhir tanpa CLI.

- [ ] `MainFrame` dengan tab/panel: Tugas, Kategori, Riwayat.
- [ ] `TugasPanel`: tabel `JTable`, tombol tambah/edit/hapus/selesaikan/refresh.
- [ ] `TugasDialog`: form judul, kategori, jenis tugas, deadline/durasi, prioritas;
      validasi input sebelum menyimpan.
- [ ] `KategoriPanel`: CRUD kategori + total poin.
- [ ] `RiwayatPanel`: daftar penyelesaian dan rekap poin.
- [ ] Controller menghubungkan view ↔ DAO; view tidak menyentuh SQL.
- [ ] Sorting deadline via `TableRowSorter`/comparator; pencarian/filter kategori.
- [ ] Aksi "Selesaikan" menangkap `TugasKedaluwarsaException` dan menampilkan
      dialog yang jelas; aplikasi tidak crash.
- [ ] Refresh otomatis tabel dan total poin setelah transaksi.
- [ ] UI dasar rapi: layout `GridBagLayout`/`BorderLayout`, ukuran minimum,
      konfirmasi hapus.

**Definition of Done:** alur "tambah tugas → selesaikan → lihat riwayat → poin
kategori bertambah" berjalan penuh lewat GUI, dan input salah tidak mematikan aplikasi.

---

### Minggu 14 — Checkpoint 4: Pattern, Multithreading, Test, Rilis (30 Nov–6 Des)

**Tujuan:** semua 8 syarat lulus dan repo siap demo.

- [ ] Strategy Pattern: `PoinStrategy`, `PoinNormalStrategy`,
      `PoinKebutSemalamStrategy`, `BonusStreakStrategy`.
- [ ] Komentar 3 kalimat di atas kelas Strategy: alasan penerapan + **2 skenario
      nyata** yang membuatnya perlu.
- [ ] `SwingWorker` untuk ekspor CSV: progress bar,-disable tombol saat proses,
      `publish/process`, penanganan `IOException` di `done()`, opsi cancel bila memungkinkan.
- [ ] Ekspor memakai `v_rekap_mingguan` atau query rentang 7 hari; hasil `.csv`
      memakai header dan escaping yang benar.
- [ ] Genapkan 5+ kasus JUnit: 2 nilai batas, 1 keadaan gagal, 1 strategi berbeda,
      1 comparator/collection. Pastikan tidak butuh GUI.
- [ ] JavaDoc pada minimal 5 method penting.
- [ ] README final: deskripsi, fitur, cara menjalankan, struktur paket, atribusi AI.
- [ ] Class diagram final disesuaikan dengan kode.
- [ ] Build JAR: `mvn clean package`; uji `java -jar target/simantap-1.0.0.jar`.
- [ ] Buat GitHub Release `v1.0.0` + upload JAR.
- [ ] Pastikan `target/` tidak ikut ter-commit.
- [ ] `docs/checkpoint-log.md` diperbarui.

**Definition of Done:** dosen bisa menjalankan JAR, 5 test hijau, ekspor CSV
berjalan di background, dan komentar pattern bisa Anda jelaskan sendiri.

---

### Minggu 15 — Demo Day (7–13 Des)

**Tujuan:** paket showcase lengkap dan presentasi 7 menit lancar.

- [ ] Siapkan data wajar (minimal 3 kategori, 8–10 tugas, 10+ riwayat).
- [ ] 5 screenshot: dashboard/daftar tugas, form tambah, penyelesaian/exception,
      riwayat + poin, proses ekspor CSV.
- [ ] Thumbnail 1200 × 630 px.
- [ ] Video demo maksimal 3 menit: masalah → solusi → alur utama → penutup.
- [ ] Kirim entri showcase kategori Desktop Application.
- [ ] Latihan presentasi 7 menit: 1 menit latar belakang, 4 menit rancangan +
      alur utama, 2 menit keputusan teknis.
- [ ] Siapkan jawaban: mengapa single-table inheritance, mengapa Strategy,
      di mana polimorfisme, bagaimana transaksi menjaga konsistensi,
      mengapa `SwingWorker`, apa yang diuji JUnit.
- [ ] Repo bersih: tidak ada file build, commit terakhir rapi, tag rilis ada.

---

## 4. Rencana Commit per Minggu

| Minggu | Minimal commit | Contoh pesan |
|---|---|---|
| 10 | 3 | `chore: init repo`, `feat(db): skema awal`, `docs: class diagram` |
| 11 | 6 | `feat(model): Tugas abstract`, `feat(model): dua turunan`, `test: poin` |
| 12 | 8 | `feat(dao): kategori CRUD`, `feat(dao): transaksi selesaikan tugas` |
| 13 | 10 | `feat(view): MainFrame`, `feat(controller): selesaikan tugas` |
| 14 | 8 | `feat(strategy): bonus streak`, `feat(export): SwingWorker CSV`, `chore: release 1.0.0` |
| 15 | 3 | `docs: screenshot & video`, `docs: finalisasi README` |

Gunakan prefix `feat/fix/test/docs/chore/refactor`. Jangan commit `target/`,
password database, atau file CSV hasil ekspor.

---

## 5. Matriks Uji JUnit Minimal

| No | Kasus | Jenis | Ekspektasi |
|---|---|---|---|
| 1 | Tugas berbatas waktu selesai tepat waktu | normal | poin dasar sesuai aturan |
| 2 | Rutinitas harian dengan durasi tertentu | normal | poin berbeda dari tugas deadline |
| 3 | Selesai tepat pada detik deadline | batas | dianggap tepat waktu |
| 4 | Selesai 1 detik setelah deadline | batas | `TugasKedaluwarsaException` |
| 5 | Streak 0 vs ambang bonus streak | batas/strategi | bonus hanya di ambang yang benar |
| 6 | Strategi kebut semalam vs normal | strategi | hasil poin berbeda |
| 7 | Comparator deadline dengan deadline null | collection | rutinitas di urutan akhir |
| 8 | Input deadline tidak valid | gagal | exception validasi, bukan crash |

Minimal 5 wajib; tabel di atas memberi nilai lebih saat tanya jawab.

---

## 6. Risiko & Mitigasi

| Risiko | Dampak | Mitigasi |
|---|---|---|
| Minggu 10 hampir habis | CP1 mepet | Selesaikan admin + repo hari ini; model dikerjakan Senin–Rabu |
| GUI memakan waktu | CP3 mundur | Pakai satu `JFrame` + 3 panel; jangan mengejar animasi/tema |
| `CHECK`/generated column tidak didukung versi MySQL | SQL gagal | Validasi tetap di Java; sesuaikan DDL bila perlu |
| Koneksi DB hardcode | repo tidak aman | `db.properties` di `.gitignore`, sediakan `db.properties.example` |
| Ekspor freeze | nilai multithreading gagal | Wajib `SwingWorker`; uji dengan 1000 baris |
| Test bercampur Swing | test tidak bisa jalan | Logika poin hanya di `model`/`strategy` |
| Kehilangan progres | fatal | Push setiap hari; branch `main` selalu bisa jalan |
| Tidak bisa menjelaskan kode | nilai demo turun | Tulis komentar alasan, latihan menjelaskan per method |

---

## 7. Checklist Akhir Sebelum Demo

- [ ] 8 syarat teknis bisa ditunjukkan satu per satu.
- [ ] Tidak ada `instanceof` di loop pemroses koleksi.
- [ ] Tidak ada `catch` kosong.
- [ ] CRUD GUI benar-benar menulis ke MySQL.
- [ ] Transaksi penyelesaian memperbarui riwayat + status + poin kategori.
- [ ] Ekspor CSV berjalan dengan progress dan tidak membekukan UI.
- [ ] 5+ JUnit lulus, termasuk 2 batas dan 1 gagal.
- [ ] Strategy punya komentar 3 kalimat + 2 skenario.
- [ ] JavaDoc 5 method, README 5 bagian, class diagram final.
- [ ] JAR bisa dijalankan `java -jar`.
- [ ] 5 screenshot + thumbnail + video + entri showcase.
- [ ] Atribusi AI ditulis di komentar kode dan README.

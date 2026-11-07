-- ============================================================================
-- SIMANTAP - Skema Basis Data
-- DBMS    : MySQL 8.x / MariaDB 10.4+ (Laragon)
-- Pemetaan pewarisan: SINGLE TABLE INHERITANCE pada tabel `tugas`
--   Tugas (abstract) + TugasBerbatasWaktu + RutinitasHarian
--   dibedakan oleh kolom diskriminator `jenis_tugas`.
-- ============================================================================

CREATE DATABASE IF NOT EXISTS simantap
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE simantap;

-- Urutan drop harus dari child ke parent (FK).
DROP TABLE IF EXISTS riwayat_penyelesaian;
DROP TABLE IF EXISTS tugas;
DROP TABLE IF EXISTS kategori_produktivitas;

-- ----------------------------------------------------------------------------
-- 1. KATEGORI_PRODUKTIVITAS
--    Kelas domain: KategoriProduktivitas
-- ----------------------------------------------------------------------------
CREATE TABLE kategori_produktivitas (
    id_kategori     INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    nama_kategori   VARCHAR(60)     NOT NULL,
    deskripsi       VARCHAR(255)    NULL,
    total_poin      INT             NOT NULL DEFAULT 0,
    dibuat_pada     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id_kategori),
    CONSTRAINT uq_kategori_nama UNIQUE (nama_kategori),
    CONSTRAINT chk_kategori_total_poin CHECK (total_poin >= 0)
) ENGINE = InnoDB;

-- ----------------------------------------------------------------------------
-- 2. TUGAS  (single table inheritance)
--    Kelas domain: Tugas (abstract), TugasBerbatasWaktu, RutinitasHarian
--
--    | Kolom                         | Tugas | BerbatasWaktu | Rutinitas |
--    |-------------------------------|-------|---------------|-----------|
--    | id_tugas, id_kategori, judul  |   v   |       v       |     v     |
--    | jenis_tugas (diskriminator)   |   v   | BERBATAS...   | RUTINITAS |
--    | deadline                      | NULL  |     wajib     |    NULL   |
--    | estimasi_menit                | NULL  |    opsional   |    NULL   |
--    | durasi_menit, target_per_hari | NULL  |      NULL     |   wajib   |
--    | streak                        |   0   |       0       |  berjalan |
--
--    CHECK di bawah menjaga agar objek tidak berada dalam keadaan "campuran".
-- ----------------------------------------------------------------------------
CREATE TABLE tugas (
    id_tugas        INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    id_kategori     INT UNSIGNED    NOT NULL,
    judul           VARCHAR(120)    NOT NULL,
    deskripsi       TEXT            NULL,
    jenis_tugas     ENUM('BERBATAS_WAKTU', 'RUTINITAS_HARIAN') NOT NULL,
    prioritas       ENUM('RENDAH', 'SEDANG', 'TINGGI') NOT NULL DEFAULT 'SEDANG',
    status          ENUM('BELUM_SELESAI', 'SELESAI') NOT NULL DEFAULT 'BELUM_SELESAI',
    deadline        DATETIME        NULL,
    estimasi_menit  SMALLINT UNSIGNED NULL,
    durasi_menit    SMALLINT UNSIGNED NULL,
    target_per_hari TINYINT UNSIGNED  NULL,
    streak          INT UNSIGNED    NOT NULL DEFAULT 0,
    dibuat_pada     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diperbarui_pada DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
                                    ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id_tugas),
    CONSTRAINT fk_tugas_kategori
        FOREIGN KEY (id_kategori) REFERENCES kategori_produktivitas (id_kategori)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_tugas_bentuk CHECK (
        (jenis_tugas = 'BERBATAS_WAKTU'
            AND deadline IS NOT NULL
            AND durasi_menit IS NULL
            AND target_per_hari IS NULL)
        OR
        (jenis_tugas = 'RUTINITAS_HARIAN'
            AND deadline IS NULL
            AND durasi_menit IS NOT NULL
            AND target_per_hari IS NOT NULL)
    ),
    INDEX idx_tugas_deadline (deadline),
    INDEX idx_tugas_status (status),
    INDEX idx_tugas_kategori (id_kategori)
) ENGINE = InnoDB;

-- ----------------------------------------------------------------------------
-- 3. RIWAYAT_PENYELESAIAN
--    Kelas domain: RiwayatPenyelesaian (log transaksi, komposisi terhadap Tugas)
--    total_poin adalah generated column: tidak boleh diisi manual oleh DAO.
-- ----------------------------------------------------------------------------
CREATE TABLE riwayat_penyelesaian (
    id_riwayat      BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_tugas        INT UNSIGNED    NOT NULL,
    waktu_selesai   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    batas_waktu     DATETIME        NULL,   -- snapshot deadline saat tugas diselesaikan
    status_ketepatan ENUM('TEPAT_WAKTU', 'TERLAMBAT', 'TANPA_DEADLINE') NOT NULL,
    poin_dasar      SMALLINT UNSIGNED NOT NULL,
    poin_bonus      SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    total_poin      SMALLINT UNSIGNED
                    GENERATED ALWAYS AS (poin_dasar + poin_bonus) STORED,
    catatan         VARCHAR(255)    NULL,

    PRIMARY KEY (id_riwayat),
    CONSTRAINT fk_riwayat_tugas
        FOREIGN KEY (id_tugas) REFERENCES tugas (id_tugas)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    INDEX idx_riwayat_waktu (waktu_selesai),
    INDEX idx_riwayat_tugas (id_tugas)
) ENGINE = InnoDB;

-- ----------------------------------------------------------------------------
-- Data contoh (opsional, aman dijalankan ulang setelah tabel dibuat)
-- ----------------------------------------------------------------------------
INSERT INTO kategori_produktivitas (nama_kategori, deskripsi) VALUES
    ('Akademik',  'Tugas kuliah, belajar, dan praktikum'),
    ('Olahraga',  'Kebiasaan fisik harian'),
    ('Hobi',      'Aktivitas pengembangan diri dan kesenangan');

INSERT INTO tugas
    (id_kategori, judul, deskripsi, jenis_tugas, prioritas, deadline,
     estimasi_menit, durasi_menit, target_per_hari)
VALUES
    (1, 'Kumpul Laporan PBO II', 'Laporan proyek mandiri', 'BERBATAS_WAKTU',
     'TINGGI', DATE_ADD(NOW(), INTERVAL 2 DAY), 180, NULL, NULL),
    (1, 'Belajar JUnit', 'Latihan unit test', 'BERBATAS_WAKTU',
     'SEDANG', DATE_ADD(NOW(), INTERVAL 5 DAY), 90, NULL, NULL),
    (2, 'Jogging Pagi', 'Keliling komplek 30 menit', 'RUTINITAS_HARIAN',
     'SEDANG', NULL, NULL, 30, 1),
    (3, 'Coding 1 Jam', 'Latihan Java setiap hari', 'RUTINITAS_HARIAN',
     'TINGGI', NULL, NULL, 60, 1);

-- ----------------------------------------------------------------------------
-- View bantu untuk laporan/ekspor CSV mingguan.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_rekap_mingguan AS
SELECT
    r.id_riwayat,
    t.id_tugas,
    t.judul,
    k.nama_kategori,
    t.jenis_tugas,
    r.waktu_selesai,
    r.batas_waktu,
    r.status_ketepatan,
    r.poin_dasar,
    r.poin_bonus,
    r.total_poin
FROM riwayat_penyelesaian r
JOIN tugas t ON t.id_tugas = r.id_tugas
JOIN kategori_produktivitas k ON k.id_kategori = t.id_kategori
WHERE r.waktu_selesai >= DATE_SUB(NOW(), INTERVAL 7 DAY);

-- ----------------------------------------------------------------------------
-- Catatan transaksi penyelesaian tugas (dijalankan dari DAO/service Java
-- di dalam satu Connection dengan auto-commit = false):
--
--   START TRANSACTION;
--   INSERT INTO riwayat_penyelesaian
--       (id_tugas, waktu_selesai, batas_waktu, status_ketepatan, poin_dasar, poin_bonus)
--   VALUES (?, NOW(), ?, ?, ?, ?);
--   UPDATE tugas SET status = 'SELESAI' WHERE id_tugas = ?;
--   UPDATE kategori_produktivitas
--      SET total_poin = total_poin + ?
--    WHERE id_kategori = ?;
--   COMMIT;
--
-- Jika salah satu gagal -> ROLLBACK, sehingga poin kategori tidak pernah
-- bertambah tanpa adanya baris riwayat.
-- ----------------------------------------------------------------------------

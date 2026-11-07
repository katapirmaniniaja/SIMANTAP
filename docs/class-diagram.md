# Class Diagram SIMANTAP

Rancangan awal (Minggu 9) yang diperbarui pada Minggu 10. Diagram sumber ada di
`docs/class-diagram.mmd`; pratinjau Mermaid dapat dibuka langsung di Visual Studio
Code (ekstensi Markdown Preview Mermaid Support).

```mermaid
classDiagram
    direction LR

    class Tugas {
        <<abstract>>
        -int idTugas
        -String judul
        -String deskripsi
        -KategoriProduktivitas kategori
        -Prioritas prioritas
        -StatusTugas status
        -int streak
        +hitungPoinDasar() int
        +hitungPoin(PoinStrategy strategy) int
        +getJenisTugas() String
        +tambahStreak() void
        +resetStreak() void
    }

    class TugasBerbatasWaktu {
        -LocalDateTime deadline
        -int estimasiMenit
        +hitungPoinDasar() int
        +getDeadline() LocalDateTime
        +sisaWaktu() Duration
        +isKedaluwarsa() boolean
    }

    class RutinitasHarian {
        -int durasiMenit
        -int targetPerHari
        +hitungPoinDasar() int
        +getJenisTugas() String
        +catatPenyelesaian() void
    }

    class KategoriProduktivitas {
        -int idKategori
        -String namaKategori
        -String deskripsi
        -int totalPoin
        -List~Tugas~ daftarTugas
        +tambahPoin(int poin) void
        +hitungTotalPoin(PoinStrategy strategy) int
    }

    class RiwayatPenyelesaian {
        -long idRiwayat
        -Tugas tugas
        -LocalDateTime waktuSelesai
        -LocalDateTime batasWaktu
        -StatusKetepatan statusKetepatan
        -int poinDasar
        -int poinBonus
        -String catatan
        +getTotalPoin() int
        +getDeadline() LocalDateTime
        +sisaWaktu() Duration
        +isKedaluwarsa() boolean
    }

    class BatasWaktu {
        <<interface>>
        +getDeadline() LocalDateTime
        +sisaWaktu() Duration
        +isKedaluwarsa() boolean
    }

    class PoinStrategy {
        <<interface>>
        +hitungBonus(Tugas tugas) int
        +getNama() String
    }

    class TanpaBonusStrategy {
        +hitungBonus(Tugas tugas) int
        +getNama() String
    }

    class BonusStreakStrategy {
        -int poinPerStreak
        -int batasBonus
        +hitungBonus(Tugas tugas) int
        +getNama() String
    }

    class ModeKebutSemalamStrategy {
        -int bonusTetap
        +hitungBonus(Tugas tugas) int
        +getNama() String
    }

    class SimantapException {
        <<abstract>>
        -String pesanPengguna
        +getPesanPengguna() String
    }

    class TugasKedaluwarsaException {
        -LocalDateTime deadline
        -LocalDateTime waktuSelesai
    }

    class ValidasiTugasException {
        -String namaField
    }

    class DataTidakDitemukanException {
        -String namaEntitas
        -Object id
    }

    class Prioritas {
        <<enumeration>>
        RENDAH
        SEDANG
        TINGGI
    }

    class StatusTugas {
        <<enumeration>>
        BELUM_SELESAI
        SELESAI
    }

    class StatusKetepatan {
        <<enumeration>>
        TEPAT_WAKTU
        TERLAMBAT
        TANPA_DEADLINE
    }

    Tugas <|-- TugasBerbatasWaktu
    Tugas <|-- RutinitasHarian

    BatasWaktu <|.. TugasBerbatasWaktu
    BatasWaktu <|.. RiwayatPenyelesaian

    KategoriProduktivitas "1" o-- "0..*" Tugas : mengelompokkan
    Tugas "1" --> "0..*" RiwayatPenyelesaian : dicatat dalam
    Tugas ..> PoinStrategy : memakai

    PoinStrategy <|.. TanpaBonusStrategy
    PoinStrategy <|.. BonusStreakStrategy
    PoinStrategy <|.. ModeKebutSemalamStrategy

    SimantapException <|-- TugasKedaluwarsaException
    SimantapException <|-- ValidasiTugasException
    SimantapException <|-- DataTidakDitemukanException

    Tugas --> Prioritas
    Tugas --> StatusTugas
    RiwayatPenyelesaian --> StatusKetepatan
```

## Penjelasan Relasi

| Relasi | Jenis | Alasan |
|---|---|---|
| `KategoriProduktivitas` ke `Tugas` | agregasi `1..0..*` | Kategori mengelompokkan tugas, tetapi tugas tetap bermakna bila kategori diganti. |
| `Tugas` ke `RiwayatPenyelesaian` | asosiasi `1..0..*` | Satu tugas dapat diselesaikan berulang kali (khususnya rutinitas), dan setiap penyelesaian menghasilkan satu baris riwayat. |
| `Tugas` ke `PoinStrategy` | dependency | `Tugas` memakai strategi bonus tanpa mengetahui implementasinya. |
| `SimantapException` ke tiga exception | generalisasi | Memenuhi syarat satu exception induk dengan minimal tiga turunan. |

## Keputusan Rancangan

1. **`Tugas` abstract** menyimpan state bersama dan memaksa setiap turunan
   mengimplementasikan `hitungPoinDasar()`. Perhitungan poin berbeda:
   - `TugasBerbatasWaktu`: mempertimbangkan prioritas dan estimasi menit.
   - `RutinitasHarian`: mempertimbangkan durasi dan target harian.
2. **Polimorfisme** terjadi saat loop `for (Tugas t : daftar) t.hitungPoin(strategy)`.
   Tidak ada `instanceof` di dalam loop.
3. **`BatasWaktu`** dipasang pada dua kelas yang benar-benar membutuhkannya:
   `TugasBerbatasWaktu` (deadline aktif) dan `RiwayatPenyelesaian` (snapshot
   deadline untuk audit keterlambatan). `RutinitasHarian` tidak dipasangi
   interface ini karena tidak memiliki deadline.
4. **`RiwayatPenyelesaian` menyimpan `batasWaktu`** agar status tepat waktu dapat
   dihitung ulang meskipun data tugas berubah di kemudian hari.
5. **Strategy Pattern** memisahkan variasi bonus (tanpa bonus, bonus streak,
   mode kebut semalam) dari kelas tugas. Ini mencegah `if/switch` yang terus
   bertambah saat aturan bonus baru muncul.
6. **Single Table Inheritance**: `Tugas`, `TugasBerbatasWaktu`, dan
   `RutinitasHarian` dipetakan ke satu tabel `tugas` dengan diskriminator
   `jenis_tugas`. Kolom khusus turunan dibuat `NULL` untuk jenis yang tidak
   memakainya, dan `CHECK` menjaga agar kombinasi kolom tetap valid.

## Pemetaan ke Tabel

| Kelas | Tabel | Kolom pembeda |
|---|---|---|
| `KategoriProduktivitas` | `kategori_produktivitas` | `id_kategori` |
| `Tugas` | `tugas` | kolom umum |
| `TugasBerbatasWaktu` | `tugas` | `jenis_tugas = 'BERBATAS_WAKTU'`, `deadline` |
| `RutinitasHarian` | `tugas` | `jenis_tugas = 'RUTINITAS_HARIAN'`, `durasi_menit`, `target_per_hari` |
| `RiwayatPenyelesaian` | `riwayat_penyelesaian` | `batas_waktu` sebagai snapshot deadline |

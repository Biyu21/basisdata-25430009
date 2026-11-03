# Praktikum Basis Data

## Identitas Mahasiswa

- **Nama:** Abbiyu Hashfi Dzakwan
- **NPM:** `25430009`
- **Kelas:** `A`

## Deskripsi Proyek

Proyek ini merupakan proyek praktikum Basis Data yang dikerjakan secara individu dan dikembangkan secara bertahap dari Pertemuan 1 sampai Pertemuan 16.

Proyek menggunakan tema **Sistem Informasi Perpustakaan AHD** dengan nama basis data `perpus_009`. Pengembangan proyek mencakup analisis kebutuhan data, pemodelan ERD, normalisasi, implementasi struktur basis data, pengujian constraint, pembuatan kueri, serta dokumentasi praktikum.

## Struktur Proyek

Struktur berikut disesuaikan dengan berkas yang ada di repositori saat ini.

```text
basisdata-25430009/
├── README.md
├── p01_lingkungan_25430009.sql
├── p02_kebutuhan_data_25430009.md
├── p03_erd_25430009.drawio
├── p04_erd_25430009.drawio
├── p04_normalisasi_25430009.md
├── p05_ddl_25430009.sql
├── p05_erd_fisik_25430009.drawio
├── p06_data_25430009.sql
├── p06_uji_25430009.sql
├── p06_uji_25430009.md
├── p06_latihan_25430009.sql
├── Laporan/
│   ├── p01_laporan_25430009.md
│   ├── p02_laporan_25430009.md
│   ├── p03_laporan_25430009.md
│   ├── p04_laporan_25430009.md
│   ├── p05_laporan_25430009.md
│   └── p06_laporan_25430009.md
└── Screenshots/
    ├── p03_erd_25430009.png
    ├── p04_erd_25430009.png
    ├── p05_erd_fisik_25430009.png
    ├── Screenshot_20261002_083752.png
    ├── Screenshot_20261002_083828.png
    ├── Screenshot_20261002_103733.png
    ├── Screenshot_20261002_104056.png
    ├── Screenshot_20261002_105046.png
    ├── Screenshot_20261002_105409.png
    ├── Screenshot_20261002_105501.png
    ├── Screenshot_20261002_111329.png
    ├── Screenshot_20261002_111450.png
    ├── Screenshot_20261002_111742.png
    ├── Screenshot_20261002_111833.png
    ├── Screenshot_20261002_111911.png
    ├── ss_p05_01_hasil_import.jpg
    ├── ss_p05_02_show_create_table.jpg
    ├── ss_p05_03_uji_fk.jpg
    ├── ss_p05_04_uji_unique.jpg
    ├── ss_p05_05_uji_check.jpg
    ├── ss_p06_01_jumlah_baris.jpg
    ├── ss_p06_02_transaksi_baru.jpg
    ├── ss_p06_03_denda.jpg
    ├── ss_p06_04_status_eksemplar.jpg
    ├── ss_p06_05_latihan_arsip.jpg
    └── ss_p06_uj01.jpg … ss_p06_uj16.jpg
```

## Daftar Pekerjaan Praktikum

| Pertemuan | Kegiatan | Berkas utama |
|---|---|---|
| 1 | Persiapan lingkungan basis data | `p01_lingkungan_25430009.sql`, `Laporan/p01_laporan_25430009.md` |
| 2 | Analisis kebutuhan data dan aturan bisnis | `p02_kebutuhan_data_25430009.md`, `Laporan/p02_laporan_25430009.md` |
| 3 | Pemodelan ERD konseptual | `p03_erd_25430009.drawio`, `Screenshots/p03_erd_25430009.png`, `Laporan/p03_laporan_25430009.md` |
| 4 | Normalisasi UNF–3NF, dependensi fungsional, pemeriksaan BCNF, dan nilai turunan | `p04_normalisasi_25430009.md`, `p04_erd_25430009.drawio`, `Screenshots/p04_erd_25430009.png`, `Laporan/p04_laporan_25430009.md` |
| 5 | Implementasi DDL, constraint, pengujian, dan ERD fisik | `p05_ddl_25430009.sql`, `p05_erd_fisik_25430009.drawio`, `Screenshots/p05_erd_fisik_25430009.png`, `Laporan/p05_laporan_25430009.md` |
| 6 | Pengisian data sampel dengan DML, mode aman, dan skenario uji positif/negatif | `p06_data_25430009.sql`, `p06_uji_25430009.sql`, `p06_uji_25430009.md`, `p06_latihan_25430009.sql`, `Laporan/p06_laporan_25430009.md` |
| 7–16 | Pengembangan lanjutan sesuai modul praktikum | Akan ditambahkan sesuai tahapan pengerjaan |

## ERD Pertemuan 3 — Konseptual

ERD konseptual menggambarkan entitas, atribut, kunci, relasi, dan kardinalitas pada Sistem Informasi Perpustakaan berdasarkan analisis kebutuhan awal.

![ERD Konseptual Sistem Informasi Perpustakaan — Pertemuan 3](Screenshots/p03_erd_25430009.png)

- **Sumber diagram yang dapat diedit:** [`p03_erd_25430009.drawio`](p03_erd_25430009.drawio)
- **Laporan:** [`Laporan/p03_laporan_25430009.md`](Laporan/p03_laporan_25430009.md)

## ERD Pertemuan 4 — Hasil Normalisasi

Diagram ini menampilkan rancangan relasi hasil normalisasi yang digunakan sebagai dasar penyesuaian sebelum implementasi DDL.

![ERD hasil normalisasi — Pertemuan 4](Screenshots/p04_erd_25430009.png)

- **Sumber diagram yang dapat diedit:** [`p04_erd_25430009.drawio`](p04_erd_25430009.drawio)
- **Dokumen normalisasi:** [`p04_normalisasi_25430009.md`](p04_normalisasi_25430009.md)
- **Laporan:** [`Laporan/p04_laporan_25430009.md`](Laporan/p04_laporan_25430009.md)

## ERD Pertemuan 5 — Fisik

ERD fisik menggambarkan implementasi struktur basis data Perpustakaan AHD. Diagram perlu sesuai dengan struktur yang benar-benar diterapkan di database `perpus_009`, termasuk tabel, kolom, primary key, foreign key, dan constraint unik yang relevan.

![ERD fisik Sistem Informasi Perpustakaan — Pertemuan 5](Screenshots/p05_erd_fisik_25430009.png)

- **Sumber diagram yang dapat diedit:** [`p05_erd_fisik_25430009.drawio`](p05_erd_fisik_25430009.drawio)
- **Skrip DDL:** [`p05_ddl_25430009.sql`](p05_ddl_25430009.sql)
- **Laporan:** [`Laporan/p05_laporan_25430009.md`](Laporan/p05_laporan_25430009.md)

## Data Sampel dan Pengujian Pertemuan 6

Data sampel Pertemuan 6 melanjutkan isi `perpus_009` hasil Pertemuan 5 (MySQL 8.4.3, Laragon). Tambahannya 7 anggota, 6 judul buku, 12 eksemplar, 10 transaksi peminjaman pada 4 tanggal (`10 × P`, P = 1), 18 item, 13 pengembalian, dan 4 denda, sehingga total menjadi anggota 17, petugas 10, buku 16, eksemplar 22, peminjaman 20, detail 28, pengembalian 23, dan denda 14. Setelah Latihan E.1 memindahkan AGT016 ke tabel `anggota_arsip`, isi `anggota` menjadi 16. Skenario uji dijalankan di tab SQL phpMyAdmin (setiap uji di-`ROLLBACK`) dan didokumentasikan pada `p06_uji_25430009.md`: 16 skenario, 15 LULUS, 1 GAGAL yang dicatat sebagai utang desain untuk Modul 14.

- **Skrip data:** [`p06_data_25430009.sql`](p06_data_25430009.sql)
- **Skenario uji:** [`p06_uji_25430009.md`](p06_uji_25430009.md), [`p06_uji_25430009.sql`](p06_uji_25430009.sql)
- **Latihan pengarsipan:** [`p06_latihan_25430009.sql`](p06_latihan_25430009.sql)
- **Laporan:** [`Laporan/p06_laporan_25430009.md`](Laporan/p06_laporan_25430009.md)
- **Bukti phpMyAdmin:** `Screenshots/ss_p06_01_jumlah_baris.jpg` sampai `ss_p06_05_latihan_arsip.jpg`, serta `ss_p06_uj01.jpg` sampai `ss_p06_uj16.jpg` (satu gambar per skenario uji)

## Dokumentasi dan Bukti Praktikum

Laporan praktikum disimpan pada folder `Laporan/`. Gambar ERD dan tangkapan layar bukti pelaksanaan disimpan pada folder `Screenshots/`. Nama file pada tautan Markdown harus sama persis dengan nama file di repositori agar gambar dapat terlihat pada VS Code Preview dan GitHub.

Bukti pengujian Pertemuan 5 meliputi hasil implementasi, tampilan `SHOW CREATE TABLE`, pengujian foreign key, pengujian UNIQUE, dan pengujian CHECK. Tangkapan layar yang digunakan pada laporan sebaiknya berasal dari eksekusi sebenarnya.

Bukti Pertemuan 6 diambil dari phpMyAdmin Laragon dengan akun `dev_009`. Isinya meliputi jumlah baris per tabel, transaksi baru, denda, status eksemplar, hasil Latihan E.1, dan 16 skenario uji positif/negatif.

## Teknologi dan Perangkat

- **DBMS:** MySQL 8.4.3 (Laragon).
- **Pemodelan ERD:** Draw.io (diagrams.net).
- **Dokumentasi:** Markdown.
- **Kontrol versi:** Git dan GitHub.

## Status Proyek

Dokumentasi dan berkas utama untuk Pertemuan 1–6 telah tersedia. Pengembangan berikutnya akan dilanjutkan sesuai modul Pertemuan 7–16, lalu diperbarui seiring penyelesaian setiap pertemuan.

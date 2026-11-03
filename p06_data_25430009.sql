-- =====================================================================
-- Pertemuan 6 - Data Sampel Proyek Perpustakaan AHD (lanjutan P01-P05)
-- Nama : Abbiyu Hashfi Dzakwan | NPM : 25430009 | Kelas : A
-- Basis data : perpus_009 (MySQL 8.4.3, Laragon)
-- Parameter  : P = 1  -> maks. item per transaksi = P + 2 = 3 (AB-04)
--                     -> tarif denda = Rp1.000/hari/buku (AB-07)
--                     -> transaksi utama baru minimal 10 x P = 10 baris
--
-- Skrip ini MELANJUTKAN isi perpus_009 hasil Pertemuan 5 (10 baris per
-- tabel). Data lama tidak diubah/dihapus. Kode baru meneruskan format
-- yang sudah dipakai di basis data:
--   anggota AGT011.., buku BUK-011.., eksemplar EKS011..,
--   peminjaman PJM-YYYYMMDD-00011.., petugas memakai petugas lama (p02..p08).
--
-- Urutan eksekusi dari basis data kosong:
--   p05_ddl_25430009.sql -> (data P05) -> p06_data_25430009.sql
--
-- Skrip dapat dijalankan ulang:
--   * tabel master memakai INSERT IGNORE + kunci alami UNIQUE;
--   * tabel transaksi memakai INSERT ... SELECT ... WHERE NOT EXISTS,
--     sehingga trigger tidak dipicu lagi untuk baris yang sudah tercatat;
--   * id tidak pernah ditebak; id dicari lewat kode alami.
--
-- Catatan teknis: insert ke detail_peminjaman dan pengembalian memakai
-- variabel sesi (@pj, @e) karena trigger AFTER INSERT pada tabel tersebut
-- meng-UPDATE eksemplar_buku/detail_peminjaman/peminjaman. Jika tabel itu
-- dibaca langsung di SELECT pada perintah INSERT yang sama, server menolak
-- dengan ERROR 1442.
-- =====================================================================

USE perpus_009;
SET NAMES utf8mb4;

-- ---------------------------------------------------------------------
-- 1. DATA INDUK (master) - induk diisi lebih dulu daripada tabel anak
--    Petugas tidak ditambah: transaksi baru dilayani petugas p02-p08.
-- ---------------------------------------------------------------------

-- 1.1 Anggota baru (7 baris; AGT016 nonaktif sejak awal,
--     AGT017 dinonaktifkan setelah transaksi pertamanya selesai)
INSERT IGNORE INTO anggota
  (no_anggota, nama_anggota, alamat_anggota, no_hp_anggota, tgl_daftar_anggota, status_anggota)
VALUES
  ('AGT011', 'Ahmad Rizky Pratama',  'Jl. Ahmad Yani No. 12, Metro Pusat',     '081278340011', '2026-02-10', 'aktif'),
  ('AGT012', 'Nabila Khairunnisa',   'Jl. Imam Bonjol No. 5, Metro Barat',     '082180457712', '2026-03-04', 'aktif'),
  ('AGT013', 'Galih Mahendra',       'Jl. Jend. Sudirman No. 88, Metro Timur', '085266901234', '2026-04-21', 'aktif'),
  ('AGT014', 'Putri Ayu Ramadhani',  'Jl. Kenanga No. 3, Metro Selatan',       '081369228805', '2026-05-15', 'aktif'),
  ('AGT015', 'Yoga Aditya Saputra',  'Jl. Pattimura No. 41, Metro Utara',      '089612340987', '2026-08-03', 'aktif'),
  ('AGT016', 'Rahmat Hidayatullah',  'Jl. Hasanudin No. 17, Metro Pusat',      '081211198830', '2024-04-22', 'nonaktif'),
  ('AGT017', 'Wulan Oktaviani',      'Jl. Cendrawasih No. 9, Metro Barat',     '082377610054', '2024-09-30', 'aktif');

-- 1.2 Buku / judul baru (6 baris)
INSERT IGNORE INTO buku
  (kode_buku, isbn_buku, judul_buku, penulis_buku, penerbit_buku, tahun_terbit_buku, kategori_buku)
VALUES
  ('BUK-011', '9786020010011', 'Pemrograman Python untuk Analisis Data', 'Bayu Wicaksono',    'Penerbit Lentera Ilmu',  2025, 'Teknologi Informasi'),
  ('BUK-012', '9786020010012', 'Perancangan Basis Data Relasional',      'Rina Marlina',      'Penerbit Andalas Media', 2024, 'Teknologi Informasi'),
  ('BUK-013', '9786020010013', 'Statistika untuk Penelitian Sosial',     'Hadi Purnomo',      'Penerbit Cakrawala',     2023, 'Matematika'),
  ('BUK-014', '9786020010014', 'Sejarah Lampung dari Masa ke Masa',      'Sutan Rajo Alam',   'Penerbit Way Sekampung', 2022, 'Sejarah'),
  ('BUK-015', '9786020010015', 'Kimia Dasar untuk Perguruan Tinggi',     'Indah Permatasari', 'Penerbit Cakrawala',     2021, 'Sains'),
  ('BUK-016', NULL,            'Kumpulan Cerpen Senja di Metro',         'Arif Maulana',      'Penerbit Pena Kampus',   2026, 'Sastra');

-- 1.3 Eksemplar baru (12 baris, dua salinan fisik per judul baru - AB-08)
INSERT IGNORE INTO eksemplar_buku (id_buku, kode_eksemplar, kondisi_eksemplar, status_eksemplar)
SELECT b.id_buku, x.kode_eksemplar, 'baik', 'tersedia'
FROM (
  SELECT 'BUK-011' AS kode_buku, 'EKS011' AS kode_eksemplar UNION ALL
  SELECT 'BUK-011', 'EKS012' UNION ALL
  SELECT 'BUK-012', 'EKS013' UNION ALL
  SELECT 'BUK-012', 'EKS014' UNION ALL
  SELECT 'BUK-013', 'EKS015' UNION ALL
  SELECT 'BUK-013', 'EKS016' UNION ALL
  SELECT 'BUK-014', 'EKS017' UNION ALL
  SELECT 'BUK-014', 'EKS018' UNION ALL
  SELECT 'BUK-015', 'EKS019' UNION ALL
  SELECT 'BUK-015', 'EKS020' UNION ALL
  SELECT 'BUK-016', 'EKS021' UNION ALL
  SELECT 'BUK-016', 'EKS022'
) AS x
JOIN buku b ON b.kode_buku = x.kode_buku;

-- ---------------------------------------------------------------------
-- 2. TRANSAKSI - dicatat kronologis (pinjam -> kembali -> pinjam lagi)
--    10 transaksi baru pada 4 tanggal berbeda:
--    2026-09-14, 2026-09-21, 2026-10-02, 2026-10-20
--    Jatuh tempo = tgl_pinjam + 7 hari (AB-06)
-- ---------------------------------------------------------------------

-- 2.1 Kepala transaksi gelombang 1 (2026-09-14)
INSERT INTO peminjaman (nomor_peminjaman, id_anggota, id_petugas, tgl_pinjam, status_peminjaman)
SELECT x.nomor, a.id_anggota, p.id_petugas, x.tgl, 'aktif'
FROM (
  SELECT 'PJM-20260914-00011' AS nomor, 'AGT017' AS agt, 'p03' AS ptg, DATE '2026-09-14' AS tgl UNION ALL
  SELECT 'PJM-20260914-00012', 'AGT011', 'p05', DATE '2026-09-14' UNION ALL
  SELECT 'PJM-20260914-00013', 'AGT012', 'p03', DATE '2026-09-14'
) AS x
JOIN anggota a ON a.no_anggota = x.agt
JOIN petugas p ON p.kode_petugas = x.ptg
WHERE NOT EXISTS (SELECT 1 FROM peminjaman q WHERE q.nomor_peminjaman = x.nomor);

-- Detail PJM-20260914-00011 : EKS011, EKS013
SET @pj = (SELECT id_peminjaman FROM peminjaman WHERE nomor_peminjaman = 'PJM-20260914-00011');
SET @e  = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS011');
INSERT INTO detail_peminjaman (id_peminjaman, id_eksemplar, tgl_jatuh_tempo)
SELECT @pj, @e, '2026-09-21' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM detail_peminjaman WHERE id_peminjaman = @pj AND id_eksemplar = @e);
SET @e  = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS013');
INSERT INTO detail_peminjaman (id_peminjaman, id_eksemplar, tgl_jatuh_tempo)
SELECT @pj, @e, '2026-09-21' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM detail_peminjaman WHERE id_peminjaman = @pj AND id_eksemplar = @e);

-- Detail PJM-20260914-00012 : EKS015
SET @pj = (SELECT id_peminjaman FROM peminjaman WHERE nomor_peminjaman = 'PJM-20260914-00012');
SET @e  = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS015');
INSERT INTO detail_peminjaman (id_peminjaman, id_eksemplar, tgl_jatuh_tempo)
SELECT @pj, @e, '2026-09-21' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM detail_peminjaman WHERE id_peminjaman = @pj AND id_eksemplar = @e);

-- Detail PJM-20260914-00013 : EKS017, EKS019, EKS021 (tepat 3 item = batas AB-04)
SET @pj = (SELECT id_peminjaman FROM peminjaman WHERE nomor_peminjaman = 'PJM-20260914-00013');
SET @e  = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS017');
INSERT INTO detail_peminjaman (id_peminjaman, id_eksemplar, tgl_jatuh_tempo)
SELECT @pj, @e, '2026-09-21' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM detail_peminjaman WHERE id_peminjaman = @pj AND id_eksemplar = @e);
SET @e  = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS019');
INSERT INTO detail_peminjaman (id_peminjaman, id_eksemplar, tgl_jatuh_tempo)
SELECT @pj, @e, '2026-09-21' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM detail_peminjaman WHERE id_peminjaman = @pj AND id_eksemplar = @e);
SET @e  = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS021');
INSERT INTO detail_peminjaman (id_peminjaman, id_eksemplar, tgl_jatuh_tempo)
SELECT @pj, @e, '2026-09-21' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM detail_peminjaman WHERE id_peminjaman = @pj AND id_eksemplar = @e);

-- 2.2 Pengembalian gelombang 1 (trigger memperbarui detail, eksemplar, dan status transaksi)
SET @ptg = (SELECT id_petugas FROM petugas WHERE kode_petugas = 'p06');

-- PJM-20260914-00011 dikembalikan 2026-09-20 (tepat waktu)
SET @pj = (SELECT id_peminjaman FROM peminjaman WHERE nomor_peminjaman = 'PJM-20260914-00011');
SET @e  = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS011');
INSERT INTO pengembalian (id_peminjaman, id_eksemplar, id_petugas, tgl_kembali, kondisi_kembali)
SELECT @pj, @e, @ptg, '2026-09-20', 'baik' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM pengembalian WHERE id_peminjaman = @pj AND id_eksemplar = @e);
SET @e  = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS013');
INSERT INTO pengembalian (id_peminjaman, id_eksemplar, id_petugas, tgl_kembali, kondisi_kembali)
SELECT @pj, @e, @ptg, '2026-09-20', 'baik' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM pengembalian WHERE id_peminjaman = @pj AND id_eksemplar = @e);

-- PJM-20260914-00013 dikembalikan 2026-09-21 (tepat waktu; EKS021 rusak ringan -> perbaikan)
SET @pj = (SELECT id_peminjaman FROM peminjaman WHERE nomor_peminjaman = 'PJM-20260914-00013');
SET @e  = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS017');
INSERT INTO pengembalian (id_peminjaman, id_eksemplar, id_petugas, tgl_kembali, kondisi_kembali)
SELECT @pj, @e, @ptg, '2026-09-21', 'baik' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM pengembalian WHERE id_peminjaman = @pj AND id_eksemplar = @e);
SET @e  = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS019');
INSERT INTO pengembalian (id_peminjaman, id_eksemplar, id_petugas, tgl_kembali, kondisi_kembali)
SELECT @pj, @e, @ptg, '2026-09-21', 'baik' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM pengembalian WHERE id_peminjaman = @pj AND id_eksemplar = @e);
SET @e  = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS021');
INSERT INTO pengembalian (id_peminjaman, id_eksemplar, id_petugas, tgl_kembali, kondisi_kembali)
SELECT @pj, @e, @ptg, '2026-09-21', 'rusak_ringan' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM pengembalian WHERE id_peminjaman = @pj AND id_eksemplar = @e);

-- PJM-20260914-00012 dikembalikan 2026-09-24 (terlambat 3 hari)
SET @pj = (SELECT id_peminjaman FROM peminjaman WHERE nomor_peminjaman = 'PJM-20260914-00012');
SET @e  = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS015');
INSERT INTO pengembalian (id_peminjaman, id_eksemplar, id_petugas, tgl_kembali, kondisi_kembali)
SELECT @pj, @e, @ptg, '2026-09-24', 'baik' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM pengembalian WHERE id_peminjaman = @pj AND id_eksemplar = @e);

-- Anggota AGT017 berhenti menjadi anggota setelah transaksinya selesai.
-- WHERE memakai kolom UNIQUE agar aman di mode sql_safe_updates.
UPDATE anggota SET status_anggota = 'nonaktif' WHERE no_anggota = 'AGT017';

-- 2.3 Kepala transaksi gelombang 2 (2026-09-21)
INSERT INTO peminjaman (nomor_peminjaman, id_anggota, id_petugas, tgl_pinjam, status_peminjaman)
SELECT x.nomor, a.id_anggota, p.id_petugas, x.tgl, 'aktif'
FROM (
  SELECT 'PJM-20260921-00014' AS nomor, 'AGT013' AS agt, 'p05' AS ptg, DATE '2026-09-21' AS tgl UNION ALL
  SELECT 'PJM-20260921-00015', 'AGT001', 'p02', DATE '2026-09-21' UNION ALL
  SELECT 'PJM-20260921-00016', 'AGT014', 'p03', DATE '2026-09-21'
) AS x
JOIN anggota a ON a.no_anggota = x.agt
JOIN petugas p ON p.kode_petugas = x.ptg
WHERE NOT EXISTS (SELECT 1 FROM peminjaman q WHERE q.nomor_peminjaman = x.nomor);

-- Detail PJM-20260921-00014 : EKS012, EKS014
SET @pj = (SELECT id_peminjaman FROM peminjaman WHERE nomor_peminjaman = 'PJM-20260921-00014');
SET @e  = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS012');
INSERT INTO detail_peminjaman (id_peminjaman, id_eksemplar, tgl_jatuh_tempo)
SELECT @pj, @e, '2026-09-28' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM detail_peminjaman WHERE id_peminjaman = @pj AND id_eksemplar = @e);
SET @e  = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS014');
INSERT INTO detail_peminjaman (id_peminjaman, id_eksemplar, tgl_jatuh_tempo)
SELECT @pj, @e, '2026-09-28' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM detail_peminjaman WHERE id_peminjaman = @pj AND id_eksemplar = @e);

-- Detail PJM-20260921-00015 : EKS011 (dipinjam ulang setelah kembali 2026-09-20)
SET @pj = (SELECT id_peminjaman FROM peminjaman WHERE nomor_peminjaman = 'PJM-20260921-00015');
SET @e  = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS011');
INSERT INTO detail_peminjaman (id_peminjaman, id_eksemplar, tgl_jatuh_tempo)
SELECT @pj, @e, '2026-09-28' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM detail_peminjaman WHERE id_peminjaman = @pj AND id_eksemplar = @e);

-- Detail PJM-20260921-00016 : EKS016, EKS018
SET @pj = (SELECT id_peminjaman FROM peminjaman WHERE nomor_peminjaman = 'PJM-20260921-00016');
SET @e  = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS016');
INSERT INTO detail_peminjaman (id_peminjaman, id_eksemplar, tgl_jatuh_tempo)
SELECT @pj, @e, '2026-09-28' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM detail_peminjaman WHERE id_peminjaman = @pj AND id_eksemplar = @e);
SET @e  = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS018');
INSERT INTO detail_peminjaman (id_peminjaman, id_eksemplar, tgl_jatuh_tempo)
SELECT @pj, @e, '2026-09-28' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM detail_peminjaman WHERE id_peminjaman = @pj AND id_eksemplar = @e);

-- 2.4 Pengembalian gelombang 2
SET @ptg = (SELECT id_petugas FROM petugas WHERE kode_petugas = 'p08');

-- PJM-20260921-00015 dikembalikan 2026-09-26 (tepat waktu)
SET @pj = (SELECT id_peminjaman FROM peminjaman WHERE nomor_peminjaman = 'PJM-20260921-00015');
SET @e  = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS011');
INSERT INTO pengembalian (id_peminjaman, id_eksemplar, id_petugas, tgl_kembali, kondisi_kembali)
SELECT @pj, @e, @ptg, '2026-09-26', 'baik' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM pengembalian WHERE id_peminjaman = @pj AND id_eksemplar = @e);

-- PJM-20260921-00016 dikembalikan 2026-09-28 (tepat pada jatuh tempo)
SET @pj = (SELECT id_peminjaman FROM peminjaman WHERE nomor_peminjaman = 'PJM-20260921-00016');
SET @e  = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS016');
INSERT INTO pengembalian (id_peminjaman, id_eksemplar, id_petugas, tgl_kembali, kondisi_kembali)
SELECT @pj, @e, @ptg, '2026-09-28', 'baik' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM pengembalian WHERE id_peminjaman = @pj AND id_eksemplar = @e);
SET @e  = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS018');
INSERT INTO pengembalian (id_peminjaman, id_eksemplar, id_petugas, tgl_kembali, kondisi_kembali)
SELECT @pj, @e, @ptg, '2026-09-28', 'baik' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM pengembalian WHERE id_peminjaman = @pj AND id_eksemplar = @e);

-- PJM-20260921-00014 dikembalikan 2026-10-01 (terlambat 3 hari, 2 buku)
SET @pj = (SELECT id_peminjaman FROM peminjaman WHERE nomor_peminjaman = 'PJM-20260921-00014');
SET @e  = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS012');
INSERT INTO pengembalian (id_peminjaman, id_eksemplar, id_petugas, tgl_kembali, kondisi_kembali)
SELECT @pj, @e, @ptg, '2026-10-01', 'baik' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM pengembalian WHERE id_peminjaman = @pj AND id_eksemplar = @e);
SET @e  = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS014');
INSERT INTO pengembalian (id_peminjaman, id_eksemplar, id_petugas, tgl_kembali, kondisi_kembali)
SELECT @pj, @e, @ptg, '2026-10-01', 'baik' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM pengembalian WHERE id_peminjaman = @pj AND id_eksemplar = @e);

-- 2.5 Kepala transaksi gelombang 3 (2026-10-02)
INSERT INTO peminjaman (nomor_peminjaman, id_anggota, id_petugas, tgl_pinjam, status_peminjaman)
SELECT x.nomor, a.id_anggota, p.id_petugas, x.tgl, 'aktif'
FROM (
  SELECT 'PJM-20261002-00017' AS nomor, 'AGT015' AS agt, 'p05' AS ptg, DATE '2026-10-02' AS tgl UNION ALL
  SELECT 'PJM-20261002-00018', 'AGT012', 'p03', DATE '2026-10-02' UNION ALL
  SELECT 'PJM-20261002-00019', 'AGT013', 'p08', DATE '2026-10-02'
) AS x
JOIN anggota a ON a.no_anggota = x.agt
JOIN petugas p ON p.kode_petugas = x.ptg
WHERE NOT EXISTS (SELECT 1 FROM peminjaman q WHERE q.nomor_peminjaman = x.nomor);

-- Detail PJM-20261002-00017 : EKS013, EKS020
SET @pj = (SELECT id_peminjaman FROM peminjaman WHERE nomor_peminjaman = 'PJM-20261002-00017');
SET @e  = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS013');
INSERT INTO detail_peminjaman (id_peminjaman, id_eksemplar, tgl_jatuh_tempo)
SELECT @pj, @e, '2026-10-09' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM detail_peminjaman WHERE id_peminjaman = @pj AND id_eksemplar = @e);
SET @e  = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS020');
INSERT INTO detail_peminjaman (id_peminjaman, id_eksemplar, tgl_jatuh_tempo)
SELECT @pj, @e, '2026-10-09' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM detail_peminjaman WHERE id_peminjaman = @pj AND id_eksemplar = @e);

-- Detail PJM-20261002-00018 : EKS015
SET @pj = (SELECT id_peminjaman FROM peminjaman WHERE nomor_peminjaman = 'PJM-20261002-00018');
SET @e  = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS015');
INSERT INTO detail_peminjaman (id_peminjaman, id_eksemplar, tgl_jatuh_tempo)
SELECT @pj, @e, '2026-10-09' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM detail_peminjaman WHERE id_peminjaman = @pj AND id_eksemplar = @e);

-- Detail PJM-20261002-00019 : EKS017, EKS019
SET @pj = (SELECT id_peminjaman FROM peminjaman WHERE nomor_peminjaman = 'PJM-20261002-00019');
SET @e  = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS017');
INSERT INTO detail_peminjaman (id_peminjaman, id_eksemplar, tgl_jatuh_tempo)
SELECT @pj, @e, '2026-10-09' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM detail_peminjaman WHERE id_peminjaman = @pj AND id_eksemplar = @e);
SET @e  = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS019');
INSERT INTO detail_peminjaman (id_peminjaman, id_eksemplar, tgl_jatuh_tempo)
SELECT @pj, @e, '2026-10-09' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM detail_peminjaman WHERE id_peminjaman = @pj AND id_eksemplar = @e);

-- 2.6 Pengembalian gelombang 3
SET @ptg = (SELECT id_petugas FROM petugas WHERE kode_petugas = 'p02');

-- PJM-20261002-00019 : hanya EKS017 yang kembali 2026-10-09; EKS019 masih dipinjam
SET @pj = (SELECT id_peminjaman FROM peminjaman WHERE nomor_peminjaman = 'PJM-20261002-00019');
SET @e  = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS017');
INSERT INTO pengembalian (id_peminjaman, id_eksemplar, id_petugas, tgl_kembali, kondisi_kembali)
SELECT @pj, @e, @ptg, '2026-10-09', 'baik' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM pengembalian WHERE id_peminjaman = @pj AND id_eksemplar = @e);

-- PJM-20261002-00018 dikembalikan 2026-10-12 (terlambat 3 hari)
SET @pj = (SELECT id_peminjaman FROM peminjaman WHERE nomor_peminjaman = 'PJM-20261002-00018');
SET @e  = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS015');
INSERT INTO pengembalian (id_peminjaman, id_eksemplar, id_petugas, tgl_kembali, kondisi_kembali)
SELECT @pj, @e, @ptg, '2026-10-12', 'baik' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM pengembalian WHERE id_peminjaman = @pj AND id_eksemplar = @e);

-- 2.7 Kepala transaksi gelombang 4 (2026-10-20) - masih berjalan
INSERT INTO peminjaman (nomor_peminjaman, id_anggota, id_petugas, tgl_pinjam, status_peminjaman)
SELECT x.nomor, a.id_anggota, p.id_petugas, x.tgl, 'aktif'
FROM (
  SELECT 'PJM-20261020-00020' AS nomor, 'AGT014' AS agt, 'p05' AS ptg, DATE '2026-10-20' AS tgl
) AS x
JOIN anggota a ON a.no_anggota = x.agt
JOIN petugas p ON p.kode_petugas = x.ptg
WHERE NOT EXISTS (SELECT 1 FROM peminjaman q WHERE q.nomor_peminjaman = x.nomor);

-- Detail PJM-20261020-00020 : EKS022, EKS011
SET @pj = (SELECT id_peminjaman FROM peminjaman WHERE nomor_peminjaman = 'PJM-20261020-00020');
SET @e  = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS022');
INSERT INTO detail_peminjaman (id_peminjaman, id_eksemplar, tgl_jatuh_tempo)
SELECT @pj, @e, '2026-10-27' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM detail_peminjaman WHERE id_peminjaman = @pj AND id_eksemplar = @e);
SET @e  = (SELECT id_eksemplar FROM eksemplar_buku WHERE kode_eksemplar = 'EKS011');
INSERT INTO detail_peminjaman (id_peminjaman, id_eksemplar, tgl_jatuh_tempo)
SELECT @pj, @e, '2026-10-27' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM detail_peminjaman WHERE id_peminjaman = @pj AND id_eksemplar = @e);

-- ---------------------------------------------------------------------
-- 3. DENDA - hanya untuk pengembalian yang terlambat (AB-07, AB-10)
--    tarif_harian disalin dari aturan saat ini (Rp1.000);
--    jumlah_denda dihitung trigger trg_denda_hitung.
-- ---------------------------------------------------------------------
INSERT INTO denda (id_pengembalian, tarif_harian)
SELECT pg.id_pengembalian, 1000
FROM pengembalian pg
JOIN peminjaman pj     ON pj.id_peminjaman = pg.id_peminjaman
JOIN eksemplar_buku ex ON ex.id_eksemplar  = pg.id_eksemplar
WHERE (pj.nomor_peminjaman, ex.kode_eksemplar) IN (
        ('PJM-20260914-00012', 'EKS015'),
        ('PJM-20260921-00014', 'EKS012'),
        ('PJM-20260921-00014', 'EKS014'),
        ('PJM-20261002-00018', 'EKS015'))
  AND NOT EXISTS (SELECT 1 FROM denda d WHERE d.id_pengembalian = pg.id_pengembalian);

-- Pelunasan denda (WHERE memakai kolom kunci id_denda)
SET @d = (SELECT d.id_denda FROM denda d
          JOIN pengembalian pg   ON pg.id_pengembalian = d.id_pengembalian
          JOIN peminjaman pj     ON pj.id_peminjaman   = pg.id_peminjaman
          JOIN eksemplar_buku ex ON ex.id_eksemplar    = pg.id_eksemplar
          WHERE pj.nomor_peminjaman = 'PJM-20260914-00012' AND ex.kode_eksemplar = 'EKS015');
UPDATE denda SET status_bayar = 'lunas', tgl_bayar = '2026-09-24' WHERE id_denda = @d;

SET @d = (SELECT d.id_denda FROM denda d
          JOIN pengembalian pg   ON pg.id_pengembalian = d.id_pengembalian
          JOIN peminjaman pj     ON pj.id_peminjaman   = pg.id_peminjaman
          JOIN eksemplar_buku ex ON ex.id_eksemplar    = pg.id_eksemplar
          WHERE pj.nomor_peminjaman = 'PJM-20260921-00014' AND ex.kode_eksemplar = 'EKS012');
UPDATE denda SET status_bayar = 'lunas', tgl_bayar = '2026-10-02' WHERE id_denda = @d;

-- ---------------------------------------------------------------------
-- 4. PEMERIKSAAN HASIL (data P05 + data baru P06)
-- ---------------------------------------------------------------------
SELECT 'anggota' AS nama_tabel, COUNT(*) AS jumlah_baris FROM anggota
UNION ALL SELECT 'petugas',           COUNT(*) FROM petugas
UNION ALL SELECT 'buku',              COUNT(*) FROM buku
UNION ALL SELECT 'eksemplar_buku',    COUNT(*) FROM eksemplar_buku
UNION ALL SELECT 'peminjaman',        COUNT(*) FROM peminjaman
UNION ALL SELECT 'detail_peminjaman', COUNT(*) FROM detail_peminjaman
UNION ALL SELECT 'pengembalian',      COUNT(*) FROM pengembalian
UNION ALL SELECT 'denda',             COUNT(*) FROM denda;

SELECT tgl_pinjam, COUNT(*) AS transaksi_baru_p06
FROM peminjaman
WHERE CAST(SUBSTRING(nomor_peminjaman, -5) AS UNSIGNED) BETWEEN 11 AND 20
GROUP BY tgl_pinjam ORDER BY tgl_pinjam;

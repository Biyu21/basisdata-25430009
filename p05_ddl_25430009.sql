CREATE DATABASE IF NOT EXISTS perpus_009
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE perpus_009;
SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS anggota (
  id_anggota INT UNSIGNED NOT NULL AUTO_INCREMENT,
  no_anggota VARCHAR(20) NOT NULL,
  nama_anggota VARCHAR(100) NOT NULL,
  alamat_anggota TEXT NULL,
  no_hp_anggota VARCHAR(20) NULL,
  tgl_daftar_anggota DATE NOT NULL,
  status_anggota ENUM('aktif','nonaktif') NOT NULL DEFAULT 'aktif',
  CONSTRAINT pk_anggota PRIMARY KEY (id_anggota),
  CONSTRAINT uq_anggota_no_anggota UNIQUE (no_anggota),
  CONSTRAINT ck_anggota_status CHECK (status_anggota IN ('aktif','nonaktif'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS petugas (
  id_petugas INT UNSIGNED NOT NULL AUTO_INCREMENT,
  kode_petugas VARCHAR(20) NOT NULL,
  nama_petugas VARCHAR(100) NOT NULL,
  peran_petugas ENUM('admin','pustakawan','petugas') NOT NULL DEFAULT 'petugas',
  CONSTRAINT pk_petugas PRIMARY KEY (id_petugas),
  CONSTRAINT uq_petugas_kode_petugas UNIQUE (kode_petugas),
  CONSTRAINT ck_petugas_nama CHECK (CHAR_LENGTH(TRIM(nama_petugas)) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS buku (
  id_buku INT UNSIGNED NOT NULL AUTO_INCREMENT,
  kode_buku VARCHAR(20) NOT NULL,
  isbn_buku VARCHAR(20) NULL,
  judul_buku VARCHAR(200) NOT NULL,
  penulis_buku VARCHAR(150) NOT NULL,
  penerbit_buku VARCHAR(150) NULL,
  tahun_terbit_buku YEAR NULL,
  kategori_buku VARCHAR(100) NULL,
  CONSTRAINT pk_buku PRIMARY KEY (id_buku),
  CONSTRAINT uq_buku_kode_buku UNIQUE (kode_buku),
  CONSTRAINT uq_buku_isbn_buku UNIQUE (isbn_buku),
  CONSTRAINT ck_buku_judul CHECK (CHAR_LENGTH(TRIM(judul_buku)) > 0),
  CONSTRAINT ck_buku_tahun_terbit CHECK (tahun_terbit_buku IS NULL OR tahun_terbit_buku BETWEEN 1901 AND 2155)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS eksemplar_buku (
  id_eksemplar INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_buku INT UNSIGNED NOT NULL,
  kode_eksemplar VARCHAR(30) NOT NULL,
  kondisi_eksemplar ENUM('baik','rusak_ringan','rusak_berat') NOT NULL DEFAULT 'baik',
  status_eksemplar ENUM('tersedia','dipinjam','perbaikan','hilang') NOT NULL DEFAULT 'tersedia',
  CONSTRAINT pk_eksemplar_buku PRIMARY KEY (id_eksemplar),
  CONSTRAINT uq_eksemplar_buku_kode_eksemplar UNIQUE (kode_eksemplar),
  CONSTRAINT fk_eksemplar_buku FOREIGN KEY (id_buku) REFERENCES buku (id_buku)
    ON DELETE RESTRICT ON UPDATE CASCADE, -- AB-08
  CONSTRAINT ck_eksemplar_kondisi CHECK (kondisi_eksemplar IN ('baik','rusak_ringan','rusak_berat')),
  CONSTRAINT ck_eksemplar_status CHECK (status_eksemplar IN ('tersedia','dipinjam','perbaikan','hilang'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS peminjaman (
  id_peminjaman INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nomor_peminjaman VARCHAR(30) NOT NULL,
  id_anggota INT UNSIGNED NOT NULL,
  id_petugas INT UNSIGNED NOT NULL,
  tgl_pinjam DATE NOT NULL,
  status_peminjaman ENUM('aktif','selesai','dibatalkan') NOT NULL DEFAULT 'aktif',
  CONSTRAINT pk_peminjaman PRIMARY KEY (id_peminjaman),
  CONSTRAINT uq_peminjaman_nomor_peminjaman UNIQUE (nomor_peminjaman),
  CONSTRAINT fk_peminjaman_anggota FOREIGN KEY (id_anggota) REFERENCES anggota (id_anggota)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_peminjaman_petugas FOREIGN KEY (id_petugas) REFERENCES petugas (id_petugas)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT ck_peminjaman_status CHECK (status_peminjaman IN ('aktif','selesai','dibatalkan'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS detail_peminjaman (
  id_peminjaman INT UNSIGNED NOT NULL,
  id_eksemplar INT UNSIGNED NOT NULL,
  tgl_jatuh_tempo DATE NOT NULL,
  status_detail ENUM('dipinjam','dikembalikan','hilang') NOT NULL DEFAULT 'dipinjam',
  CONSTRAINT pk_detail_peminjaman PRIMARY KEY (id_peminjaman, id_eksemplar),
  CONSTRAINT fk_detail_peminjaman FOREIGN KEY (id_peminjaman) REFERENCES peminjaman (id_peminjaman)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_detail_eksemplar FOREIGN KEY (id_eksemplar) REFERENCES eksemplar_buku (id_eksemplar)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT ck_detail_status CHECK (status_detail IN ('dipinjam','dikembalikan','hilang')),
  CONSTRAINT ck_detail_tgl_jatuh_tempo CHECK (tgl_jatuh_tempo IS NOT NULL)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS pengembalian (
  id_pengembalian INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_peminjaman INT UNSIGNED NOT NULL,
  id_eksemplar INT UNSIGNED NOT NULL,
  id_petugas INT UNSIGNED NOT NULL,
  tgl_kembali DATE NOT NULL,
  kondisi_kembali ENUM('baik','rusak_ringan','rusak_berat','hilang') NOT NULL DEFAULT 'baik',
  CONSTRAINT pk_pengembalian PRIMARY KEY (id_pengembalian),
  CONSTRAINT uq_pengembalian_detail UNIQUE (id_peminjaman, id_eksemplar),
  CONSTRAINT fk_pengembalian_detail FOREIGN KEY (id_peminjaman, id_eksemplar)
    REFERENCES detail_peminjaman (id_peminjaman, id_eksemplar)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_pengembalian_petugas FOREIGN KEY (id_petugas) REFERENCES petugas (id_petugas)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT ck_pengembalian_kondisi CHECK (kondisi_kembali IN ('baik','rusak_ringan','rusak_berat','hilang'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS denda (
  id_denda INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_pengembalian INT UNSIGNED NOT NULL,
  tarif_harian INT UNSIGNED NOT NULL DEFAULT 1000,
  jumlah_denda DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  status_bayar ENUM('belum_bayar','lunas') NOT NULL DEFAULT 'belum_bayar',
  tgl_bayar DATE NULL,
  CONSTRAINT pk_denda PRIMARY KEY (id_denda),
  CONSTRAINT uq_denda_id_pengembalian UNIQUE (id_pengembalian),
  CONSTRAINT fk_denda_pengembalian FOREIGN KEY (id_pengembalian) REFERENCES pengembalian (id_pengembalian)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT ck_denda_tarif_harian CHECK (tarif_harian > 0),
  CONSTRAINT ck_denda_jumlah_nonneg CHECK (jumlah_denda >= 0),
  CONSTRAINT ck_denda_status_tanggal CHECK (
    (status_bayar = 'lunas' AND tgl_bayar IS NOT NULL)
    OR (status_bayar = 'belum_bayar' AND tgl_bayar IS NULL)
  )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET @ddl = IF(
  (SELECT COUNT(*) FROM information_schema.columns
   WHERE table_schema=DATABASE() AND table_name='buku' AND column_name='kode_buku') = 0,
  'ALTER TABLE buku ADD COLUMN kode_buku VARCHAR(20) NULL AFTER id_buku',
  'SELECT 1'
);
PREPARE p05_stmt FROM @ddl; EXECUTE p05_stmt; DEALLOCATE PREPARE p05_stmt;
UPDATE buku
SET kode_buku = CONCAT('BUK-', LPAD(id_buku, 3, '0'))
WHERE kode_buku IS NULL OR TRIM(kode_buku) = '';
ALTER TABLE buku MODIFY COLUMN kode_buku VARCHAR(20) NOT NULL;

SET @ddl = IF(
  (SELECT COUNT(*) FROM information_schema.columns
   WHERE table_schema=DATABASE() AND table_name='peminjaman' AND column_name='nomor_peminjaman') = 0,
  'ALTER TABLE peminjaman ADD COLUMN nomor_peminjaman VARCHAR(30) NULL AFTER id_peminjaman',
  'SELECT 1'
);
PREPARE p05_stmt FROM @ddl; EXECUTE p05_stmt; DEALLOCATE PREPARE p05_stmt;
UPDATE peminjaman
SET nomor_peminjaman = CONCAT('PJM-', DATE_FORMAT(tgl_pinjam, '%Y%m%d'), '-', LPAD(id_peminjaman, 5, '0'))
WHERE nomor_peminjaman IS NULL OR TRIM(nomor_peminjaman) = '';
ALTER TABLE peminjaman MODIFY COLUMN nomor_peminjaman VARCHAR(30) NOT NULL;

SET @ddl = IF(
  (SELECT COUNT(*) FROM information_schema.columns
   WHERE table_schema=DATABASE() AND table_name='denda' AND column_name='tarif_harian') = 0,
  'ALTER TABLE denda ADD COLUMN tarif_harian INT UNSIGNED NOT NULL DEFAULT 1000 AFTER id_pengembalian',
  'SELECT 1'
);
PREPARE p05_stmt FROM @ddl; EXECUTE p05_stmt; DEALLOCATE PREPARE p05_stmt;

ALTER TABLE petugas MODIFY COLUMN kode_petugas VARCHAR(20) NOT NULL;

SET @ddl = IF(
  (SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE() AND table_name='anggota' AND index_name='no_anggota') > 0
  AND
  (SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE() AND table_name='anggota' AND index_name='uq_anggota_no_anggota') = 0,
  'ALTER TABLE `anggota` RENAME INDEX `no_anggota` TO `uq_anggota_no_anggota`',
  'SELECT 1'
);
PREPARE p05_stmt FROM @ddl; EXECUTE p05_stmt; DEALLOCATE PREPARE p05_stmt;
SET @ddl = IF(
  (SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE() AND table_name='buku' AND index_name='isbn_buku') > 0
  AND
  (SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE() AND table_name='buku' AND index_name='uq_buku_isbn_buku') = 0,
  'ALTER TABLE `buku` RENAME INDEX `isbn_buku` TO `uq_buku_isbn_buku`',
  'SELECT 1'
);
PREPARE p05_stmt FROM @ddl; EXECUTE p05_stmt; DEALLOCATE PREPARE p05_stmt;
SET @ddl = IF(
  (SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE() AND table_name='denda' AND index_name='id_pengembalian') > 0
  AND
  (SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE() AND table_name='denda' AND index_name='uq_denda_id_pengembalian') = 0,
  'ALTER TABLE `denda` RENAME INDEX `id_pengembalian` TO `uq_denda_id_pengembalian`',
  'SELECT 1'
);
PREPARE p05_stmt FROM @ddl; EXECUTE p05_stmt; DEALLOCATE PREPARE p05_stmt;
SET @ddl = IF(
  (SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE() AND table_name='eksemplar_buku' AND index_name='kode_eksemplar') > 0
  AND
  (SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE() AND table_name='eksemplar_buku' AND index_name='uq_eksemplar_buku_kode_eksemplar') = 0,
  'ALTER TABLE `eksemplar_buku` RENAME INDEX `kode_eksemplar` TO `uq_eksemplar_buku_kode_eksemplar`',
  'SELECT 1'
);
PREPARE p05_stmt FROM @ddl; EXECUTE p05_stmt; DEALLOCATE PREPARE p05_stmt;
SET @ddl = IF(
  (SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE() AND table_name='petugas' AND index_name='kode_petugas') > 0
  AND
  (SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE() AND table_name='petugas' AND index_name='uq_petugas_kode_petugas') = 0,
  'ALTER TABLE `petugas` RENAME INDEX `kode_petugas` TO `uq_petugas_kode_petugas`',
  'SELECT 1'
);
PREPARE p05_stmt FROM @ddl; EXECUTE p05_stmt; DEALLOCATE PREPARE p05_stmt;

SET @ddl = IF(
  (SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE() AND table_name='buku' AND index_name='uq_buku_kode_buku') = 0,
  'ALTER TABLE `buku` ADD CONSTRAINT `uq_buku_kode_buku` UNIQUE (`kode_buku`)',
  'SELECT 1'
);
PREPARE p05_stmt FROM @ddl; EXECUTE p05_stmt; DEALLOCATE PREPARE p05_stmt;
SET @ddl = IF(
  (SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=DATABASE() AND table_name='peminjaman' AND index_name='uq_peminjaman_nomor_peminjaman') = 0,
  'ALTER TABLE `peminjaman` ADD CONSTRAINT `uq_peminjaman_nomor_peminjaman` UNIQUE (`nomor_peminjaman`)',
  'SELECT 1'
);
PREPARE p05_stmt FROM @ddl; EXECUTE p05_stmt; DEALLOCATE PREPARE p05_stmt;

SET @ddl = IF(
  (SELECT COUNT(*) FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND table_name='anggota' AND constraint_name='ck_anggota_status' AND constraint_type='CHECK') = 0,
  'ALTER TABLE `anggota` ADD CONSTRAINT `ck_anggota_status` CHECK (`status_anggota` IN (''aktif'',''nonaktif''))',
  'SELECT 1'
);
PREPARE p05_stmt FROM @ddl; EXECUTE p05_stmt; DEALLOCATE PREPARE p05_stmt;
SET @ddl = IF(
  (SELECT COUNT(*) FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND table_name='petugas' AND constraint_name='ck_petugas_nama' AND constraint_type='CHECK') = 0,
  'ALTER TABLE `petugas` ADD CONSTRAINT `ck_petugas_nama` CHECK (CHAR_LENGTH(TRIM(`nama_petugas`)) > 0)',
  'SELECT 1'
);
PREPARE p05_stmt FROM @ddl; EXECUTE p05_stmt; DEALLOCATE PREPARE p05_stmt;
SET @ddl = IF(
  (SELECT COUNT(*) FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND table_name='buku' AND constraint_name='ck_buku_judul' AND constraint_type='CHECK') = 0,
  'ALTER TABLE `buku` ADD CONSTRAINT `ck_buku_judul` CHECK (CHAR_LENGTH(TRIM(`judul_buku`)) > 0)',
  'SELECT 1'
);
PREPARE p05_stmt FROM @ddl; EXECUTE p05_stmt; DEALLOCATE PREPARE p05_stmt;
SET @ddl = IF(
  (SELECT COUNT(*) FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND table_name='buku' AND constraint_name='ck_buku_tahun_terbit' AND constraint_type='CHECK') = 0,
  'ALTER TABLE `buku` ADD CONSTRAINT `ck_buku_tahun_terbit` CHECK (`tahun_terbit_buku` IS NULL OR `tahun_terbit_buku` BETWEEN 1901 AND 2155)',
  'SELECT 1'
);
PREPARE p05_stmt FROM @ddl; EXECUTE p05_stmt; DEALLOCATE PREPARE p05_stmt;
SET @ddl = IF(
  (SELECT COUNT(*) FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND table_name='eksemplar_buku' AND constraint_name='ck_eksemplar_kondisi' AND constraint_type='CHECK') = 0,
  'ALTER TABLE `eksemplar_buku` ADD CONSTRAINT `ck_eksemplar_kondisi` CHECK (`kondisi_eksemplar` IN (''baik'',''rusak_ringan'',''rusak_berat''))',
  'SELECT 1'
);
PREPARE p05_stmt FROM @ddl; EXECUTE p05_stmt; DEALLOCATE PREPARE p05_stmt;
SET @ddl = IF(
  (SELECT COUNT(*) FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND table_name='eksemplar_buku' AND constraint_name='ck_eksemplar_status' AND constraint_type='CHECK') = 0,
  'ALTER TABLE `eksemplar_buku` ADD CONSTRAINT `ck_eksemplar_status` CHECK (`status_eksemplar` IN (''tersedia'',''dipinjam'',''perbaikan'',''hilang''))',
  'SELECT 1'
);
PREPARE p05_stmt FROM @ddl; EXECUTE p05_stmt; DEALLOCATE PREPARE p05_stmt;
SET @ddl = IF(
  (SELECT COUNT(*) FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND table_name='peminjaman' AND constraint_name='ck_peminjaman_status' AND constraint_type='CHECK') = 0,
  'ALTER TABLE `peminjaman` ADD CONSTRAINT `ck_peminjaman_status` CHECK (`status_peminjaman` IN (''aktif'',''selesai'',''dibatalkan''))',
  'SELECT 1'
);
PREPARE p05_stmt FROM @ddl; EXECUTE p05_stmt; DEALLOCATE PREPARE p05_stmt;
SET @ddl = IF(
  (SELECT COUNT(*) FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND table_name='detail_peminjaman' AND constraint_name='ck_detail_status' AND constraint_type='CHECK') = 0,
  'ALTER TABLE `detail_peminjaman` ADD CONSTRAINT `ck_detail_status` CHECK (`status_detail` IN (''dipinjam'',''dikembalikan'',''hilang''))',
  'SELECT 1'
);
PREPARE p05_stmt FROM @ddl; EXECUTE p05_stmt; DEALLOCATE PREPARE p05_stmt;
SET @ddl = IF(
  (SELECT COUNT(*) FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND table_name='detail_peminjaman' AND constraint_name='ck_detail_tgl_jatuh_tempo' AND constraint_type='CHECK') = 0,
  'ALTER TABLE `detail_peminjaman` ADD CONSTRAINT `ck_detail_tgl_jatuh_tempo` CHECK (`tgl_jatuh_tempo` IS NOT NULL)',
  'SELECT 1'
);
PREPARE p05_stmt FROM @ddl; EXECUTE p05_stmt; DEALLOCATE PREPARE p05_stmt;
SET @ddl = IF(
  (SELECT COUNT(*) FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND table_name='pengembalian' AND constraint_name='ck_pengembalian_kondisi' AND constraint_type='CHECK') = 0,
  'ALTER TABLE `pengembalian` ADD CONSTRAINT `ck_pengembalian_kondisi` CHECK (`kondisi_kembali` IN (''baik'',''rusak_ringan'',''rusak_berat'',''hilang''))',
  'SELECT 1'
);
PREPARE p05_stmt FROM @ddl; EXECUTE p05_stmt; DEALLOCATE PREPARE p05_stmt;
SET @ddl = IF(
  (SELECT COUNT(*) FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND table_name='denda' AND constraint_name='ck_denda_tarif_harian' AND constraint_type='CHECK') = 0,
  'ALTER TABLE `denda` ADD CONSTRAINT `ck_denda_tarif_harian` CHECK (`tarif_harian` > 0)',
  'SELECT 1'
);
PREPARE p05_stmt FROM @ddl; EXECUTE p05_stmt; DEALLOCATE PREPARE p05_stmt;
SET @ddl = IF(
  (SELECT COUNT(*) FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND table_name='denda' AND constraint_name='ck_denda_jumlah_nonneg' AND constraint_type='CHECK') = 0,
  'ALTER TABLE `denda` ADD CONSTRAINT `ck_denda_jumlah_nonneg` CHECK (`jumlah_denda` >= 0)',
  'SELECT 1'
);
PREPARE p05_stmt FROM @ddl; EXECUTE p05_stmt; DEALLOCATE PREPARE p05_stmt;
SET @ddl = IF(
  (SELECT COUNT(*) FROM information_schema.table_constraints WHERE constraint_schema=DATABASE() AND table_name='denda' AND constraint_name='ck_denda_status_tanggal' AND constraint_type='CHECK') = 0,
  'ALTER TABLE `denda` ADD CONSTRAINT `ck_denda_status_tanggal` CHECK ((`status_bayar` = ''lunas'' AND `tgl_bayar` IS NOT NULL) OR (`status_bayar` = ''belum_bayar'' AND `tgl_bayar` IS NULL))',
  'SELECT 1'
);
PREPARE p05_stmt FROM @ddl; EXECUTE p05_stmt; DEALLOCATE PREPARE p05_stmt;

DELIMITER $$
CREATE TRIGGER IF NOT EXISTS trg_peminjaman_anggota_aktif
BEFORE INSERT ON peminjaman FOR EACH ROW
BEGIN
  DECLARE v_status VARCHAR(20);
  SELECT status_anggota INTO v_status FROM anggota WHERE id_anggota = NEW.id_anggota;
  IF v_status IS NULL OR v_status <> 'aktif' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Peminjaman ditolak: anggota tidak aktif atau tidak ditemukan.';
  END IF;
END$$

CREATE TRIGGER IF NOT EXISTS trg_detail_peminjaman_validasi
BEFORE INSERT ON detail_peminjaman FOR EACH ROW
BEGIN
  DECLARE v_jumlah INT DEFAULT 0;
  DECLARE v_status_transaksi VARCHAR(20);
  DECLARE v_status_eksemplar VARCHAR(20);
  SELECT status_peminjaman INTO v_status_transaksi
    FROM peminjaman WHERE id_peminjaman = NEW.id_peminjaman;
  IF v_status_transaksi IS NULL OR v_status_transaksi <> 'aktif' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Detail ditolak: transaksi tidak aktif atau tidak ditemukan.';
  END IF;
  SELECT COUNT(*) INTO v_jumlah FROM detail_peminjaman WHERE id_peminjaman = NEW.id_peminjaman;
  IF v_jumlah >= 3 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Peminjaman ditolak: maksimal tiga eksemplar per transaksi.';
  END IF;
  SELECT status_eksemplar INTO v_status_eksemplar FROM eksemplar_buku WHERE id_eksemplar = NEW.id_eksemplar;
  IF v_status_eksemplar IS NULL OR v_status_eksemplar <> 'tersedia' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eksemplar tidak tersedia untuk dipinjam.';
  END IF;
  SELECT COUNT(*) INTO v_jumlah
    FROM detail_peminjaman dp JOIN peminjaman p ON p.id_peminjaman = dp.id_peminjaman
    WHERE dp.id_eksemplar = NEW.id_eksemplar AND dp.status_detail = 'dipinjam' AND p.status_peminjaman = 'aktif';
  IF v_jumlah > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Eksemplar sudah berada dalam peminjaman aktif.';
  END IF;
END$$

CREATE TRIGGER IF NOT EXISTS trg_detail_set_dipinjam
AFTER INSERT ON detail_peminjaman FOR EACH ROW
BEGIN
  UPDATE eksemplar_buku SET status_eksemplar = 'dipinjam' WHERE id_eksemplar = NEW.id_eksemplar;
END$$

CREATE TRIGGER IF NOT EXISTS trg_detail_status_update
AFTER UPDATE ON detail_peminjaman FOR EACH ROW
BEGIN
  IF NEW.status_detail IN ('dikembalikan','hilang') THEN
    UPDATE eksemplar_buku SET status_eksemplar = CASE WHEN NEW.status_detail = 'hilang' THEN 'hilang' ELSE 'tersedia' END
    WHERE id_eksemplar = NEW.id_eksemplar;
  ELSEIF NEW.status_detail = 'dipinjam' THEN
    UPDATE eksemplar_buku SET status_eksemplar = 'dipinjam' WHERE id_eksemplar = NEW.id_eksemplar;
  END IF;
END$$

CREATE TRIGGER IF NOT EXISTS trg_detail_perbarui_transaksi
AFTER UPDATE ON detail_peminjaman FOR EACH ROW
BEGIN
  DECLARE v_sisa INT DEFAULT 0;
  SELECT COUNT(*) INTO v_sisa FROM detail_peminjaman
    WHERE id_peminjaman = NEW.id_peminjaman AND status_detail = 'dipinjam';
  IF v_sisa = 0 THEN
    UPDATE peminjaman SET status_peminjaman = 'selesai'
      WHERE id_peminjaman = NEW.id_peminjaman AND status_peminjaman = 'aktif';
  END IF;
END$$

CREATE TRIGGER IF NOT EXISTS trg_pengembalian_update_detail
AFTER INSERT ON pengembalian FOR EACH ROW
BEGIN
  UPDATE detail_peminjaman
    SET status_detail = CASE WHEN NEW.kondisi_kembali = 'hilang' THEN 'hilang' ELSE 'dikembalikan' END
    WHERE id_peminjaman = NEW.id_peminjaman AND id_eksemplar = NEW.id_eksemplar;
  UPDATE eksemplar_buku
    SET status_eksemplar = CASE
      WHEN NEW.kondisi_kembali = 'hilang' THEN 'hilang'
      WHEN NEW.kondisi_kembali IN ('rusak_ringan','rusak_berat') THEN 'perbaikan'
      ELSE 'tersedia' END,
      kondisi_eksemplar = CASE WHEN NEW.kondisi_kembali = 'hilang' THEN kondisi_eksemplar ELSE NEW.kondisi_kembali END
    WHERE id_eksemplar = NEW.id_eksemplar;
END$$

CREATE TRIGGER IF NOT EXISTS trg_denda_hitung
BEFORE INSERT ON denda FOR EACH ROW
BEGIN
  DECLARE v_tgl_jatuh_tempo DATE;
  DECLARE v_tgl_kembali DATE;
  DECLARE v_hari_terlambat INT DEFAULT 0;
  SELECT dp.tgl_jatuh_tempo, pg.tgl_kembali INTO v_tgl_jatuh_tempo, v_tgl_kembali
    FROM pengembalian pg
    JOIN detail_peminjaman dp ON dp.id_peminjaman = pg.id_peminjaman AND dp.id_eksemplar = pg.id_eksemplar
    WHERE pg.id_pengembalian = NEW.id_pengembalian;
  SET v_hari_terlambat = GREATEST(DATEDIFF(v_tgl_kembali, v_tgl_jatuh_tempo), 0);
  SET NEW.jumlah_denda = v_hari_terlambat * NEW.tarif_harian;
  IF NEW.jumlah_denda = 0 THEN
    SET NEW.status_bayar = 'lunas';
    SET NEW.tgl_bayar = v_tgl_kembali;
  END IF;
END$$
DELIMITER ;

SELECT 'anggota' AS nama_tabel, COUNT(*) AS jumlah_baris FROM anggota
UNION ALL SELECT 'buku', COUNT(*) FROM buku
UNION ALL SELECT 'eksemplar_buku', COUNT(*) FROM eksemplar_buku
UNION ALL SELECT 'petugas', COUNT(*) FROM petugas
UNION ALL SELECT 'peminjaman', COUNT(*) FROM peminjaman
UNION ALL SELECT 'detail_peminjaman', COUNT(*) FROM detail_peminjaman
UNION ALL SELECT 'pengembalian', COUNT(*) FROM pengembalian
UNION ALL SELECT 'denda', COUNT(*) FROM denda;
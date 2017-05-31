-- Tao Database
CREATE TABLE NhanVien
(
  maNV NCHAR(10),
  hoTen NVARCHAR2(100),
  diaChi NVARCHAR2(100),
  dienThoai CHAR(15),
  email NVARCHAR2(50),
  maPhong NCHAR(10),
  chiNhanh NCHAR(10),
  luong raw(2000),
  PRIMARY KEY (maNV)
);

CREATE TABLE ChiNhanh
(
  maCN NCHAR(10),
  tenCN NVARCHAR2(100),
  truongChiNhanh NCHAR(10),
  PRIMARY KEY (maCN)
);

CREATE TABLE ChiTieu
(
  maChiTieu NCHAR(10),
  tenChTieu NVARCHAR2(100),
  soTien INT,
  duAn NCHAR(10),
  PRIMARY KEY (maChiTieu)
);

CREATE TABLE DuAn
(
  maDA NCHAR(10),
  tenDA NVARCHAR2(100),
  kinhPhi INT,
  phongChuTri NCHAR(10),
  truongDA NCHAR(10),
  PRIMARY KEY (maDA)
);

CREATE TABLE PhongBan
(
  maPhong NCHAR(10),
  tenPhong NVARCHAR2(100),
  truongPhong NCHAR(10),
  ngayNhanChuc DATE,
  soNhanVien INT,
  chiNhanh NCHAR(10),
  PRIMARY KEY (maPhong)
);

CREATE TABLE  PhanCong
(
  maNV NCHAR(10),
  duAn NCHAR(10),
  vaiTro NVARCHAR2(100),
  phuCap INT,
  PRIMARY KEY (maNV, DuAn)
);

ALTER TABLE NhanVien
ADD CONSTRAINT NhanVienThuocMaPhong
FOREIGN KEY (maPhong)
REFERENCES PhongBan(maPhong);

ALTER TABLE NhanVien
ADD CONSTRAINT NhanVienThuocChiNhanh
FOREIGN KEY (chiNhanh)
REFERENCES ChiNhanh(maCN);

ALTER TABLE ChiNhanh
ADD CONSTRAINT NhanVienLamTruongChiNhanh
FOREIGN KEY (truongChiNhanh)
REFERENCES NhanVien(maNV);

ALTER TABLE ChiTieu
ADD CONSTRAINT ChiTieuCuaDuAn
FOREIGN KEY (duAn)
REFERENCES DuAn(maDA);

ALTER TABLE DuAn
ADD CONSTRAINT DuAnThuocPhongBan
FOREIGN KEY (phongChuTri)
REFERENCES PhongBan(maPhong);

ALTER TABLE DuAn
ADD CONSTRAINT NhanVienLamTruongDuAn
FOREIGN KEY (truongDA)
REFERENCES NhanVien(maNV);

ALTER TABLE PhongBan
ADD CONSTRAINT PhongBanThuocChiNhanh
FOREIGN KEY (chiNhanh)
REFERENCES ChiNhanh(maCN);

ALTER TABLE PhongBan
ADD CONSTRAINT PhongBan
FOREIGN KEY (truongPhong)
REFERENCES NhanVien(maNV);

ALTER TABLE PhanCong
ADD CONSTRAINT PhanCongNhanVien
FOREIGN KEY (maNV)
REFERENCES NhanVien(maNV);

ALTER TABLE PhanCong
ADD CONSTRAINT PhanCongCuaDuAn
FOREIGN KEY (duAn)
REFERENCES DuAn(maDA);
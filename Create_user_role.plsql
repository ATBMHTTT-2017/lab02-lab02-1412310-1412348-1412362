alter session set "_ORACLE_SCRIPT"=true;
--1. Ta user cho moi nhan vien: dung cursor de tao.
DECLARE CURSOR  c_nhanVien IS
SELECT* FROM NhanVien;
v_nhanVien c_nhanVien%rowtype;
BEGIN
OPEN c_nhanVien;
LOOP
      FETCH c_nhanVien INTO v_nhanVien;
      EXIT WHEN c_nhanVien%notfound;
      EXECUTE IMMEDIATE 'CREATE USER ' || v_nhanVien.maNV || ' IDENTIFIED BY 123456';
      EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO ' || v_nhanVien.maNV;
END LOOP;
CLOSE c_nhanVien;
END;

--2. Tao role
--2.1 Tao role truong du an va them cac nhan vien la truong du an vao role.
CREATE ROLE truongDuAn;
GRANT truongDuAn TO TDA001;
GRANT truongDuAn TO TDA002;
GRANT truongDuAn to TDA003;
GRANT truongDuAn TO TDA004;
GRANT truongDuAn TO TDA005;

--2.2 Tao role truong phong va them cac nhan vien la truong phong vao role.
CREATE ROLE truongPhong;
GRANT truongPhong TO TP001;
GRANT truongPhong TO TP002;
GRANT truongPhong TO TP003;
GRANT truongPhong TO TP004;
GRANT truongPhong TO TP005;

--2.3 Tao role truong chi nhanh va them cac nhan vien la truong chi nhanh vao role.
CREATE ROLE truongChiNhanh;
GRANT truongChiNhanh TO TCN001;
GRANT truongChiNhanh TO TCN002;
GRANT truongChiNhanh TO TCN003;
GRANT truongChiNhanh TO TCN004;
GRANT truongChiNhanh TO TCN005;

--2.4 Tao role nhan vien va them cac nhan vien binh thuong vao role.
CREATE ROLE nhanVien;
GRANT nhanVien TO NV001;
GRANT nhanVien TO NV002;
GRANT nhanVien TO NV003;
GRANT nhanVien TO NV004;
GRANT nhanVien TO NV005;
GRANT nhanVien TO NV006;
GRANT nhanVien TO NV007;
GRANT nhanVien TO NV008;
GRANT nhanVien TO NV009;
GRANT nhanVien TO NV010;

--2.5 Tao role giam doc va them cac nhan vien la giam doc vao role.
CREATE ROLE giamDoc;
GRANT giamDoc TO GD001;
GRANT giamDoc TO GD002;
GRANT giamDoc TO GD003;
GRANT giamDoc TO GD004;
GRANT giamDoc TO GD005;
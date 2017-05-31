create or replace package        crypt_util as
function crypt (p_str in varchar2, p_key in raw) return raw;
function decrypt (p_data in raw, p_key in raw) return varchar2;
function get_key return raw;
end crypt_util;
 
 create or replace package body crypt_util  
as         
         
    function crypt (p_str in varchar2, p_key in raw)  
         return raw  
    as  
        l_data    varchar2(255);  
        l_datar   raw(255);  
        l_retval  raw(255);  
    begin  

        l_data := rpad( p_str, (trunc(length(p_str)/8)+1)*8, chr(0) );  
        l_datar := utl_raw.cast_to_raw(l_data);  
        dbms_obfuscation_toolkit.des3encrypt  (
            input => l_datar, 
            key => p_key, 
            which => dbms_obfuscation_toolkit.ThreeKeyMode,  
            encrypted_data => l_retval);  
            return l_retval;  
         end;  

    function get_key  
        return raw  
    as  
        l_keyr  raw(255);  
        l_seed  varchar2(255);  
        l_seedr raw(255);  
    begin  

        l_seed :=  'UpKYrZHeiooBqkvpJHuImXrLOmVzYhgBhJcNLQL'||  'wkKYAhKgoZKnXPDBjcgYPGnfPyQOBAGmtRTJUhXAo';          
        l_seedr := utl_raw.cast_to_raw(l_seed);  
        dbms_obfuscation_toolkit.des3GetKey (
            which => dbms_obfuscation_toolkit.ThreeKeyMode,  
            seed => l_seedr,  
            key => l_keyr );  
            return l_keyr;  
    end;  

    function dcrypt (p_data in raw, p_key in raw)  
        return varchar2  
    as  
        l_data  varchar2(255);  
        l_datar raw(255);  
    begin  
        l_datar := dbms_obfuscation_toolkit.des3decrypt  
                         (input => p_data,  
                          key => p_key,  
                          which => dbms_obfuscation_toolkit.ThreeKeyMode);  

        return (substr(utl_raw.cast_to_varchar2(l_datar), 1, instr(utl_raw.cast_to_varchar2(l_datar),chr(0),1)-1));  
        end;  
end crypt_util;
--tao moi 1 bang de luu key rieng
create TABLE MaMN_Key(
  maNV NCHAR(10),
  Key RAW(255),
  PRIMARY KEY (maNV)
);
--tao cot moi luongnv kieu du lieu raw
ALTER TABLE NhanVien ADD p_LuongNV raw;
--tao du lieu
update nhanvien set luongNV=system.crypt_util.crypt(luong,key) ;
--xoa cot luong
alter table
   NhanVien
drop column
   luong;
--viet thu tuc de cap nhat du lieu cho bang NhanVien, MaNV_Key moi khi them vao 1 nhan vien moi
create or replace Procedure    Insert_LuongNhanVien
( p_MaNV in nchar := 10, p_HoTen in nvarchar2 := 100,p_DiaChi in nvarchar2 := 100,p_DienThoai in char := 15,p_Email in nvarchar2 := 50, p_MaPhong  in nchar := 10,p_chiNhanh in nchar:=10,p_LuongNV in int)
IS
 l_key raw(255);
begin
l_key := system.crypt_util.get_key; 
insert into NhanVien ( MaNV,HoTen, DiaChi, DienThoai,Email, MaPhong, ChiNhanh, LuongNV) values (p_MaNV, p_HoTen, p_DiaChi, p_DienThoai,p_Email,p_MaPhong,p_ChiNhanh,system.crypt_util.crypt(to_char(p_LuongNV),l_key));
insert into MaMN_Key ( MaNV,Key) values (p_MaNV, l_key);
end;
--insert vao 2 bang du lieu, goi thu tuc
 execute Insert_LuongNhanVien ('GD0020','Nguyen Van A','32 Nguyen Thi Minh Khai','0963906906','abc@gmail.com','PKD       ','CN002     ',567);
 --Tao stored procedure cap nhat thong tin Luong cua Nhan Vien
CREATE OR REPLACE Procedure Update_Luong
(  p_MaNV in nchar := 10, p_HoTen in nvarchar2 := 100,p_DiaChi in nvarchar2 := 100,p_DienThoai in char := 15,p_Email in nvarchar2 := 50, p_MaPhong  in nchar := 10,p_chiNhanh in nchar:=10,p_LuongNV in int)
IS
l_key raw(255);
begin
    select Key into l_key
    from MaMN_Key where MaNV = p_MaNV;
    update NhanVien
    set HoTen = p_HoTen,DiaChi = p_DiaChi,DienThoai=p_DienThoai, Email=p_Email, MaPhong=p_MaPhong,ChiNhanh=p_chiNhanh, LuongNV = system.crypt_util.crypt(to_char(p_LuongNV),l_key)
    where MaNV = p_MaNV;
end;

-- Tao stored procedure xoa thong tin Luong
CREATE OR REPLACE Procedure Delete_Luong
( p_maNV nchar := 10)
IS
begin
/*    Dau tien xoa tu bang ChiTieu_Key Sau do xoa tu bang ChiTieu */
delete from MaMN_Key where maNV = p_maNV;
delete from NhanVien where maNV = p_maNV;
end;

 --tao view, function, policy cap quyen xem luong cho nguoi dang nhap
 create view  view_nhanviengiaima as 
  SELECT n.manv, n.MaNV,n.HoTen, n.DiaChi, n.DienThoai,n.Email, n.MaPhong, n.ChiNhanh,CAST (
             system.crypt_util.decrypt (n.LuongNV, m.key) AS VARCHAR2 (10))
             luongnvgiaima
    FROM nhanvien n inner join MaMN_Key m on n.manv=m.manv;


grant select on view_nhanviengiaima to nhanvien;

create or replace function xem_luongNV (
p_schema varchar2, p_obj varchar2)
return varchar2
as
  user varchar2(100);
begin
  user := sys_context('userenv', 'session_user');
  return 'manv = ' || q'[']' || user  ||  q'[']';
end;

begin
dbms_rls.add_policy (
  object_schema => 'system',
  object_name => 'view_nhanviengiaima',
  policy_name => 'xemluongNV',
  function_schema => 'system',
  policy_function => 'xem_luongNV',
  sec_relevant_cols => 'luongnvgiaima');
end;
 


 

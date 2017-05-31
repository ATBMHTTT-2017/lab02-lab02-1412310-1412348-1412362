--
grant connect, resource to truongDuAn; 
 
grant create procedure to truongDuAn; 
 
Grant create public synonym to truongDuAn; 
 
Grant drop public synonym to truongDuAn; 

GRANT CREATE TABLESPACE TO truongDuAn ;
grant unlimited tablespace to truongDuAn ;

---------------
create or replace package crypt_util   
as   
    function crypt (p_str in varchar2, p_key in raw) 
        return raw;  
    function dcrypt (p_data  in raw, p_key in raw) 
        return varchar2;  
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
----
-- Tao bang luu khoa ma hoa cho moi dong trong bang chi tieu
CREATE TABLE ChiTieu_Key
(
  maChiTieu  NCHAR(10),
  Key   RAW(255),
  primary key (maChiTieu)
);

----
ALTER TABLE ChiTieu_Key 
ADD CONSTRAINT FK_ChiTieu
FOREIGN KEY (maChiTieu)
REFERENCES ChiTieu(maChiTieu);
---

-- Tao cot soTien_Ecr luu du lieu ma hoa kieu du lieu raw
ALTER TABLE ChiTieu ADD soTien_Ecr RAW(255);
-- Tao du lieu ma hoa

update ChiTieu set soTien_Ecr = crypt_util.crypt(soTien, crypt_util.get_key);

--Xoa cot soTien
alter table ChiTieu drop column soTien;
-------

CREATE OR REPLACE Procedure Insert_ChiTieu_SP
( p_maChiTieu in nchar := 10, p_tenChiTieu in nvarchar2 := 100, p_soTien in int, p_duAn in nchar := 10)
IS
 l_key raw(255);
begin
l_key := crypt_util.get_key; 
insert into ChiTieu ( maChiTieu, tenChTieu, soTien_Ecr, duAn) values (p_maChiTieu,p_tenChiTieu, crypt_util.crypt(to_char(p_soTien),l_key), p_duAn);
insert into ChiTieu_Key (maChiTieu,Key) values (p_maChiTieu,l_key); 
end;

/*
begin 
Insert_ChiTieu_SP (N'CT002     ', N'Goi dien cho ung cu vien', 500, N'DA002     ');
end; */

--Tao stored procedure cap nhat thong tin chi tieu
CREATE OR REPLACE Procedure Update_ChiTieu_SP
( p_maChiTieu in nchar := 10, p_tenChiTieu in nvarchar2 := 100, p_soTien in int, p_duAn in nchar := 10)
IS
l_key raw(255);
begin
    select Key into l_key
    from ChiTieu_Key where maChiTieu = p_maChiTieu;
    update ChiTieu
    set tenChTieu = p_tenChiTieu, soTien_Ecr = crypt_util.crypt(to_char(p_soTien), l_key)
    where maChiTieu = p_maChiTieu;
end;

-- Tao stored procedure xoa thong tin chi tieu
CREATE OR REPLACE Procedure Delete_ChiTieu_SP
( p_maChiTieu nchar := 10)
IS
begin
/*    Dau tien xoa tu bang ChiTieu_Key Sau do xoa tu bang ChiTieu */
delete from ChiTieu_Key where maChiTieu = p_maChiTieu;
delete from ChiTieu
where maChiTieu = p_maChiTieu;
end;

-- Tao stored procedure giai ma
create or replace procedure ChiTieu_Dcr_SP
is
begin
    update ChiTieu 
    set soTien_Ecr = (select crypt_util.dcrypt(c.soTien_Ecr, k.key)
                     from ChiTieu c, ChiTieu_Key k
                     where c.maChiTieu = k.maChiTieu);
end;

Create public synonym ChiTieu_Table for ChiTieu_Dcr_SP; 



CREATE OR REPLACE VIEW xemChiTieu
AS
SELECT * FROM DuAn da, ChiTieu ct
WHERE da.maDA = ct.duAn;

create or replace function cau07(p_schema varchar2, p_obj varchar2)
return NVARCHAR2
as
user NCHAR(10);
begin
if(SYS_CONTEXT('userenv', 'ISDBA') = 'true')
  then return ' ';
else
user := SYS_CONTEXT('userevn', 'SESSION_USER');
  return 'da.truongDA  = ' || q'[']' || user  ||  q'[']';
  end if;
end;

begin
dbms_rls.add_policy(
  object_schema => 'system',
  object_name => 'xemChiTieu',
  policy_name => 'cau07AddPolicy',
  function_schema => 'system',
  policy_function => 'cau07',
  statement_types => 'select, insert',
  update_check => TRUE );
end;

grant select, insert, update on system.xemChiTieu to truongDuAn;

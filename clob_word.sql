Procedure Download_Result_Word(pi_store_id number) is
cur_clob CLOB;

tmp_clob CLOB;
Begin
for d_all in (select distinct file_name, file_ext,
decode(lower(file_ext), ‘xml’, ‘doc’, file_ext) file_ext_file
from STD_WORD_API_FILE
order by file_name, file_ext
)
loop

DBMS_LOB.createtemporary(
lob_loc => tmp_clob,
cache => true,
dur => DBMS_LOB.session);

if DBMS_LOB.isopen(tmp_clob)=0
then
DBMS_LOB.open(tmp_clob, DBMS_LOB.lob_readwrite);
end if;

insert into MPD_DOG_FILE(id, dfs_id, file_name, file_ext, file_type, file_content)
values(MPD_DFL_SEQ1.Nextval, pi_store_id, d_all.file_name, d_all.file_ext_file, ‘W’, EMPTY_CLOB())
returning file_content into cur_clob;

if DBMS_LOB.isopen(cur_clob)=0
then
DBMS_LOB.open(cur_clob, DBMS_LOB.lob_readwrite);
end if;

for w in (select line_number, line_value
from STD_WORD_API_FILE
where file_name = d_all.file_name
and file_ext = d_all.file_ext
order by line_number
)
loop
if w.line_value is not null
then
DBMS_LOB.writeappend(tmp_clob, DBMS_LOB.getlength(w.line_value), w.line_value);
end if;
end loop;

DBMS_LOB.copy(
dest_lob => cur_clob,
src_lob => tmp_clob,
amount => DBMS_LOB.getlength(tmp_clob),
dest_offset => 1,
src_offset => 1);

if DBMS_LOB.isopen(cur_clob)=1
then
DBMS_LOB.Close(cur_clob);
end if;

if DBMS_LOB.isopen(tmp_clob)=1
then
DBMS_LOB.Close(tmp_clob);
end if;

DBMS_LOB.freetemporary(lob_loc => tmp_clob);
end loop;

End;


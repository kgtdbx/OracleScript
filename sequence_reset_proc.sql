create or replace
procedure reset_sequence(p_seq in varchar2)
is
    l_value number;
begin
-- Select the next value of the sequence
    execute immediate
    'select ' || p_seq || 
    '.nextval from dual' INTO l_value;
 
-- Set a negative increment for the sequence, 
-- with value = the current value of the sequence
 
    execute immediate
    'alter sequence ' || p_seq || 
    ' increment by -' || l_value || ' minvalue 0';
 
-- Select once from the sequence, to 
-- take its current value back to 0
 
    execute immediate
    'select ' || p_seq || 
    '.nextval from dual' INTO l_value;
 
-- Set the increment back to 1
 
    execute immediate
    'alter sequence ' || p_seq || 
    ' increment by 1 minvalue 0';
end;
/
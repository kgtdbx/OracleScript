/*create function nfactorial(n in number) return number 
is
begin
f number:=1;

for i 

end;
*/

SET serveroutput ON
declare
n number :=16;
m number := 0;
f number :=1;
begin
for i in 1..n loop
m:=m+1;
f:=f*m;
dbms_output.put_line(m||'! = '||f);
end loop;
end;

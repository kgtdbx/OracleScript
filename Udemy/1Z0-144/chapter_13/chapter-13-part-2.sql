--overloading the standard package
create or replace package override
is
/*we defined to_char function and this function already exist 
as oracle bulit-in function
*/

function to_char( p1 number, p2 date )
return varchar2;

procedure print;

end;

create or replace package body override
is

      function to_char( p1 number, p2 date )
      return varchar2
      is 
      begin
      return p1||p2;
      end;
      
      procedure print
      is
      begin
      dbms_output.put_line(to_char(1,'1-jan-81' )); -- this will be from the package
      dbms_output.put_line(standard.to_char(10)); --this to use the standard built-in
      end;
      
end;


execute override.print




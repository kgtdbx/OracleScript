create or replace function fn_get_PKFK_ddl (i_constraint_name in varchar2 )
return clob
is

h number;
o_constraint_ddl       varchar2(32760);

begin
     h:=dbms_metadata.open('CONSTRAINT');
     dbms_metadata.set_transform_param (DBMS_METADATA.SESSION_TRANSFORM, 'CONSTRAINTS_AS_ALTER', 
true );
     dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'STORAGE', false );
     dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'SQLTERMINATOR', TRUE );
     o_constraint_ddl:=DBMS_METADATA.GET_DDL('CONSTRAINT' ,i_constraint_name); 
     dbms_metadata.close(h);

     return (o_constraint_ddl) ;

end  fn_get_PKFK_ddl  ;


SQL> select fn_get_PKFK_ddl ('PK_DEPT') from dual;

--Which Gives:

  ALTER TABLE "SCOTT"."DEPT" ADD CONSTRAINT "PK_DEPT" PRIMARY KEY ("DEPTNO")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)   TABLESPACE "SYSTEM"  ENABLE ;
 
--and that's nice.


How do I get a FOREIGN KEY DDL?

--#########################################


ops$tkyte@ORA9IR2> create table dept as select * from scott.dept;
 
Table created.
 
ops$tkyte@ORA9IR2> alter table dept add constraint dept_pk primary key(deptno);
 
Table altered.
 
ops$tkyte@ORA9IR2> create table emp as select * from scott.emp;
 
Table created.
 
ops$tkyte@ORA9IR2> alter table emp add constraint emp_pk primary key(empno);
 
Table altered.
 
ops$tkyte@ORA9IR2> alter table emp add constraint emp_emp_fk foreign key (mgr) references 
emp(empno);
 
Table altered.
 
ops$tkyte@ORA9IR2> alter table emp add constraint emp_dept_fk foreign key (deptno) references 
dept(deptno);
 
Table altered.
 
ops$tkyte@ORA9IR2>
ops$tkyte@ORA9IR2>
ops$tkyte@ORA9IR2> column text format a80 word_wrapped;
ops$tkyte@ORA9IR2>
ops$tkyte@ORA9IR2> select dbms_metadata.get_dependent_ddl( 'REF_CONSTRAINT', 'EMP' ) text
  2    from dual;
 
TEXT
-------------------------------------------------------------------------------
ALTER TABLE "OPS$TKYTE"."EMP" ADD CONSTRAINT "EMP_EMP_FK" FOREIGN KEY ("MGR")
REFERENCES "OPS$TKYTE"."EMP" ("EMPNO") ENABLE
ALTER TABLE "OPS$TKYTE"."EMP" ADD CONSTRAINT "EMP_DEPT_FK" FOREIGN KEY
("DEPTNO")
REFERENCES "OPS$TKYTE"."DEPT" ("DEPTNO") ENABLE
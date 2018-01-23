Oracle 12c: Correct column positioning with invisible columns
Introduction
Change column order with invisible column
Why do it manually?
Conclusion
Introduction
In one of my last article, I had discussed about Invisible Columns in Oracle database 12c. I had also mentioned that, invisible columns can be used as a method to change ordering of columns in a table.
In today's article, I will discuss about the concept of changing order (position) of table columns with the help of invisible columns. In my earlier post, we have seen, when we add a invisible column or make a column invisible, it is not allocated a column ID (column position) unless it is made visible. Further, when we change a invisible column to visible, it is allocated a column ID (column position) and is placed (positioned) as the last column in the respective table.
We can use this fact, to come up with a trick that can be helpful for changing column ordering in a given table. Let's go through a simple example to understand the trick and it's effectiveness.
Change column order with invisible column
As part of our demonstration, I have created the following table with four columns COL1, COL3, COL4 and COL2 respectively in the noted order.
---//
---// Create table for demonstration //---
---//
SQL> create table TEST_TAB_INV_ORDR
  2  (
  3  COL1 number,
  4  COL3 number,
  5  COL4 number,
  6  COL2 number
  7  );

Table created.

---//
---// desc table to verify column positioning //---
---//
SQL> desc TEST_TAB_INV_ORDR
 Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 COL1                                               NUMBER
 COL3                                               NUMBER
 COL4                                               NUMBER
 COL2                                               NUMBER
Now, consider we had actually created the table with an incorrect column ordering and the columns should have been positioned in the order COL1, COL2, COL3 and COL4. We will use this example to understand, how the invisible column feature can be utilized to correct the column position within a table.
So far, we know the fact that a invisible column doesn't have a column position within a given table and is tracked internally be a internal ID. This means, when we change a visible column to invisible, the position allocated to that column will lost and once we make the column visible again, the column would be positioned as the last visible column. Let's utilize this fact as a foundation to build our trick. Here is the trick
In the first step, we will make all the table columns invisible except the intended first table column. This will cause all the other columns to loose their column position within the given table . At this point, we will have the first column already positioned in the first place in the table and all the other columns in the invisible state with no assigned column position.
In the next step, we will start changing the invisible columns to visible. However, we shall make them visible in the order in which we want them to be positioned within the table. This is due to the fact that, when we change an invisible column to visible, it is positioned as the last visible column.
Let's work on our example, to have a better understanding of the trick outlined above.
In our example, the table TEST_TAB_INV_ORDR has columns positioned as COL1, COL3, COL4 and COL2. We want the columns to be positioned as COL1, COL2 , COL3 and COL4. Let's make all the columns invisible except COL1, which we want to be positioned as first column in the table.
 
---//
---// making all columns invisible except COL1 //---
---//
SQL>  alter table TEST_TAB_INV_ORDR modify COL3 invisible;

Table altered.

SQL> alter table TEST_TAB_INV_ORDR modify COL4 invisible;

Table altered.

SQL> alter table TEST_TAB_INV_ORDR modify COL2 invisible;

Table altered.

---//
---// verify column position post invisible operation //---
---// COL1 is left visible and is placed as first column //---
---//
SQL> set COLINVISIBLE ON
SQL> desc TEST_TAB_INV_ORDR
 Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 COL1                                               NUMBER
 COL3 (INVISIBLE)                                   NUMBER
 COL4 (INVISIBLE)                                   NUMBER
 COL2 (INVISIBLE)                                   NUMBER
As we can observe from above output, we have the column COL1 already positioned as first column in the table and all the other columns are in invisible state. As a next step of correcting the column ordering, lets start changing the invisible columns to visible. Remember, we want the columns to be ordered as COL1, COL2, COL3 and COL4. As we know, the moment we change invisible column to visible, it will be positioned as the last visible column within the table; we can start making the columns visible in the order COL2, COL3 and COL4.
Let's walk through step by step of this process for a better insight. COL1 is already positioned as first column, we want COL2 to be positioned as second column in the table. Lets change the COL2 from invisible to visible as shown below.
---//
---// making COL2 visible to position it as second column //---
---//
SQL> alter table TEST_TAB_INV_ORDR modify COL2 visible;

Table altered.

---//
---// verfiy column order post visible operation //---
---//
SQL> desc TEST_TAB_INV_ORDR
 Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 COL1                                               NUMBER
 COL2                                               NUMBER
 COL3 (INVISIBLE)                                   NUMBER
 COL4 (INVISIBLE)                                   NUMBER
The moment we changed COL2 to visible, it got positioned within the table as the last visible column. At this point, we have COL1 and COL2 correctly positioned as first and second column respectively. Lets change COL3 from invisible to visible for positioning it as the third column within the table as shown below.
 
---//
---// making COL3 visible to position it as third column //---
---//
SQL> alter table TEST_TAB_INV_ORDR modify COL3 visible;

Table altered.

---//
---// verfiy column order post visible operation //---
---//
SQL> desc TEST_TAB_INV_ORDR
 Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 COL1                                               NUMBER
 COL2                                               NUMBER
 COL3                                               NUMBER
 COL4 (INVISIBLE)                                   NUMBER
Now, we have COL1, COL2 and COL3 correctly positioned as first, second and third column respectively. Lets change COL4 from invisible to visible for positioning it as the fourth (last) column within the table as shown below.
---//
---// making COL4 visible to position it as fourth column //---
---//
SQL> alter table TEST_TAB_INV_ORDR modify COL4  visible;

Table altered.

---//
---// verfiy column order post visible operation //---
---//
SQL>  desc TEST_TAB_INV_ORDR
 Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 COL1                                               NUMBER
 COL2                                               NUMBER
 COL3                                               NUMBER
 COL4                                               NUMBER
Now, we have all the columns positioned correctly within the table. Simple isn't it!
Here is a recap of the trick, that we used to correct column positioning within the table
Leave the intended first column as visible and change all the other columns to invisible
Start changing the invisible columns to visible in the order in which we want them to be positioned within the table.
Why do it manually?
In the previous section, we have seen how we can utilize invisible columns as a trick to correct column positioning within a given table. I have come up with a PL/SQL script (procedure) which converts this trick into a simple algorithm and can be used for correcting column positioning within a given table.
Here is the PL/SQL procedure that I have written based on the trick stated in the previous section. You can refer in-line comments for a brief idea about it's logic.
---//
---// PL/SQL procedure to correct column positing using invisible columns //---
---//
create or replace procedure change_col_order (o_column_list varchar2, e_tab_name varchar2, t_owner varchar2)
is
--- Custom column separator ---
TB constant varchar2(1):=CHR(9);
--- exception to handle non existence columns --
col_not_found EXCEPTION;
--- exception to handle column count mismatch ---
col_count_mismatch EXCEPTION;
--- flag to check column existence ----
col_e number;
--- variable to hold column count from dba_tab_cols ---
col_count_p number;
--- variable to hold column count from user given list ---
col_count_o number;
--- variable to hold first column name ---
col_start varchar2(200);
--- Creating a cursor of column names from the given column list ---
cursor col_l is 
select regexp_substr(o_column_list,'[^,]+', 1, level) column_name from dual
connect by regexp_substr(o_column_list,'[^,]+', 1, level) is not null;
col_rec col_l%ROWTYPE;
begin
select substr(o_column_list,1,instr(o_column_list,',',1) -1) into col_start from dual;
--- fetching column count from user given column list ---
select count(*) into col_count_p from dual
connect by regexp_substr(o_column_list,'[^,]+', 1, level) is not null;
--- fetching column count from dba_tab_cols ---
select count(*) into col_count_o from dba_tab_cols
where owner=t_owner and table_name=e_tab_name and hidden_column='NO';
--- validating column counts ---
	if col_count_p != col_count_o then
		raise col_count_mismatch;
	end if;
--- checking column existence ---	
for col_rec in col_l LOOP	
	select count(*) into col_e from dba_tab_cols where owner=t_owner and table_name=e_tab_name and column_name=col_rec.column_name;
	if col_e = 0 then
		raise col_not_found;
	end if;
END LOOP;
--- printing current column order ---
dbms_output.put_line(TB);
dbms_output.put_line('Current column order for table '||t_owner||'.'||e_tab_name||' is:');
for c_rec in (select column_name,data_type from dba_tab_cols where owner=t_owner and table_name=e_tab_name order by column_id ) LOOP
	dbms_output.put_line(c_rec.column_name||'('||c_rec.data_type||')');
END LOOP;	
--- making all columns invisible except the starting column ---
for col_rec in col_l LOOP
	if col_rec.column_name != col_start then
		execute immediate 'alter table '||t_owner||'.'||e_tab_name||' modify '||col_rec.column_name||' invisible';
	end if;
END LOOP;
--- making columns visible to match the required ordering ---
for col_rec in col_l LOOP
	if col_rec.column_name != col_start then
		execute immediate 'alter table '||t_owner||'.'||e_tab_name||' modify '||col_rec.column_name||' visible';
	end if;
END LOOP;
--- printing current column order ---
dbms_output.put_line(TB);
dbms_output.put_line('New column order for table '||t_owner||'.'||e_tab_name||' is:');
for c_rec in (select column_name,data_type from dba_tab_cols where owner=t_owner and table_name=e_tab_name order by column_id ) LOOP
	dbms_output.put_line(c_rec.column_name||'('||c_rec.data_type||')');
END LOOP;	
EXCEPTION
	WHEN col_not_found THEN
		dbms_output.put_line('ORA-100002: column does not exist');
	WHEN col_count_mismatch THEN
		dbms_output.put_line('ORA-100001: mismatch in column counts');
end;
/
---//
---// End of procedure change_col_order //---
---//
Lets go through a demonstration to understand how the custom procedure works. The procedure takes three arguments (all strings within single quotes). The first argument is a comma separated list of column names (in the order in which we want the columns to be positioned), the second argument is the name of table for which the columns needs to be re-ordered and the third argument is the schema name to which the table belongs to.
---//
---// changing column positioning using change_col_order procedure //---
---//
SQL> set serveroutput on
SQL> exec change_col_order('COL1,COL2,COL3,COL4','TEST_TAB_INV_ORDR','MYAPP');

Current column order for table MYAPP.TEST_TAB_INV_ORDR is:
COL4(NUMBER)
COL3(NUMBER)
COL2(NUMBER)
COL1(NUMBER)

New column order for table MYAPP.TEST_TAB_INV_ORDR is:
COL1(NUMBER)
COL2(NUMBER)
COL3(NUMBER)
COL4(NUMBER)

PL/SQL procedure successfully completed.

SQL>
As we can observe from the above output, the procedure reads the arguments, displays current column positioning (order) and then applies the algorithm (based on invisible column feature) before listing the final corrected column positioning (order).
Conclusion
In this article, we have explored; how we can utilize the 12c invisible columns feature to correct the positioning of columns within a given table. We have also explored the customized PL/SQL script which can be implemented to automate this trick and can be used as an alternative to the manual approach.
SQL>
SQL> CREATE TABLE EMP (EMPNO NUMBER(4) NOT NULL,
  2                    ENAME VARCHAR2(10),
  3                    JOB VARCHAR2(9),
  4                    MGR NUMBER(4),
  5                    HIREDATE DATE,
  6                    SAL NUMBER(7, 2),
  7                    COMM NUMBER(7, 2),
  8                    DEPTNO NUMBER(2));

Table created.

SQL>
SQL> INSERT INTO EMP VALUES (7369, 'SMITH', 'CLERK',    7902, TO_DATE('17-DEC-1980', 'DD-MON-YYYY'), 800, NULL, 20);

1 row created.

SQL> INSERT INTO EMP VALUES (7499, 'ALLEN', 'SALESMAN', 7698, TO_DATE('20-FEB-1981', 'DD-MON-YYYY'), 1600, 300, 30);

1 row created.

SQL> INSERT INTO EMP VALUES (7521, 'WARD',  'SALESMAN', 7698, TO_DATE('22-FEB-1981', 'DD-MON-YYYY'), 1250, 500, 30);

1 row created.

SQL> INSERT INTO EMP VALUES (7566, 'JONES', 'MANAGER',  7839, TO_DATE('2-APR-1981',  'DD-MON-YYYY'), 2975, NULL, 20);

1 row created.

SQL> INSERT INTO EMP VALUES (7654, 'MARTIN', 'SALESMAN', 7698,TO_DATE('28-SEP-1981', 'DD-MON-YYYY'), 1250, 1400, 30);

1 row created.

SQL> INSERT INTO EMP VALUES (7698, 'BLAKE', 'MANAGER', 7839,TO_DATE('1-MAY-1981', 'DD-MON-YYYY'), 2850, NULL, 30);

1 row created.

SQL> INSERT INTO EMP VALUES (7782, 'CLARK', 'MANAGER', 7839,TO_DATE('9-JUN-1981', 'DD-MON-YYYY'), 2450, NULL, 10);

1 row created.

SQL> INSERT INTO EMP VALUES (7788, 'SCOTT', 'ANALYST', 7566,TO_DATE('09-DEC-1982', 'DD-MON-YYYY'), 3000, NULL, 20);

1 row created.

SQL> INSERT INTO EMP VALUES (7839, 'KING', 'PRESIDENT', NULL,TO_DATE('17-NOV-1981', 'DD-MON-YYYY'), 5000, NULL, 10);

1 row created.

SQL> INSERT INTO EMP VALUES (7844, 'TURNER', 'SALESMAN', 7698,TO_DATE('8-SEP-1981', 'DD-MON-YYYY'), 1500, 0, 30);

1 row created.

SQL> INSERT INTO EMP VALUES (7876, 'ADAMS', 'CLERK', 7788,TO_DATE('12-JAN-1983', 'DD-MON-YYYY'), 1100, NULL, 20);

1 row created.

SQL> INSERT INTO EMP VALUES (7900, 'JAMES', 'CLERK', 7698,TO_DATE('3-DEC-1981', 'DD-MON-YYYY'), 950, NULL, 30);

1 row created.

SQL> INSERT INTO EMP VALUES (7902, 'FORD', 'ANALYST', 7566,TO_DATE('3-DEC-1981', 'DD-MON-YYYY'), 3000, NULL, 20);

1 row created.

SQL> INSERT INTO EMP VALUES (7934, 'MILLER', 'CLERK', 7782,TO_DATE('23-JAN-1982', 'DD-MON-YYYY'), 1300, NULL, 10);

1 row created.

SQL>
SQL> create or replace view emp_view as select ename, empno from emp
  2  where ename = sys_context( 'userenv', 'client_info');

View created.

SQL>
SQL> exec dbms_application_info.set_client_info('BLAKE');

PL/SQL procedure successfully completed.

SQL>
SQL> select * from emp_view;

ENAME           EMPNO
---------- ----------
BLAKE            7698

SQL>
SQL> drop table emp;

Table dropped.
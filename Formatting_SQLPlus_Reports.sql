
set linesize 250 pagesize 0 trims on tab off long 1000000
set timing on
set autotrace traceonly explain

Formatting SQL*Plus Reports
This chapter explains how to format your query results to produce a finished report. This chapter does not discuss HTML output, but covers the following topics:

Formatting Columns

Clarifying Your Report with Spacing and Summary Lines

Defining Page and Report Titles and Dimensions

Storing and Printing Query Results

Read this chapter while sitting at your computer and try out the examples shown. Before beginning, make sure you have access to the HR sample schema described in SQL*Plus Quick Start.

Formatting Columns
Through the SQL*Plus COLUMN command, you can change the column headings and reformat the column data in your query results.

Changing Column Headings
When displaying column headings, you can either use the default heading or you can change it using the COLUMN command. The following sections describe how default headings are derived and how to alter them using the COLUMN command. See the COLUMN command for more details.

Default Headings
SQL*Plus uses column or expression names as default column headings when displaying query results. Column names are often short and cryptic, however, and expressions can be hard to understand.

Changing Default Headings
You can define a more useful column heading with the HEADING clause of the COLUMN command, in the following format:

COLUMN column_name HEADING column_heading
Example 6-1 Changing a Column Heading

To produce a report from EMP_DETAILS_VIEW with new headings specified for LAST_NAME, SALARY, and COMMISSION_PCT, enter the following commands:

COLUMN LAST_NAME        HEADING 'LAST NAME'
COLUMN SALARY           HEADING 'MONTHLY SALARY'
COLUMN COMMISSION_PCT   HEADING COMMISSION
SELECT LAST_NAME, SALARY, COMMISSION_PCT
FROM EMP_DETAILS_VIEW
WHERE JOB_ID='SA_MAN';
LAST NAME                 MONTHLY SALARY COMMISSION
------------------------- -------------- ----------
Russell                            14000         .4
Partners                           13500         .3
Errazuriz                          12000         .3
Cambrault                          11000         .3
Zlotkey                            10500         .2

Note:

The new headings will remain in effect until you enter different headings, reset each column's format, or exit from SQL*Plus.
To change a column heading to two or more words, enclose the new heading in single or double quotation marks when you enter the COLUMN command. To display a column heading on more than one line, use a vertical bar (|) where you want to begin a new line. (You can use a character other than a vertical bar by changing the setting of the HEADSEP variable of the SET command. See the SET command for more information.)

Example 6-2 Splitting a Column Heading

To give the columns SALARY and LAST_NAME the headings MONTHLY SALARY and LAST NAME respectively, and to split the new headings onto two lines, enter

COLUMN SALARY HEADING 'MONTHLY|SALARY'
COLUMN LAST_NAME HEADING 'LAST|NAME'
Now rerun the query with the slash (/) command:

 /
LAST                         MONTHLY
NAME                          SALARY COMMISSION
------------------------- ---------- ----------
Russell                        14000         .4
Partners                       13500         .3
Errazuriz                      12000         .3
Cambrault                      11000         .3
Zlotkey                        10500         .2

Example 6-3 Setting the Underline Character

To change the character used to underline headings to an equal sign and rerun the query, enter the following commands:

SET UNDERLINE =
/
LAST                         MONTHLY
NAME                          SALARY COMMISSION
========================= ========== ==========
Russell                        14000         .4
Partners                       13500         .3
Errazuriz                      12000         .3
Cambrault                      11000         .3
Zlotkey                        10500         .2

Now change the underline character back to a dash:

SET UNDERLINE '-'
Note:

You must enclose the dash in quotation marks; otherwise, SQL*Plus interprets the dash as a hyphen indicating that you wish to continue the command on another line.
Formatting NUMBER Columns
When displaying NUMBER columns, you can either accept the SQL*Plus default display width or you can change it using the COLUMN command. Later sections describe the default display and how you can alter it with the COLUMN command. The format model will stay in effect until you enter a new one, reset the column's format with

COLUMN column_name CLEAR
or exit from SQL*Plus.

Default Display
A NUMBER column's width equals the width of the heading or the width of the FORMAT plus one space for the sign, whichever is greater. If you do not explicitly use FORMAT, then the column's width will always be at least the value of SET NUMWIDTH.

SQL*Plus normally displays numbers with as many digits as are required for accuracy, up to a standard display width determined by the value of the NUMWIDTH variable of the SET command (normally 10). If a number is larger than the value of SET NUMWIDTH, SQL*Plus rounds the number up or down to the maximum number of characters allowed if possible, or displays hashes if the number is too large.

You can choose a different format for any NUMBER column by using a format model in a COLUMN command. A format model is a representation of the way you want the numbers in the column to appear, using 9s to represent digits.

Changing the Default Display
The COLUMN command identifies the column you want to format and the model you want to use, as shown:

COLUMN column_name FORMAT model
Use format models to add commas, dollar signs, angle brackets (around negative values), and leading zeros to numbers in a given column. You can also round the values to a given number of decimal places, display minus signs to the right of negative values (instead of to the left), and display values in exponential notation.

To use more than one format model for a single column, combine the desired models in one COLUMN command (see Example 6-4). See COLUMN for a complete list of format models and further details.

Example 6-4 Formatting a NUMBER Column

To display SALARY with a dollar sign, a comma, and the numeral zero instead of a blank for any zero values, enter the following command:

COLUMN SALARY FORMAT $99,990
Now rerun the current query:

/
LAST                       MONTHLY
NAME                        SALARY COMMISSION
------------------------- -------- ----------
Russell                    $14,000         .4
Partners                   $13,500         .3
Errazuriz                  $12,000         .3
Cambrault                  $11,000         .3
Zlotkey                    $10,500         .2

Use a zero in your format model, as shown, when you use other formats such as a dollar sign and wish to display a zero in place of a blank for zero values.

Formatting Datatypes
When displaying datatypes, you can either accept the SQL*Plus default display width or you can change it using the COLUMN command. The format model will stay in effect until you enter a new one, reset the column's format with

COLUMN column_name CLEAR
or exit from SQL*Plus. Datatypes, in this manual, include the following types:

CHAR

NCHAR

VARCHAR2 (VARCHAR)

NVARCHAR2 (NCHAR VARYING)

DATE

LONG

BLOB

BFILE

CLOB

NCLOB

XMLType

Default Display
The default width of datatype columns is the width of the column in the database. The column width of a LONG, BLOB, BFILE, CLOB, NCLOB or XMLType defaults to the value of SET LONGCHUNKSIZE or SET LONG, whichever is the smaller.

The default width and format of unformatted DATE columns in SQL*Plus is determined by the database NLS_DATE_FORMAT parameter. Otherwise, the default format width is A9. See the FORMAT clause of the COLUMN command for more information on formatting DATE columns.

Left justification is the default for datatypes.

Changing the Default Display
You can change the displayed width of a datatype or DATE, by using the COLUMN command with a format model consisting of the letter A (for alphanumeric) followed by a number representing the width of the column in characters.

Within the COLUMN command, identify the column you want to format and the model you want to use:

COLUMN column_name FORMAT model
If you specify a width shorter than the column heading, SQL*Plus truncates the heading. See the COLUMN command for more details.

Example 6-5 Formatting a Character Column

To set the width of the column LAST_NAME to four characters and rerun the current query, enter

COLUMN LAST_NAME FORMAT A4
/
LAST  MONTHLY
NAME   SALARY COMMISSION
---- -------- ----------
Russ  $14,000         .4
ell

Part  $13,500         .3
ners

Erra  $12,000         .3
zuri
z


LAST  MONTHLY
NAME   SALARY COMMISSION
---- -------- ----------
Camb  $11,000         .3
raul
t

Zlot  $10,500         .2
key

If the WRAP variable of the SET command is set to ON (its default value), the employee names wrap to the next line after the fourth character, as shown in Example 6-5, "Formatting a Character Column". If WRAP is set to OFF, the names are truncated (cut off) after the fourth character.

The system variable WRAP controls all columns; you can override the setting of WRAP for a given column through the WRAPPED, WORD_WRAPPED, and TRUNCATED clauses of the COLUMN command. See the COLUMN command for more information on these clauses. You will use the WORD_WRAPPED clause of COLUMN later in this chapter.

NCLOB, BLOB, BFILE or multibyte CLOB columns cannot be formatted with the WORD_WRAPPED option. If you format an NCLOB, BLOB, BFILE or multibyte CLOB column with COLUMN WORD_WRAPPED, the column data behaves as though COLUMN WRAPPED was applied instead.

Note:

The column heading is truncated regardless of the setting of WRAP or any COLUMN command clauses.
Now return the column to its previous format:

COLUMN LAST_NAME FORMAT A10
Example 6-6 Formatting an XMLType Column

Before illustrating how to format an XMLType column, you must create a table with an XMLType column definition, and insert some data into the table. You can create an XMLType column like any other user-defined column. To create a table containing an XMLType column, enter

CREATE TABLE warehouses (
  warehouse_id  NUMBER(3),
  warehouse_spec  SYS.XMLTYPE,
  warehouse_name  VARCHAR2 (35),
  location_id  NUMBER(4));
To insert a new record containing warehouse_id and warehouse_spec values into the new warehouses table, enter

INSERT into warehouses (warehouse_id, warehouse_spec)
  VALUES (100, sys.XMLTYPE.createXML(
  '<Warehouse whNo="100">
    <Building>Owned</Building>
  </Warehouse>'));
To set the XMLType column width to 20 characters and then select the XMLType column, enter

COLUMN Building FORMAT A20
SELECT
  w.warehouse_spec.extract('/Warehouse/Building/text()').getStringVal()
  "Building"
  FROM warehouses w;
Building
--------------------
Owned

For more information about the createXML, extract, text and getStringVal functions, and about creating and manipulating XMLType data, see Oracle Database PL/SQL Packages and Types Reference.

Copying Column Display Attributes
When you want to give more than one column the same display attributes, you can reduce the length of the commands you must enter by using the LIKE clause of the COLUMN command. The LIKE clause tells SQL*Plus to copy the display attributes of a previously defined column to the new column, except for changes made by other clauses in the same command.

Example 6-7 Copying a Column's Display Attributes

To give the column COMMISSION_PCT the same display attributes you gave to SALARY, but to specify a different heading, enter the following command:

COLUMN COMMISSION_PCT LIKE SALARY HEADING BONUS
Rerun the query:

/
LAST        MONTHLY
NAME         SALARY    BONUS
---------- -------- --------
Russell     $14,000       $0
Partners    $13,500       $0
Errazuriz   $12,000       $0
Cambrault   $11,000       $0
Zlotkey     $10,500       $0

Listing and Resetting Column Display Attributes
To list the current display attributes for a given column, use the COLUMN command followed by the column name only, as shown:

COLUMN column_name
To list the current display attributes for all columns, enter the COLUMN command with no column names or clauses after it:

COLUMN
To reset the display attributes for a column to their default values, use the CLEAR clause of the COLUMN command as shown:

COLUMN column_name CLEAR
Example 6-8 Resetting Column Display Attributes to their Defaults

To reset all column display attributes to their default values, enter:

CLEAR COLUMNS
columns cleared

Suppressing and Restoring Column Display Attributes
You can suppress and restore the display attributes you have given a specific column. To suppress a column's display attributes, enter a COLUMN command in the following form:

COLUMN column_name OFF
OFF tells SQL*Plus to use the default display attributes for the column, but does not remove the attributes you have defined through the COLUMN command. To restore the attributes you defined through COLUMN, use the ON clause:

COLUMN column_name ON
Printing a Line of Characters after Wrapped Column Values
As you have seen, by default SQL*Plus wraps column values to additional lines when the value does not fit the column width. If you want to insert a record separator (a line of characters or a blank line) after each wrapped line of output (or after every row), use the RECSEP and RECSEPCHAR variables of the SET command.

RECSEP determines when the line of characters is printed; you set RECSEP to EACH to print after every line, to WRAPPED to print after wrapped lines, and to OFF to suppress printing. The default setting of RECSEP is WRAPPED.

RECSEPCHAR sets the character printed in each line. You can set RECSEPCHAR to any character.

You may wish to wrap whole words to additional lines when a column value wraps to additional lines. To do so, use the WORD_WRAPPED clause of the COLUMN command as shown:

COLUMN column_name WORD_WRAPPED
Example 6-9 Printing a Line of Characters after Wrapped Column Values

To print a line of dashes after each wrapped column value, enter the commands:

SET RECSEP WRAPPED
SET RECSEPCHAR "-"
Finally, enter the following query:

SELECT LAST_NAME, JOB_TITLE, CITY
FROM EMP_DETAILS_VIEW
WHERE SALARY>12000;
Now restrict the width of the column JOB_TITLE and tell SQL*Plus to wrap whole words to additional lines when necessary:

COLUMN JOB_TITLE FORMAT A20 WORD_WRAPPED
Run the query:

/
LAST_NAME                 JOB_TITLE            CITY
------------------------- -------------------- --------
King                      President            Seattle
Kochhar                   Administration Vice  Seattle
                          President
-------------------------------------------------------
De Haan                   Administration Vice  Seattle
                          President
-------------------------------------------------------
Russell                   Sales Manager        Oxford
Partners                  Sales Manager        Oxford
Hartstein                 Marketing Manager    Toronto

6 rows selected.

If you set RECSEP to EACH, SQL*Plus prints a line of characters after every row (after every department, for the above example).

Before continuing, set RECSEP to OFF to suppress the printing of record separators:

SET RECSEP OFF
Clarifying Your Report with Spacing and Summary Lines
When you use an ORDER BY clause in your SQL SELECT command, rows with the same value in the ordered column (or expression) are displayed together in your output. You can make this output more useful to the user by using the SQL*Plus BREAK and COMPUTE commands to create subsets of records and add space or summary lines after each subset.

The column you specify in a BREAK command is called a break column. By including the break column in your ORDER BY clause, you create meaningful subsets of records in your output. You can then add formatting to the subsets within the same BREAK command, and add a summary line (containing totals, averages, and so on) by specifying the break column in a COMPUTE command.

SELECT DEPARTMENT_ID, LAST_NAME, SALARY
FROM EMP_DETAILS_VIEW
WHERE SALARY > 12000
ORDER BY DEPARTMENT_ID;
DEPARTMENT_ID LAST_NAME                     SALARY
------------- ------------------------- ----------
           20 Hartstein                      13000
           80 Russell                        14000
           80 Partners                       13500
           90 King                           24000
           90 Kochhar                        17000
           90 De Haan                        17000

6 rows selected.

To make this report more useful, you would use BREAK to establish DEPARTMENT_ID as the break column. Through BREAK you could suppress duplicate values in DEPARTMENT_ID and place blank lines or begin a new page between departments. You could use BREAK in conjunction with COMPUTE to calculate and print summary lines containing the total salary for each department and for all departments. You could also print summary lines containing the average, maximum, minimum, standard deviation, variance, or row count.

Suppressing Duplicate Values in Break Columns
The BREAK command suppresses duplicate values by default in the column or expression you name. Thus, to suppress the duplicate values in a column specified in an ORDER BY clause, use the BREAK command in its simplest form:

BREAK ON break_column
Note:

Whenever you specify a column or expression in a BREAK command, use an ORDER BY clause specifying the same column or expression. If you do not do this, breaks occur every time the column value changes.
Example 6-10 Suppressing Duplicate Values in a Break Column

To suppress the display of duplicate department numbers in the query results shown, enter the following commands:

BREAK ON DEPARTMENT_ID;
For the following query (which is the current query stored in the buffer):

SELECT DEPARTMENT_ID, LAST_NAME, SALARY
FROM EMP_DETAILS_VIEW
WHERE SALARY > 12000
ORDER BY DEPARTMENT_ID;
DEPARTMENT_ID LAST_NAME                     SALARY
------------- ------------------------- ----------
           20 Hartstein                      13000
           80 Russell                        14000
              Partners                       13500
           90 King                           24000
              Kochhar                        17000
              De Haan                        17000

6 rows selected.

Inserting Space when a Break Column's Value Changes
You can insert blank lines or begin a new page each time the value changes in the break column. To insert n blank lines, use the BREAK command in the following form:

BREAK ON break_column SKIP n
To skip a page, use the command in this form:

BREAK ON break_column SKIP PAGE
Example 6-11 Inserting Space when a Break Column's Value Changes

To place one blank line between departments, enter the following command:

BREAK ON DEPARTMENT_ID SKIP 1
Now rerun the query:

/
DEPARTMENT_ID LAST_NAME                     SALARY
------------- ------------------------- ----------
           20 Hartstein                      13000

           80 Russell                        14000
              Partners                       13500

           90 King                           24000
              Kochhar                        17000
              De Haan                        17000

6 rows selected.

Inserting Space after Every Row
You may wish to insert blank lines or a blank page after every row. To skip n lines after every row, use BREAK in the following form:

BREAK ON ROW SKIP n
To skip a page after every row, use

BREAK ON ROW SKIP PAGE
Note:

SKIP PAGE does not cause a physical page break character to be generated unless you have also specified NEWPAGE 0.
Using Multiple Spacing Techniques
Suppose you have more than one column in your ORDER BY clause and wish to insert space when each column's value changes. Each BREAK command you enter replaces the previous one. Thus, if you want to use different spacing techniques in one report or insert space after the value changes in more than one ordered column, you must specify multiple columns and actions in a single BREAK command.

Example 6-12 Combining Spacing Techniques

Type the following:

SELECT DEPARTMENT_ID, JOB_ID, LAST_NAME, SALARY
FROM EMP_DETAILS_VIEW
WHERE SALARY>12000
ORDER BY DEPARTMENT_ID, JOB_ID;
Now, to skip a page when the value of DEPARTMENT_ID changes and one line when the value of JOB_ID changes, enter the following command:

BREAK ON DEPARTMENT_ID SKIP PAGE ON JOB_ID SKIP 1
To show that SKIP PAGE has taken effect, create a TTITLE with a page number:

TTITLE COL 35 FORMAT 9 'Page:' SQL.PNO
Run the new query to see the results:

                                  Page: 1
DEPARTMENT_ID JOB_ID     LAST_NAME                     SALARY
------------- ---------- ------------------------- ----------
           20 MK_MAN     Hartstein                      13000

                                  Page: 2
DEPARTMENT_ID JOB_ID     LAST_NAME                     SALARY
------------- ---------- ------------------------- ----------
           80 SA_MAN     Russell                        14000
                         Partners                       13500

                                  Page: 3
DEPARTMENT_ID JOB_ID     LAST_NAME                     SALARY
------------- ---------- ------------------------- ----------
           90 AD_PRES    King                           24000

              AD_VP      Kochhar                        17000
                         De Haan                        17000

6 rows selected.

Listing and Removing Break Definitions
Before continuing, turn off the top title display without changing its definition:

TTITLE OFF
You can list your current break definition by entering the BREAK command with no clauses:

BREAK
You can remove the current break definition by entering the CLEAR command with the BREAKS clause:

CLEAR BREAKS
You may wish to place the command CLEAR BREAKS at the beginning of every script to ensure that previously entered BREAK commands will not affect queries you run in a given file.

Computing Summary Lines when a Break Column's Value Changes
If you organize the rows of a report into subsets with the BREAK command, you can perform various computations on the rows in each subset. You do this with the functions of the SQL*Plus COMPUTE command. Use the BREAK and COMPUTE commands together in the following forms:

BREAK ON break_column
COMPUTE function LABEL label_name OF column column column
... ON break_column
You can include multiple break columns and actions, such as skipping lines in the BREAK command, as long as the column you name after ON in the COMPUTE command also appears after ON in the BREAK command. To include multiple break columns and actions in BREAK when using it in conjunction with COMPUTE, use these commands in the following forms:

BREAK ON break_column_1 SKIP PAGE ON break_column_2 SKIP 1
COMPUTE function LABEL label_name OF column column column
... ON break_column_2
The COMPUTE command has no effect without a corresponding BREAK command.

You can COMPUTE on NUMBER columns and, in certain cases, on all types of columns. For more information see the COMPUTE command.

The following table lists compute functions and their effects

Table 6-1 Compute Functions

Function...	Computes the...
SUM
Sum of the values in the column.

MINIMUM
Minimum value in the column.

MAXIMUM
Maximum value in the column.

AVG
Average of the values in the column.

STD
Standard deviation of the values in the column.

VARIANCE
Variance of the values in the column.

COUNT
Number of non-null values in the column.

NUMBER
Number of rows in the column.


The function you specify in the COMPUTE command applies to all columns you enter after OF and before ON. The computed values print on a separate line when the value of the ordered column changes.

Labels for ON REPORT and ON ROW computations appear in the first column; otherwise, they appear in the column specified in the ON clause.

You can change the compute label by using COMPUTE LABEL. If you do not define a label for the computed value, SQL*Plus prints the unabbreviated function keyword.

The compute label can be suppressed by using the NOPRINT option of the COLUMN command on the break column. See the COMPUTE command for more details. If you use the NOPRINT option for the column on which the COMPUTE is being performed, the COMPUTE result is also suppressed.

Example 6-13 Computing and Printing Subtotals

To compute the total of SALARY by department, first list the current BREAK definition:

BREAK
which displays current BREAK definitions:

break on DEPARTMENT_ID page  nodup
          on JOB_ID skip 1 nodup

Now enter the following COMPUTE command and run the current query:

COMPUTE SUM OF SALARY ON DEPARTMENT_ID
/
DEPARTMENT_ID JOB_ID     LAST_NAME                     SALARY
------------- ---------- ------------------------- ----------
           20 MK_MAN     Hartstein                      13000
************* **********                           ----------
sum                                                     13000

DEPARTMENT_ID JOB_ID     LAST_NAME                     SALARY
------------- ---------- ------------------------- ----------
           80 SA_MAN     Russell                        14000
                         Partners                       13500

************* **********                           ----------
sum                                                     27500

DEPARTMENT_ID JOB_ID     LAST_NAME                     SALARY
------------- ---------- ------------------------- ----------
           90 AD_PRES    King                           24000

              AD_VP      Kochhar                        17000
                         De Haan                        17000

************* **********                           ----------
sum                                                     58000

6 rows selected.

To compute the sum of salaries for departments 10 and 20 without printing the compute label:

COLUMN DUMMY NOPRINT;
COMPUTE SUM OF SALARY ON DUMMY;
BREAK ON DUMMY SKIP 1;
SELECT DEPARTMENT_ID DUMMY,DEPARTMENT_ID, LAST_NAME, SALARY
FROM EMP_DETAILS_VIEW
WHERE SALARY>12000
ORDER BY DEPARTMENT_ID;
DEPARTMENT_ID LAST_NAME                     SALARY
------------- ------------------------- ----------
           20 Hartstein                      13000
                                        ----------
                                             13000

           80 Russell                        14000
           80 Partners                       13500
                                        ----------
                                             27500

           90 King                           24000
           90 Kochhar                        17000
           90 De Haan                        17000
                                        ----------
                                             58000

6 rows selected.

To compute the salaries just at the end of the report:

COLUMN DUMMY NOPRINT;
COMPUTE SUM OF SALARY ON DUMMY;
BREAK ON DUMMY;
SELECT NULL DUMMY,DEPARTMENT_ID, LAST_NAME, SALARY
FROM EMP_DETAILS_VIEW
WHERE SALARY>12000
ORDER BY DEPARTMENT_ID;
DEPARTMENT_ID LAST_NAME                     SALARY
------------- ------------------------- ----------
           20 Hartstein                      13000
           80 Russell                        14000
           80 Partners                       13500
           90 King                           24000
           90 Kochhar                        17000
           90 De Haan                        17000
                                        ----------
                                             98500

6 rows selected.

When you establish the format of a NUMBER column, you must allow for the size of the sums included in the report.

Computing Summary Lines at the End of the Report
You can calculate and print summary lines based on all values in a column by using BREAK and COMPUTE in the following forms:

BREAK ON REPORT
COMPUTE function LABEL label_name OF column column column
... ON REPORT
Example 6-14 Computing and Printing a Grand Total

To calculate and print the grand total of salaries for all sales people and change the compute label, first enter the following BREAK and COMPUTE commands:

BREAK ON REPORT
COMPUTE SUM LABEL TOTAL OF SALARY ON REPORT
Next, enter and run a new query:

SELECT LAST_NAME, SALARY 
FROM EMP_DETAILS_VIEW
WHERE JOB_ID='SA_MAN';
LAST_NAME                     SALARY
------------------------- ----------
Russell                        14000
Partners                       13500
Errazuriz                      12000
Cambrault                      11000
Zlotkey                        10500
                          ----------
TOTAL                          61000

To print a grand total (or grand average, grand maximum, and so on) in addition to subtotals (or sub-averages, and so on), include a break column and an ON REPORT clause in your BREAK command. Then, enter one COMPUTE command for the break column and another to compute ON REPORT:

BREAK ON break_column ON REPORT
COMPUTE function LABEL label_name OF column ON break_column
COMPUTE function LABEL label_name OF column ON REPORT
Computing Multiple Summary Values and Lines
You can compute and print the same type of summary value on different columns. To do so, enter a separate COMPUTE command for each column.

Example 6-15 Computing the Same Type of Summary Value on Different Columns

To print the total of salaries and commissions for all sales people, first enter the following COMPUTE command:

COMPUTE SUM OF SALARY COMMISSION_PCT ON REPORT
You do not have to enter a BREAK command; the BREAK you entered in Example 6-14, "Computing and Printing a Grand Total" is still in effect. Now, change the first line of the select query to include COMMISSION_PCT:

1 
1* SELECT LAST_NAME, SALARY

APPEND , COMMISSION_PCT;
Finally, run the revised query to see the results:

/
LAST_NAME                     SALARY COMMISSION_PCT
------------------------- ---------- --------------
Russell                        14000             .4
Partners                       13500             .3
Errazuriz                      12000             .3
Cambrault                      11000             .3
Zlotkey                        10500             .2
                          ---------- --------------
sum                            61000            1.5

You can also print multiple summary lines on the same break column. To do so, include the function for each summary line in the COMPUTE command as follows:

COMPUTE function LABEL label_name function
  LABEL label_name function LABEL label_name ...
  OF column ON break_column
If you include multiple columns after OF and before ON, COMPUTE calculates and prints values for each column you specify.

Example 6-16 Computing Multiple Summary Lines on the Same Break Column

To compute the average and sum of salaries for the sales department, first enter the following BREAK and COMPUTE commands:

BREAK ON DEPARTMENT_ID
COMPUTE AVG SUM OF SALARY ON DEPARTMENT_ID
Now, enter and run the following query:

SELECT DEPARTMENT_ID, LAST_NAME, SALARY
FROM EMP_DETAILS_VIEW
WHERE DEPARTMENT_ID = 30
ORDER BY DEPARTMENT_ID, SALARY;
DEPARTMENT_ID LAST_NAME                     SALARY
------------- ------------------------- ----------
           30 Colmenares                      2500
              Himuro                          2600
              Tobias                          2800
              Baida                           2900
              Khoo                            3100
              Raphaely                       11000
*************                           ----------
avg                                           4150
sum                                          24900

6 rows selected.

Listing and Removing COMPUTE Definitions
You can list your current COMPUTE definitions by entering the COMPUTE command with no clauses:

COMPUTE
Example 6-17 Removing COMPUTE Definitions

To remove all COMPUTE definitions and the accompanying BREAK definition, enter the following commands:

CLEAR BREAKS
breaks cleared

CLEAR COMPUTES
computes cleared

You may wish to place the commands CLEAR BREAKS and CLEAR COMPUTES at the beginning of every script to ensure that previously entered BREAK and COMPUTE commands will not affect queries you run in a given file.

Defining Page and Report Titles and Dimensions
The word page refers to a screen full of information on your display or a page of a spooled (printed) report. You can place top and bottom titles on each page, set the number of lines per page, and determine the width of each line.

The word report refers to the complete results of a query. You can also place headers and footers on each report and format them in the same way as top and bottom titles on pages.

Setting the Top and Bottom Titles and Headers and Footers
As you have already seen, you can set a title to display at the top of each page of a report. You can also set a title to display at the bottom of each page. The TTITLE command defines the top title; the BTITLE command defines the bottom title.

You can also set a header and footer for each report. The REPHEADER command defines the report header; the REPFOOTER command defines the report footer.

A TTITLE, BTITLE, REPHEADER or REPFOOTER command consists of the command name followed by one or more clauses specifying a position or format and a CHAR value you wish to place in that position or give that format. You can include multiple sets of clauses and CHAR values:

TTITLE position_clause(s) char_value position_clause(s) char_value ...
BTITLE position_clause(s) char_value position_clause(s) char_value ...
REPHEADER position_clause(s) char_value position_clause(s) char_value ...
REPFOOTER position_clause(s) char_value position_clause(s) char_value ...
For descriptions of all TTITLE, BTITLE, REPHEADER and REPFOOTER clauses, see the TTITLE command and the REPHEADER command.

Example 6-18 Placing a Top and Bottom Title on a Page

To put titles at the top and bottom of each page of a report, enter

TTITLE CENTER -
"ACME SALES DEPARTMENT PERSONNEL REPORT"
BTITLE CENTER "COMPANY CONFIDENTIAL"
Now run the current query:

/
                  ACME SALES DEPARTMENT PERSONNEL REPORT
DEPARTMENT_ID LAST_NAME                     SALARY
------------- ------------------------- ----------
           30 Colmenares                      2500
           30 Himuro                          2600
           30 Tobias                          2800
           30 Baida                           2900
           30 Khoo                            3100
           30 Raphaely                       11000


                         COMPANY CONFIDENTIAL

6 rows selected.

Example 6-19 Placing a Header on a Report

To put a report header on a separate page, and to center it, enter

REPHEADER PAGE CENTER 'PERFECT WIDGETS'
Now run the current query:

/
which displays the following two pages of output, with the new REPHEADER displayed on the first page:

                ACME SALES DEPARTMENT PERSONNEL REPORT
                            PERFECT WIDGETS


                         COMPANY CONFIDENTIAL

                ACME SALES DEPARTMENT PERSONNEL REPORT
DEPARTMENT_ID LAST_NAME                     SALARY
------------- ------------------------- ----------
           30 Colmenares                      2500
           30 Himuro                          2600
           30 Tobias                          2800
           30 Baida                           2900
           30 Khoo                            3100
           30 Raphaely                       11000

                         COMPANY CONFIDENTIAL

6 rows selected.

To suppress the report header without changing its definition, enter

REPHEADER OFF
Positioning Title Elements
The report in the preceding exercises might look more attractive if you give the company name more emphasis and place the type of report and the department name on either end of a separate line. It may also help to reduce the line size and thus center the titles more closely around the data.

You can accomplish these changes by adding some clauses to the TTITLE command and by resetting the system variable LINESIZE, as the following example shows.

You can format report headers and footers in the same way as BTITLE and TTITLE using the REPHEADER and REPFOOTER commands.

Example 6-20 Positioning Title Elements

To redisplay the personnel report with a repositioned top title, enter the following commands:

TTITLE CENTER 'A C M E  W I D G E T' SKIP 1 -
CENTER ==================== SKIP 1 LEFT 'PERSONNEL REPORT' -
RIGHT 'SALES DEPARTMENT' SKIP 2
SET LINESIZE 60
/
                    A C M E  W I D G E T
                    ====================
PERSONNEL REPORT                  SALES DEPARTMENT

DEPARTMENT_ID LAST_NAME                     SALARY
------------- ------------------------- ----------
           30 Colmenares                      2500
           30 Himuro                          2600
           30 Tobias                          2800
           30 Baida                           2900
           30 Khoo                            3100
           30 Raphaely                       11000
                    COMPANY CONFIDENTIAL

6 rows selected.

The LEFT, RIGHT, and CENTER clauses place the following values at the beginning, end, and center of the line. The SKIP clause tells SQL*Plus to move down one or more lines.

Note that there is no longer any space between the last row of the results and the bottom title. The last line of the bottom title prints on the last line of the page. The amount of space between the last row of the report and the bottom title depends on the overall page size, the number of lines occupied by the top title, and the number of rows in a given page. In the above example, the top title occupies three more lines than the top title in the previous example. You will learn to set the number of lines per page later in this chapter.

To always print n blank lines before the bottom title, use the SKIP n clause at the beginning of the BTITLE command. For example, to skip one line before the bottom title in the example above, you could enter the following command:

BTITLE SKIP 1 CENTER 'COMPANY CONFIDENTIAL'
Indenting a Title Element
You can use the COL clause in TTITLE or BTITLE to indent the title element a specific number of spaces. For example, COL 1 places the following values in the first character position, and so is equivalent to LEFT, or an indent of zero. COL 15 places the title element in the 15th character position, indenting it 14 spaces.

Example 6-21 Indenting a Title Element

To print the company name left-aligned with the report name indented five spaces on the next line, enter

TTITLE LEFT 'ACME WIDGET' SKIP 1 -
COL 6 'SALES DEPARTMENT PERSONNEL REPORT' SKIP 2
Now rerun the current query to see the results:

/
ACME WIDGET
     SALES DEPARTMENT PERSONNEL REPORT

DEPARTMENT_ID LAST_NAME                     SALARY
------------- ------------------------- ----------
           30 Colmenares                      2500
           30 Himuro                          2600
           30 Tobias                          2800
           30 Baida                           2900
           30 Khoo                            3100
           30 Raphaely                       11000

                    COMPANY CONFIDENTIAL

6 rows selected.

Entering Long Titles
If you need to enter a title greater than 500 characters in length, you can use the SQL*Plus command DEFINE to place the text of each line of the title in a separate substitution variable:

DEFINE LINE1 = 'This is the first line...'
DEFINE LINE2 = 'This is the second line...'
DEFINE LINE3 = 'This is the third line...'
Then, reference the variables in your TTITLE or BTITLE command as follows:

TTITLE CENTER LINE1 SKIP 1 CENTER LINE2 SKIP 1 -
CENTER LINE3
Displaying System-Maintained Values in Titles
You can display the current page number and other system-maintained values in your title by entering a system value name as a title element, for example:

TTITLE LEFT system-maintained_value_name
There are five system-maintained values you can display in titles, the most commonly used of which is SQL.PNO (the current page number). See TTITLE for a list of system-maintained values you can display in titles.

Example 6-22 Displaying the Current Page Number in a Title

To display the current page number at the top of each page, along with the company name, enter the following command:

TTITLE LEFT 'ACME WIDGET' RIGHT 'PAGE:' SQL.PNO SKIP 2
Now rerun the current query:

/
ACMEWIDGET                                  PAGE:         1

DEPARTMENT_ID LAST_NAME                     SALARY
------------- ------------------------- ----------
           30 Colmenares                      2500
           30 Himuro                          2600
           30 Tobias                          2800
           30 Baida                           2900
           30 Khoo                            3100
           30 Raphaely                       11000


                    COMPANY CONFIDENTIAL

6 rows selected.

Note that SQL.PNO has a format ten spaces wide. You can change this format with the FORMAT clause of TTITLE (or BTITLE).

Example 6-23 Formatting a System-Maintained Value in a Title

To close up the space between the word PAGE: and the page number, reenter the TTITLE command as shown:

TTITLE LEFT 'ACME WIDGET' RIGHT 'PAGE:' FORMAT 999 -
SQL.PNO SKIP 2
Now rerun the query:

/
ACME WIDGET                                     'PAGE:'   1

DEPARTMENT_ID LAST_NAME                     SALARY
------------- ------------------------- ----------
           30 Colmenares                      2500
           30 Himuro                          2600
           30 Tobias                          2800
           30 Baida                           2900
           30 Khoo                            3100
           30 Raphaely                       11000


                    COMPANY CONFIDENTIAL

6 rows selected.

Listing, Suppressing, and Restoring Page Title Definitions
To list a page title definition, enter the appropriate title command with no clauses:

TTITLE
BTITLE
To suppress a title definition, enter:

TTITLE OFF
BTITLE OFF
These commands cause SQL*Plus to cease displaying titles on reports, but do not clear the current definitions of the titles. You may restore the current definitions by entering:

TTITLE ON
BTITLE ON
Displaying Column Values in Titles
You may wish to create a master/detail report that displays a changing master column value at the top of each page with the detail query results for that value underneath. You can reference a column value in a top title by storing the desired value in a variable and referencing the variable in a TTITLE command. Use the following form of the COLUMN command to define the variable:

COLUMN column_name NEW_VALUE variable_name
You must include the master column in an ORDER BY clause and in a BREAK command using the SKIP PAGE clause.

Example 6-24 Creating a Master/Detail Report

Suppose you want to create a report that displays two different managers' employee numbers, each at the top of a separate page, and the people reporting to the manager on the same page as the manager's employee number. First create a variable, MGRVAR, to hold the value of the current manager's employee number:

COLUMN MANAGER_ID NEW_VALUE MGRVAR NOPRINT
Because you will only display the managers' employee numbers in the title, you do not want them to print as part of the detail. The NOPRINT clause you entered above tells SQL*Plus not to print the column MANAGER_ID.

Next, include a label and the value in your page title, enter the proper BREAK command, and suppress the bottom title from the last example:

TTITLE LEFT 'Manager: ' MGRVAR SKIP 2
BREAK ON MANAGER_ID SKIP PAGE
BTITLE OFF
Finally, enter and run the following query:

SELECT MANAGER_ID, DEPARTMENT_ID, LAST_NAME, SALARY
FROM EMP_DETAILS_VIEW
WHERE MANAGER_ID IN (101, 201)
ORDER BY MANAGER_ID, DEPARTMENT_ID;
Manager:       101

DEPARTMENT_ID LAST_NAME                     SALARY
------------- ------------------------- ----------
           10 Whalen                          4400
           40 Mavris                          6500
           70 Baer                           10000
          100 Greenberg                      12000
          110 Higgins                        12000

Manager:       201

DEPARTMENT_ID LAST_NAME                     SALARY
------------- ------------------------- ----------
           20 Fay                             6000

6 rows selected.

If you want to print the value of a column at the bottom of the page, you can use the COLUMN command in the following form:

COLUMN column_name OLD_VALUE variable_name
SQL*Plus prints the bottom title as part of the process of breaking to a new page—after finding the new value for the master column. Therefore, if you simply referenced the NEW_VALUE of the master column, you would get the value for the next set of details. OLD_VALUE remembers the value of the master column that was in effect before the page break began.

Displaying the Current Date in Titles
You can, of course, date your reports by simply typing a value in the title. This is satisfactory for ad hoc reports, but if you want to run the same report repeatedly, you would probably prefer to have the date automatically appear when the report is run. You can do this by creating a variable to hold the current date.

You can reference the predefined substitution variable _DATE to display the current date in a title as you would any other variable.

The date format model you include in your LOGIN file or in your SELECT statement determines the format in which SQL*Plus displays the date. See your Oracle Database SQL Language Reference for more information on date format models. See Modifying Your LOGIN File for more information about the LOGIN file.

You can also enter these commands interactively. See COLUMN for more information.

Setting Page Dimensions
Typically, a page of a report contains the number of blank line(s) set in the NEWPAGE variable of the SET command, a top title, column headings, your query results, and a bottom title. SQL*Plus displays a report that is too long to fit on one page on several consecutive pages, each with its own titles and column headings. The amount of data SQL*Plus displays on each page depends on the current page dimensions.

The default page dimensions used by SQL*Plus are shown underneath:

number of lines before the top title: 1

number of lines per page, from the top title to the bottom of the page: 14

number of characters per line: 80

You can change these settings to match the size of your computer screen or, for printing, the size of a sheet of paper.

You can change the page length with the system variable PAGESIZE. For example, you may wish to do so when you print a report.

To set the number of lines between the beginning of each page and the top title, use the NEWPAGE variable of the SET command:

SET NEWPAGE number_of_lines
If you set NEWPAGE to zero, SQL*Plus skips zero lines and displays and prints a formfeed character to begin a new page. On most types of computer screens, the formfeed character clears the screen and moves the cursor to the beginning of the first line. When you print a report, the formfeed character makes the printer move to the top of a new sheet of paper, even if the overall page length is less than that of the paper. If you set NEWPAGE to NONE, SQL*Plus does not print a blank line or formfeed between report pages.

To set the number of lines on a page, use the PAGESIZE variable of the SET command:

SET PAGESIZE number_of_lines
You may wish to reduce the line size to center a title properly over your output, or you may want to increase line size for printing on wide paper. You can change the line width using the LINESIZE variable of the SET command:

SET LINESIZE number_of_characters
Example 6-25 Setting Page Dimensions

To set the page size to 66 lines, clear the screen (or advance the printer to a new sheet of paper) at the start of each page, and set the line size to 70, enter the following commands:

SET PAGESIZE 66
SET NEWPAGE 0
SET LINESIZE 70
Now enter and run the following commands to see the results:

TTITLE CENTER 'ACME WIDGET PERSONNEL REPORT' SKIP 1 -
CENTER '01-JAN-2001' SKIP 2
Now run the following query:

COLUMN FIRST_NAME HEADING 'FIRST|NAME';
COLUMN LAST_NAME HEADING 'LAST|NAME';
COLUMN SALARY  HEADING 'MONTHLY|SALARY' FORMAT $99,999;
SELECT DEPARTMENT_ID, FIRST_NAME, LAST_NAME, SALARY
FROM EMP_DETAILS_VIEW
WHERE SALARY>12000;
                    ACME WIDGET PERSONNEL REPORT
                              01-JAN-2001

              FIRST                LAST                      MONTHLY
DEPARTMENT_ID NAME                 NAME                       SALARY
------------- -------------------- ------------------------- --------
           90 Steven               King                       $24,000
           90 Neena                Kochhar                    $17,000
           90 Lex                  De Haan                    $17,000
           80 John                 Russell                    $14,000
           80 Karen                Partners                   $13,500
           20 Michael              Hartstein                  $13,000

6 rows selected.

Now reset PAGESIZE, NEWPAGE, and LINESIZE to their default values:

SET PAGESIZE 14
SET NEWPAGE 1
SET LINESIZE 80
To list the current values of these variables, use the SHOW command:

SHOW PAGESIZE
SHOW NEWPAGE
SHOW LINESIZE
Through the SQL*Plus command SPOOL, you can store your query results in a file or print them on your computer's default printer.

Storing and Printing Query Results
Send your query results to a file when you want to edit them with a word processor before printing or include them in a letter, email, or other document.

To store the results of a query in a file—and still display them on the screen—enter the SPOOL command in the following form:

SPOOL file_name
If you do not follow the filename with a period and an extension, SPOOL adds a default file extension to the filename to identify it as an output file. The default varies with the operating system; on most hosts it is LST or LIS. The extension is not appended when you spool to system generated files such as /dev/null and /dev/stderr. See the platform-specific Oracle documentation provided for your operating system for more information.

SQL*Plus continues to spool information to the file until you turn spooling off, using the following form of SPOOL:

SPOOL OFF
Creating a Flat File
When moving data between different software products, it is sometimes necessary to use a "flat" file (an operating system file with no escape characters, headings, or extra characters embedded). For example, if you do not have Oracle Net, you need to create a flat file for use with SQL*Loader when moving data from Oracle9i to Oracle Database 10g.

To create a flat file with SQL*Plus, you first must enter the following SET commands:

SET NEWPAGE 0
SET SPACE 0
SET LINESIZE 80
SET PAGESIZE 0
SET ECHO OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET HEADING OFF
SET MARKUP HTML OFF SPOOL OFF
After entering these commands, you use the SPOOL command as shown in the previous section to create the flat file.

The SET COLSEP command may be useful to delineate the columns. For more information, see the SET command.

Sending Results to a File
To store the results of a query in a file—and still display them on the screen—enter the SPOOL command in the following form:

SPOOL file_name
SQL*Plus stores all information displayed on the screen after you enter the SPOOL command in the file you specify.

Sending Results to a Printer
To print query results, spool them to a file as described in the previous section. Then, instead of using SPOOL OFF, enter the command in the following form:

SPOOL OUT
SQL*Plus stops spooling and copies the contents of the spooled file to your computer's standard (default) printer. SPOOL OUT does not delete the spool file after printing.

Example 6-26 Sending Query Results to a Printer

To generate a final report and spool and print the results, create a script named EMPRPT containing the following commands.

First, use EDIT to create the script with your operating system text editor.

EDIT EMPRPT
Next, enter the following commands into the file, using your text editor:

SPOOL TEMP
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

COLUMN DEPARTMENT_ID HEADING DEPARTMENT
COLUMN LAST_NAME HEADING 'LAST NAME'
COLUMN SALARY HEADING 'MONTHLY SALARY' FORMAT $99,999

BREAK ON DEPARTMENT_ID SKIP 1 ON REPORT
COMPUTE SUM OF SALARY ON DEPARTMENT_ID
COMPUTE SUM OF SALARY ON REPORT

SET PAGESIZE 24
SET NEWPAGE 0
SET LINESIZE 70

TTITLE CENTER 'A C M E  W I D G E T' SKIP 2 -
LEFT 'EMPLOYEE REPORT' RIGHT 'PAGE:' -
FORMAT 999 SQL.PNO SKIP 2
BTITLE CENTER 'COMPANY CONFIDENTIAL'

SELECT DEPARTMENT_ID, LAST_NAME, SALARY
FROM EMP_DETAILS_VIEW
WHERE SALARY>12000
ORDER BY DEPARTMENT_ID;

SPOOL OFF
If you do not want to see the output on your screen, you can also add SET TERMOUT OFF to the beginning of the file and SET TERMOUT ON to the end of the file. Save and close the file in your text editor (you will automatically return to SQL*Plus). Now, run the script EMPRPT:

@EMPRPT
SQL*Plus displays the output on your screen (unless you set TERMOUT to OFF), and spools it to the file TEMP:

                         A C M E  W I D G E T

EMPLOYEE REPORT                                              PAGE: 1

DEPARTMENT LAST NAME                 MONTHLY SALARY
---------- ------------------------- --------------
        20 Hartstein                        $13,000
**********                           --------------
sum                                         $13,000

        80 Russell                          $14,000
           Partners                         $13,500
**********                           --------------
sum                                         $27,500

        90 King                             $24,000
           Kochhar                          $17,000
           De Haan                          $17,000
**********                           --------------
sum                                         $58,000

                                     --------------
sum                                         $98,500
                         COMPANY CONFIDENTIAL

6 rows selected.
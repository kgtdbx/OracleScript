Oracle INSTR

The syntax for Oracle INSTR function is as follows:

instr (s1, s2, st, t)

The Oracle INSTR  function is similar to the SUBSTR, except instead of returning the sub string, Oracle INSTR returns the location of the string.

oracle instr

SELECT
  INSTR('Now is the time for all good men',' ',1,3)
FROM
  dual; 

 INSTR('NOWISTHETIMEFORALLGOODMEN','',1,3)
 -----------------------------------------                                       11

1 row selected.

In the example above, I am using Oracle INSTR to look for the third occurrence of the string “ ” (a space) starting at the beginning.  According to the results of the Oracle INSTR function, the third space in the string is at character number 11.

Now for a little challenge.  Suppose that my boss wants to know what the first word of every book title is.  Think about the solution before looking at the answer below.

SELECT

  SUBSTR(book_title,1,(INSTR(book_title,' ',1,1)-1)) "First Word"
FROM
  book; 



Basically, I used the Oracle INSTR function and queried a substring of the book title starting at the first character, until the first space, minus one to remove the space from the results.  This type of Oracle INSTR query is actually very common on databases that are not properly normalized.  If the author names were stored in our PUBS database in one column, we would have to use this type of Oracle INSTR query to separate the first and last names when needed.

Oracle 10g Changes to Oracle INSTR

The Oracle INSTR function has been extended with the new function regexp_instr.

regexp_instr extends the functionality of the Oracle INSTR function by letting you search a string for a POSIX regular expression pattern. The function evaluates strings using characters, as defined by the input character set. It returns an integer indicating the beginning or ending position of the matched substring, depending on the value of the return_option argument. If no match is found, the function returns 0.



The Oracle documentation gives us the following example for the INSTR syntax:

Description of instr.gif follows

With the following description of the above illustration:
{ INSTR
| INSTRB
| INSTRC
| INSTR2
| INSTR4
}
(string , substring [, position [, occurrence ] ])

--***********************************
SUBSTR (Substring) Built-in String Function 
SUBSTR (overload 1) SUBSTR(
 STR1 VARCHAR2 CHARACTER SET ANY_CS, 
 POS  PLS_INTEGER,                -- starting position
 LEN  PLS_INTEGER := 2147483647)  -- number of characters
RETURN VARCHAR2 CHARACTER SET STR1%CHARSET; 
SUBSTR (overload 2) SUBSTR(
 STR1 CLOB CHARACTER SET ANY_CS, 
 POS  NUMBER,                -- starting position
 LEN  NUMBER := 2147483647)  -- number of characters
RETURN CLOB CHARACTER SET STR1%CHARSET; 
Substring Beginning Of String SELECT SUBSTR(<value>, 1, <number_of_characters>)
FROM DUAL;  
SELECT SUBSTR('Take the first four characters', 1, 4) FIRST_FOUR
FROM DUAL;  
Substring Middle Of String SELECT SUBSTR(<value>, <starting_position>, <number_of_characters>)
FROM DUAL.  
SELECT SUBSTR('Take the first four characters', 16, 4) MIDDLE_FOUR
FROM DUAL; 

 Substring End of String SELECT SUBSTR(<value>, <starting_position>)
FROM DUAL; 
SELECT SUBSTR('Take the first four characters', 16) SIXTEEN_TO_END
FROM DUAL;

SELECT SUBSTR('Take the first four characters', -4) FINAL_FOUR
FROM DUAL; 
Simplified Examples 
 Examples in Oracle/PLSQL of using the substr() function to extract a substring from a string: 
The general syntax for the SUBSTR() function is: 

    SUBSTR( source_string, start_position, [ length ] ) 

"source_string" is the original source_string that the substring will be taken from. 

"start_position" is the position in the source_string where you want to start extracting characters. The first position in the string is always '1', NOT '0', as in many other languages. 

"length" is an optional parameter that specifies how many characters to extract. If this parameter is not used, SUBSTR will return everything from the start_position to the end of the string. 

Notes:
 If the start_position is specified as "0", substr treats start_position as "1", that is, as the first position in the string. 

If the start_position is a positive number, then substr starts from the beginning of the string. 

If the start_position is a negative number, then substr starts from the end of the string and counts backwards. 

If the length is a negative number, then substr will return a NULL value. 

Examples: 





     substr('Dinner starts in one hour.', 8, 6)    will return 'starts'
     substr('Dinner starts in one hour.', 8)       will return 'starts in one hour.'
     substr('Dinner starts in one hour.', 1, 6)    will return 'Dinner'
     substr('Dinner starts in one hour.', 0, 6)    will return 'Dinner'
     substr('Dinner starts in one hour.', -4, 3)   will return 'our'
     substr('Dinner starts in one hour.', -9, 3)   will return 'one'
     substr('Dinner starts in one hour.', -9, 2)   will return 'on'
 
This function works identically in Oracle 8i, Oracle 9i, Oracle 10g, and Oracle 11g. 

 
 
  
INSTR (Instring) Built-in String Function 
INSTR (overload 1) INSTR(
 STR1 VARCHAR2 CHARACTER SET ANY_CS,        -- test string
 STR2 VARCHAR2 CHARACTER SET STR1%CHARSET,  -- string to locate
 POS  PLS_INTEGER := 1,                     -- position
 NTH  POSITIVE := 1)                        -- occurrence number
RETURN PLS_INTEGER; 
INSTR (overload 2) INSTR(
 STR1 CLOB CHARACTER SET ANY_CS,            -- test string
 STR2 CLOB CHARACTER SET STR1%CHARSET,      -- string to locate
 POS  INTEGER := 1,                         -- position
 NTH  POSITIVE := 1)                        -- occurrence number
RETURN INTEGER; 
Instring For Matching First Value Found SELECT INSTR(<value>, <value_to_match>, <direction>, <instance>
FROM DUAL; 
SELECT INSTR('Take the first four characters',  'a', 1, 1) FOUND_1
FROM DUAL; 
Instring If No Matching Second Value Found SELECT INSTR('Take the first four characters', 'a', 1, 2) FOUND_2
FROM DUAL; 
Instring For Multiple
 Characters SELECT INSTR('Take the first four characters', 'four', 1, 1) MCHARS
FROM DUAL; 
Reverse Direction Search SELECT INSTR('Take the first four characters', 'a', -1, 1) REV_SRCH
FROM DUAL; 
Reverse Direction Search Second Match SELECT INSTR('Take the first four characters', 'a', -1, 2) REV_TWO
FROM DUAL; 
  
String Parsing By Combining SUBSTR And INSTR Built-in String Functions 
List parsing first value

 Take up to the character before the first comma  SELECT SUBSTR('abc,def,ghi', 1 ,INSTR('abc,def,ghi', ',', 1, 1)-1)
FROM DUAL;  
List parsing center value

 Take the value between the commas  SELECT SUBSTR('abc,def,ghi', INSTR('abc,def,ghi',',', 1, 1)+1,
INSTR('abc,def,ghi',',',1,2)-INSTR('abc,def,ghi',',',1,1)-1)
FROM DUAL;  
List parsing last value

 Take the value after the last comma SELECT SUBSTR('abc,def,ghi', INSTR('abc,def,ghi',',', -1, 1)+1)
FROM DUAL;  

----

with t as
(select 'AG_DEPOSIT_AGREEMENTS_RBGT_MV' as name from dual)
select substr(name,1,length(name)-3) from t;

-----

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE tb$issue_rowid_for_closing';
EXCEPTION
   WHEN OTHERS
   THEN
      NULL;
END;
/

CREATE TABLE tb$issue_rowid_for_closing
AS
   SELECT e.rowid_object
     FROM security_instrument s
          JOIN equity_xref PARTITION (FINANCIAL_INSTRUMENT) e
             ON s.instrument_id = e.id_object
    WHERE     s.status_cd = 'A'
          AND s.is_skeleton IS NULL
          AND e.rowid_object NOT IN (SELECT d.instr_id
                                       FROM dm_equity_issue@dbl_equity_mdm d
                                      WHERE d.delete_flag IS NULL
                                     UNION ALL
                                     SELECT d.instr_id
                                       FROM dm_equity_issue_m@dbl_equity_mdm d
                                      WHERE d.delete_flag IS NULL);

EXEC DBMS_STATS.GATHER_TABLE_STATS(user,tabname=>'TB$ISSUE_ROWID_FOR_CLOSING',degree=>4,cascade=>true);
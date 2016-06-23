--Connect as SYSTEM.

CREATE USER username IDENTIFIED BY apassword;

GRANT CONNECT TO username;

GRANT EXECUTE on schema.procedure TO username;
You may also need to:

GRANT SELECT [, INSERT] [, UPDATE] [, DELETE] on schema.table TO username;
to whichever tables the procedure uses.

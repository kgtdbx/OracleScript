Online Index Rebuilds

Online index rebuilds allow DML operations on the base table during index creation. Oracle9i extends the online index rebuild feature to include Reverse Key, Function Based and Key Compressed indexes. Key compressed indexes on Index Oraganized Tables (IOT) can also be rebuilt online.

ALTER INDEX my_index REBUILD ONLINE;
When the ONLINE keyword is used as part of the CREATE or ALTER syntax the current index is left intact while a new copy of the index is built, allowing DML to access the old index. Any alterations to the old index are recorded in a Index Organized Table known as a "journal table". Once the rebuild is complete the alterations from the journal table are merged into the new index. This may take several passes depending on the frequency of alterations to the index. The process will skip any locked rows and commit every 20 rows. Once the merge operation is complete the data dictionary is updated and the old index is dropped. DML access is only blocked during the data dictionary updates, which complete very quickly.

The availability of Index Organized Tables (IOTs) has been improved by:

Online creation and rebuild of secondary indexes.

ALTER INDEX <index_name> REBUILD ONLINE;
Online COALESCE of IOTs primary key index.

ALTER TABLE <table_name> COALESCE;
Online update of logical rowids for secondary indexes.

ALTER INDEX <index_name> UPDATE BLOCK REFERENCES;
Online move of overflow segments.

ALTER TABLE <table_name> MOVE ONLINE TABLESPACE data1 OVERFLOW TABLESPACE data2;
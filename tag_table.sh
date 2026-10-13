cd ../book-wrk

sqlean -batch -readonly -csv -header -quote FiscalAssets.gnc3 < ../sql/tag_table.sql     > tag_table.csv
sqlean -batch -readonly -csv -header -quote FiscalAssets.gnc3 < ../sql/tag_table_all.sql > tag_table_all.csv


# wrkWmSE.gnc3
# wrk.gnc3
# FiscalAssets.gnc3

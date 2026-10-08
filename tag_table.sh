cd ../book-wrk

sqlean -batch -readonly -csv -header -quote wrk.gnc3 < ../sql/tag_table.sql > tag_table.csv


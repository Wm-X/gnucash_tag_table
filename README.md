# gnucash_tag_table
GnuCash tag table scripts

These scripts work but will need tweaking to work for you.

1. edit tag_table.sql so the Regular Expression in the second line is sensible for your data
2. check the paths in tag_table.sh so they are sensible for you
3. run tag_table.sh
4. load tag_table.csv into a spreadsheet, select the whole thing and make a pivot table
5. have fun doing endless analysis

   Note: I use sqlean rather than sqlite because it has a postgres compatible regexp_substr()
   see https://github.com/nalgeon/sqlean
   and https://antonz.org/sqlean-regexp/
   
here is a pic of a pivot table
https://github.com/Wm-X/gnucash_tag_table/blob/main/Clipboard_10-08-2026_01.png 

here is a pic of a pivot table with matching gnucash transaction report
https://github.com/Wm-X/gnucash_tag_table/blob/main/Screenshot%202026-10-12%20130639.png

2026-10-11 include ACCOUNT TYPE in csv so Income Statement and Balance Sheet type analysis is easier

2026-10-13 added tag_table_all.sql   include NULL values, the data that goes in the Other column of QuickBooks Class style reports

2026-10-13 added 2 csv files for people to play with in their spreadsheet of choice, suggest Insert Pivot Table and tag as the column, account as the row and Sum val as the data to get started

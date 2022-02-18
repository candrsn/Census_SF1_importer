# csv_to_sas
# simple program to convert CSV to SAS7BDat

options compress=CHAR;
%let csvfile = %scan(&sysparm,1)
%let sasfile = %scan(&sysparm,2)

proc import file=&csvfile
    out=work.&sasfile
    dbms=csv
    replace;
run;



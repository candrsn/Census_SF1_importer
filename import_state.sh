#!/bin/bash

# stop on error
set -e

if [ -z "$1" ]; then
    usage
fi

ST="$1"
MDB_TEMPLATE="SF1_Access2003.mdb"
ZF="zip/${ST}2010.sf1.zip"
DB=sf1_${ST}.sqlite



usage() {
    echo "import_state.sh <state code>" >&2
    exit
} 

mdb_list_tables() {
    mdb-tables "$1"
}


mdb_table_sql() {
    basename=$(echo $2 | sed -e 's/mod//')
    mdb-schema $1 -T $2 sqlite | awk -e '/CREATE TABLE/ { sub("mod","", $0); print $0; next; }
/./ { print $0;}'> ddl/${basename}.sql
}

merge_cifsn() {
(
    grep -v ');' ddl/SF1*${1}_PT1.sql | sed -e 's/_PT1//'
    echo ","
    cat ddl/SF1*${1}_PT2.sql | awk -e 'FNR>18 { print $0; }'
) > ddl/SF1_000${1}.sql

rm ddl/SF1*${1}_PT1.sql ddl/SF1*${1}_PT2.sql
}

generate_ddl() {
for tbl in $(mdb_list_tables $MDB_TEMPLATE); do
    mdb_table_sql $MDB_TEMPLATE $tbl
done
merge_cifsn 45

}


create_tables() {
    (
    echo "
PRAGMA SYNCHRONOUS=off;
PRAGMA block_size=4096;
"
cat ddl/*sql
    ) | sqlite3 $DB

}

txtname_to_tblname() {

    case $1 in
    *geols-l2010.sf1)
        echo "GEO_HEADER_SF1"
        ;;
    *)
        p=${1:2:5}  
        echo "SF1_$p"
        ;;
    esac

}

load_geo() {

    tbl="GEO_HEADER_SF1"

    unzip -p $ZF $itm | awk -f import_geo.awk >> fifo1 &

echo ".mode tab
.headers off
.separator '|'
.import 'fifo1' ${tbl}


    " | tee tbl.sql | sqlite3 $DB 

    kill `jobs -p` | :

}

load_table() {

    tbl=$(txtname_to_tblname $itm)

    unzip -p $ZF $itm >> fifo1 &

echo ".mode csv
.headers off
.import 'fifo1' ${tbl}


    " | tee tbl.sql | sqlite3 $DB 2>/dev/null

    kill `jobs -p` | :

}

load_tables() {
for itm in $(unzip -l $ZF | awk -e '/sf1/ { print $4; }'  | grep -v 'txt' ); do
    case $itm in
    *geo*)
        load_geo $itm | :
        ;;
    *)
        load_table $itm
        ;;
    esac
done

}

prepare_extracts() {
    tbl="$1"
    echo "
    CREATE INDEX IF NOT EXISTS ${tbl}__logrecno__ind on ${tbl}(logrecno);
    " | sqlite3 $DB

}

pseudo_table_names() {
    echo "
.mode list
.separator \" \"
SELECT DISTINCT substr(name, 1, length(name) -3) 
    FROM pragma_table_info('$1') 
    WHERE cid >= 5 
    ORDER BY cid;
" | sqlite3 $DB

}

pseudo_table_cols() {
    echo "
.mode list
.separator \" \" \",\"
SELECT '$3' || name FROM pragma_table_info('$1') 
    WHERE cid < 5 OR
       name like '${2}%'
    ORDER BY cid;
" | sqlite3 $DB | sed -e 's/.$//'

}


extract_sumlevel() {
    sumlev=${1:0:3}
    geocomp=${1:4:2}
    mkdir -p csv/${ST}/${sumlev}/${geocomp}

    for tbl in $(echo "SELECT name FROM SQLITE_MASTER WHERE name like 'SF1%' and type = 'table'" | sqlite3 $DB); do
        prepare_extracts $tbl
        ( echo "
          DROP TABLE IF EXISTS temp.geo_temp;
          CREATE TEMP TABLE geo_temp AS SELECT * FROM GEO_HEADER_SF1 WHERE sumlev = '$sumlev' and geocomp = '$geocomp';
          CREATE INDEX geo_temp__logrecno__ind on geo_temp(logrecno);
"
        
        for ptbl in $(pseudo_table_names $tbl); do
            pcols=$(pseudo_table_cols $tbl $ptbl t.)
            echo "
.mode csv
.headers on
.once 'csv/${ST}/${sumlev}/${geocomp}/${ptbl}.csv'
SELECT $pcols 
    FROM $tbl t,
       geo_temp g
    WHERE g.logrecno = t.logrecno;
" | tee extract_$tbl.sql | sqlite3 $DB

    done ) | sqlite3 $DB
        done

}

extract_sumlevels() {
    for itm in $(echo "SELECT DISTINCT sumlev, geocomp FROM GEO_HEADER_SF1 ORDER BY sumlev, geocomp;" | sqlite3 $DB); do
        extract_sumlevel $itm
    done
}

build_db() {
rm $DB | :
if [ ! -r ddl/GEO_HEADER_SF1.sql ]; then
    generate_ddl
fi
create_tables
load_tables
}

#build_db
extract_sumlevels
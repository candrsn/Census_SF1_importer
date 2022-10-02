#!/bin/bash

set -e
export S3="${S3_ROOT}/"

build_state_db() {

    gdest="state.txt"
    if [ -s $gdest ]; then
        return
    fi

    curl -k -L -o "$gdest" "https://www2.census.gov/geo/docs/reference/state.txt"

     echo "
.mode csv
.separator '|'
.import $gdest state_geography
    " | sqlite3 state_geography.sqlite

}

get_state_s3() {


}

get_state_ftp() {
    st=$1

    dest="${st}2010.sf1.zip"
    if [ -s "zip/$dest" ]; then
        echo "state SF1 file already available"
        return
    fi

    stname=$(echo "SELECT replace(state_name, ' ', '_') FROM state_geography WHERE stusab=upper('$st') limit 1" | sqlite3 state_geography.sqlite)

    pushd zip
    curl -R -o $dest https://www2.census.gov/programs-surveys/decennial/2010/data/04-Summary_File_1/${stname}/${st}2010.sf1.zip
    popd
}

get_file() {
    if [ ! -s "$2" ]; then
        curl -R -o $2  $1
    fi
}

get_template() {
    get_file "https://www2.census.gov/programs-surveys/decennial/2010/data/04-Summary_File_1/SF1_Access2003.mdb" SF1_Access2003.mdb 
    get_file "https://www2.census.gov/programs-surveys/decennial/2010/data/04-Summary_File_1/SF1_Access2007.mdb" SF1_Access2007.mdb 
}


get_state
build_state_db
get_template
get_state $1




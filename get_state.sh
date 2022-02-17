#!/bin/bash

st='al'
stname='Alabama'

get_state() {
pushd zip
curl -R -O https://www2.census.gov/programs-surveys/decennial/2010/data/04-Summary_File_1/${stname}/${st}2010.sf1.zip
popd
}


get_template() {
curl -R -O https://www2.census.gov/programs-surveys/decennial/2010/data/04-Summary_File_1/SF1_Access2003.mdb
curl -R -O https://www2.census.gov/programs-surveys/decennial/2010/data/04-Summary_File_1/SF1_Access2007.mdb
}




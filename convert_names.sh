#!/bin/bash

convert_file() {
sed -e 's/SUMLEV/SUMLEVEL/' \
   -e 's/GEOCOMP/COMPONENT/' \
   -e 's/STATE/ST/' \
   -e 's/COUNTY/CTY/' \
   -e 's/COUSUB/MCD/' \
   -e 's/PLACE/PL/' \
   -e 's/TRACT/TR/' \
   -e 's/BLKGRP/BG/' \
   -e 's/BLOCK/BLK/' \
   -e 's/AIANHH/AINDN/' \
   -e 's/TTRACT/BTTR/' \
   -e 's/TBLKGRP/BTBG/' \
   -e 's/SDELM/SDELEM/' $1 > tmp.sql
   
     mv tmp.sql $1
}

pushd ddl

for itm in [SG]*sql; do
    convert_file $itm
done
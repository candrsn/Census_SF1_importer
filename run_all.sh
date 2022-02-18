#!/bin/bash

set -e
if [ -z "$1" ]; then
   usage
   exit
fi

ST=$1
FI=$2
# this is the preferred list of summary levels and components in the format <sumlevel>|<component>,<sumlevel>|<component>,...
export SL_LIST="040|00,080|00,101|00,140|00,070|00,150|00,160|00"

usage() {
     echo "run_all.sh <state list>"
}

# unpack the list of statesccc
for itm in $(echo "$1" | tr ',' '\n'); do
    time (bash -v -x import_state_pop.sh $itm $FI 2>&1 | tee run_${itm}.log)
done
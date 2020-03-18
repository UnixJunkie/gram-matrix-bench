#!/bin/bash

set -x # DEBUG
set -u

NPROCS=`getconf _NPROCESSORS_ONLN`

for np in `seq 2 $NPROCS`; do
    for c in `echo 1 3 10 30 100 300 1000`; do
        ./_build/default/src/gram.exe -i data/1k.csv -np $np -c $c
    done
done

#!/bin/bash

NPX=1
NPY=2
IM=1000
JM=1000
DT="0.01"

trap "/bin/rm -f tmp tmp.o tmp.f tmp.log" 0 1 2 3 15

NB=1
while [ $NB -le $((IM/NPX)) ]; do
    NBX=$NB
    NBY=$NB
    sed -e "s/(DT=[^!]*)/(DT=${DT}D0)/" \
	-e "s/(IM=[^!]*, *JM=[^!]*)/(IM=$IM, JM=$JM)/" \
	-e "s/(NPX=[^!]*, *NPY=[^!]*)/(NPX=$NPX, NPY=$NPY)/" \
	-e "s/(NBX=[^!]*, *NBY=[^!]*)/(NBX=$NBX, NBY=$NBY)/" heat2.f >tmp.f
    if ! mpif77 -O2 -o tmp tmp.f >/dev/null 2>&1; then
	echo 1>&2 "Compilation error, abort."
        exit
    fi
    wtime=`mpirun -np $((NPX*NPY)) ./tmp | tee tmp.log \
	| grep 'Wall time:' | awk '{print $3}'`
    err=`grep 'Error:' tmp.log | awk '{print $2}'`
    echo "$NBX $NBY $wtime $err" \
	| awk '{printf "%4s %4s  time: %s  error: %s\n", $1, $2, $3, $4}'
    NB=$((NB+NB))
done

#!/bin/bash
# to be run from main directory of the assignment (not tests directory) so that the paths work correctly
# test basic commands
workers=`cat /proc/cpuinfo | grep processor | wc -l`
n=1
while [ $n -le $workers ]; do
    #/home/socs/workdir/A4/submitJob.sh ps
    ./submitJob.sh ps
    n=$(( $n + 1 ))
done
n=1
while [ $n -le $workers ]; do
    #/home/socs/workdir/A4/submitJob.sh ps
    ./submitJob.sh ls -l
    n=$(( $n + 1 ))
done
sleep 2
./submitJob.sh -s
# ./submitJob.sh -x
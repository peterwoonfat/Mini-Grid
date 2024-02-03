#!/bin/bash
# to be run from main directory of the assignment (not tests directory) so that the paths work correctly
# test round robin scheduling by using long-running timedCountdown.sh script
workers=`cat /proc/cpuinfo | grep processor | wc -l`
commands=$(( $workers + $workers ))
n=1
while [ $n -le $commands ]; do
    ./submitJob.sh ./tests/timedCountdown.sh 3
    n=$(( $n + 1 ))
done
# sleep to give time for the countdowns to finish
sleep 50
./submitJob.sh -s
# ./submitJob.sh -x
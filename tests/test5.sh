#!/bin/bash
# to be run from main directory of the assignment (not tests directory) so that the paths work correctly
# test behaviour of server and workers when shutdown command received while workers still running tasks.
# BUGS THE CODE DUE TO ABRUPT TERMINATION - required recreating the dev environment to fix the pipes.
workers=`cat /proc/cpuinfo | grep processor | wc -l`
n=1
while [ $n -le $workers ]; do
    ./submitJob.sh ./tests/timedCountdown.sh 5
    n=$(( $n + 1 ))
    sleep 2
done
./submitJob.sh -s
# ./submitJob.sh -x
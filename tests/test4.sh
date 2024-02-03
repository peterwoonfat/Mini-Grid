#!/bin/bash
# to be run from main directory of the assignment (not tests directory) so that the paths work correctly
# test more complex commands involving piping
./submitJob.sh "ls | grep worker"
./submitJob.sh "cat submitJob.sh | wc -l"
./submitJob.sh -s
# ./submitJob.sh -x
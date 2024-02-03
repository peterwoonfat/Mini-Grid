#!/bin/bash
SoCSusername=pwoonfat

# get command line arguments for this script and pass them to server as commands to be run
input=$*

if [[ $input == "-s" ]] ; then
    echo 'status' > /tmp/server-$SoCSusername-inputfifo
elif [[ $input == "-x" ]] ; then
    echo 'shutdown' > /tmp/server-$SoCSusername-inputfifo
else
    # preface commands to be executed with "CMD" to differentiate from -s and -x
    echo "CMD $*" > /tmp/server-$SoCSusername-inputfifo
fi
#!/bin/bash
SoCSusername=pwoonfat

# get command line args to get worker number
id=$1

# create a new log file upon start for finished tasks, overwrite if already exists. log file not deleted upon program ending
> /tmp/worker-$SoCSusername.$id.log

# establish the server input pipe
if [ -e /tmp/worker$id-$SoCSusername-inputfifo ]; then
    # file exists, check if it is not a named pipe - if it is not then create it, if it is then delete it and reinitialize
    if [ ! -p /tmp/server-$SoCSusername-inputfifo ]; then 
        mkfifo /tmp/worker$id-$SoCSusername-inputfifo
    else
        rm /tmp/worker$id-$SoCSusername-inputfifo
        mkfifo /tmp/worker$id-$SoCSusername-inputfifo
    fi
else
    # file does not exist, create named pipe
    mkfifo /tmp/worker$id-$SoCSusername-inputfifo
fi

# get task from pipe
terminate=1
while [ $terminate != 0 ]
do
    # check if line successfully read
    if read line; then
        # check if command is "shutdown"
        if [[ $line == "shutdown" ]]; then
            terminate=0
        else
            # run task in the background and wait for completion
            {
                output=$(eval $line)
                echo $output >> /tmp/worker-$SoCSusername.$id.log
                # tell server task has been completed
                echo "done $id" > /tmp/server-$SoCSusername-inputfifo
            } &
            # Wait for task to finish and be logged
            wait $!
        fi
    fi
done </tmp/worker$id-$SoCSusername-inputfifo

# delete fifo pipe
if [ -p /tmp/worker$id-$SoCSusername-inputfifo ]; then
    rm /tmp/worker$id-$SoCSusername-inputfifo
fi

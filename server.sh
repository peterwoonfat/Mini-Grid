#!/bin/bash
SoCSusername=pwoonfat

# server receives commands to run from the submitter and does task scheduling
# determine number of workers (dependent on machine)
workers=`cat /proc/cpuinfo | grep processor | wc -l`
# run workers in the background
n=1
while [ $n -le $workers ]; do
    ./worker.sh $n &
    n=$(( $n + 1 ))
done
echo Starting up $workers processing units

# establish the server input pipe
if [ -e /tmp/server-$SoCSusername-inputfifo ]; then
    # if pipe still exists - was not deleted from last run due to abrupt termination - delete the pipe before recreating it
    rm /tmp/server-$SoCSusername-inputfifo
fi
mkfifo /tmp/server-$SoCSusername-inputfifo
echo Ready for processing: place tasks into /tmp/server-$SoCSusername-inputfifo

# initialize array to hold waiting jobs
declare -a taskQueue
# initialize arrays used to track worker information (status and tasks completed)
# for workerStatus, let 0 = waiting and 1 = busy
declare -a workerStatus
declare -a tasksCompleted
n=1
while [ $n -le $workers ]; do
    workerStatus+=( 0 )
    tasksCompleted+=( 0 )
    n=$(( $n+1 ))
done

numWorkers=0
numProcessed=0
nextWorker=1
terminate=1
while [ $terminate != 0 ]
do
    # check if line successfully read
    if read line; then
        if [[ $line == "status" ]]; then
            read -a array
            totalTasksCompleted=0
            for i in ${tasksCompleted[@]}; do
                totalTasksCompleted=$(( $totalTasksCompleted+$i ))
            done
            echo $totalTasksCompleted tasks have been completed across $workers workers.
        elif [[ $line == "shutdown" ]]; then
            echo Shutting down server and workers...
            # tell all workers to shut down
            n=1
            while [ $n -le $workers ]; do
                echo "shutdown" > /tmp/worker$n-$SoCSusername-inputfifo
                n=$(( $n+1 ))
            done
            terminate=0
        elif [[ $line == CMD* ]] || [[ $line == done* ]]; then
            if [[ $line == CMD* ]]; then
                # remove "CMD" prefix from command
                command=`echo $line | cut -c 4-`
                # command received, add it to taskQueue
                taskQueue+=( "$command" )
            elif [[ $line == done* ]]; then
                # a worker finished a task, adjust worker status and number of tasks completed for that worker
                workerNumber=`echo $line | cut -c 5-`
                index=$(( $workerNumber-1 ))
                workerStatus[$index]=0
                tasksCompleted[$index]=$(( ${tasksCompleted[$index]} + 1 ))
            fi

            # assign tasks to workers using round robin scheduling
            # check if nextWorker is available to run next task and taskQueue is not empty (there is a task to be executed), otherwise keep waititng
            index=$(( $nextWorker-1 ))
            if [ ${workerStatus[$index]} -eq 0 ] && [ ${#taskQueue[@]} -ne 0 ]; then
                # worker is waiting, assign task then remove it from the queue, set worker status to busy (1)
                workerStatus[index]=1
                echo "${taskQueue[0]}" > /tmp/worker$nextWorker-$SoCSusername-inputfifo
                unset 'taskQueue[0]'
                taskQueue=("${taskQueue[@]}")
                # decide next worker to be assigned a task
                if [[ $nextWorker -eq $workers ]]; then
                    nextWorker=1
                else
                    nextWorker=$(( $nextWorker+1 ))
                fi
            fi
        fi
    fi
done </tmp/server-$SoCSusername-inputfifo

# cleanup
unset taskQueue
unset workerStatus
unset completedTasks
if [ -p /tmp/server-$SoCSusername-inputfifo ]; then
    rm /tmp/server-$SoCSusername-inputfifo
fi
pkill worker.sh
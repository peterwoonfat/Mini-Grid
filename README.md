Mini Grid

Implementation Details

The grid is split into 3 parts -- the submitter, the server, and the workers. First, the user should run server.sh in one terminal, before using submitJob.sh in another terminal to send tasks to the server. Upon start the server spawns background worker.sh processes with the number varying depending on machine core count. submitJob.sh submits tasks to the server and prefaces them with "CMD" so that the server knows they are actual commands to be sent to a worker and executed. Sending the server "-s" displays the status and "-x" shuts down the server.

The tasks sent from the submitter to the server are first added to the task queue before checking if the next worker in the round robin scheduling is available. If it is available, then the command is sent to the worker and removed from the task queue. If it is not available, then the task stays in the queue and nothing happens on that iteration of the while loop that reads from the pipe; the server does not check if the worker is available again until it reads something from the pipe --another command from the submitter or a done message from a worker. When a worker completes a task and logs it, the worker then writes "done [insert worker number]" to the pipe so that the server knows to the worker completed the task and its status can be updated from busy to waiting.

Upon shutdown the server sends a message to each worker to shutdown, and they will delete their fifo pipes, before the server itself cleans up its resources and deletes its own fifo pipe. The workers create a new log file upon creation using the format "/tmp/worker-$SoCSusername.$id.log", which contains the output from the commands the respective worker has executed. When the server creates the worker processes in the background, it passes a number as an argument -- the worker number starting at 1.

Tests

test1.sh:

Uses basic commands such as "ps" and "ls -l" to establish a basis that the program works in basic conditions. Each worker runs the "ps" command once followed by the "ls -l" command.

The output in the log file for each worker should have the currently running processes on the first line -- should be bash, the server, the workers, and the ps command. The second line in the output file should be all files in the submission directory: runtests.sh, server.sh, submitJob.sh, worker.sh, tests. The output can be verified by looking at the worker log files. The -s command is also run before -x so the server should confirm that the number of jobs run is equal to 2x the number of workers. My code passes this test.

test2.sh:

Uses timedcountdown.sh to have long-running tasks that ensure all workers will be busy. Tests the queue to hold tasks when workers busy and the server's ability to perform round robin scheduling. The script is set to sleep for 50 seconds after sending all the tasks and before running -s and -x to allow all the workers to finish.

The output in the log file for each worker should have 2 lines counting down from 3 as the timedCountdown script was run twice for each worker and the countdown was set to 3 for all of them. My code passes this test.

test3.sh:

The script again tests basic commands but mixes in an invalid command. The third command is invalid so assuming each command runs on its own worker, all should log proper output for their respective command save for the third worker which will have an empty log. My code passes this test. The error is output to stdout.

test4.sh:

The script tests more complex commands involving piping "ls | grep worker" and 'cat submitJob.sh | wc -l". The log of worker 1 should contain "worker.sh" and the log of worker 2 should contain "13". My code passes this test.

test5.sh:

The script uses the timedCountdown.sh script to test the behaviour of the server and workers when the shutdown command is received while workers are still running tasks. Each worker runs timedCountdown.sh with a 1 second sleep in between sending each command to space it so that some tasks can finish and some can not. The first task should at least finish before the shutdown command and depending on the number of workers a few others may finish, but there will

be some that do not finish before receiving the command, but continue to finish their task because the workers are set to wait on the task before reading from the pipe again.

The logs for every worker should have the output of timedCountdown.sh counting down from 5. My code passes this test. However, the workers may write to the pipe but it won't be read since the server has terminated, meaning there will be leftover text in the server pipe for the next instance. My program works around this by checking in the server if the server pipe already exists -- if it does then it is deleted before a new pipe is created for the fresh instance of server.sh.

runtests.sh

The script runs all the tests in the tests directory consecutively starting with test1.sh and ending with test5.sh, then sending the shutdown command. My code passes all the tests and the output from the tests is properly appended to the logs, which can be checked after the completion of the script. Although the output for the scripts may be found in different worker logs than as mentioned above since those descriptions assumed testing the scripts on a fresh start for the server, but runtests tests them all on the same server instance.

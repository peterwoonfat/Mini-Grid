#!/bin/bash
# script runs all test cases in the test directory consecutively

# run test 1
echo Running ./tests/test1.sh...
./tests/test1.sh
echo ./tests/test1.sh completed.
sleep 1

# run test 2
echo Running ./tests/test2.sh...
./tests/test2.sh
echo ./tests/test2.sh completed.
sleep 1

# run test 3
echo Running ./tests/test3.sh...
./tests/test3.sh
echo ./tests/test3.sh completed.
sleep 1

# run test 4
echo Running ./tests/test4.sh...
./tests/test4.sh
echo ./tests/test4.sh completed.
sleep 1

# run test 5
echo Running ./tests/test5.sh...
./tests/test5.sh
echo ./tests/test5.sh completed.
sleep 1

# send shutdown
echo All tests completed.
./submitJob -x
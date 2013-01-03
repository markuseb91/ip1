#!/bin/bash

# Wrapper around our 'runJMeter.sh' script. 
# This runs the IP1_OldIp1Req.jmx test i

# 1st arg.  number of threads (default is 1)
# 2nd arg.  test duration in seconds (default is 5min (300s))

# Check the arguments 

if [ -z "$1" ]; then
  NUM_THREADS=1 
else
  NUM_THREADS=$1
fi
echo "Number of threads: ${NUM_THREADS}"

if [ -z "$2" ]; then
  TEST_TIME=300 
else
  TEST_TIME=$2
fi
echo "Test time: ${TEST_TIME}"

# 
# Run the darn thing already...
./runJMeter.sh IP1_OldIP1Req.jmx $NUM_THREADS $TEST_TIME
echo "Goodbye!"

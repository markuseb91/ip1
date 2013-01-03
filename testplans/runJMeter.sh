#!/bin/bash
clear 

export JAVA_HOME=/usr/java/latest
export JMETER_HOME=/usr/jmeter/apache-jmeter-2.8
export IP_JMETER_HOME=/home/jmeter
export IP_PROJ=ip1
export IP_PATH=$IP_JMETER_HOME/$IP_PROJ
export IP_RESULTS=$IP_PATH/results
export CLASSPATH=$JAVA_HOME/lib:$JMETER_HOME/lib
export PATH=$PATH:$JMETER_HOME/bin


echo "Current JMeter environment..."
echo
echo "-----------------------------------------------------"
echo "JAVA_HOME:        ${JAVA_HOME}"
echo "JMETER_HOME:      ${JMETER_HOME}" 
echo "IP_JMETER_HOME:   ${IP_JMETER_HOME}"
echo "IP_PROJ:          ${IP_PROJ}"
echo "IP_PATH:          ${IP_PATH}"
echo "IP_RESULTS:       ${IP_RESULTS}"
echo "CLASSPATH:        ${CLASSPATH}"
echo "PATH:             ${PATH}"
echo "-----------------------------------------------------"

# Some simple script variables...
IP_JTL_PATH=${IP_PATH}/ip.jtl
IP_CSV_PATH=${IP_PATH}/aggregatedata.csv
IP_RESP_GRAPH=${IP_PATH}/responseovertime.png
IP_RESP_THREAD_GRAPH=${IP_PATH}/responsethreads.png

# Clean up .csv and .jtl files
echo "Cleaning up..." 
if [ -e ${IP_JTL_PATH} ]; then
   rm -f ${IP_JTL_PATH}
fi
if [ -e ${IP_CSV_PATH} ]; then
   rm -f ${IP_CSV_PATH}
   rm -f ${IP_PATH}/bpperrors.csv
   rm -f ${IP_PATH}/bpptimes.csv
fi 

# Run JMeter in non-GUI mode
cd $JMETER_HOME/bin
echo "Running JMeter test...num threads; $2 test duration: $3" 
sh jmeter --jmeterlogfile ${IP_PATH}/jmeter.log -n -t ${IP_PATH}/testplans/$1 -l${IP_JTL_PATH} -Jip.results.dir=${IP_PATH} -Jip.num.threads=$2 -Jip.test.duration=$3 

echo "Running JMeter Plugin Reporter tool..."
cd ${JMETER_HOME}/lib/ext
java -jar -Djava.awt.headless=true CMDRunner.jar --tool Reporter --generate-csv ${IP_CSV_PATH} --input-jtl ${IP_JTL_PATH} --plugin-type AggregateReport

java -jar -Djava.awt.headless=true CMDRunner.jar --tool Reporter --generate-png ${IP_RESP_GRAPH} --input-jtl ${IP_JTL_PATH} --plugin-type ResponseTimesOverTime 

java -jar -Djava.awt.headless=true CMDRunner.jar --tool Reporter --generate-png ${IP_RESP_THREAD_GRAPH} --input-jtl ${IP_JTL_PATH} --plugin-type TimesVsThreads 
# Copy .csv, .itl and .log files to specified results directory
echo "Copying results..."
if [ -z $4 ]; then
   echo "No results directory specified! Generated results not copied." 
else
   # Make the directory if it doesn't exist
   RESULTS_DIR=${IP_RESULTS}/$4
   if [ ! -d ${RESULTS_DIR} ]; then
      echo "Creating results directory ${RESULTS_DIR}..."
      mkdir -p $RESULTS_DIR
   fi

   echo "Copying test results to ${RESULTS_DIR}..."   
   cp -p $IP_PATH/*.csv $RESULTS_DIR/.
   cp -p $IP_PATH/ip.jtl $RESULTS_DIR/.
   cp -p $IP_PATH/jmeter.log $RESULTS_DIR/.
fi

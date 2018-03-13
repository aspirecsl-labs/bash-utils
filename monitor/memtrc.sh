#!/bin/bash
#set -x
#####################################################################
#                                                                   #
# Author      :  AspireCSL Labs                                     #
# Description :  A simple imemory monitor script.                   #
#                This script logs the memory usage of a server and  # 
#                the processes with the largest memory usage. This  #
#                output is refreshed periodically.                  #
# Arguments   :  [OPTIONAL] -d : daemon mode - stdout suppressed    # 
#                              - modes are: start, stop or status   #
#                              - output logged in LOG_FILE          #
#                [OPTIONAL]  -n : number of processes to log        #
#                              - default = 10                       #
#                [OPTIONAL]  -i : refresh interval in seconds       #
#                              - default = 30s                      #
#                                                                   #
#####################################################################

### MODIFY THE FOLLOWING VALUES AS NEEDED ###

LOG_FILE=/tmp/memtrc.log
LOCK_FILE=/tmp/memtrc.lock

### DO NOT MODIFY BELOW THIS LINE ###

bad_usage() {
    echo "Usage: `basename $0` [-n number of processes] [-i refresh interval in seconds] [-m start|stop|status]"
    echo "Values for OP_MODE: start, stop, or status"
    return 9
}

startLogging() {

  while true
  do
    declare -a tmpArr=(`free -m \
                          | awk \
                              '{
                                if (NR==2)
                                {
                                  printf("%s ", $2);
                                }
                                else if (NR==3)
                                {
                                  printf("%s ", $4);
                                }
                                else if(NR==4)
                                {
                                  printf("%s ", $3);
                                }
                              }'\
                      `)
    
    local used_ram=`expr ${tmpArr[0]} \- ${tmpArr[1]}`
    local used_swap=${tmpArr[2]}
   
    echo "At: `date '+%Y%m%d-%H%M%S'`" 
    echo "####### FREE MEMORY #######"
    free -m
    echo "####### PROCESS MEMORY FOOTPRINT #######"
    ### cater for the header line, so increment PROCESS_NUM_LIMIT by 1 ###
    COLUMNS=160 ps -eo pid,user,rss,vsize,size,args --sort=-rss | head -n `expr $PROCESS_NUM_LIMIT \+ 1`
    echo "Refreshng in $SLEEP_TIME seconds..."
    echo "-------------------------------------------------------------------------------------------------------------"
    sleep $SLEEP_TIME
  done

}

OP_MODE=I
SLEEP_TIME=30
PROCESS_NUM_LIMIT=10

while getopts m:n:i: optname;
do
  case $optname in
    m)
      OP_MODE=$OPTARG;;
    n)
      PROCESS_NUM_LIMIT=$OPTARG;;
    i)
      SLEEP_TIME=$OPTARG;;
    *)
      bad_usage
      exit $?;;
  esac
done

shift $(($OPTIND - 1))

case $OP_MODE in
    start)
        if [ ! -f $LOCK_FILE ]
        then
            startLogging >> $LOG_FILE 2>&1 &
            echo "$!" > $LOCK_FILE
            echo -e "\E[32mmemtrc started successfully...\E[0m"
            exit 0
        else
            echo -e "\E[33mmemtrc is running already...\E[0m"
            exit 2
        fi;;
    stop)
        if [ -f $LOCK_FILE ]
        then
            memtrc_pid=`cat $LOCK_FILE`
            ps -p $memtrc_pid > /dev/null 2>&1
            if [ $? -eq 0 ]
            then
                kill -SIGTERM $memtrc_pid > /dev/null 2>&1
                rm -f $LOCK_FILE
                echo -e "\E[32mmemtrc stopped successfully...\E[0m"
                exit 0
            else
                echo -e "\E[33mmemtrc is not running; but lock file exists...\E[0m"
                echo -e "\E[33mremoving stale lock file...\E[0m"
                rm -f $LOCK_FILE
                exit 4                
            fi
        else
            echo -e "\E[33mmemtrc is stopped already...\E[0m"
            exit 3
        fi;;
    status)
        if [ -f $LOCK_FILE ]
        then
            memtrc_pid=`cat $LOCK_FILE`
            ps -p $memtrc_pid > /dev/null 2>&1
            if [ $? -eq 0 ]
            then
                echo -e "\E[32mmemtrc is running...\E[0m"
                exit 0
            else
                echo -e "\E[31mmemtrc is not running; but lock file exists...\E[0m"
                exit 5                
            fi
        fi
        echo -e "\E[33mmemtrc is not running...\E[0m"
        exit 1;;
    I)
        startLogging;;
    *)
        bad_usage
        exit $?;;
esac

exit 0

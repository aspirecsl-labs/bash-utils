#!/bin/bash
#set -x
#####################################################################
#                                                                   #
# Author       : AspireCSL Labs                                     #
# Description  : Script to display the memory usage of processes    #
# Arguments    : [MANDATORY] comma separated list of unique process #
#                            identifiers - like a pid or a name     #
#              : [OPTIONAL]  -c : continous mode                    # 
#                              - display refreshes periodically     #
#                [OPTIONAL]  -i : refresh interval in seconds       #
#                              - default = 3 seconds                #
#                                                                   #
#####################################################################

_exit_bad_usage(){

  echo "Usage `basename $0` [-c] [-i interval (integer value) ] comma-separated-process-identifiers"
  exit 9

}

OP_MODE="ONCE"
INTERVAL=3
SCRIPT_NAME=`basename $0`

while getopts ci: optname; 
do
    case $optname in
        c)
          OP_MODE="LOOP";;   
        i)
          test ${OPTARG} -eq 1 >/dev/null 2>&1
          if [ $? -eq 2 ]
          then
            _exit_bad_usage
          fi
          INTERVAL=$OPTARG;;   
        *)
          _exit_bad_usage;;
    esac 
done

shift $(($OPTIND - 1))

if [ $# -ne 1 ]
then
  _exit_bad_usage
fi

IFS=', ' 
read -r -a  processGrepStrArr <<< `echo $1`
unset IFS

if [ $OP_MODE == "LOOP" ]
then
  while true
  do
    for process in ${processGrepStrArr[@]}
    do
      COLUMNS=250 \
        ps -eo pid,user,rss,args --sort=-rss \
          | grep $process \
            | grep -v "grep\|$SCRIPT_NAME\|awk" \
              | awk \
                  -v _PNAME=$process \
                  '{printf("%s:%s:%s:%s KB\n",_PNAME,$1,$2,$3)}' \
                | showtable -d: -titles=NAME,PID,USER,MEMORY -f1-4
      if [ ${PIPESTATUS[2]} -ne 0 ]
      then
        for idx in "${!processGrepStrArr[@]}"
        do
          if [[ ${processGrepStrArr[$idx]} = "$process" ]]
          then
            unset 'processGrepStrArr[$idx]'
          fi
        done
      fi
    done
    if [ ${#processGrepStrArr[@]} -eq 0 ]
    then
      echo -e "processes seem to have terminated...exiting...\n"
      exit 0
    fi
    echo -e "\nrefreshing in $INTERVAL seconds...press Ctrl+C to quit...\n"
    sleep ${INTERVAL}s
  done
else
  for process in ${processGrepStrArr[@]}
  do
    COLUMNS=250 \
      ps -eo pid,user,rss,args --sort=-rss \
        | grep $process \
          | grep -v "grep\|$SCRIPT_NAME\|awk" \
            | awk \
                -v _PNAME=$process \
                '{printf("%s:%s:%s:%s KB\n",_PNAME,$1,$2,$3)}' \
              | showtable -d: -titles=NAME,PID,USER,MEMORY -f1-4
  done
fi

exit 0

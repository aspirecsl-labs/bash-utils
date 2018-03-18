# Monitor Scripts

A collection of scripts that can be used to monitor the state of a Linux server.

# memtrc.sh

A simple memory monitor script that reports the following (data refreshed periodically):
 - the memory usage of a server, and
 - the processes with the largest memory usage

It accepts the following OPTIONAL arguments:
 - -d : daemon mode (allowed values are start, stop or status); stdout is suppressed and the output is redirected to a file
 - -n : number of processes to log (default = 10)
 - -i : refresh interval in seconds (default = 30 seconds)

Usage examples:
 - memtrc.sh -m start : starts the script in background mode using default values
 - memtrc.sh -m start -n 15 : starts the script in background mode reporting 15 memory heavy processes
 - memtrc.sh -m start -n 15 : starts the script in background mode reporting 15 memory heavy processes and refreshing every 15 seconds
 - memtrc.sh : starts the script in the current terminal and the output is displayed on stdout

# memory_usage.sh

A simple memory monitor script that reports the memory usage of the given process(es).

Prerquisites:
 - ShowTable perl module should be installed on the system

It requires the following MANDATORY arguments:
 - comma separated list of unique process identifiers - like a pid or a process name

It accepts the following OPTIONAL arguments:
 - -c : continous mode in which data refreshes periodically
 - -i : refresh interval in seconds (default = 3 seconds)

Usage examples:
 - memory_usage.sh 1234 : displays the memory usage of the process(es) that can be identified by '1234'
 - memory_usage.sh java,python,1234 : displays the memory usage the processes that can be identified by 'java', 'python' or '1234'
 - memory_usage.sh -c -i 5 1234 : displays the memory usage of the process(es) that can be identified by '1234' and refreshes the output every 5 seconds

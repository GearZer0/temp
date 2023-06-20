#!/bin/bash
cat <<EOT > commands
##### START WRITING YOUR COMMANDS HERE #####


##### Active Network ####

# Open network ports or raw sockets
netstat -plant

# open ports with assoicated process
/usr/sbin/lsof -i -n -P
/usr/bin/lsof -i -n -P

#Firewall Rules
/usr/sbin/iptables -L
/usr/bin/iptables -L

#System ARP cache
/usr/sbin/arp -a
/usr/bin/arp -a

#List all services
/usr/sbin/service --status-all
/usr/bin/service --status-all

#network interface
/usr/sbin/ifconfig
/usr/bin/ifconfig

#DNS
cat /etc/hosts
cat /etc/resolv.conf

##########################3

##### Process #####

#Running Processes
ps -auxw --forest
#ps -u <username>

#List open Files and sockets by a process
/usr/sbin/lsof -R -p <PID>

#processes associated with a username
#ps -u <username>

#Information of a process
ls -lah /proc/<PID>/

#copy of executable file
#xxd -p /proc/<PID>/exe

#File Handle / what the process has opened
ls -la /proc/<PID>/fd

#Process environment:
strings /proc/<PID>/environ

#Process command name/cmdline:
strings /proc/<PID>/comm
strings /proc/<PID>/cmdline

#Deleted binaries still running:
#ls -laR /proc/*/exe 2> /dev/null | grep -i deleted



##### DON'T WRITE ANYTHING AFTER THIS #####
EOT


# Function to both print to screen and also log to file
function echo_and_log() {
        echo $1
        echo $1 >> $log_file
}

# Function to display the utc_date
function utc_date() {
        date -u +'%Y.%m.%d.%H.%M.%S'
}

# Create a string in the <name>_hostname_date pattern
function hostname_date_pattern {
        datetime=$(utc_date)
        echo "${1}_${hostname}_${datetime}"
}

hostname=$(hostname)

# The folder where the script output will be
output_dir_location="/RTR/Collections/rtr_linux_process_network"

# The name of the folder to output the log files to
#output_dir="${output_dir_location}/$(hostname_date_pattern output_folder)"
output_dir="${output_dir_location}"

# The name of the log file where all this automation transcript is recorded
log_file="${output_dir}/script_log.txt"

# The file name of where all the commands are located
commands_filename="commands"

# The default timeout foreach command before terminating it
timeout=20

# Arguments assigment
pid=$1
usrname=$2

# Create the output_dir folder if non existent
mkdir -p $output_dir

echo_and_log "Script started - $(utc_date) (UTC)"

# Read the whole commands file
while IFS="" read -r line || [ -n "$line" ]
do
  # If the line isn't empty
  if [[ ! -z $line ]] && [[ $line != \#* ]]; then
          # Replace the <PID> into the actual PID passed to script
          command=$(echo $line | sed 's/<PID>/'"$pid"'/g' | sed 's/<username>/'"$usrname"'/g')

          # Clear the command out of all the spaces and special characters
          clean_name=$(echo $command | sed "s/[^[:alpha:]+]/_/g" | tr '[:upper:]' '[:lower:]')

          # Get current datetime and generate filename
          file_name=$(hostname_date_pattern ${clean_name})".txt"


          # Run the command using timeout
          output=`timeout $timeout $command`

          # Write a log according to the command return code
          rc=$?
          if [ $rc -eq 0 ]; then
            echo_and_log "Command $command succeeded"
          elif [ $rc -eq 124 ]; then
            echo_and_log "Command $command reached timeout"
          else
            echo_and_log "Command $command failed"
          fi

          # Log the file output
          echo "$output" > $output_dir/$file_name
  fi
done < $commands_filename

echo_and_log "Script ended - $(utc_date) (UTC) - Beggining ZIP"

# ZIP the file
# tar -cf "${output_dir_location}/$(hostname_date_pattern files).tar" --remove-files $output_dir

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

# The name of the folder to output the log files to
output_dir=$(hostname_date_pattern output_folder)

# The name of the log file where all this automation transcript is recorded
log_file="${output_dir}/script_log.txt"

# The file name of where all the commands are located
commands_filename="commands"


# The RTR output dir
rtr_directory="RTR/Collections/rtr_linux_Process_Network"

# The default timeout foreach command before terminating it
timeout=5

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
          clean_name=$(echo $command | tr -dc '[:alnum:]\n\r' | tr '[:upper:]' '[:lower:]')

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
tar -cf $(hostname_date_pattern files_${datetime}).tar --remove-files $output_dir

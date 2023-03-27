# parameters to enter from the PowerShell console
param(
    [Parameter(Mandatory=$true)]
    [string]$file,
    [Parameter(Mandatory=$true)]
    [string]$start,
    [Parameter(Mandatory=$true)]
    [string]$end
)

# clear any possible previous errors
$error.Clear()

# import the csv, using comma as a delimiter
try {
    $list = Import-Csv -Path $file.trim('"') -Delimiter "," -ErrorAction Stop
}
catch {
    $psitem
    exit
}

# enter the name of the .csv file to export here
$csv_to_export = "exported.csv"
# enter the name of the other .csv file to export here
$message_id_csv_to_export = "message_id_and_recipient.csv"
# enter the name name of the .log file to export
$log_file_name = "log.txt"

# one way of measuring the time of the script running
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

# setting some primary variables
$pageSize = 5000

# creating an array for the final output
$global:final_output = @()

# array for each of the the recursive loop
$global:recursive_results= @()

# variables for statistics
$global:total_emails_searched = 0
$global:total_pages_searched = 0
$global:all_returned_email = @()
$global:all_users_stats = @()

# date handling
$today = Get-Date
$10_days = ($today).AddDays(-10)

$start = $start | Get-Date
# check if startdate is older than 10 days 
if ([datetime]$10_days.ToShortDateString() -gt $start) {
    Write-Output "Startdate can't be older than 10 days"
    exit
}

# if end is specified as "now", set it as todays date
if ($end -like "now") {
    $end = $today
} else {
    $end = $end | Get-Date
}

# function for the message trace itself, takes two parameters - senderaddress and subject
function message_trace {
    param (
        $senderaddress, $subject
    )

    $page = 1
    $message_list = @()

    do {
        Write-Output "Getting page $page of messages..."
        try {
            $messagesThisPage = Get-MessageTrace -SenderAddress $senderaddress -StartDate $start -EndDate $end -PageSize $pageSize -Page $page
        }
        catch {
            $PSItem
        }

        if ($messagesThisPage.count -eq $pageSize) {
            $midPoint = (Get-Date $start).AddSeconds(((Get-Date $end) - (Get-Date $start)).TotalSeconds / 2)
            Write-Output "Found 5000 messages in the time interval, splitting into smaller intervals..."

            message_trace -senderaddress $senderaddress -subject $subject -startDate $start -endDate $midPoint
            message_trace -senderaddress $senderaddress -subject $subject -startDate $midPoint -endDate $end
            return
        }

        # rest of the code
    } until ($messagesThisPage.count -lt $pageSize)
}

#variables for usage in the function for loop
$subject_for_loop = ""
# iterate through the given .CSV and run the message_trace function for each, included write-progress so you can see the progress
$i = 1
$list | ForEach-Object {
    # empty the recursive results array for the next loop in the function
    $recursive_results = @()
    # set the subject values for usage in the foreach loop in the function itself
    $subject_for_loop = $psitem.subject
    # write-progress so we can see the progress
    Write-Progress -Activity "Looping through the .csv" -status "$i of $($list.count)" -PercentComplete (($i / $list.count) * 100)
    $i++
    # call out the function with the provided subject and senderaddress from the .csv
    message_trace -senderaddress $psitem.senderaddress -subject $psitem.subject -startdate $start -enddate $end
}

Write-Progress -Activity "Looping through the .csv" -Status "Ready" -Completed

# count all overall unique email addresses
$all_unique_sender_addresses = $all_returned_email | Select-Object senderaddress -Unique
$all_unique_recipient_adrresses = $all_returned_email | Select-Object recipientaddress -Unique
$unique_addresses_overall = $all_unique_sender_addresses.count + $all_unique_recipient_adrresses.count

# stop the stopwatch 
$stopwatch.Stop()
$total_time_taken = "$($stopwatch.Elapsed.Hours) Hours, $($stopwatch.Elapsed.Minutes) minutes, $($stopwatch.Elapsed.Seconds) seconds"

$log_content = "Total number of unique email addresses overall (both sender and recipient) $unique_addresses_overall, `
Total number of pages searched $total_pages_searched, `
Total number of emails searched $($all_returned_email.count), `
Total time taken $total_time_taken  `n"  

# export the final csv and logs
$final_output | Export-Csv "$PSScriptRoot/$csv_to_export" -Force
# additional csv
$message_id_rec_address_unique = $final_output | Select-Object @{N = 'message_id';  E = {$psitem.messageid -replace '[<>]',''}}, @{N = 'recipient';  E = {$psitem.recipientaddress}} -Unique
$message_id_rec_address_unique | Export-Csv "$PSScriptRoot/$message_id_csv_to_export" -Force
$log_content | out-file "$PSScriptRoot/$log_file_name" -Force
($all_users_stats | Format-Table | Out-String -Width 10000) | out-file "$PSScriptRoot/$log_file_name" -Append

# in case of any errors, we export all of the errors in to a log file
if ($error) {
    $error | Out-File "$PSScriptRoot/ERROR.log" -Force
}

# Disconnect EXO session ?
# Disconnect-ExchangeOnline

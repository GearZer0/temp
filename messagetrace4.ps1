<# current script function - 
1. CSV with a list of email addresses, together with an email subject.
2. Iterate through the list of email addresses and the email subject.
3. Perform a message trace for each email address and email subject using the Get-MessageTrace cmdlet.
4. Extract all the recipients.
5. Use a loop to iterate through all the recipients and perform a message trace on each recipient, together with an email subject that was identified in step 1
6. Repeat steps 4 and 5 until there are no more results.
7. Repeat steps 2 to 6 for all initial email addresses and subjects until there are no more results.
8. it will split into interval (10 as default) if a page reaches 5,000 maximum objects. because if the desired object is at 5,001 or above, it wont be captured due to the cap 5,000
9. The desired output will have all the email events and all its available fields to a csv file.
10. Create a log that logs the number of page and its message searched, Total number of message searched, and total time taken.
Added no.9 the log file to follow https://cynicalsys.com/2019/09/13/working-with-large-exchange-messages-traces-in-powershell/
#>


# parameters to enter from the PowerShell console
param(
    [Parameter(Mandatory=$true)]
    [string]$file,
    [Parameter(Mandatory=$false)]
    [string]$start,
    [Parameter(Mandatory=$false)]
    [string]$end,
    [Parameter(Mandatory=$false)]
    [int]$days
)

if ($days){
    $numIntervals = $days
} else {
    $numIntervals = 10
}

if (!($start))
	{
		$start = (Get-Date).AddDays(-$numIntervals)
	}

if (!($end))
	{
		$end = Get-Date
	}


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


function CheckDateTime  {

[CmdletBinding()]
	Param(
		[Parameter(Mandatory = $True,
		Position = 0)]
		[String]
		$InputDate)

Try {
	$ConvertedDate = $InputDate | Get-date -ErrorAction Stop
	}

Catch{
	Try{
		$ConvertedDate = $InputDate.Split("/")[1] + "/" + $InputDate.Split("/")[0] + "/" + $InputDate.Split("/")[2] | Get-Date
		}
	Catch {
		Write-host "Provide the Date in dd/MM/yyyy HH:mm OR MM/dd/yyyy HH:mm format" -f Red
		Exit
		}
	}

Return $ConvertedDate
}




#$start = $start | Get-Date

[datetime]$start = CheckDateTime -InputDate $start


# date handling
$today = Get-Date
$10_daysTemp = ($today).AddDays(-10)
$10_Days = $10_daysTemp.AddHours(-1)


# check if startdate is older than 10 days 
#if ([datetime]$10_days.ToShortDateString() -gt $start) {

if ($10_days.ToString() -gt $start.ToString()) {
    Write-Output "Startdate can't be older than 10 days"
    exit
}

# if end is specified as "now", set it as todays date
if ($end -like "now") {
    $end = $today
} else {
    #$end = $end | Get-Date

    [datetime]$end = CheckDateTime -InputDate $end

}


# function for the message trace itself, takes two parameters - senderaddress and subject
function message_trace {
    param (
        $senderaddress, $subject
    )

    # Convert start and end to DateTime objects...Not Needed
   # $startDateTime = [DateTime]::Parse($start)
   # $endDateTime = [DateTime]::Parse($end)

    $startDateTime = $start
    $endDateTime = $end

    # Calculate the time interval and split it into 10 equal sub-intervals if necessary
    $interval = (New-TimeSpan -Start $startDateTime -End $endDateTime).TotalMinutes
    if ($interval -gt 0) {
        $subInterval = $interval / $numIntervals
    }

    # paging setup included if there should be over 5000 results on the page
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

        # If there are 5000 messages on the page, process 10 sub-intervals separately
        if ($messagesThisPage.count -eq $pageSize) {
            Write-Output "Page with 5000 objects detected, processing sub-intervals"
            $messagesThisPageTemp
            for ($i = 0; $i -lt $numIntervals; $i++) {
                $newStart = $startDateTime.AddMinutes($i * $subInterval)
                $newEnd = $newStart.AddMinutes($subInterval)
                $subMessages = Get-MessageTrace -SenderAddress $senderaddress -StartDate $newStart -EndDate $newEnd -pageSize $pageSize -Page $page
                $messagesThisPageTemp += $subMessages
                Write-Output "$($messagesThisPageTemp.count) messages on page $page, interval $($i + 1)"
            }
            $messagesThisPage = $messagesThisPageTemp
            
        }
        
        # update the statistics variables
        $global:all_returned_email += $messagesThisPage
        $global:total_pages_searched++

        # filter our results by subject
        $filtered_result = $messagesThisPage | Where-Object {$psitem.subject -like "*$subject*"}

        # more statistics for the log file, for each senderaddress
        $users_stats = $messagesThisPage | Select-Object @{N = 'senderaddress';  E = {$senderaddress}}, @{N = 'page nr.';  E = {$page}}, 
            @{N = 'messages on this page';  E = {$messagesThisPage.count}}, @{N = 'hit on subject';  E = {($PSItem | Where-Object {$psitem.subject -like "*$subject*"}).subject}},
                @{N = 'date';  E = {$psitem | Select-Object -ExpandProperty received}}
        $global:all_users_stats += $users_stats

        # add to our final output array
        $global:final_output += $filtered_result
        $message_list += $filtered_result

        # write output and increase the page count
        Write-Output "There were $($messagesThisPage.count) messages on page $page..."
        $page++

    } until ($messagesThisPage.count -lt $pageSize)

    Write-Output "Message trace returned $($message_list.count) messages with our subject"

    # using the power of recursive function, we call out the function again for each recipient. 
    foreach ($message_list_item in $message_list) {
        # Avoid endless loop by not running the same trace with the same sender address twice
        $recursive_address = $global:recursive_results.senderaddress
        if ($recursive_address -contains $message_list_item.recipientaddress) {
            # Write-Output "Avoided infinite loop"
        } else {
        $global:recursive_results += $message_list_item
        message_trace -senderaddress $message_list_item.RecipientAddress -subject $subject_for_loop -startdate $start -enddate $end
        }
    }
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
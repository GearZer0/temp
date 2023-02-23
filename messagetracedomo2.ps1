# input the path of your .csv file here
$list_input = "C:\temp\noja.csv"
$list = Import-Csv $list_input -Delimiter ","

# one way of measuring the time of the script running, I personally like this one the best
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

# setting some primary variables
$today = Get-Date
$10_days = (Get-Date $today).AddDays(-10)
$pageSize = 5000 # Max pagesize is 5000. There isn't really a reason to decrease this in this instance.
$total_emails_searched = 0
$total_pages_searched = 0

# creating an array for the final output
$final_output = @()

# function for the message trace itself, takes two parameters - senderaddress and subject
function message_trace {
    param (
        $senderaddress, $subject
    )

# paging setup
$page = 1
$message_list = @()

do
{
    #Write-Output "Getting page $page of messages..."
    try {
        $messagesThisPage = Get-MessageTrace -SenderAddress $senderaddress -StartDate $10_days -EndDate $today -PageSize $pageSize -Page $page
    }
    catch {
        $PSItem
    }
    #Write-Output "There were $($messagesThisPage.count) messages on page $page..."
    $page++

    # update the statistics variables
    $script:total_emails_searched += $messagesThisPage.count
    $script:total_pages_searched++

    # filter the results based on the given email subject and add to our final output array
    $script:final_output += ($messagesThisPage | Where-Object {$psitem.subject -like "*$subject*"})
    $message_list += ($messagesThisPage | Where-Object {$psitem.subject -like "*$subject*"})    

} until ($messagesThisPage.count -lt $pageSize)

# call out the function itself again for each recipient
foreach ($message_list_item in $message_list) {
    message_trace -senderaddress $message_list_item.RecipientAddress -subject $message_list_item.subject    
}

}

# iterate through the given .CSV and run the message_trace function for each 
$list | ForEach-Object {
    message_trace -senderaddress $psitem.senderaddress -subject $psitem.subject
}

# stop the stopwatch 
$stopwatch.Stop()
$total_time_taken = "$($stopwatch.Elapsed.Hours) Hours, $($stopwatch.Elapsed.Seconds) seconds"

# export the final csv and logs
$final_output | Export-Csv "C:\temp\final_output.csv"

$log_content = "Total number of pages searched - $total_pages_searched, total number of emails searched $total_emails_searched, total time taken $total_time_taken"
$log_content | out-file "C:\temp\log.txt"


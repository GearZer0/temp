[CmdletBinding()]
param(

[Parameter(Mandatory=$True)][string]$Pages,
[Parameter(Mandatory=$True)][string]$MessageID,
[Parameter(Mandatory=$True)][string]$Resultfile

)





$a="######################## FINDING THE SENDER OF THE EMAIL##########"
Write-host $a -ForegroundColor "Green"

$mail=@()
$i=1
$z=10
while($z -gt 0)
{
    $date=(get-date).AddDays(-$z)
    $enddate=(get-date).AddDays(-$z +1)
   Write-host "Scanning Message Trace $($MessageID)   $z days back"
    while($i  -lt $pages)
{     
      $mail+=Get-MessageTrace -Page $i -PageSize 5000 -MessageTraceId $MessageID -startdate $date -enddate $enddate
    $i++
      
}
       if($mail.count -gt 0)
           {
				$z=1
				Write-host "Mail found"
                                $i=$page
	   }
        else
       {

       $i=1
       }


$z=$z-1
}

if ($mail.count -gt 0)
{

$sender=($mail.senderaddress |group-object).name
$rcvd=$mail |select RecipientAddress
$date= $mail[0].received |%{get-date $_}
$enddate=$date.adddays(3)
$subject=$mail[0].Subject

$save=$rcvd.count
sleep(5)
Write-host "The sender of the email is $($sender) and It was received by $($rcvd.count) number of People"
$a="#################### Email Sender Found################"
Write-host $a -ForegroundColor "Green"

$flag=1
while($flag)
{

foreach($r in $rcvd)
{


$pages=100
$i=1
 while($i  -lt $pages)
{     
      $mail+=Get-MessageTrace -Page $i -PageSize 5000  -senderaddress $r.recipientaddress   -startdate $date -enddate $enddate
      $i++
     
      
}
Write-Host "Scanning for User $($r.recipientaddress)"


}
$sample=$null
$sample=$mail |?{$_.subject -match $subject}
$test=$sample |group-object RecipientAddress| ?{$_.count -eq 1}
if($test.count -gt 0)
{
Write-Host "Scanning Done"
$flag=0
}
else
{
$rcvd=$test|?{$_.count -lt 2} |select @{n="RecipientAddress";e={$_.name}}
$date= ($test |sort-object Received)[0].Received
$enddate=$date.adddays(3)
}
}

$mails |export-csv -nti  dump.csv
$mails=$mail |?{$_.subject -match  $subject} 
$mails |export-csv -nti sample.csv
foreach($msg in $mails)
{
Write-host "Scanning emails"
$sender=($msg).'SenderAddress'
$Reipient=($msg).'RecipientAddress'
$MsgId=($msg).'MessagetraceID'.guid
$date=$msg.Received
$Status=$msg.Status
$Type=$null
$Sub=$msg.Subject
if(!($Sub  -match "Re:" -and $Sub -match "Fw:"))
   {
   $Type="First Mail Send"
   }
if($Sub -match "Fw:|FYI")
   {
   $Type="Forwarded"
   }
if($Sub  -match "Re:")
   {
   $Type="Replied Back"
   }

if($Sub  -match "Re:" -and $Sub -match "Fw:")
   {
   $Type="Replied and Forwarded"
   }




$obj=new-object psobject
$obj |add-member -NotePropertyname Date -NotePropertyValue $date
$obj |add-member -NotePropertyname MessageID -NotePropertyValue $MsgId
$obj |add-member -NotePropertyname Sender -NotePropertyValue $sender 
$obj |add-member -NotePropertyname Subject -NotePropertyValue $Sub 
$obj |add-member -NotePropertyname Recipient -NotePropertyValue $Reipient
$obj |add-member -NotePropertyname Status -NotePropertyValue $status
$obj |add-member -NotePropertyname Type -NotePropertyValue $type

$obj |export-csv -nti $Resultfile  -append
$obj




}

$sample1=import-csv $Resultfile |?{!($_.type -match "First")}


if($sample1.count -gt $save.count)
{

Write-host "Email is suspicious in nature"

}
}

else
{

Write-host "Couldnt find the Message ID"
}


Write-Host " Script Complete   !!"





   

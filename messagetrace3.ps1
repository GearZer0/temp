[CmdletBinding()]
param(

[Parameter(Mandatory=$True)][string]$Pages,
[Parameter(Mandatory=$True)][string]$MessageID,
[Parameter(Mandatory=$True)][string]$Resultfile

)





function MessageTrace
{
param([string]$RecipientAddress,$Subject)
    $mail=$null
    $mail=@()
    $i=1
    $z=10
   Write-Host "MESSAGE TRACE CALL FOR USER $($RecipientAddress)"
   Write-host "The Subject is $($Subject)"
    while($z -gt 0)
           {
              $date=(get-date).AddDays(-$z)
              $enddate= get-date
              #Write-host "Scanning Message Trace for Recipeint $($RecipientAddress)  for the $($subject) $z  days back"
              while($i  -lt $pages)
                  {     
                     $mail+=Get-MessageTrace -Page $i -PageSize 5000 -SenderAddress $RecipientAddress -startdate $date -enddate $enddate
                      $i++
                      Write-host "Message Trace going for user $($RecipientAddress) for page # $i "
                   }
            $z=$z-1	

            }
Write-host "Hello!!!!"
return $mail 
} 
  






#Scripts starts here#################################


$a="######################## FINDING THE SENDER OF THE EMAIL##########"
Write-host $a -ForegroundColor "Green"

$mail=@()
$i=1
$z=10
while($z -gt 0)
{
    $date=(get-date).AddDays(-$z)
    $enddate= get-date
    Write-host "Scanning Message Trace $($MessageID)   $z days back"
    while($i  -lt $pages)
{     
      $mail+=Get-MessageTrace -Page $i -PageSize 5000 -MessageID $MessageID -startdate $date -enddate $enddate
      $i++
      
}
$z=$z-1
}
#================ SEARCHING OF EMAIL  ENDS===================##


if($mail.count -gt 0)
{
   Write-Host "Email Found. The email was send by $($mail[0].senderaddress)"
   $a="#Getting the list of recipients of Email"
   Write-Host $a
   

$sender=@()
$receiver=@()   
$i=1
while($i)
{
$i=0
if($mail.count -eq 1)
   {
   Write-Host "The email eas received by single recipient $($mail.recipientaddress)"
   $Subject=$Mail.Subject
   $mx=$null
   $msg= MessageTrace  -RecipientAddress  $mail.RecipientAddress -Subject  $Subject  
   $mx=$msg |?{$_.subject -match $subject}
}
else
   { $Subject=$Mail[0].Subject
     $mx=$null;$mx=@()
     foreach($ml in $mail)
        {
           $mx+= MessageTrace  -RecipientAddress  $ml.RecipientAddress -Subject  $Subject  
        }
   }
$r=1
while($r)
{
Write-Host "Inside the loop"
$sender+=$mx |select SenderAddress
$receiver+=$mx |select RecipientAddress
#$receiver

$mom=$null
Write-host "Outside the loop"
$check=$sender.SenderAddress + $receiver.RecipientAddress |group-object
$check
if ($check |?{$_.count -lt 2})
{
foreach($rec in $receiver)
      { 
        Write-host "Inside the loop !!!!!!!"
        $y=$rec.RecipientAddress
        $z=$sender |?{$_.SenderAddress -match $y}
        if($z.count -eq 0)
        {  
          
           Write-host "$($y) is not scanned yet"
           $rmp= MessageTrace  -RecipientAddress  $y -Subject  $Subject 
           $sender+=$y |select @{n="SenderAddress";e={$_}}
           $receiver+=$rmp |select RecipientAddress
        }

        else
        {
        Write-host "$($y) Already Scanned scanned yet"
        }  
      } #forEach loop
}
else
{
$r=0
$i=0
}


}
}
}

else
{

Write-Host "Email not found"
}

Write-Host "Preparing Report........................" -ForegroundColor Green

$data =$mx|?{$_.subject -match $subject}


foreach($mail in $data)
{
$sender=($mail).'SenderAddress'
$Reipient=($mail).'RecipientAddress'
$MsgId=($mail).'MessageID'
$date=$mail.Received
$Status=$mail.Status
$Type=$null
$Sub=$Mail.Subject
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

$obj |sort-object date |export-csv -nti $Resultfile  -append




}


Write-Host "Search Complete!!!"






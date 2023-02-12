[CmdletBinding()]
param(
[Parameter(Mandatory=$False)][string]$SenderEmailaddres,
[Parameter(Mandatory=$False)][string]$RecipientEmailaddres,
[Parameter(Mandatory=$True)][string]$Pages,
[Parameter(Mandatory=$False)][string]$MessageID,
[Parameter(Mandatory=$True)][string]$Resultfile,
[Parameter(Mandatory=$True)][string]$startdate,
[Parameter(Mandatory=$True)][string]$enddate,
[Parameter(Mandatory=$False)][string]$SubJectQuery
)

function MessageID
{ 
 $mail=$null;$mail=@()
 $i=1
  while($i  -lt $page)
  {
  Write-Host "Checking Email of Page # $($i)"
  $Mail+=Get-MessageTrace -MessageTraceID $MessageID -Page $i -PageSize 5000 -startdate $startdate -enddate $enddate
  $i++
  }
  $mail=$mail |?{$_.senderaddress -match "@"}
  return $mail
}

function Sender
{
$mail=@()
$i=1
Write-Host "Sender"
while($i  -lt $page)
  {
  Write-Host "Checking Email of Page # $($i)"
  $Mail+=Get-MessageTrace -SenderAddress $SenderEmailaddres -Page $i -PageSize 5000 -startdate $startdate -enddate $enddate
  $i++
  }
return $mail
}

function Receiver
{
$mail=@()
$i=1
Write-Host "Receiver Email $($RecipientEmailaddres)"
while($i  -lt $page)
  {
  Write-Host "Checking Email of Page # $($i)"
  $Mail+=Get-MessageTrace -RecipientAddress $RecipientEmailaddres -Page $i -PageSize 5000 -startdate $startdate -enddate $enddate
  $mail.count
  $i++
  }
return $mail
}

function SendReceive
{
$mail=@()
$i=1
Write-Host "SendReceive"
 while($i  -lt $page)
  {
  Write-Host "Checking Email of Page # $($i)"
  $Mail+=Get-MessageTrace -SenderAddress $SenderEmailaddres -RecipientAddress $RecipientEmailaddres -Page $i -PageSize 5000 -startdate $startdate -enddate $enddate
  $i++
  }
return $mail
}


#===================================


#$global:Mail=@()
$global:Page=$Pages
$global:date=$Daysold
$global:startdate=$startdate 
$global:enddate=$enddate
$global:RecipientEmailaddres=$RecipientEmailaddres
$global:MessageID=$MessageID
$global:SenderEmailaddres=$SenderEmailaddres


if($MessageID -match '[a-z]')
{ 
 Write-Host "MessageID"
  $mail=MessageID

}

else
{
  if(!($RecipientEmailaddres -match '@') -and $SenderEmailaddres -match '@')
    {
     Write-Host "Sender"
     $mail=sender -Sender  $SenderEmailaddres
    }

   if($RecipientEmailaddres -match '@' -and !($SenderEmailaddres -match '@'))
    {
    Write-Host "Receiver"
     $mail=Receiver
    }
   
   if($RecipientEmailaddres -match '@' -and $SenderEmailaddres -match '@')
    { Write-Host "SendReceive"
      $Mail=SendReceive -Sender $SenderEmailaddres -Receiver $RecipientEmailaddres
    }
    

}
$mail.count
$mail |export-csv -nti dump.csv
if(!($SubjectQuery -eq $null))
{
$Mails=$Mail |?{$_.subject -match $SubJectQuery}
}
else
{
$Mails=$mail
}

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

Write-Host " Script Complete   !!"

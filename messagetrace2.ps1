[CmdletBinding()]
param(
[Parameter(Mandatory=$False)][string]$SenderEmailaddres,
[Parameter(Mandatory=$False)][string]$RecipientEmailaddres,
[Parameter(Mandatory=$True)][string]$Pages,
[Parameter(Mandatory=$False)][string]$MessageID,
[Parameter(Mandatory=$True)][string]$Resultfile,
[Parameter(Mandatory=$False)][string]$startdate,
[Parameter(Mandatory=$False)][string]$enddate,
[Parameter(Mandatory=$True)][string]$SubJectQuery
)

function MessageID
{ 
  param([string]$MessageID)
  while($i  -lt $page)
  {
  Write-Host "Checking Email of Page # $($i)"
  $Mail+=Get-MessageTrace -MessageTraceID $MessageID -Page $i -PageSize 5000 -startdate $startdate -enddate $enddate
  $i++
  }
}

function Sender
{
 param([string]$SenderEmailaddres)
while($i  -lt $page)
  {
  Write-Host "Checking Email of Page # $($i)"
  $Mail+=Get-MessageTrace -SenderAddress $SenderEmailaddres -Page $i -PageSize 5000 -startdate $startdate -enddate $enddate
  $i++
  }
}

function Receiver
{
param([string]$RecipientEmailaddres)
while($i  -lt $page)
  {
  Write-Host "Checking Email of Page # $($i)"
  $Mail+=Get-MessageTrace -RecipientAddress $RecipientEmailaddres -Page $i -PageSize 5000 -startdate $startdate -enddate $enddate
  $i++
  }
}

function SendReceive
{
param([string]$RecipientEmailaddres)
param([string]$SenderEmailaddres)
 while($i  -lt $page)
  {
  Write-Host "Checking Email of Page # $($i)"
  $Mail+=Get-MessageTrace -SenderAddress $SenderEmailaddres -RecipientAddress $RecipientEmailaddres -Page $i -PageSize 5000 -startdate $startdate -enddate $enddate
  $i++
  }

}


#===================================


$global:Mail=@()
$global:Page=$Pages
$global:date=$Daysold
$global:$startdate=$startdate 
$global:$enddate=$enddate

if(!($startdate -match '[0-9'] -or $enddate -match '[0-9']  ))
{
$startdate=get-date(-10)
$enddate=get-date

}

if($MessageID -ne $null)
{
  MessageID -Id $MessageID
}

else
{
  if($RecipientEmailaddres -eq $null -and $SenderEmailaddres -ne $null)
    {
     sender -Sender  $SenderEmailaddres
    }

   if($RecipientEmailaddres -ne $null -and $SenderEmailaddres -eq $null)
    {
     Receiver -Receiver $RecipientEmailaddres
    }
   
   if($RecipientEmailaddres -ne $null -and $SenderEmailaddres -ne $null)
    {
      SendReceive -Sender $SenderEmailaddres -Receiver $RecipientEmailaddres
    }
    

}

$Mails=$Mail |?{$_.subject -match $SubJectQuery}

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

[string]$SubJectQuery,
$mails=$msg |?{$_.Subject -match $SubJectQuery}

}

Write-Host " Script Complete   !!"

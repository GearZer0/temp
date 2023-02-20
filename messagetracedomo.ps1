# Step 1: Create a list of email addresses and subjects
$emailList = @(
    @{Address="user1@example.com"; Subject="Email Subject 1"},
    @{Address="user2@example.com"; Subject="Email Subject 2"}
)

# Step 2-7: Perform message trace for each email address and subject, and drill down to all recipients
foreach ($email in $emailList) {
    $recipients = @($email.Address)

    do {
        $results = Get-MessageTrace -RecipientAddress $recipients -MessageSubject $email.Subject
        $recipients = $results.RecipientAddress | Select-Object -Unique
    } while ($recipients)

    # Output the results for each email address and subject
    Write-Host "Results for $($email.Address) - $($email.Subject): $($results.Count) messages found"
}

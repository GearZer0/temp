# Replace these with your own values
$SenderEmailAddress = "sender@example.com"
$EmailSubject = "Your email subject"

# Get the message trace results for the sender's email address and email subject
$MessageTraceResults = Get-MessageTrace -SenderAddress $SenderEmailAddress -MessageSubject $EmailSubject

# Loop through each message trace result
foreach ($Result in $MessageTraceResults) {
    # Get all the recipients for this message trace result
    $Recipients = $Result.RecipientAddress

    # Loop through each recipient
    foreach ($Recipient in $Recipients) {
        # Perform a message trace for this recipient
        $RecipientTraceResults = Get-MessageTrace -RecipientAddress $Recipient -MessageSubject $EmailSubject

        # Loop through each message trace result for this recipient
        foreach ($RecipientResult in $RecipientTraceResults) {
            # Get all the recipients for this recipient's message trace result
            $SubRecipients = $RecipientResult.RecipientAddress

            # Loop through each sub-recipient
            foreach ($SubRecipient in $SubRecipients) {
                # Perform a message trace for this sub-recipient
                $SubRecipientTraceResults = Get-MessageTrace -RecipientAddress $SubRecipient -MessageSubject $EmailSubject

                # If there are no results for this sub-recipient, move on to the next one
                if ($SubRecipientTraceResults.Count -eq 0) {
                    continue
                }

                # Loop through each message trace result for this sub-recipient
                foreach ($SubRecipientResult in $SubRecipientTraceResults) {
                    # Get all the recipients for this sub-recipient's message trace result
                    $SubSubRecipients = $SubRecipientResult.RecipientAddress

                    # Loop through each sub-sub-recipient
                    foreach ($SubSubRecipient in $SubSubRecipients) {
                        # Perform a message trace for this sub-sub-recipient
                        $SubSubRecipientTraceResults = Get-MessageTrace -RecipientAddress $SubSubRecipient -MessageSubject $EmailSubject

                        # If there are no results for this sub-sub-recipient, move on to the next one
                        if ($SubSubRecipientTraceResults.Count -eq 0) {
                            continue
                        }

                        # Loop through each message trace result for this sub-sub-recipient
                        foreach ($SubSubRecipientResult in $SubSubRecipientTraceResults) {
                            # Get all the recipients for this sub-sub-recipient's message trace result
                            $SubSubSubRecipients = $SubSubRecipientResult.RecipientAddress

                            # Loop through each sub-sub-sub-recipient (and so on)
                            # ... (you get the idea)
                        }
                    }
                }
            }
        }
    }
}

# PowerShell script file to be executed as a AWS Lambda function. 
# 
# When executing in Lambda the following variables will be predefined.
#   $LambdaInput - A PSObject that contains the Lambda function input data.
#   $LambdaContext - An Amazon.Lambda.Core.ILambdaContext object that contains information about the currently running Lambda environment.
#
# The last item in the PowerShell pipeline will be returned as the result of the Lambda function.
#
# To include PowerShell modules with your Lambda function, like the AWSPowerShell.NetCore module, add a "#Requires" statement 
# indicating the module and version.

#Requires -Modules @{ModuleName='CBSApi';ModuleVersion='0.1.0'}

if ($LambdaInput) {
    write-host "LambdaInput found"
    write-host $LambdaInput
    write-host $LambdaInput.records
    write-host $LambdaInput.records.sns
    write-host $LambdaInput.records.sns.message
    if ((Test-Json $LambdaInput -ErrorAction SilentlyContinue) -or (Test-Json $LambdaInput.records.sns.message -ErrorAction SilentlyContinue)) {
        write-host "LambdaInput is JSON, converting to object"
        $LambdaInput = $LambdaInput.records.sns.message | ConvertFrom-Json
        write-host $LambdaInput.text
    }
    else {
        write-host "LambdaInput not JSON, not converting"
        $LambdaInput = $LambdaInput.records.sns.message
    }
}
else {
    $LambdaInput = New-Object -TypeName PSObject -Property @{
        text = '1'
        channel_name = 'jefftest'
    }
}

write-host "Preprocess - LambdaInput is $LambdaInput"
write-host "Getting contract info for team $($LambdaInput.text)"

$teamobj = Get-Team -Team $LambdaInput.text
if (!$teamobj) {
    Send-SimpleSlackMessage -Text "Team *$($LambdaInput.text)* not found in league" -Channel $LambdaInput.channel_name
    return "Team $($LambdaInput.text) not found in league"
}

$contracts = Get-Contracts -team $teamobj.id
if (!$contracts) { 
    Send-SimpleSlackMessage -Text "Error retrieving data from CBS API" -Channel $LambdaInput.channel_name
    return "Error retrieving data from CBS API"
}
write-host "got api results"

$SlackMessage = ""
$SlackMessage += "*$($teamobj.name)* - Contract Info\n"
$CapNumber = 0
foreach($contract in $contracts) {
    $SlackMessage += "*$($contract.fullname)* - $($contract.wildcards.contract) $($contract.wildcards.salary)\n"
    $CapNumber += $contract.wildcards.salary
}
$CapSpace = $env:salarycap - $CapNumber
$SlackMessage += "*Salary Cap:* $CapNumber/$env:salarycap - *Cap Space:* $CapSpace"

write-host "finished building message"
write-host "Sending to channel $($LambdaInput.channel_name)"

$body = New-Object -TypeName psobject -Property @{
    type = 'mrkdwn'
    text = $SlackMessage
    channel = $LambdaInput.channel_name
}

write-host "body created"
$body = $body | ConvertTo-JSON | ForEach-Object{[regex]::Unescape($_)}

write-host "body jsoned"

$msg = Send-SlackMessage -body $body
$msg

write-host "message sent to slack"

# Uncomment to send the input event to CloudWatch Logs
# Write-Host (ConvertTo-Json -InputObject $LambdaInput -Compress -Depth 5)

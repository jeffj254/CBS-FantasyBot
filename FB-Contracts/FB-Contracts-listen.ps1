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

#Requires -Modules @{ModuleName='AWS.Tools.Common';ModuleVersion='4.0.4.0'},@{ModuleName='AWS.Tools.SimpleNotificationService';ModuleVersion='4.0.4.0'}

if ($LambdaInput) {
    write-host "LambdaInput found"
    write-host $LambdaInput
    write-host $LambdaInput.text
    if (Test-Json $LambdaInput -ErrorAction SilentlyContinue) {
        $LambdaInput = $LambdaInput | ConvertFrom-Json
        write-host $LambdaInput.text
    }
    else {
    }
}
else {
    $LambdaInput = New-Object -TypeName PSObject -Property @{
        text = '1'
        channel_name = 'jefftest'
    }
}

$LambdaInput | Add-Member -NotePropertyName 'default' -NotePropertyValue 'Slack slash command'

$JSONInput = $LambdaInput | ConvertTo-JSON
Publish-SNSMessage -TopicArn 'arn:aws:sns:us-west-2:405304447125:RosterTest' -Message $JSONInput -MessageStructure 'JSON'

# Uncomment to send the input event to CloudWatch Logs
Write-Host (ConvertTo-Json -InputObject $LambdaInput -Compress -Depth 5)

return "Querying CBS API..."

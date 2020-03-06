[cmdletbinding()]
Param()

function Invoke-CBSApi {
    Param(
        [Parameter(Mandatory=$true)][string]$queryendpoint,
        [string]$queryparams
    )
    write-host "$Env:cbsurl/$queryendpoint`?version=$Env:apiversion&league_id=$Env:leagueid&response_format=$Env:responseformat&access_token=$Env:cbstoken&$queryparams"
    $response = invoke-webrequest "$Env:cbsurl/$queryendpoint`?version=$Env:apiversion&league_id=$Env:leagueid&response_format=$Env:responseformat&access_token=$Env:cbstoken&$queryparams"
    $obj = $response.content | ConvertFrom-Json
    return $obj
}

function Send-SlackMessage {
    Param(
        [Parameter(Mandatory=$true)][string]$Body

    )
    $msgrequest = invoke-webrequest -Method POST -body $body $env:slackhookurl
    return $msgrequest.rawcontent
}

function Send-SimpleSlackMessage {
    Param(
        [Parameter(Mandatory=$true)][string]$Text,
        [Parameter(Mandatory=$true)][string]$Channel
    )
    $body = New-Object -TypeName psobject -Property @{
        type = 'mrkdwn'
        text = $Text
        channel = $Channel
    }
    $body = $body | ConvertTo-JSON | ForEach-Object{[regex]::Unescape($_)}
    $msgrequest = invoke-webrequest -Method POST -body $body $env:slackhookurl
    return $msgrequest.rawcontent
}

function Get-TeamID {
    Param(
        [Parameter(Mandatory=$true)][string]$Team
    )

    if($Team -match "^[\d\.]+$") { 
        $theteam = Get-TeamInfo | Where-Object { $_.id -eq $Team }
    }
    else {
        $theteam = Get-Teaminfo | Where-Object { $_.name -eq $Team }
    }
    if ($theteam) { return $theteam.id }
    else { return }
}

function Get-Team {
    Param(
        [Parameter(Mandatory=$true)][string]$Team
    )

    if($Team -match "^[\d\.]+$") { 
        $theteam = Get-TeamInfo | Where-Object { $_.id -eq $Team }
    }
    else {
        $theteam = Get-Teaminfo | Where-Object { $_.name -eq $Team }
    }
    if ($theteam) { return $theteam }
    else { return }
}

function Get-Roster {
    Param(
        [Parameter(Mandatory=$true)][string]$Team
    )
    $response = Invoke-CBSApi -queryendpoint 'rosters' -queryparams "team_id=$team"
    $rosters = $response.body.rosters
    return $rosters
}

function Get-Stats {
    Param(
        [int]$year = '2019',
        [Parameter(Mandatory=$true)][string]$team
    )
    $response = Invoke-CBSApi -queryendpoint 'stats' -queryparams "timeframe=$year&team_id=$team"
    $stats = $response.body.league_stats.players
    return $stats
}

function Get-Teaminfo {
    Param(
    )
    $response = Invoke-CBSApi -queryendpoint 'teams'
    $teams = $response.body.teams
    return $teams
}

function Get-Contracts {
    Param(
        [Parameter(Mandatory=$true)][string]$Team
    )
    $roster = Get-Roster -Team $Team
    $contracts = $roster.teams.players | Select-Object fullname, wildcards
    return $contracts
}

function Get-SalaryCap {
    Param(
        [string]$Team
    )
    $contracts = Get-Contracts -Team $Team
    $salary = 0
    foreach($contract in $contracts) {
        $salary += $contract.wildcards.salary
    }
    return $salary
}

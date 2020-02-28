Param(
    [string]$token = 'U2FsdGVkX18_eSlN4QQM_RYxTZvWFi1mWni7uRjk_DlHThypspLtp0t0HddVCRIXkiXB1FF6kD_lzfdzFbRfrhmIBcoIMhYmJm4tb3m68BJcfiPq83Ysz5-tg8ttn7jyEwgP4oqPZ9e69H5SVxLdxQ',
    [string]$team
)

$leagueid = 'pstigers'
$sport = 'baseball'
$response_format = 'JSON'
$apiversion = '3.0'

if ($team) {
    $response = invoke-webrequest "http://api.cbssports.com/fantasy/league/rosters?version=$apiversion&league_id=$leagueid&response_format=$response_format&access_token=$token&team_id=$team"
}
else {
    $response = invoke-webrequest "http://api.cbssports.com/fantasy/league/rosters?version=$apiversion&league_id=$leagueid&response_format=$response_format&access_token=$token"
}

$obj = $response.content | convertfrom-JSON
$rosters = $obj.body.rosters

return $rosters


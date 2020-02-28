Param(
    [string]$token = 'U2FsdGVkX18_eSlN4QQM_RYxTZvWFi1mWni7uRjk_DlHThypspLtp0t0HddVCRIXkiXB1FF6kD_lzfdzFbRfrhmIBcoIMhYmJm4tb3m68BJcfiPq83Ysz5-tg8ttn7jyEwgP4oqPZ9e69H5SVxLdxQ'
)

$leagueid = 'pstigers'
$sport = 'baseball'
$response_format = 'JSON'
$apiversion = '3.0'

$response = invoke-webrequest "http://api.cbssports.com/fantasy/league/teams?version=$apiversion&league_id=$leagueid&response_format=$response_format&access_token=$token"

$obj = $response.content | convertfrom-JSON
$teams = $obj.body.teams

return $teams


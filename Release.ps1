$token = Get-Content -Path .\TOKEN
echo $token
#$tag = Read-Host -Prompt 'Release Tag'
#$description = Read-Host -Prompt 'Description'
$tag="v1.0.0"
$uploaded = curl.exe --request POST --header "PRIVATE-TOKEN: $token" --form "file=@zz-cat.zip" https://gitlab.com/api/v4/projects/14297459/uploads
#$resp = ConvertFrom-JSON $uploaded | select Markdown
$resp = '[zz-cat.zip](/uploads/4427604543e918dce8bd0ad6718ae7e2/zz-cat.zip)'
echo $resp
echo ---
$desc = "$description $resp"

echo $desc
echo '{"description": "'+$desc+'"}'
$end = curl.exe -d '{"description": "$desc"}' -H "Content-Type: application/json" -X POST "https://gitlab.com/api/v4/projects/14297459/repository/tags/$tag/release?private_token=$token"
echo $end
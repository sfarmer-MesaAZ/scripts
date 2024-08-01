$teams = Get-Process -Name 'Teams' -ErrorAction SilentlyContinue
if($teams){
Stop-Process -Name 'Teams'
Remove-Item $env:appdata'\Microsoft\Teams\blob_storage\*' -Recurse
Remove-Item $env:appdata'\Microsoft\Teams\Cache\*' -Recurse
Remove-Item $env:appdata'\Microsoft\Teams\databases\*' -Recurse
Remove-Item $env:appdata'\Microsoft\Teams\GPUCache\*' -Recurse
Remove-Item $env:appdata'\Microsoft\Teams\IndexedDB\*' -Recurse
Remove-Item $env:appdata'\Microsoft\Teams\Local Storage\*' -Recurse
Remove-Item $env:appdata'\Microsoft\Teams\tmp\*' -Recurse
Start-Process $env:localappdata'\Microsoft\Teams\Update.exe' -ArgumentList '--processStart "Teams.exe"'
}else{
Stop-Process -Name 'ms-teams'
Remove-Item $env:localappdata'\Packages\MSTeams_8wekyb3d8bbwe\*' -Recurse
Start-Process 'ms-teams.exe'
}

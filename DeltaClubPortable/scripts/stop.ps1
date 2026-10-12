$ErrorActionPreference = 'Continue'
$root = Split-Path -Parent $PSScriptRoot
$runtime = Join-Path $root 'runtime'
$pidFile = Join-Path $root 'data\processes.json'
$mysqlAdmin = Join-Path $runtime 'mysql\bin\mysqladmin.exe'
$redisCli = Join-Path $runtime 'redis\redis-cli.exe'

if (-not (Test-Path $pidFile)) {
    Write-Host 'No saved Delta process list was found.'
    exit 0
}

$processes = Get-Content $pidFile -Raw | ConvertFrom-Json
if (Test-Path $mysqlAdmin) { & $mysqlAdmin --host=127.0.0.1 --port=3306 --user=root shutdown 2>$null | Out-Null }
if (Test-Path $redisCli) { & $redisCli -h 127.0.0.1 -p 6379 shutdown 2>$null | Out-Null }
foreach ($name in @('web', 'backend', 'mysql', 'redis')) {
    $id = $processes.$name
    if ($id) { Stop-Process -Id ([int]$id) -Force -ErrorAction SilentlyContinue }
}
Remove-Item $pidFile -Force -ErrorAction SilentlyContinue
Write-Host 'Delta portable preview has stopped.'

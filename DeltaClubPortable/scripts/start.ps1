param([switch]$Lan)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
if (-not ('DeltaPortablePath' -as [type])) {
    Add-Type -TypeDefinition @'
using System.Runtime.InteropServices;
using System.Text;
public static class DeltaPortablePath {
    [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern uint GetShortPathName(string path, StringBuilder shortPath, uint bufferSize);
}
'@
}
$shortRoot = New-Object System.Text.StringBuilder 32768
[void][DeltaPortablePath]::GetShortPathName($root, $shortRoot, $shortRoot.Capacity)
if ($shortRoot.Length -gt 0) { $root = $shortRoot.ToString() }
$runtime = Join-Path $root 'runtime'
$null = New-Item -ItemType Directory -Force -Path (Join-Path $root 'logs'), (Join-Path $root 'data'), (Join-Path $root 'upload')
$mysqlRoot = Join-Path $runtime 'mysql'
$mysqlData = Join-Path $root 'data\mysql'
$mysql = Join-Path $mysqlRoot 'bin\mysql.exe'
$mysqlAdmin = Join-Path $mysqlRoot 'bin\mysqladmin.exe'
$mysqld = Join-Path $mysqlRoot 'bin\mysqld.exe'
$redisServer = Join-Path $runtime 'redis\redis-server.exe'
$redisCli = Join-Path $runtime 'redis\redis-cli.exe'
$java = Join-Path $runtime 'java\bin\java.exe'
$node = Join-Path $runtime 'node\node.exe'
$app = Join-Path $runtime 'delta-admin.jar'
$schema = Join-Path $root 'setup\delta_game.sql'
$accountSql = Join-Path $root 'setup\preview-admin.sql'
$pidFile = Join-Path $root 'data\processes.json'
$ports = @(3306, 6379, 8081, 3000, 5174)

function Test-PortInUse([int]$port) {
    $client = [System.Net.Sockets.TcpClient]::new()
    try { $client.Connect('127.0.0.1', $port); return $true }
    catch { return $false }
    finally { $client.Dispose() }
}

function Start-HiddenProcess([string]$filePath, [string]$arguments, [string]$workingDirectory, [string]$logName) {
    $log = Join-Path $root "logs\$logName.log"
    $err = Join-Path $root "logs\$logName-error.log"
    return Start-Process -FilePath $filePath -ArgumentList $arguments -WorkingDirectory $workingDirectory `
        -RedirectStandardOutput $log -RedirectStandardError $err -WindowStyle Hidden -PassThru
}

foreach ($port in $ports) {
    if (Test-PortInUse $port) { throw "Port $port is already in use. Close the other program and run START.bat again." }
}

foreach ($item in @($mysqld, $mysql, $redisServer, $redisCli, $java, $node, $app, $schema, $accountSql)) {
    if (-not (Test-Path $item)) { throw "Deployment file is missing: $item" }
}

$processes = @{}
if (-not (Test-Path (Join-Path $mysqlData 'ibdata1'))) {
    $initArgs = "--basedir=`"$mysqlRoot`" --datadir=`"$mysqlData`" --initialize-insecure --console"
    $init = Start-Process -FilePath $mysqld -ArgumentList $initArgs -WorkingDirectory $root `
        -RedirectStandardOutput (Join-Path $root 'logs\mysql-init.log') `
        -RedirectStandardError (Join-Path $root 'logs\mysql-init-error.log') -WindowStyle Hidden -PassThru -Wait
    if ($init.ExitCode -ne 0) { throw 'MySQL data initialization failed. Check logs\mysql-init-error.log.' }
}

$mysqlArgs = "--basedir=`"$mysqlRoot`" --datadir=`"$mysqlData`" --port=3306 --bind-address=127.0.0.1 --mysqlx=0 --console"
$processes.mysql = Start-HiddenProcess $mysqld $mysqlArgs $root 'mysql'
$redisArgs = '--port 6379 --bind 127.0.0.1 --protected-mode yes'
$processes.redis = Start-HiddenProcess $redisServer $redisArgs $root 'redis'
@{ mysql = $processes.mysql.Id; redis = $processes.redis.Id } |
    ConvertTo-Json | Set-Content -Path $pidFile -Encoding UTF8

$mysqlReady = $false
for ($i = 0; $i -lt 60; $i++) {
    & $mysqlAdmin --host=127.0.0.1 --port=3306 --user=root ping 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) { $mysqlReady = $true; break }
    Start-Sleep -Seconds 1
}
if (-not $mysqlReady) { throw 'MySQL did not start. Check logs\mysql-error.log.' }

if (-not (Test-Path (Join-Path $root 'data\schema-ready'))) {
    & $mysql --host=127.0.0.1 --port=3306 --user=root --execute="CREATE DATABASE IF NOT EXISTS delta_game CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
    if ($LASTEXITCODE -ne 0) { throw 'Could not create the Delta database.' }
    $oldEncoding = [Console]::OutputEncoding
    [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
    try {
        Get-Content -Raw -Encoding UTF8 $schema | & $mysql --host=127.0.0.1 --port=3306 --user=root --default-character-set=utf8mb4 delta_game
    } finally {
        [Console]::OutputEncoding = $oldEncoding
    }
    if ($LASTEXITCODE -ne 0) { throw 'Database import failed. Check logs and setup\delta_game.sql.' }
    Get-Content -Raw -Encoding UTF8 $accountSql | & $mysql --host=127.0.0.1 --port=3306 --user=root --default-character-set=utf8mb4 delta_game
    if ($LASTEXITCODE -ne 0) { throw 'Local preview administrator setup failed.' }
    Set-Content -Path (Join-Path $root 'data\schema-ready') -Value 'ready' -Encoding ASCII
}

$env:DB_PASSWORD = ''
$env:DB_USERNAME = 'root'
$env:AUTH_H5_LOGIN_CODE = '123456'
$env:JWT_SECRET = 'DeltaPortableLocalPreviewSecretKeyAtLeast256Bits000000000000'
$fileHost = 'localhost'
if ($Lan) {
    $route = Get-NetRoute -AddressFamily IPv4 -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue |
        Sort-Object RouteMetric | Select-Object -First 1
    $fileHost = Get-NetIPAddress -AddressFamily IPv4 -InterfaceIndex $route.InterfaceIndex -ErrorAction SilentlyContinue |
        Where-Object { $_.IPAddress -notlike '127.*' } | Select-Object -First 1 -ExpandProperty IPAddress
    if (-not $fileHost) { throw 'No active LAN IPv4 address was found.' }
}
$javaArgs = "-jar `"$app`" --spring.profiles.active=dev --server.address=127.0.0.1 --server.port=8081 --spring.datasource.url=jdbc:mysql://127.0.0.1:3306/delta_game?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai&useSSL=false&allowPublicKeyRetrieval=true --spring.data.redis.host=127.0.0.1 --spring.data.redis.port=6379 --file.upload.path=`"$root\upload`" --file.upload.url-prefix=http://${fileHost}:3000/file/"
$processes.backend = Start-HiddenProcess $java $javaArgs $root 'backend'
@{ mysql = $processes.mysql.Id; redis = $processes.redis.Id; backend = $processes.backend.Id } |
    ConvertTo-Json | Set-Content -Path $pidFile -Encoding UTF8

for ($i = 0; $i -lt 45 -and -not (Test-PortInUse 8081); $i++) { Start-Sleep -Seconds 1 }
if (-not (Test-PortInUse 8081)) { throw 'Delta backend did not start. Check logs\backend-error.log.' }

$env:DELTA_HOST = if ($Lan) { '0.0.0.0' } else { '127.0.0.1' }
$env:DELTA_H5_PORT = '5174'
$processes.web = Start-HiddenProcess $node ('"' + (Join-Path $root 'server.mjs') + '"') $root 'web'
@{ mysql = $processes.mysql.Id; redis = $processes.redis.Id; backend = $processes.backend.Id; web = $processes.web.Id } |
    ConvertTo-Json | Set-Content -Path $pidFile -Encoding UTF8

for ($i = 0; $i -lt 15 -and (-not (Test-PortInUse 3000) -or -not (Test-PortInUse 5174)); $i++) { Start-Sleep -Seconds 1 }
if (-not (Test-PortInUse 3000) -or -not (Test-PortInUse 5174)) { throw 'Web preview did not start. Check logs\web-error.log.' }

Write-Host ''
Write-Host 'Delta portable preview is ready.' -ForegroundColor Green
Write-Host 'Admin: http://localhost:3000/login'
Write-Host 'H5:    http://localhost:5174/'
Write-Host 'Login: preview / DeltaPreview2026!'
if ($Lan) {
    Write-Host "LAN admin: http://${fileHost}:3000/login"
    Write-Host "LAN H5:    http://${fileHost}:5174/"
}
Start-Process 'http://localhost:3000/login'
Start-Process 'http://localhost:5174/'

param([ValidateSet('Start','Stop','Status','Login','Backup')][string]$Action='Start')
$ErrorActionPreference='Stop'
$env:PYTHONDONTWRITEBYTECODE='1'
$env:PYTHONUTF8='1'
$app=Join-Path $PSScriptRoot 'freight-import-assistant-0.13.0-linux-amd64'
$state=Join-Path $PSScriptRoot 'review-data'
$project='freight-windows-review'
function Run-Python([string[]]$Arguments) {
    & $script:python @Arguments
    if ($LASTEXITCODE -ne 0) { throw "Operation failed (exit $LASTEXITCODE). Keep this window for diagnosis." }
}
function Get-EngineInfo {
    $saved=$ErrorActionPreference
    $ErrorActionPreference='Continue'
    try {
        $result= & docker info --format '{{.OSType}}/{{.Architecture}}' 2>$null
        if ($LASTEXITCODE -eq 0) { return $result }
        return 'unavailable'
    } finally { $ErrorActionPreference=$saved }
}
try {
    if ($Action -eq 'Login') {
        $login=Join-Path $state 'first-login.json'
        if (!(Test-Path -LiteralPath $login)) { throw 'Start the application first.' }
        Start-Process notepad.exe -ArgumentList ('"'+$login+'"')
        exit 0
    }
    $script:python=$null
    foreach ($candidate in @('python','python3','py')) {
        if (Get-Command $candidate -ErrorAction SilentlyContinue) {
            & $candidate -c 'import sys; sys.exit(0 if sys.version_info >= (3,11) else 1)' 2>$null
            if ($LASTEXITCODE -eq 0) { $script:python=$candidate; break }
        }
    }
    if (!$script:python) { throw 'Python 3.11+ is required. Install Python with Add python.exe to PATH enabled, then retry.' }
    if (!(Get-Command docker -ErrorAction SilentlyContinue)) { throw 'Install Docker Desktop, enable WSL2 Linux containers, then retry.' }
    if ($env:DOCKER_HOST -or $env:DOCKER_CONTEXT) { throw 'Use the local Docker Desktop context; remove DOCKER_HOST/DOCKER_CONTEXT overrides first.' }
    $context= & docker context show
    if ($context -notin @('desktop-linux','default')) { throw 'Select the local Docker Desktop Linux context first.' }
    if ($Action -eq 'Start') {
        Run-Python @((Join-Path $app 'scripts/verify_delivery.py'),$app)
        $desktop=Join-Path $env:LOCALAPPDATA 'Programs\DockerDesktop\Docker Desktop.exe'
        if (!(Test-Path $desktop)) { $desktop=Join-Path $env:ProgramFiles 'Docker\Docker\Docker Desktop.exe' }
        $info=Get-EngineInfo
        if ($info -eq 'unavailable' -and (Test-Path $desktop)) {
            Write-Host 'Starting Docker Desktop. Waiting up to 120 seconds...'
            Start-Process -FilePath $desktop -WindowStyle Hidden
            for ($i=0; $i -lt 40; $i++) {
                Start-Sleep -Seconds 3
                $info=Get-EngineInfo
                if ($info -ne 'unavailable') { break }
            }
        }
        if ($info -notmatch '^linux/(x86_64|amd64)$') { throw 'Docker Desktop Linux/amd64 engine is not ready. Start it and retry.' }
        & docker compose version
        if ($LASTEXITCODE -ne 0) { throw 'Docker Compose plugin is required.' }
        if (!(Test-Path (Join-Path $state '.env.production'))) {
            foreach ($port in @(28443,28080)) {
                $listener=New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Loopback,$port)
                try { $listener.Start() } finally { $listener.Stop() }
            }
        }
        Run-Python @((Join-Path $app 'scripts/bootstrap.py'),'--directory',$state,'--project',$project,'--origin','https://127.0.0.1:28443','--http-port','28080','--bind','127.0.0.1','--no-browser','--no-trust')
        Write-Host 'Trusting this installation CA in the CURRENT USER certificate store...'
        & certutil -user -addstore Root (Join-Path $state 'internal-root.crt')
        if ($LASTEXITCODE -ne 0) { throw 'Certificate trust installation failed. Do not bypass browser certificate checks.' }
        $response=Invoke-WebRequest -UseBasicParsing -Uri 'https://127.0.0.1:28443/api/ready' -TimeoutSec 20
        if ($response.StatusCode -ne 200) { throw 'Readiness verification failed.' }
        Start-Process 'https://127.0.0.1:28443/'
        Start-Process notepad.exe -ArgumentList ('"'+(Join-Path $state 'first-login.json')+'"')
        Write-Host 'Ready. Credentials are shown locally in Notepad. Stop using Stop.cmd.'
    } else {
        $operation=@{Stop='stop';Status='status';Backup='backup'}[$Action]
        Run-Python @((Join-Path $app 'scripts/deploy.py'),'--directory',$state,'--project',$project,$operation)
    }
} catch {
    Write-Host ('ERROR: '+$_.Exception.Message) -ForegroundColor Red
    exit 1
}

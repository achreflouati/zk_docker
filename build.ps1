# ── ZK HRMS — Build script (PowerShell Windows) ─────────────────────────────
# Lance ce script UNE SEULE FOIS pour builder l'image Docker.
# Ensuite tu peux la pousser sur Docker Hub pour ne jamais rebuilder.
#
# Usage: .\build.ps1
# Ou avec push Docker Hub: .\build.ps1 -Push -DockerHubUser "achreflouati"

param(
    [switch]$Push,
    [string]$DockerHubUser = "achreflouati",
    [string]$Tag = "v15"
)

$IMAGE_NAME = "$DockerHubUser/zk-hrms:$Tag"
$APPS_JSON_PATH = "$PSScriptRoot\apps.json"

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host " ZK HRMS — Building Docker image" -ForegroundColor Cyan
Write-Host " Image: $IMAGE_NAME" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

# Encode apps.json to base64
$APPS_JSON_BASE64 = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($APPS_JSON_PATH))

Write-Host "`n[1/2] Building image (15-20 min first time)..." -ForegroundColor Yellow

docker build `
    --build-arg="FRAPPE_PATH=https://github.com/frappe/frappe" `
    --build-arg="FRAPPE_BRANCH=version-15" `
    --build-arg="PYTHON_VERSION=3.11.9" `
    --build-arg="NODE_VERSION=18.20.2" `
    --build-arg="APPS_JSON_BASE64=$APPS_JSON_BASE64" `
    --tag="$IMAGE_NAME" `
    --file="images/layered/Containerfile" `
    "https://github.com/frappe/frappe_docker.git#main"

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n❌ Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "`n✅ Image built: $IMAGE_NAME" -ForegroundColor Green

# Tag aussi comme "latest" localement
docker tag $IMAGE_NAME "${DockerHubUser}/zk-hrms:latest"

if ($Push) {
    Write-Host "`n[2/2] Pushing to Docker Hub..." -ForegroundColor Yellow
    docker login
    docker push $IMAGE_NAME
    docker push "${DockerHubUser}/zk-hrms:latest"
    Write-Host "`n✅ Pushed to Docker Hub!" -ForegroundColor Green
    Write-Host "   Prochaine fois: docker pull $IMAGE_NAME" -ForegroundColor Gray
} else {
    Write-Host "`n[2/2] Pour pousser sur Docker Hub (optionnel):" -ForegroundColor Gray
    Write-Host "   .\build.ps1 -Push" -ForegroundColor Gray
}

Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host " Maintenant lance: docker compose up -d" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

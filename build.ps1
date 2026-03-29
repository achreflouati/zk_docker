param(
    [switch]$Push,
    [string]$DockerHubUser = "achreflouati",
    [string]$Tag = "v15"
)

$IMAGE = "$DockerHubUser/zk-hrms:$Tag"

Write-Host "Building image: $IMAGE" -ForegroundColor Cyan
Write-Host "Using local Dockerfile (more reliable than frappe_docker builder)" -ForegroundColor Gray

& docker build --tag $IMAGE --file "$PSScriptRoot\Dockerfile" "$PSScriptRoot"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

docker tag $IMAGE "$DockerHubUser/zk-hrms:latest"
Write-Host "Image built: $IMAGE" -ForegroundColor Green

if ($Push) {
    Write-Host "Pushing to Docker Hub..." -ForegroundColor Yellow
    docker login
    docker push $IMAGE
    docker push "$DockerHubUser/zk-hrms:latest"
    Write-Host "Pushed to Docker Hub!" -ForegroundColor Green
}

Write-Host "Done. Now run: docker compose up -d" -ForegroundColor Green

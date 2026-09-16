Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "SMART CAMPUS ISSUE MANAGER - API TEST" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 1. Health
Write-Host "`n1. Testing Health Endpoint..." -ForegroundColor Yellow
$health = Invoke-RestMethod -Uri "http://localhost:8081/api/v1/health" -Method Get
Write-Host "Status: $($health.status) | Service: $($health.service) | Version: $($health.version)" -ForegroundColor Green

# 2. Login
Write-Host "`n2. Testing Student Login (/api/v1/auth/login)..." -ForegroundColor Yellow
$loginPayload = @{
    email = "student@smartcampus.edu"
    password = "Password@123"
} | ConvertTo-Json

$auth = Invoke-RestMethod -Uri "http://localhost:8081/api/v1/auth/login" -Method Post -ContentType "application/json" -Body $loginPayload
Write-Host "Login Successful!" -ForegroundColor Green
Write-Host "User: $($auth.user.displayName) ($($auth.user.email))" -ForegroundColor Green
Write-Host "Role: $($auth.user.role)" -ForegroundColor Green
Write-Host "Token Type: $($auth.tokenType)" -ForegroundColor Green

# 3. Profile
Write-Host "`n3. Testing Protected Profile (/api/v1/users/me)..." -ForegroundColor Yellow
$headers = @{
    Authorization = "Bearer $($auth.accessToken)"
}
$profile = Invoke-RestMethod -Uri "http://localhost:8081/api/v1/users/me" -Method Get -Headers $headers
Write-Host "Profile Retrieved Successfully!" -ForegroundColor Green
Write-Host "Display Name: $($profile.displayName)" -ForegroundColor Green
Write-Host "Organization: $($profile.organizationName)" -ForegroundColor Green

Write-Host "`n4. Swagger UI: http://localhost:8081/swagger-ui.html" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

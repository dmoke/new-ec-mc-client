param(
    [string]$NewVersion = "",
    [switch]$AutoCommit = $false,
    [switch]$AutoTag = $false
)

Write-Host "Engineering Club MC Launcher - Build Script" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

# Build the executable
Write-Host "Building executable with PyInstaller..." -ForegroundColor Yellow
& pyinstaller launcher.spec

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build successful! Replacing launcher in root folder..." -ForegroundColor Green

    # Copy the built executable
    Copy-Item -Path "dist\launcher.exe" -Destination "launcher.exe" -Force
    Write-Host "Launcher replaced successfully!" -ForegroundColor Green

    # Update version if specified
    if ($NewVersion) {
        Write-Host "Updating version to $NewVersion..." -ForegroundColor Yellow
        $versionData = Get-Content "assets/version.json" | ConvertFrom-Json
        $versionData.version = $NewVersion
        $versionData | ConvertTo-Json | Set-Content "assets/version.json"
        Write-Host "Version updated to $NewVersion" -ForegroundColor Green
    }

    # Auto commit if requested
    if ($AutoCommit) {
        Write-Host "Committing changes..." -ForegroundColor Yellow
        & git add .
        $commitMessage = if ($NewVersion) { "Build launcher v$NewVersion" } else { "Update launcher build" }
        & git commit -m $commitMessage
        Write-Host "Changes committed!" -ForegroundColor Green
    }

    # Auto tag if requested
    if ($AutoTag -and $NewVersion) {
        Write-Host "Creating tag $NewVersion..." -ForegroundColor Yellow
        & git tag $NewVersion
        Write-Host "Tag $NewVersion created!" -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Test the new launcher.exe"
    if (-not $AutoCommit) {
        Write-Host "2. Commit changes: git add . && git commit -m 'Update launcher'"
    }
    if (-not $AutoTag -and $NewVersion) {
        Write-Host "3. Create tag: git tag $NewVersion"
    }
    Write-Host "4. Push to GitHub: git push origin master && git push origin $NewVersion"

} else {
    Write-Host "Build failed! Please check the errors above." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Build completed successfully!" -ForegroundColor Green

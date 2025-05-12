$gradleZipPath = "C:\Users\HARSHAD\.gradle\wrapper\dists\gradle-8.10.2-all\7iv73wktx1xtkvlq19urqw1wm\gradle-8.10.2-all.zip"
$gradleUrl = "https://services.gradle.org/distributions/gradle-8.10.2-all.zip"
$gradleDir = Split-Path -Parent $gradleZipPath

# Create directory if it doesn't exist
if (-not (Test-Path $gradleDir)) {
    New-Item -ItemType Directory -Path $gradleDir -Force
}

Write-Host "Downloading Gradle from $gradleUrl to $gradleZipPath"
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile($gradleUrl, $gradleZipPath)

if (Test-Path $gradleZipPath) {
    Write-Host "Successfully downloaded Gradle zip file"
} else {
    Write-Host "Failed to download Gradle zip file"
}

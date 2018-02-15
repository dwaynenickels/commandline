$projectName = "CommandLine"

if (!(Test-Path (".\" + $projectName + ".nuspec")))
{
    Write-Host "Nuspec file not found." -foregroundcolor "red"
    Write-Host ("Please run 'nuget spec " + $projectName + ".csproj' to generate nuspec file.") -foregroundcolor "yellow"
    Exit
}

[xml]$xml = Get-Content (".\" + $projectName + ".nuspec")

$version = $xml.package.metadata.version
$releaseNotes = $xml.package.metadata.releaseNotes
$id = $xml.package.metadata.id

Write-Host ("Current package version: " + $version) -foregroundcolor "green"
$newVersion = Read-Host "What is the new package version? "

if ([string]::IsNullOrEmpty($newVersion))
{
    $newVersion = $version
}

Write-Host ("Current package release notes: " + $releaseNotes) -foregroundcolor "green"
$newReleaseNotes = Read-Host "What are the new release notes? "

if ([string]::IsNullOrEmpty($newReleaseNotes))
{
    $newReleaseNotes = $releaseNotes
}

$xml.package.metadata.version = [string]$newVersion
$xml.package.metadata.releaseNotes = [string]$newReleaseNotes

$saveDir = Resolve-Path(".\" + $projectName + ".nuspec")
$xml.Save($saveDir)

Write-Host ("Nuspec file updated.") -foregroundcolor "green"
Write-Host ("Remember to check-in new version of nuspec file to source control.") -foregroundcolor "yellow"

Write-Host ("Building project in release mode") -foregroundcolor "green"
&"C:/Program Files (x86)/MSBuild/14.0/Bin/MSBuild.exe" $projectName.csproj /p:Configuration=Release

Write-Host ("Creating new NuGet package.") -foregroundcolor "green"
nuget pack $projectName.csproj -Prop Configuration=Release

$nuGetPkgName = ($projectName + "." + $newVersion + ".nupkg")

$nugetUrl = Read-Host "What is the NuGet server URL? "
$nugetKey = Read-Host "What is the NuGet server key? "

Write-Host ("Pushing new NuGet package to NuGet server") -foregroundcolor "green"
nuget push $nuGetPkgName -Source $nugetUrl $nugetKey


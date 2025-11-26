$_nugetUrl = "https://api.nuget.org/v3/index.json" 
$packageSources = Get-PackageSource
if(@($packageSources).Where{$_.location -eq $_nugetUrl}.count -eq 0) {
   Register-PackageSource -Name MyNuGet -Location $_nugetUrl -ProviderName NuGet
}
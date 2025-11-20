$bloat_apps = @(
    "Microsoft.ZuneMusic"
  , "Microsoft.Music.Preview"
  , "Microsoft.XboxIdentityProvider"
  , "Microsoft.BingTravel"
  , "Microsoft.BingHealthAndFitness"
  , "Microsoft.BingFoodAndDrink"
  , "Microsoft.People"
  , "Microsoft.BingFinance"
  , "Microsoft.3DBuilder"
  , "Microsoft.BingNews"
  , "Microsoft.BingSports"
  , "Microsoft.Getstarted"
  , "Microsoft.MicrosoftSolitaireCollection"
  , "Microsoft.MicrosoftOfficeHub"
  , "Microsoft.BingWeather"
  , "Microsoft.GetHelp"
  , "Microsoft.Messaging"
  , "Microsoft.News"
  , "Microsoft.Office.Lens"
  , "Microsoft.Office.Sway"
  , "Microsoft.OneConnect"
  , "Microsoft.Print3D"
  , "Microsoft.SkypeApp"
  , "*EclipseManager*"
  , "*ActiproSoftwareLLC*"
  , "*AdobeSystemsIncorporated.AdobePhotoshopExpress*"
  , "*Duolingo-LearnLanguagesforFree*"
  , "*PandoraMediaInc*"
  , "*CandyCrush*"
  , "*BubbleWitch3Saga*"
  , "*Wunderlist*"
  , "*Flipboard*"
  , "*Twitter*"
  , "*Facebook*"
  , "*Minecraft*"
  , "*Royal Revolt*"
  , "*Sway*"
  , "*McAfee*"
  , "*Dropbox*"
)

ipmo Appx -UseWindowsPowershell
foreach ($bloat_app in $bloat_apps) {
    if ($bloat_app) {
        Write-Host "Removing $bloat_app..."
        $pkg = Get-AppxPackage -name $bloat_app
        if ($pkg) {
            $pkg | Remove-AppxPackage
        }
    }
}
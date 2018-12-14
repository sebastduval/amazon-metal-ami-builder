$ErrorActionPreference = "Stop"
Function Remove-StoreApp{
    $apps = @(
        "Microsoft.3DBuilder",
        "Microsoft.Appconnector",
        "Microsoft.BingFinance",
        "Microsoft.BingNews",
        "Microsoft.BingSports",
        "Microsoft.BingWeather",
        "Microsoft.FreshPaint",
        "Microsoft.Getstarted",
        "Microsoft.MicrosoftOfficeHub",
        "Microsoft.MicrosoftSolitaireCollection",
        "Microsoft.MicrosoftStickyNotes",
        "Microsoft.Office.OneNote",
        "Microsoft.OneConnect",
        "Microsoft.People",
        "Microsoft.SkypeApp",
        "Microsoft.Windows.Photos",
        "Microsoft.WindowsAlarms",
        "Microsoft.WindowsCalculator",
        "Microsoft.WindowsCamera",
        "Microsoft.WindowsMaps",
        "Microsoft.WindowsPhone",
        "Microsoft.WindowsSoundRecorder",
        "Microsoft.XboxApp",
        "Microsoft.ZuneMusic",
        "Microsoft.ZuneVideo",
        "Microsoft.WindowsCommunicationsApps",
        "Microsoft.MinecraftUWP",
        "Microsoft.MicrosoftPowerBIForWindows",
        "Microsoft.NetworkSpeedTest",
        "Microsoft.CommsPhone",
        "Microsoft.ConnectivityStore",
        "Microsoft.Messaging",
        "Microsoft.Office.Sway",
        "Microsoft.OneConnect",
        "Microsoft.WindowsFeedbackHub",
        "Microsoft.BingFoodAndDrink",
        "Microsoft.BingTravel",
        "Microsoft.BingHealthAndFitness",
        "Microsoft.WindowsReadingList",
        "Microsoft.MSPaint",
        "Microsoft.Microsoft3DViewer",
        "Microsoft.Print3D",
        "9E2F88E3.Twitter",
        "PandoraMediaInc.29680B314EFC2",
        "Flipboard.Flipboard",
        "ShazamEntertainmentLtd.Shazam",
        "king.com.CandyCrushSaga",
        "king.com.CandyCrushSodaSaga",
        "king.com.*",
        "ClearChannelRadioDigital.iHeartRadio",
        "4DF9E0F8.Netflix",
        "6Wunderkinder.Wunderlist",
        "Drawboard.DrawboardPDF",
        "2FE3CB00.PicsArt-PhotoStudio",
        "D52A8D61.FarmVille2CountryEscape",
        "TuneIn.TuneInRadio",
        "GAMELOFTSA.Asphalt8Airborne",
        "TheNewYorkTimes.NYTCrossword",
        "DB6EA5DB.CyberLinkMediaSuiteEssentials",
        "Facebook.Facebook",
        "flaregamesGmbH.RoyalRevolt2",
        "Playtika.CaesarsSlotsFreeCasino",
        "A278AB0D.MarchofEmpires",
        "KeeperSecurityInc.Keeper",
        "ThumbmunkeysLtd.PhototasticCollage",
        "XINGAG.XING",
        "89006A2E.AutodeskSketchBook",
        "D5EA27B7.Duolingo-LearnLanguagesforFree",
        "46928bounde.EclipseManager",
        "ActiproSoftwareLLC.562882FEEB491",
        "Fitbit.FitbitCoach",
        "Microsoft.BingWeather",
        "Netflix"
    )
    foreach ($app in $apps) {
        Write-Host $app
        Try{
            Get-AppxPackage -Name $app -AllUsers | %{Remove-AppxPackage -AllUsers $_}
        }
        Catch{
            Write-Host $_
        }
        Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $app } | Remove-AppxProvisionedPackage -Online
    }
}

Remove-StoreApp
Start-Sleep 5
Remove-StoreApp
Start-Sleep 5

#Remove OneDrive 
#&cmd.exe /c %SystemRoot%\SysWOW64\OneDriveSetup.exe /uninstall
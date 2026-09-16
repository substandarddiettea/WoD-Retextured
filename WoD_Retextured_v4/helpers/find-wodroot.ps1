$ErrorActionPreference = 'SilentlyContinue'

$steamRoots = @(
    (Get-ItemProperty -Path 'HKCU:\Software\Valve\Steam').SteamPath
    (Get-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam').InstallPath
    (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Valve\Steam').InstallPath
    [Environment]::GetEnvironmentVariable('ProgramFiles(x86)') + '\Steam'
    [Environment]::GetEnvironmentVariable('ProgramFiles') + '\Steam'
    'C:\Program Files (x86)\Steam'
    'C:\Program Files\Steam'
)

$libraryRoots = @()
foreach ($steamRoot in ($steamRoots | Where-Object { $_ } | Select-Object -Unique)) {
    if (Test-Path -LiteralPath $steamRoot) {
        $libraryRoots += $steamRoot
        $libraryFile = Join-Path $steamRoot 'steamapps\libraryfolders.vdf'
        if (Test-Path -LiteralPath $libraryFile) {
            $contents = Get-Content -Raw -LiteralPath $libraryFile
            foreach ($match in [regex]::Matches($contents, '"path"\s+"([^"]+)"')) {
                $libraryRoots += ($match.Groups[1].Value -replace '\\\\', '\')
            }
        }
    }
}

foreach ($libraryRoot in ($libraryRoots | Select-Object -Unique)) {
    $candidate = Join-Path $libraryRoot 'steamapps\common\War of Dots'
    if (Test-Path -LiteralPath (Join-Path $candidate 'game.exe')) {
        Write-Output $candidate
        exit 0
    }

    # use Steam's own manifest when the install folder has been renamed
    $manifestDirectory = Join-Path $libraryRoot 'steamapps'
    foreach ($manifest in (Get-ChildItem -LiteralPath $manifestDirectory -Filter 'appmanifest_*.acf' -File)) {
        $manifestText = Get-Content -Raw -LiteralPath $manifest.FullName
        if ($manifestText -match '"name"\s+"War of Dots"' -and $manifestText -match '"installdir"\s+"([^"]+)"') {
            $manifestCandidate = Join-Path $libraryRoot (Join-Path 'steamapps\common' $matches[1])
            if (Test-Path -LiteralPath (Join-Path $manifestCandidate 'game.exe')) {
                Write-Output $manifestCandidate
                exit 0
            }
        }
    }
}

exit 1

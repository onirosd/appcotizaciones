$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$flutter = Join-Path $projectRoot ".fvm\flutter_sdk\bin\flutter.bat"

if (!(Test-Path $flutter)) {
  Write-Error "No se encontro Flutter 3.10.5 en $flutter"
}

& $flutter --version
& $flutter pub get
& $flutter run --enable-software-rendering

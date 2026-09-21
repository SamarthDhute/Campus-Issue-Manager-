$env:TEMP = 'E:\temp'
$env:TMP = 'E:\temp'

Set-Location -Path 'frontend'
flutter run -d web-server --web-port=3000 --web-hostname=localhost

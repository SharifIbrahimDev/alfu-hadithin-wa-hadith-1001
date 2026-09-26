$paths = @(
    "C:\flutter\bin\flutter.bat",
    "C:\src\flutter\bin\flutter.bat",
    "C:\Users\USER\flutter\bin\flutter.bat",
    "C:\tools\flutter\bin\flutter.bat",
    "C:\Program Files\flutter\bin\flutter.bat",
    "C:\Program Files (x86)\flutter\bin\flutter.bat",
    "C:\Users\USER\AppData\Local\flutter\bin\flutter.bat",
    "C:\Users\USER\AppData\Roaming\flutter\bin\flutter.bat",
    "D:\flutter\bin\flutter.bat",
    "E:\flutter\bin\flutter.bat"
)

foreach ($p in $paths) {
    if (Test-Path $p) {
        Write-Host "FOUND FLUTTER AT: $p"
    }
}

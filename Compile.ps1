function Set-Vcvars {
    param (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Object]
        $Vcvars
    )

    
    if (!(Test-Path -Path $Vcvars -PathType Leaf)) {
        Write-Error "Invalid vcvars file. ""$Vcvars"""
        exit 1
    }
    

    #Push-Location $VcvarsDir
    Write-Host "Running cmd.exe /c ""$exe"" & SET"
    Write-Host
        
    cmd /c """$Vcvars"" & SET" | ForEach-Object {
        if ($_ -match "=") {
            $v = $_.split("="); 
            #Write-PrettyKeyValue "$($v[0])" "$($v[1])" Blue White
            Set-Item -Force -Path "Env:\$($v[0])" -value "$($v[1])"
        }
        else {
            Write-Host $_
        }
    }
    Write-Host

    
}

$icuURL = "https://github.com/unicode-org/icu/releases/download/release-72-1/icu4c-72_1-Win64-MSVC2019.zip"
$icuZipFile = "icu.zip"
$icuInternalZipFile = "icu-windows.zip"
$icuFolder = "ICU72_1"
$icuInternalFolder = "20221013.8_ICU4C_MSVC_x64_Release"

if(! (Test-Path -PathType Container -Path "$icuFolder"))
{
    New-Item -ItemType Directory -Force -Path "$icuFolder"
    Push-Location "$icuFolder" -StackName "MainFolder"
    Invoke-WebRequest -Uri $icuURL -OutFile "$icuZipFile" | Out-Null
    Expand-Archive -Path "$icuZipFile" -DestinationPath "$(Get-Location)"
    Remove-Item $icuZipFile -Force -ErrorAction Ignore
    Push-Location "$icuInternalFolder" -StackName "MainFolder"
    Expand-Archive -Path $icuInternalZipFile -DestinationPath "$(Get-Location)"
    Remove-Item $icuInternalZipFile -Force -ErrorAction Ignore
    Pop-Location -StackName "MainFolder" 
    Pop-Location -StackName "MainFolder" 
}

$include = "$icuFolder/$icuInternalFolder/include"
$libs = "$icuFolder/$icuInternalFolder/lib64"
$dlls = "$icuFolder/$icuInternalFolder/bin64/*.dll"

Set-Vcvars -Vcvars "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"


& cl.exe /Fe"$($PSScriptRoot)/dist/main.exe" /MT /EHsc /std:c++17 /utf-8 /I"$include" main.cpp /link /libpath:"$libs" icuin.lib icuio.lib icutu.lib icuuc.lib icudt.lib icutest.lib /DYNAMICBASE 

New-Item "dist" -Force -ItemType Directory
Copy-Item -Path $dlls -Destination "dist" -Force
Remove-Item "main.obj" -ErrorAction Ignore -Force
Remove-Item "main.exe" -ErrorAction Ignore -Force
 
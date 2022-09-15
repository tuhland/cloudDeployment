write-host "`n## SCRIPTING DEPENDENCIES INSTALLER ##`n"

### [COMMON] CONFIGURATION

# Node.js
$version = "16.17.0-x64"
$url = "https://nodejs.org/dist/latest-v16.x/node-v$version.msi"
$install_node = $TRUE

### [NODE.JS] VERSION CHECK

write-host "`n----------------------------"
write-host " Node.js Version check       "
write-host "----------------------------`n"

 if (Get-Command node -errorAction SilentlyContinue) {
     $current_version = (node -v)
 }
 
 if ($current_version) {
     write-host "Node.js $current_version already installed`n"
         $install_node = $FALSE
 }
 else
 {
    write-host "Node.js not yet installed`n"
 }

if ($install_node) {
    
    ### [NODE.JS] Download
    # warning : if a node.msi file is already present in the current folder, this script will simply use it
        
    write-host "`n----------------------------"
    write-host " Downloading Node.js MSI     "
    write-host "----------------------------`n"

    $filename = "node.msi"
    $node_msi = "$PSScriptRoot\$filename"

    
    $download_node = $TRUE

    if (Test-Path $node_msi) {
        $download_node = $FALSE
    }

    if ($download_node) {
        write-host "Downloading Node.js installer"
        write-host "URL : $url"
        $start_time = Get-Date
        $wc = New-Object System.Net.WebClient
        $wc.DownloadFile($url, $node_msi)
        write-Output "$filename downloaded"
        write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
    } else {
        write-host "Using the existing node.msi file"
    }

    ### [NODE.JS] Install

    write-host "`n----------------------------"
    write-host " Installing Node.js           "
    write-host "----------------------------`n"

    write-host "Installing $node_msi"

    $installLogFile = "installNodeJs.log"
    $installLogPath = "$PSScriptRoot\$installLogFile"
    
    #$installJob = Start-Job {msiexec /qn /l* installNodeJs.log /i $node_msi}
    
    #Wait-Job $installJob

    #Start-Process -FilePath "msiexec" - /qn /l* installNodeJs.log /i $node_msi" -Wait

    $params = @{
        "FilePath" = "$Env:SystemRoot\system32\msiexec.exe"
        "ArgumentList" = @(
        "/i"
        "$($node_msi)"
        "/qn"
        "/l*"
        "$($installLogFile)"
        )
        "Verb" = "runas"
        "PassThru" = $true
    }

    $installer = start-process @params
    $installer.WaitForExit()
    
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 
    
} else {
    write-host "Proceeding with the previously installed Nodejs version"
}

### [COMMON] Clean Up

write-host "`n----------------------------"
write-host " Cleaning up                  "
write-host "----------------------------`n"

if ($node_msi -and (Test-Path $node_msi)) {
    rm $node_msi
}

write-host "Done"
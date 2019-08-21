﻿# Init Script for PowerShell
# Created as part of cmder project

# !!! THIS FILE IS OVERWRITTEN WHEN CMDER IS UPDATED
# !!! Use "%CMDER_ROOT%\config\user_profile.ps1" to add your own startup commands

# Compatibility with PS major versions <= 2
if(!$PSScriptRoot) {
    $PSScriptRoot = Split-Path $Script:MyInvocation.MyCommand.Path
}

if ($ENV:CMDER_USER_CONFIG) {
    # write-host "CMDER IS ALSO USING INDIVIDUAL USER CONFIG FROM '$ENV:CMDER_USER_CONFIG'!"
}

# We do this for Powershell as Admin Sessions because CMDER_ROOT is not beng set.
if (! $ENV:CMDER_ROOT ) {
    if ( $ENV:ConEmuDir ) {
        $ENV:CMDER_ROOT = resolve-path( $ENV:ConEmuDir + "\..\.." )
    } else {
        $ENV:CMDER_ROOT = resolve-path( $PSScriptRoot + "\.." )
    }
}

# Remove trailing '\'
$ENV:CMDER_ROOT = (($ENV:CMDER_ROOT).trimend("\"))

# Do not load bundled psget if a module installer is already available
# -> recent PowerShell versions include PowerShellGet out of the box
$moduleInstallerAvailable = [bool](Get-Command -Name 'Install-Module' -ErrorAction SilentlyContinue)

# Add Cmder modules directory to the autoload path.
$CmderModulePath = Join-path $PSScriptRoot "psmodules/"

if(-not $moduleInstallerAvailable -and -not $env:PSModulePath.Contains($CmderModulePath) ){
    $env:PSModulePath = $env:PSModulePath.Insert(0, "$CmderModulePath;")
}

function Configure-Git($GIT_INSTALL_ROOT){
  $env:Path += $(";" + $GIT_INSTALL_ROOT + "\cmd")

  # Add "$GIT_INSTALL_ROOT\usr\bin" to the path if exists and not done already
  $GIT_INSTALL_ROOT_ESC=$GIT_INSTALL_ROOT.replace('\','\\')
  if ((test-path "$GIT_INSTALL_ROOT\usr\bin") -and -not ($env:path -match "$GIT_INSTALL_ROOT_ESC\\usr\\bin")) {
      $env:path = "$env:path;$GIT_INSTALL_ROOT\usr\bin"
  }
  
  # Add "$GIT_INSTALL_ROOT\mingw[32|64]\bin" to the path if exists and not done already
  if ((test-path "$GIT_INSTALL_ROOT\mingw32\bin") -and -not ($env:path -match "$GIT_INSTALL_ROOT_ESC\\mingw32\\bin")) {
      $env:path = "$env:path;$GIT_INSTALL_ROOT\mingw32\bin"
  } elseif ((test-path "$GIT_INSTALL_ROOT\mingw64\bin") -and -not ($env:path -match "$GIT_INSTALL_ROOT_ESC\\mingw64\\bin")) {
      $env:path = "$env:path;$GIT_INSTALL_ROOT\mingw64\bin"
  }
}

$gitLoaded = $false
function Import-Git($Loaded){
    if($Loaded) { return }
    $GitModule = Get-Module -Name Posh-Git -ListAvailable
    if($GitModule | select version | where version -le ([version]"0.6.1.20160330")){
        Import-Module Posh-Git > $null
    }
    if(-not ($GitModule) ) {
        Write-Warning "Missing git support, install posh-git with 'Install-Module posh-git' and restart cmder."
    }
    # Make sure we only run once by alawys returning true
    return $true
}

function checkGit($Path) {
    if (Test-Path -Path (Join-Path $Path '.git') ) {
        $gitLoaded = Import-Git $gitLoaded
        Write-VcsStatus
        return
    }
    $SplitPath = split-path $path
    if ($SplitPath) {
        checkGit($SplitPath)
    }
}

try {
    # Check if git is on PATH, i.e. Git already installed on system
    Get-command -Name "git" -ErrorAction Stop >$null
} catch {
    if (test-path "$env:CMDER_ROOT\vendor\git-for-windows") {
        Configure-Git "$env:CMDER_ROOT\vendor\git-for-windows"
    }
}

if ( Get-command -Name "vim" -ErrorAction silentlycontinue) {
    new-alias -name "vi" -value vim
}

if (Get-Module PSReadline -ErrorAction "SilentlyContinue") {
    Set-PSReadlineOption -ExtraPromptLineCount 1
}

# Enhance Path
$env:Path = "$Env:CMDER_ROOT\bin;$Env:CMDER_ROOT\vendor\bin;$env:Path;$Env:CMDER_ROOT"

# Drop *.ps1 files into "$ENV:CMDER_ROOT\config\profile.d"
# to source them at startup.
if (-not (test-path "$ENV:CMDER_ROOT\config\profile.d")) {
  mkdir "$ENV:CMDER_ROOT\config\profile.d"
}

pushd $ENV:CMDER_ROOT\config\profile.d
foreach ($x in Get-ChildItem *.psm1) {
  # write-host write-host Sourcing $x
  Import-Module $x
}

foreach ($x in Get-ChildItem *.ps1) {
  # write-host write-host Sourcing $x
  . $x
}
popd

# Drop *.ps1 files into "$ENV:CMDER_USER_CONFIG\config\profile.d"
# to source them at startup.  Requires using cmder.exe /C [cmder_user_root_path] argument
if ($ENV:CMDER_USER_CONFIG -ne "" -and (test-path "$ENV:CMDER_USER_CONFIG\profile.d")) {
    pushd $ENV:CMDER_USER_CONFIG\profile.d
    foreach ($x in Get-ChildItem *.psm1) {
      # write-host write-host Sourcing $x
      Import-Module $x
    }

    foreach ($x in Get-ChildItem *.ps1) {
      # write-host write-host Sourcing $x
      . $x
    }
    popd
}

# Renaming to "config\user_profile.ps1" to "user_profile.ps1" for consistency.
if (test-path "$env:CMDER_ROOT\config\user-profile.ps1") {
  rename-item  "$env:CMDER_ROOT\config\user-profile.ps1" user_profile.ps1
}

$CmderUserProfilePath = Join-Path $env:CMDER_ROOT "config\user_profile.ps1"
if (Test-Path $CmderUserProfilePath) {
    # Create this file and place your own command in there.
    . "$CmderUserProfilePath" # user_profile.ps1 is not a module DO NOT USE import-module
}

if ($ENV:CMDER_USER_CONFIG) {
    # Renaming to "$env:CMDER_USER_CONFIG\user-profile.ps1" to "user_profile.ps1" for consistency.
    if (test-path "$env:CMDER_USER_CONFIG\user-profile.ps1") {
      rename-item  "$env:CMDER_USER_CONFIG\user-profile.ps1" user_profile.ps1
    }

    $env:Path = "$Env:CMDER_USER_CONFIG\bin;$env:Path"

    $CmderUserProfilePath = Join-Path $ENV:CMDER_USER_CONFIG "user_profile.ps1"
    if (Test-Path $CmderUserProfilePath) {
      . "$CmderUserProfilePath" # user_profile.ps1 is not a module DO NOT USE import-module
    }
}

if (! (Test-Path $CmderUserProfilePath) ) {
    Write-Host -BackgroundColor Darkgreen -ForegroundColor White "First Run: Creating user startup file: $CmderUserProfilePath"
    Copy-Item "$env:CMDER_ROOT\vendor\user_profile.ps1.default" -Destination $CmderUserProfilePath
}

#
# Prompt Section
#   Users should modify their user_profile.ps1 as it will be safe from updates.
#

# Only set the prompt if it is currently set to the default
# This allows users to configure the prompt in their user_profile.ps1 or config\profile.d\*.ps1
if ( $(get-command prompt).Definition -match 'PS \$\(\$executionContext.SessionState.Path.CurrentLocation\)\$\(' -and `
  $(get-command prompt).Definition -match '\(\$nestedPromptLevel \+ 1\)\) ";') {
  # Pre assign the hooks so the first run of cmder gets a working prompt.
  [ScriptBlock]$PrePrompt = {}
  [ScriptBlock]$PostPrompt = {}
  [ScriptBlock]$CmderPrompt = {
      $Host.UI.RawUI.ForegroundColor = "White"
      Microsoft.PowerShell.Utility\Write-Host $pwd.ProviderPath -NoNewLine -ForegroundColor Green
      if (get-command git -erroraction silentlycontinue) {
          checkGit($pwd.ProviderPath)
      }
  }

  <#
  This scriptblock runs every time the prompt is returned.
  Explicitly use functions from MS namespace to protect from being overridden in the user session.
  Custom prompt functions are loaded in as constants to get the same behaviour
  #>
  [ScriptBlock]$Prompt = {
      $realLASTEXITCODE = $LASTEXITCODE
      $host.UI.RawUI.WindowTitle = Microsoft.PowerShell.Management\Split-Path $pwd.ProviderPath -Leaf
      PrePrompt | Microsoft.PowerShell.Utility\Write-Host -NoNewline
      CmderPrompt
      Microsoft.PowerShell.Utility\Write-Host "`nλ " -NoNewLine -ForegroundColor "DarkGray"
      PostPrompt | Microsoft.PowerShell.Utility\Write-Host -NoNewline
      $global:LASTEXITCODE = $realLASTEXITCODE
      return " "
  }


  # Once Created these code blocks cannot be overwritten
  # if (-not $(get-command PrePrompt).Options -match 'Constant') {Set-Item -Path function:\PrePrompt   -Value $PrePrompt   -Options Constant}
  # if (-not $(get-command CmderPrompt).Options -match 'Constant') {Set-Item -Path function:\CmderPrompt -Value $CmderPrompt -Options Constant}
  # if (-not $(get-command PostPrompt).Options -match 'Constant') {Set-Item -Path function:\PostPrompt  -Value $PostPrompt  -Options Constant}

  Set-Item -Path function:\PrePrompt   -Value $PrePrompt   -Options Constant
  Set-Item -Path function:\CmderPrompt -Value $CmderPrompt -Options Constant
  Set-Item -Path function:\PostPrompt  -Value $PostPrompt  -Options Constant

  # Functions can be made constant only at creation time
  # ReadOnly at least requires `-force` to be overwritten
  # if (!$(get-command Prompt).Options -match 'ReadOnly') {Set-Item -Path function:\prompt  -Value $Prompt  -Options ReadOnly}
  Set-Item -Path function:\prompt  -Value $Prompt  -Options ReadOnly
}

Import-Module posh-git
Import-Module oh-my-posh
Set-Theme Agnoster
Remove-Item alias:\curl
Remove-Item alias:\wget
